import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:io_photobooth/common/models/ImagePath.dart';
import 'package:io_photobooth/common/utils/prompt.dart';
import 'package:path/path.dart' as p;
import 'dart:async';
import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:cross_file/cross_file.dart';
import 'package:equatable/equatable.dart';
import 'package:image_compositor/image_compositor.dart';
import 'package:io_photobooth/photobooth/photobooth.dart';
import '../../config.dart' as config;
import '../../common/photos_repository.dart';
import '../../common/camera_image_blob.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;
part 'share_event.dart';
part 'share_state.dart';

class ShareBloc extends Bloc<ShareEvent, ShareState> {
  ShareBloc({
    required PhotosRepository photosRepository,
    required this.imageId,
    CameraImageBlob? image,
    required this.assets,
    required this.aspectRatio,
    required this.shareText,
    String negativePrompt = config.AiNegativePrompt,
    bool isSharingEnabled = const bool.fromEnvironment('SHARING_ENABLED'),
  })  : _photosRepository = photosRepository,
        _isSharingEnabled = isSharingEnabled,
        _negativePrompt = negativePrompt,
        this.image =
            image ?? CameraImageBlob(data: imageId, width: 0, height: 0),
        super(const ShareState()) {
    on<ShareViewLoaded>(_onShareViewLoaded);
    on<ShareTapped>(_onShareTapped);
    on<GenerateAiTapped>(_onGenerateAiTapped);
    on<GenerateAiImageSucceeded>(_onGenerateAiImageSucceeded);
    on<_AiImageUploadSucceeded>(_onAiImageUploadSucceeded);
    on<_AiImageUploadFailed>(_onAiImageUploadFailed);
    on<_ShareUploadStarting>(_onShareUploadStarting);
    on<_ShareCompositeSucceeded>(_onShareCompositeSucceeded);
    on<_ShareUploadSucceeded>(_onShareUploadSucceeded);
    on<GenerateAiImageFailed>(
        (event, emit) => emit(state.copyWith(aiStatus: ShareStatus.failure)));
    on<_ShareCompositeFailed>(
      (event, emit) => emit(
        state.copyWith(
          compositeStatus: ShareStatus.failure,
        ),
      ),
    );
  }

  final PhotosRepository _photosRepository;
  final String imageId;
  final CameraImageBlob image;
  final List<PhotoAsset> assets;
  final double aspectRatio;
  final bool _isSharingEnabled;
  final String _negativePrompt;
  final String shareText;

  void _onShareViewLoaded(
    ShareViewLoaded event,
    Emitter<ShareState> emit,
  ) {
    emit(state.copyWith(compositeStatus: ShareStatus.loading));
    unawaited(
      _composite().then(
        (value) => add(_ShareCompositeSucceeded(bytes: value)),
        onError: (_) => add(const _ShareCompositeFailed()),
      ),
    );
  }

  Future<void> _onShareTapped(
    ShareTapped event,
    Emitter<ShareState> emit,
  ) async {
    if (!_isSharingEnabled) return;

    final shareUrl =
        event is ShareOnTwitterTapped ? ShareUrl.twitter : ShareUrl.facebook;

    emit(
      state.copyWith(
        uploadStatus: ShareStatus.initial,
        aiStatus: ShareStatus.initial,
        isDownloadRequested: false,
        isUploadRequested: true,
        shareUrl: shareUrl,
      ),
    );

    if (state.compositeStatus.isLoading) return;
    if (state.uploadStatus.isLoading) return;
    if (state.aiStatus.isLoading) return;
//    if (state.uploadStatus.isSuccess) return;
//    if (state.compositeStatus.isFailure) {
      emit(
        state.copyWith(
          compositeStatus: ShareStatus.loading,
          uploadStatus: ShareStatus.initial,
        aiStatus: ShareStatus.initial,
          isDownloadRequested: false,
          isUploadRequested: true,
          shareUrl: shareUrl,
        ),
      );

      unawaited(
        _composite().then(
          (value) => add(_ShareCompositeSucceeded(bytes: value)),
          onError: (_) => add(const _ShareCompositeFailed()),
        ),
      );
    // } else if (state.compositeStatus.isSuccess) {
    //   emit(
    //     state.copyWith(
    //       uploadStatus: ShareStatus.loading,
    //       isDownloadRequested: false,
    //       isUploadRequested: true,
    //       shareUrl: shareUrl,
    //     ),
    //   );
    //   try {
    //     add(_ShareUploadStarting(imageId: imageId, shareText: shareText, bytes: state.bytes!));
    //     final shareUrls = await _photosRepository.sharePhoto(
    //       imageId: imageId,
    //       fileName: _getPhotoFileName(imageId),
    //       data: state.bytes!,
    //       shareText: shareText,
    //     );
    //     emit(
    //       state.copyWith(
    //         uploadStatus: ShareStatus.success,
    //         isDownloadRequested: false,
    //         isUploadRequested: true,
    //         file: state.file,
    //         bytes: state.bytes,
    //         explicitShareUrl: shareUrls.explicitShareUrl,
    //         facebookShareUrl: shareUrls.facebookShareUrl,
    //         twitterShareUrl: shareUrls.twitterShareUrl,
    //         shareUrl: shareUrl,
    //       ),
    //     );
    //     add(_ShareUploadSucceeded(url: shareUrls.explicitShareUrl));

    //   } catch (_) {
    //     emit(
    //       state.copyWith(
    //         uploadStatus: ShareStatus.failure,
    //         isDownloadRequested: false,
    //         shareUrl: shareUrl,
    //       ),
    //     );
    //   }
//    }
  }

