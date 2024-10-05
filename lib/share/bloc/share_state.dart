part of 'share_bloc.dart';

enum ShareStatus { initial, loading, success, failure }

enum ShareUrl { none, twitter, facebook }

extension ShareStatusX on ShareStatus {
  bool get isLoading => this == ShareStatus.loading;
  bool get isSuccess => this == ShareStatus.success;
  bool get isFailure => this == ShareStatus.failure;
}

class ShareState extends Equatable {
  const ShareState({
    this.compositeStatus = ShareStatus.initial,
    this.uploadStatus = ShareStatus.initial,
    this.file,
    this.bytes,
    this.explicitShareUrl = '',
    this.facebookShareUrl = '',
    this.twitterShareUrl = '',
    this.isDownloadRequested = false,
    this.isUploadRequested = true,
    this.shareUrl = ShareUrl.none,
    this.aiStatus = ShareStatus.initial,
    this.aiImages,
    this.aiPrompt = ''
  });

  final ShareStatus compositeStatus;
  final ShareStatus uploadStatus;
  final ShareStatus aiStatus;
  final List<ImagePath>? aiImages;
  final XFile? file;
  final Uint8List? bytes;
  final String explicitShareUrl;
  final String twitterShareUrl;
  final String facebookShareUrl;
  final bool isUploadRequested;
  final bool isDownloadRequested;
  final ShareUrl shareUrl;
  final String aiPrompt;

  @override
  List<Object?> get props => [
        compositeStatus,
        uploadStatus,
        file,
//        bytes,
        twitterShareUrl,
        facebookShareUrl,
        isUploadRequested,
        isDownloadRequested,
        shareUrl,
        aiStatus,
        aiImages
      ];

  ShareState copyWith({
    ShareStatus? compositeStatus,
    ShareStatus? uploadStatus,
    XFile? file,
    Uint8List? bytes,
    String? explicitShareUrl,
    String? twitterShareUrl,
    String? facebookShareUrl,
    bool? isUploadRequested,
    bool? isDownloadRequested,
    ShareUrl? shareUrl,
    ShareStatus? aiStatus,
    List<ImagePath>? aiImages,
    String? aiPrompt
  }) {
    return ShareState(
      compositeStatus: compositeStatus ?? this.compositeStatus,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      file: file ?? this.file,
      bytes: bytes ?? this.bytes,
      explicitShareUrl: explicitShareUrl ?? this.explicitShareUrl,
      twitterShareUrl: twitterShareUrl ?? this.twitterShareUrl,
      facebookShareUrl: facebookShareUrl ?? this.facebookShareUrl,
      isUploadRequested: isUploadRequested ?? this.isUploadRequested,
      isDownloadRequested: isDownloadRequested ?? this.isDownloadRequested,
      shareUrl: shareUrl ?? this.shareUrl,
      aiStatus: aiStatus ?? this.aiStatus,
      aiImages: aiImages ?? this.aiImages,
      aiPrompt: aiPrompt ?? this.aiPrompt
    );
  }
}
