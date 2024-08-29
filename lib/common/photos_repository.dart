import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_compositor/image_compositor.dart';
import '../config.dart' as config;
/// {@template upload_photo_exception}
/// Exception thrown when upload photo operation failed.
///
/// It contains a [message] field which describes the error.
/// {@endtemplate}
class UploadPhotoException implements Exception {
  /// {@macro upload_photo_exception}
  const UploadPhotoException(this.message);

  /// Description of the failure
  final String message;

  @override
  String toString() => message;
}

/// {@template composite_photo_exception}
/// Exception thrown when composite photo operation failed.
///
/// It contains a [message] field which describes the error.
/// {@endtemplate}
class CompositePhotoException implements Exception {
  /// {@macro composite_photo_exception}
  const CompositePhotoException(this.message);

  /// Description of the failure
  final String message;

  @override
  String toString() => message;
}

/// {@template share_urls}
/// A list of social share urls which are returned by the `sharePhoto` API.
/// {@endtemplate}
class ShareUrls {
  /// {@macro share_urls}
  const ShareUrls({
    required this.explicitShareUrl,
    required this.facebookShareUrl,
    required this.twitterShareUrl,
  });

  /// The share url for explicit sharing.
  final String explicitShareUrl;

  /// The share url for sharing on Facebook.
  final String facebookShareUrl;

  /// The share url for sharing on Twitter.
  final String twitterShareUrl;
}

class FirebasePhotosRepository extends PhotosRepository<Reference> {
  FirebasePhotosRepository({
    required FirebaseStorage firebaseStorage,
    super.imageCompositor,
  })  : _firebaseStorage = firebaseStorage;
  final FirebaseStorage _firebaseStorage;
  Reference getFileReference(String fileName) {
        try {
        return _firebaseStorage.ref('uploads/$fileName');
        } catch (e, st) {
      throw UploadPhotoException(
        'Uploading photo $fileName failed. '
        "Couldn't get storage reference 'uploads/$fileName'.\n"
        'Error: $e. StackTrace: $st',
      );
    }

  }
  
  Future<bool> photoExists(Reference reference) async {
    try {
      await reference.getDownloadURL();
      return true;
    } catch (_) {
      return false;
    }
  }
  
  Future<Reference> uploadPhoto(Reference reference, Uint8List data) async {
    try {
      return (await reference.putData(data)).ref;
    } catch (e, st) {
      throw UploadPhotoException(
        'Uploading photo failed. '
        'Error: $e. StackTrace: $st',
      );
    }
  }
    String getSharePhotoUrl(Reference ref) => '${config.ShareUrl}/${ref.name}';

}

/// {@template photos_repository}
/// Repository that persists photos in a Firebase Storage.
/// {@endtemplate
abstract class PhotosRepository<TReference> {
  /// {@macro photos_repository}
  PhotosRepository({
    ImageCompositor? imageCompositor,
  })  : _imageCompositor = imageCompositor ?? ImageCompositor();

  final ImageCompositor _imageCompositor;
 
  TReference getFileReference(String fileName);
  /// Uploads photo to the [FirebaseStorage] if it doesn't already exist
  /// and returns [ShareUrls].
  Future<ShareUrls> sharePhoto({
    required String fileName,
    required Uint8List data,
    required String shareText,
  }) async {
    final reference = getFileReference(fileName);

    if (await photoExists(reference)) {
      return ShareUrls(
        explicitShareUrl: getSharePhotoUrl(reference),
        facebookShareUrl: _facebookShareUrl(reference, shareText),
        twitterShareUrl: _twitterShareUrl(reference, shareText),
      );
    }
    final r2 = await uploadPhoto(reference, data);

    return ShareUrls(
      explicitShareUrl: getSharePhotoUrl(r2),
      facebookShareUrl: _facebookShareUrl(r2, shareText),
      twitterShareUrl: _twitterShareUrl(r2, shareText),
    );
  }

  /// Given an image ([data]) with the provided [layers]
  /// it will return a ByteArray ([Uint8List]) which represents a
  /// composite of the original [data] and [layers] which is cropped for
  /// the provided [aspectRatio].
  Future<Uint8List> composite({
    required int width,
    required int height,
    required String data,
    required List<CompositeLayer> layers,
    required double aspectRatio,
  }) async {
    try {
      final image = await _imageCompositor.composite(
        data: data,
        width: width,
        height: height,
        layers: layers.map((l) => l.toJson()).toList(),
        aspectRatio: aspectRatio,
      );
      return Uint8List.fromList(image);
    } catch (error, stackTrace) {
      throw CompositePhotoException(
        'compositing photo failed. '
        'Error: $error. StackTrace: $stackTrace',
      );
    }
  }

  Future<bool> photoExists(TReference reference);

  Future<TReference> uploadPhoto(TReference reference, Uint8List data);
  String _twitterShareUrl(TReference ref, String shareText) {
    final encodedShareText = Uri.encodeComponent(shareText);
    return 'https://twitter.com/intent/tweet?url=${getSharePhotoUrl(ref)}&text=';
  }

  String _facebookShareUrl(TReference ref, String shareText) {
    final encodedShareText = Uri.encodeComponent(shareText);
    return 'https://www.facebook.com/sharer.php?u=${getSharePhotoUrl(ref)}&quote=';
  }

  String getSharePhotoUrl(TReference ref);
  }
