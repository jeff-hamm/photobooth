import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_compositor/image_compositor.dart';
import 'package:io_photobooth/common/camera_image_blob.dart';
import 'package:io_photobooth/common/models/ImagePath.dart';
import 'package:io_photobooth/common/photos_repository.dart';
import 'package:io_photobooth/common/utils/prompt.dart';
import 'package:io_photobooth/common/widgets.dart';
import 'package:io_photobooth/main.dart';
import 'package:io_photobooth/share/share.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

import '../../config.dart' as config;

part 'photobooth_event.dart';
part 'photobooth_state.dart';

typedef UuidGetter = String Function();

const _debounceDuration = Duration(milliseconds: 16);

class PhotoboothBloc extends Bloc<PhotoboothEvent, PhotoboothState> {
  PhotoboothBloc(UuidGetter? uuid,
      {required this.photosRepository,
      bool isLockedClient = false,
      bool? isDebugClient})
      : this.uuid = uuid ?? const Uuid().v4,
        this.isDebugClient =
            isDebugClient == true || kDebugMode || config.IsDebug,
        super(PhotoboothState(isLockedClient)) {
    EventTransformer<E> debounce<E extends PhotoboothEvent>() =>
        (Stream<E> events, EventMapper<E> mapper) =>
            events.debounceTime(_debounceDuration).asyncExpand(mapper);

    on<PhotoCharacterDragged>(
      _onPhotoCharacterDragged,
      transformer: debounce(),
    );
    on<PhotoStickerDragged>(
      _onPhotoStickerDragged,
      transformer: debounce(),
    );
    on<PhotoSetCaptureStarted>(_onPhotoSetCaptureStarted);
    on<PhotoSetCaptureCompleted>(_onPhotoSetCaptureCompleted);
    on<PhotoCaptured>(_onPhotoCaptured);
    on<AiPhotoRequested>(_onAiPhotoRequested);
    on<GenerateAiPhotoBoothSucceeded>(_onAiPhotoGenerated);
    on<PhotoCharacterToggled>(_onPhotoCharacterToggled);
    on<PhotoStickerTapped>(_onPhotoStickerTapped);
    on<PhotoClearStickersTapped>(_onPhotoClearStickersTapped);
    on<PhotoClearAllTapped>(_onPhotoClearAllTapped);
    on<PhotoDeleteSelectedStickerTapped>(_onPhotoDeleteSelectedStickerTapped);
    on<PhotoTapped>(_onPhotoTapped);
    on<PhotoSelectToggled>(_onPhotoSelected);
    on<OrientationChanged>(_onOrientationChanged);
    on<UploadImages>(_onUploadImages);
  }
  final PhotosRepository photosRepository;
  final UuidGetter uuid;
  void _onOrientationChanged(
      OrientationChanged event, Emitter<PhotoboothState> emit) {
    emit(
      state.copyWith(
        aspectRatio: event.orientation == Orientation.landscape
            ? PhotoboothAspectRatio.landscape
            : PhotoboothAspectRatio.portrait,
      ),
    );
  }

  void _onAiPhotoGenerated(
      GenerateAiPhotoBoothSucceeded event, Emitter<PhotoboothState> emit) {
    if (event.imageUrls.isEmpty) {
      return;
    }
    emit(
      state.copyWith(aiImage: [event.imageUrls.first]),
    );
  }

  void _onPhotoSetCaptureStarted(
      PhotoSetCaptureStarted event, Emitter<PhotoboothState> emit) {
    emit(state.copyWith(isCapturingPhotoSet: true));
  }

  void _onPhotoSetCaptureCompleted(
      PhotoSetCaptureCompleted event, Emitter<PhotoboothState> emit) {
    emit(state.copyWith(isCapturingPhotoSet: false));
  }

  bool isGeneratingAi = false;