  Future<void> _onShareCompositeSucceeded(
    _ShareCompositeSucceeded event,
    Emitter<ShareState> emit,
  ) async {
    final file = XFile.fromData(
      event.bytes,
      mimeType: 'image/png',
      name: _getPhotoFileName(imageId),
    );
    final bytes = event.bytes;

    emit(
      state.copyWith(
        compositeStatus: ShareStatus.success,
        bytes: bytes,
        file: file,
      ),
    );

    if (state.isUploadRequested) {
      emit(
        state.copyWith(
          uploadStatus: ShareStatus.loading,
          bytes: bytes,
          file: file,
          isDownloadRequested: false,
          isUploadRequested: true,
        ),
      );

      try {
        add(_ShareUploadStarting(
            imageId: imageId,
            fileName: _getPhotoFileName(imageId),
            shareText: shareText,
            bytes: event.bytes!));
        final shareUrls = await _photosRepository.sharePhoto(
          imageId: imageId,
          fileName: _getPhotoFileName(imageId),
          data: event.bytes,
          shareText: shareText,
        );
        emit(
          state.copyWith(
            compositeStatus: ShareStatus.success,
            uploadStatus: ShareStatus.success,
            isDownloadRequested: false,
            isUploadRequested: true,
            bytes: bytes,
            file: file,
            explicitShareUrl: shareUrls.explicitShareUrl,
            facebookShareUrl: shareUrls.facebookShareUrl,
            twitterShareUrl: shareUrls.twitterShareUrl,
          ),
        );
        add(_ShareUploadSucceeded(url: shareUrls.explicitShareUrl));
      } catch (_) {
        emit(
          state.copyWith(
            compositeStatus: ShareStatus.success,
            uploadStatus: ShareStatus.failure,
            bytes: bytes,
            file: file,
            isDownloadRequested: false,
          ),
        );
      }
    }
  }
  Future<void> _onGenerateAiTapped(
      GenerateAiTapped event, Emitter<ShareState> emit) async {
    try {
      final aiPrompt = event.imageFile.aiPrompt ?? await getRandomPrompt();
      final aiUrls = await _photosRepository.generateAiPhoto(
        imageId: event.imageId ?? UniqueKey().toString(),
        imagePath: event.imageFile,
        data: event.bytes,
        prompt: aiPrompt,
        negative: _negativePrompt,
      );
      if (aiUrls.length == 0) {
        emit(
          state.copyWith(
            aiStatus: ShareStatus.failure,
          ),
        );
        return;
      }
      emit(
        state.copyWith(
          aiStatus: ShareStatus.success,
          aiImages: aiUrls,
          aiPrompt: aiPrompt,
        ),
      );
      add(GenerateAiImageSucceeded(
          imageUrls: aiUrls, aiPrompt: await getRandomPrompt()));
    } catch (e) {
      log('Error generating AI image: $e');
      add(const GenerateAiImageFailed());
      state.copyWith(
        aiStatus: ShareStatus.failure,
      );
    }
  }

  Future<void> _onShareUploadSucceeded(
      _ShareUploadSucceeded event, Emitter<ShareState> emit) async {}
  Future<void> _onShareUploadStarting(
      _ShareUploadStarting event, Emitter<ShareState> emit) async {
    if (!config.EnableAi) {
      return;
    }
    emit(
      state.copyWith(
          aiStatus: ShareStatus.loading, aiPrompt: await getRandomPrompt()),
    );
    try {
      add(GenerateAiTapped(ImagePath.parse(event.fileName),
          imageId: event.imageId, bytes: event.bytes));
      } catch (_) {
        emit(
          state.copyWith(
            aiStatus: ShareStatus.failure
          ),
        );
      }
  }

  FutureOr<void> _onAiImageUploadFailed(
      _AiImageUploadFailed event, Emitter<ShareState> emit) {}
  FutureOr<void> _onAiImageUploadSucceeded(_AiImageUploadSucceeded event, Emitter<ShareState> emit) { 
  }
  FutureOr<void> _onGenerateAiImageSucceeded(GenerateAiImageSucceeded event, Emitter<ShareState> emit) async {
    if (!config.AiUpload) {
      return;
    }
    try {
    List<String> imageUrls = [];
    for(final image in event.imageUrls) {
        final aiImageId = shortHash(UniqueKey()).toString();
        final fileName = aiImageId + image.fileExtension;
        final reference = this._photosRepository.getFileReference(fileName);
        imageUrls.add(
          this._photosRepository.getSharePhotoUrl(
            await this
            ._photosRepository
            .uploadPhoto(aiImageId, reference, await image.toBytes(), null)
          )
        );
    }
    add(_AiImageUploadSucceeded(imageUrls: imageUrls));
    } catch (e) {
      log('Error uploading AI image: $e');
      add(const _AiImageUploadFailed());
    }

  }


  Future<Uint8List> _composite() async {
    final composite = await _photosRepository.composite(
      aspectRatio: aspectRatio,
      data: image.data,
      width: image.width,
      height: image.height,
      layers: [
        ...assets.map(
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
  static String _getPhotoPath(String imageId) =>
      imageId.startsWith(RegExp(r'http[s]://'))
          ? imageId
          : _getPhotoFileName(imageId);
  static String _getPhotoFileName(String photoName) => '$photoName.png';

}
