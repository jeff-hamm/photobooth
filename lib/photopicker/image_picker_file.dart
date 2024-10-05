import 'package:io_photobooth/common/models/ImagePath.dart';
import 'package:multi_image_picker_view/multi_image_picker_view.dart';

class ImagePickerFile extends ImageFile {
  ImagePickerFile(this.image, this.isSelected)
      : super(image.imageId,
            name: image.toFileName(),
            extension: image.fileExtension,
            path: image.path);
  ImagePath image;
  bool isSelected;

  static ImagePickerFile loading = ImagePickerFile(ImagePath.loading, false);
  double? get aspectRatio => image.width == null || image.height == null
      ? null
      : image.width! / image.height!;
}