  final bool isDebugClient;
  FutureOr<void> _onAiPhotoRequested(
      AiPhotoRequested event, Emitter<PhotoboothState> emit) async {
    if (isGeneratingAi) {
      return;
    }

    isGeneratingAi = true;
    try {
      final toGenerate = state.aiQueue
          .where((e) => e.imageId == event.image.imageId)
          .firstOrNull;
      if (toGenerate == null) {
        return;
      }
      state.aiQueue.removeAt(0);

      emit(
        state.copyWith(
            generatingAiImage: toGenerate,
            aiQueue: state.aiQueue,
            aiGeneratingStatus: ShareStatus.loading),
      );
      final aiUrls = await photosRepository.generateAiPhoto(
        imageId: event.image.imageId,
        imagePath: event.image,
//      data:  event.,
        prompt: await getRandomPrompt(),
        negative: config.AiNegativePrompt,
      );
      emit(
        state.copyWith(
            //images: state.images,
            aiImage: state.aiImage + aiUrls,
            generatingAiImage: aiUrls.first,
            aiGeneratingStatus: ShareStatus.success),
      );
    } catch (e) {
      errorHandler.onError('Error generating AI image: $e');
      emit(state.copyWith(
        aiGeneratingStatus: ShareStatus.failure,
      ));
      // add(const GenerateAiImageFailed());
      // state.copyWith(
      //   aiStatus: ShareStatus.failure,
      // );
    } finally {
      isGeneratingAi = false;
      if ((config.NumAiImages != null &&
              state.aiImage.length < config.NumAiImages!) ||
          state.aiImage.length < state.images.length) {
        add(AiPhotoRequested(state.aiQueue.first));
      }
    }
  }

  void _onPhotoCaptured(PhotoCaptured event, Emitter<PhotoboothState> emit) {
    emit(
      state.copyWith(
        aspectRatio: event.aspectRatio,
        images: state.images + [event.image],
        aiQueue: state.aiQueue + [event.image.path],
//        mostRecentImage: event.image,
        imageId: shortHash(UniqueKey()),
        selectedAssetId: emptyAssetId,
      ),
    );
    add(AiPhotoRequested(event.image.path));
  }

  void _onPhotoCharacterToggled(
    PhotoCharacterToggled event,
    Emitter<PhotoboothState> emit,
  ) {
    final asset = event.character;
    final characters = List.of(state.characters);
    final index = characters.indexWhere((c) => c.asset.name == asset.name);
    final characterExists = index != -1;

    if (characterExists) {
      characters.removeAt(index);
      return emit(
        state.copyWith(
          characters: characters,
        ),
      );
    }

    final newCharacter = PhotoAsset(id: uuid(), asset: asset);
    characters.add(newCharacter);
    emit(
      state.copyWith(
        characters: characters,
        selectedAssetId: newCharacter.id,
      ),
    );
  }

  void _onPhotoCharacterDragged(
    PhotoCharacterDragged event,
    Emitter<PhotoboothState> emit,
  ) {
    final asset = event.character;
    final characters = List.of(state.characters);
    final index = characters.indexWhere((element) => element.id == asset.id);
    final character = characters.removeAt(index);
    characters.add(
      character.copyWith(
        angle: event.update.angle,
        position: PhotoAssetPosition(
          dx: event.update.position.dx,
          dy: event.update.position.dy,
        ),
        size: PhotoAssetSize(
          width: event.update.size.width,
          height: event.update.size.height,
        ),
        constraint: PhotoConstraint(
          width: event.update.constraints.width,
          height: event.update.constraints.height,
        ),
      ),
    );
    emit(
      state.copyWith(
        characters: characters,
        selectedAssetId: asset.id,
      ),
    );
  }

  void _onPhotoStickerTapped(
    PhotoStickerTapped event,
    Emitter<PhotoboothState> emit,
  ) {
    final asset = event.sticker;
    final newSticker = PhotoAsset(id: uuid(), asset: asset);
    emit(
      state.copyWith(
        stickers: List.of(state.stickers)..add(newSticker),
        selectedAssetId: newSticker.id,
      ),
    );
  }

  void _onPhotoStickerDragged(
    PhotoStickerDragged event,
    Emitter<PhotoboothState> emit,
  ) {
    final asset = event.sticker;
    final stickers = List.of(state.stickers);
    final index = stickers.indexWhere((element) => element.id == asset.id);
    final sticker = stickers.removeAt(index);
    stickers.add(
      sticker.copyWith(
        angle: event.update.angle,
        position: PhotoAssetPosition(
          dx: event.update.position.dx,
          dy: event.update.position.dy,
        ),
        size: PhotoAssetSize(
          width: event.update.size.width,
          height: event.update.size.height,
        ),
        constraint: PhotoConstraint(
          width: event.update.constraints.width,
          height: event.update.constraints.height,
        ),
      ),
    );
    emit(
      state.copyWith(
        stickers: stickers,
        selectedAssetId: asset.id,
      ),
    );
  }

