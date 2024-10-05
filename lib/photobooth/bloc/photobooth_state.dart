part of 'photobooth_bloc.dart';

const emptyAssetId = '';
const emptyImage = '';

class PhotoConstraint extends Equatable {
  const PhotoConstraint({this.width = 1, this.height = 1});

  final double width;
  final double height;

  @override
  List<Object> get props => [width, height];
}

class PhotoAssetSize extends Equatable {
  const PhotoAssetSize({this.width = 2, this.height = 2});

  final double width;
  final double height;

  @override
  List<Object?> get props => [width, height];
}

class PhotoAssetPosition extends Equatable {
  const PhotoAssetPosition({this.dx = 0, this.dy = 0});

  final double dx;
  final double dy;

  @override
  List<Object> get props => [dx, dy];
}

class PhotoAsset extends Equatable {
  const PhotoAsset({
    required this.id,
    required this.asset,
    this.angle = 0.0,
    this.constraint = const PhotoConstraint(),
    this.position = const PhotoAssetPosition(),
    this.size = const PhotoAssetSize(),
  });

  final String id;
  final Asset asset;
  final double angle;
  final PhotoConstraint constraint;
  final PhotoAssetPosition position;
  final PhotoAssetSize size;

  @override
  List<Object> get props => [id, asset.name, angle, constraint, position, size];

  PhotoAsset copyWith({
    Asset? asset,
    double? angle,
    PhotoConstraint? constraint,
    PhotoAssetPosition? position,
    PhotoAssetSize? size,
  }) {
    return PhotoAsset(
      id: id,
      asset: asset ?? this.asset,
      angle: angle ?? this.angle,
      constraint: constraint ?? this.constraint,
      position: position ?? this.position,
      size: size ?? this.size,
    );
  }
}

class PhotoboothState extends Equatable {
  PhotoboothState(
    this.isPrimaryClient, {
    this.characters = const <PhotoAsset>[],
    this.stickers = const <PhotoAsset>[],
    this.selectedAssetId = emptyAssetId,
    this.aspectRatio = PhotoboothAspectRatio.portrait,
    this.images = const [],
    this.mostRecentImage = ImagePath.empty,
    String? imageId,
    List<ImagePath>? aiImage,
    this.isInPhotoStream = false,
    this.generationQueue = 0,
    this.aiQueue = const [],
    this.generatingAiImage,
    this.aiGeneratingStatus = ShareStatus.initial,
    this.imageUploadStatus = ShareStatus.initial,
  })  : imageId = imageId ?? shortHash(UniqueKey()),
        aiImage = aiImage ?? [];
  int generationQueue;
  bool get isDashSelected => characters.containsAsset(named: 'dash');
  bool isSelected(String name) => stickers.containsAsset(named: name);

  bool get isAndroidSelected => characters.containsAsset(named: 'android');

  bool get isSparkySelected => characters.containsAsset(named: 'sparky');

  bool get isDinoSelected => characters.containsAsset(named: 'dino');

  bool get isAnyCharacterSelected => characters.isNotEmpty;

  List<PhotoAsset> get assets => characters + stickers;
  final ImagePath? generatingAiImage;
  final List<ImagePath> aiQueue;
  final bool isPrimaryClient;
  final double aspectRatio;
  final List<CameraImageBlob> images;
  final ImagePath mostRecentImage;
  final String imageId;
  final List<PhotoAsset> characters;
  final List<PhotoAsset> stickers;
  final String selectedAssetId;
  final List<ImagePath> aiImage;
  final bool isInPhotoStream;

  ImagePath get selectedImage => !mostRecentImage.isEmpty
      ? mostRecentImage
      : (images.isNotEmpty ? images[0].path : ImagePath.empty);

  @override
  List<Object?> get props => [
        aspectRatio,
        images,
        mostRecentImage,
        imageId,
        characters,
        stickers,
        selectedAssetId,
        aiImage,
        isInPhotoStream,
        generatingAiImage,
        aiGeneratingStatus,
        imageUploadStatus
      ];

  bool get isGeneratingAi => generatingAiImage?.isNotEmpty == true;
  final ShareStatus aiGeneratingStatus;

  final ShareStatus imageUploadStatus;
  PhotoboothState copyWith({
    double? aspectRatio,
    List<CameraImageBlob>? images,
    ImagePath? mostRecentImage,
    List<PhotoAsset>? characters,
    List<PhotoAsset>? stickers,
    String? selectedAssetId,
    bool? isPrimaryClient,
    String? imageId,
    List<ImagePath>? aiImage,
    bool? isCapturingPhotoSet,
    List<ImagePath>? aiQueue,
    ImagePath? generatingAiImage,
    ShareStatus? aiGeneratingStatus,
    ShareStatus? imageUploadStatus,

  }) {
    return PhotoboothState(
      isPrimaryClient ?? this.isPrimaryClient,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      mostRecentImage: mostRecentImage ?? this.mostRecentImage,
      images: images ?? this.images,
      imageId: imageId ?? this.imageId,
      characters: characters ?? this.characters,
      stickers: stickers ?? this.stickers,
      selectedAssetId: selectedAssetId ?? this.selectedAssetId,
      aiImage: aiImage ?? this.aiImage,
      isInPhotoStream: isCapturingPhotoSet ?? this.isInPhotoStream,
      aiQueue: aiQueue ?? this.aiQueue,
      generatingAiImage: generatingAiImage ?? this.generatingAiImage,
      aiGeneratingStatus: aiGeneratingStatus ?? this.aiGeneratingStatus,
      imageUploadStatus: imageUploadStatus ?? this.imageUploadStatus,
    );
  }
}

extension PhotoAssetsX on List<PhotoAsset> {
  bool containsAsset({required String named}) {
    return indexWhere((e) => e.asset.name == named) != -1;
  }
}
