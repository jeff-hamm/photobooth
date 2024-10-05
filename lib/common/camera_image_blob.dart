import 'package:io_photobooth/common/models/ImagePath.dart';

const CameraImageBlob emptyCameraImage =
    CameraImageBlob.fromPath(data: ImagePath.empty, width: 0, height: 0);

class CameraImageBlob {
  CameraImageBlob({
    required String data,
    required this.width,
    required this.height,
  }) : data = ImagePath.parse(data,
            width: width.toDouble(), height: height.toDouble());
  const CameraImageBlob.fromPath({
    required this.data,
    required this.width,
    required this.height,
  });
  ImagePath get path => data;
  bool get isEmpty => path.isEmpty;

  /// A data URI containing a representation of the image ('image/png').
  final ImagePath data;

  /// Is an unsigned long representing the actual height,
  /// in pixels, of the image data.
  final int width;

  /// Is an unsigned long representing the actual width,
  /// in pixels, of the image data.
  final int height;
}
