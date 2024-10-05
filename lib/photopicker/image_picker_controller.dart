import 'package:io_photobooth/common/models/ImagePath.dart';
import 'package:io_photobooth/common/widgets.dart';
import 'package:multi_image_picker_view/multi_image_picker_view.dart';

import 'image_picker_file.dart';

class ImagePickerController extends MultiImagePickerController {
  ImagePickerController({
    Iterable<ImagePath> imagePaths = const [],
    bool isLoading = true,
  })  : _isLoading = isLoading,
        imageFiles = imagePaths
            .where((i) => !i.isEmpty)
            .map((i) => ImagePickerFile(i, false))
            .toList(),
        super(picker: (allowMultiple) => Future.value([]));
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  List<ImagePickerFile> imageFiles;
  @override
  List<ImageFile> get images {
    final r = imageFiles.toList();
    if (isLoading) {
      r.add(ImagePickerFile.loading);
    }
    super.updateImages(r);
    return r;
  }

  void toggleSelection(ImagePickerFile imageFile) {
    imageFile.isSelected = !imageFile.isSelected;
    notifyListeners();
  }

  @override
  void clearImages() {
    // TODO: implement clearImages
    imageFiles.clear();
    super.clearImages();
  }

  @override
  void updateImages(List<ImageFile> images) {
    // TODO: implement updateImages
    super.updateImages(images);
  }

  void addImage(ImagePath image) {
    if (image.isEmpty) {
      return;
    }
    for (final i in imageFiles) {
      if (i.image.imageId == image.imageId) {
        return;
      }
    }
    imageFiles.add(ImagePickerFile(image, false));
    updateImages(imageFiles);
  }

  @override
  bool get hasNoImages => imageFiles.isEmpty;

  double get aspectRatio =>
      imageFiles.isEmpty || imageFiles.first.aspectRatio == null
          ? PhotoboothAspectRatio.landscape
          : imageFiles.first.aspectRatio!;

  @override
  void removeImage(ImageFile imageFile) {
    toggleSelection(imageFile as ImagePickerFile);
    notifyListeners();
  }
}