  void _onPhotoClearStickersTapped(
    PhotoClearStickersTapped event,
    Emitter<PhotoboothState> emit,
  ) {
    emit(
      state.copyWith(
          characters: const <PhotoAsset>[],
          stickers: const <PhotoAsset>[],
          selectedAssetId: emptyAssetId,
          aiImage: [ImagePath.empty]),
    );
  }

  void _onPhotoClearAllTapped(
    PhotoClearAllTapped event,
    Emitter<PhotoboothState> emit,
  ) {
    emit(
      state.copyWith(
        aiGeneratingStatus: ShareStatus.initial,
        aiQueue: [],
        imageUploadStatus: ShareStatus.initial,
        isCapturingPhotoSet: false,
        imageId: UniqueKey().toString(),
        generatingAiImage: null,
        characters: const <PhotoAsset>[],
        stickers: const <PhotoAsset>[],
        selectedAssetId: emptyAssetId,
        images: <CameraImageBlob>[],
        aiImage: <ImagePath>[],
        mostRecentImage: ImagePath.empty,
      ),
    );
  }

  void _onPhotoDeleteSelectedStickerTapped(
    PhotoDeleteSelectedStickerTapped event,
    Emitter<PhotoboothState> emit,
  ) {
    final stickers = List.of(state.stickers);
    final index = stickers.indexWhere(
      (element) => element.id == state.selectedAssetId,
    );
    final stickerExists = index != -1;

    if (stickerExists) {
      stickers.removeAt(index);
    }

    emit(
      state.copyWith(
        stickers: stickers,
        selectedAssetId: emptyAssetId,
      ),
    );
  }

  void _onPhotoSelected(
      PhotoSelectToggled event, Emitter<PhotoboothState> emit) {
    emit(
      state.copyWith(
          mostRecentImage:
              state.images.firstWhere((e) => e.data == event.image)?.path ??
                  state.aiImage.firstWhere((e) => e.path == event.image)),
    );
  }

  void _onPhotoTapped(PhotoTapped event, Emitter<PhotoboothState> emit) {
    emit(
      state.copyWith(selectedAssetId: emptyAssetId),
    );
  }

  FutureOr<void> _onUploadImages(
      UploadImages event, Emitter<PhotoboothState> emit) async {
    emit(
      state.copyWith(imageUploadStatus: ShareStatus.loading),
    );
    try {
      for (final image in event.images) {
        final bytes = await _composite(image, PhotoboothAspectRatio.landscape);
        final file = XFile.fromData(
          bytes,
          mimeType: 'image/png',
          name: _getPhotoFileName(image.imageId),
        );

        final shareUrls = await photosRepository.sharePhoto(
          imageId: image.imageId,
          fileName: _getPhotoFileName(image.imageId),
          data: bytes,
          shareText: image.aiPrompt ?? '',
        );
      }
      emit(
        state.copyWith(imageUploadStatus: ShareStatus.success),
      );
    } catch (e) {
      errorHandler.onError('Error uploading image: ${e}');
      emit(
        state.copyWith(imageUploadStatus: ShareStatus.failure),
      );
    } finally {}
  }

  Future<Uint8List> _composite(ImagePath image, double aspectRatio) async {
    final composite = await photosRepository.composite(
      aspectRatio: aspectRatio,
      data: image,
      width: image.width!.toInt(),
      height: image.height!.toInt(),
      layers: [
        ...state.assets.map(
          (l) => CompositeLayer(
            angle: l.angle,
            assetPath: 'assets/${l.asset.path}',
            constraints: Vector2D(l.constraint.width, l.constraint.height),
            position: Vector2D(l.position.dx, l.position.dy),
            size: Vector2D(l.size.width, l.size.height),
          ),
        )
      ],
    );
    return Uint8List.fromList(composite);
  }

  String _getPhotoPath(String imageId) =>
      imageId.startsWith(RegExp(r'http[s]://'))
          ? imageId
          : _getPhotoFileName(imageId);
  String _getPhotoFileName(String photoName) => '$photoName.png';
}
