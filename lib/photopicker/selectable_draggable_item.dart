import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:io_photobooth/common/camera_service.dart';
import 'package:io_photobooth/common/theme/aspect_ratio.dart';
import 'package:io_photobooth/common/theme/colors.dart';
import 'package:io_photobooth/common/widgets.dart';
import 'package:io_photobooth/config.dart';
import 'package:io_photobooth/photobooth/bloc/photobooth_bloc.dart';
import 'package:io_photobooth/photopicker/image_picker_enlarge.dart';
import 'package:io_photobooth/photopicker/image_picker_file.dart';
import 'package:multi_image_picker_view/multi_image_picker_view.dart';

class SelectableDraggableItemWidget extends StatelessWidget {
  const SelectableDraggableItemWidget(
      {required this.imageFile,
      this.boxDecoration = const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      super.key});

  final ImagePickerFile imageFile;

  final BoxDecoration boxDecoration;
  void _onSelected() {}

  void _onCanceled() {}

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      InkWell(
        onTap: () {
                    imageFile.isSelected = !imageFile.isSelected;
                    context.read<PhotoboothBloc>().add(PhotoSelectToggled(
                        imageFile!.image,
                        toggled: imageFile.isSelected));
        }
      child: DefaultDraggableItemWidget(
        imageFile: imageFile,
      
        boxDecoration: boxDecoration,
        closeButtonAlignment: Alignment.topLeft,
        fit: BoxFit.cover,
        closeButtonIcon: imageFile.isSelected
            ? const Icon(
                Icons.check_circle_outline,
                color: PhotoboothColors.selected,
                size: 24,
              )
            : const Icon(
                Icons.radio_button_unchecked_outlined,
                color: PhotoboothColors.black,
                size: 24,
              ),
        closeButtonBoxDecoration: null,
        showCloseButton: true,
        closeButtonMargin: const EdgeInsets.all(3),
        closeButtonPadding: const EdgeInsets.all(3),
      )),
      // Align(
      //     alignment: Alignment.bottomCenter,
      //     child: Row(
      //         mainAxisAlignment: MainAxisAlignment.center,
      //         crossAxisAlignment: CrossAxisAlignment.end,
      //         children: [
      //           IconButton.filled(
      //             onPressed: () {
      //               imageFile.isSelected = !imageFile.isSelected;
      //               context.read<PhotoboothBloc>().add(PhotoSelectToggled(
      //                   imageFile!.image,
      //                   toggled: imageFile.isSelected));
      //             },
      //             icon: imageFile.isSelected
      //                 ? const Icon(Icons.check_rounded, color: AppTheme.green)
      //                 : IconButton.filled(
      //                     onPressed: _onCanceled,
      //                     icon: const Icon(Icons.close_rounded,
      //                         color: PhotoboothColors.gray)),
      //           )
      //         ]))
    ]);
  }
}

  //   },
  //         child: Center(
  //           child: ,
  // Positioned.fill(
  // child: GestureDetector(
  // onTap: () {
  // context.read<PhotoboothBloc>()
  //     .add(PhotoSelected(imageFile.path!));
  // context.router.push(const StickersRoute());
  // },
  // ),
  // )]);