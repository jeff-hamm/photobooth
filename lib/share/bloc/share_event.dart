part of 'share_bloc.dart';

abstract class ShareEvent extends Equatable {
  const ShareEvent();

  @override
  List<Object> get props => [];
}

class ShareViewLoaded extends ShareEvent {
  const ShareViewLoaded();
}

abstract class ShareTapped extends ShareEvent {
  const ShareTapped();
}

class ShareOnTwitterTapped extends ShareTapped {
  const ShareOnTwitterTapped();
}

class ShareOnFacebookTapped extends ShareTapped {
  const ShareOnFacebookTapped();
}
class GenerateAiImageSucceeded extends ShareEvent {
  const GenerateAiImageSucceeded({required this.imageUrls, required this.aiPrompt});
  final String aiPrompt;
  final List<String> imageUrls;
}
class _ShareUploadSucceeded extends ShareEvent {
  const _ShareUploadSucceeded({required this.url});
  final String url;
}
class _AiImageUploadSucceeded extends ShareEvent {
  const _AiImageUploadSucceeded({required this.imageUrls});
  final List<String> imageUrls;
}

class _ShareCompositeSucceeded extends ShareEvent {
  const _ShareCompositeSucceeded({required this.bytes});
  final Uint8List bytes;
}

class _ShareCompositeFailed extends ShareEvent {
  const _ShareCompositeFailed();
}
