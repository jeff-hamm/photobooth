import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:io_photobooth/app/router.gr.dart';
import 'package:io_photobooth/common/buttons/retake_row.dart';
import 'package:io_photobooth/common/camera_image_blob.dart';
import 'package:io_photobooth/common/buttons/retake_button.dart';
import 'package:io_photobooth/common/theme.dart';
import 'package:io_photobooth/photobooth/photobooth.dart';
import 'package:io_photobooth/common/models/ImagePath.dart';
import 'package:io_photobooth/photopicker/image_pocker_view.dart';
import 'package:io_photobooth/share/share.dart';
import 'package:multi_image_picker_view/multi_image_picker_view.dart';
import 'package:path/path.dart' as p;
import 'package:io_photobooth/common/widgets.dart';
import 'package:provider/provider.dart';
import '../config.dart' as config;

class MyMultiImagePickerController extends MultiImagePickerController {
  MyMultiImagePickerController({
    required List<ImageFile> super.images,
    required super.picker,
  }) : myImages = images;
  List<ImageFile> myImages;
  @override
  List<ImageFile> get images => myImages;
}

@RoutePage()
class PickerPage extends StatelessWidget {
  const PickerPage({this.images});

  final List<ImagePath>? images;
  @override
  Widget build(BuildContext context) {
    final boothBloc = context.watch<PhotoboothBloc>();
    if (images == null && boothBloc.state.images.isEmpty) {
      boothBloc.add(const PhotoClearAllTapped());
      AutoRouter.of(context).replace(const PhotobothViewRoute());
      return const SizedBox();
    }

    return Scaffold(
        backgroundColor: PhotoboothColors.black, body: const ImagePickerView());
  }
}
        
  
// }

// class ImagePicker extends StatelessWidget {
//   const ImagePicker({this.imageBlobs});
//   // : imageBlobs = imageBlobs,
//   //   images = imageBlobs
//   //       .map((i) => ImageFile(
//   //             i.imageId,
//   //                 name: i.toFileName(),
//   //                 extension: i.fileExtension,
//   //                 path: i.toFilePath(),
//   //           ))
//   //       .toList();
//   final List<ImagePath>? imageBlobs;
//   //List<ImageFile> images;

//   @override
//   Widget build(BuildContext c) {
//     return OrientationBuilder(builder: (context, orientation) {
//       // final size = MediaQuery.of(context).size;
//       // double gridSize;
//       // double aspectRatio;
//       // double? mainSize = null;
//       // final controller = context.read<MultiImagePickerController>() as MyMultiImagePickerController;
//       // final imagePaths = context.select((PhotoboothBloc bloc) => bloc.state.images)
//       //   .map((i) => ImagePath.from(i))
//       //   .followedBy(context.select((PhotoboothBloc bloc) => bloc.state.aiImage));
//       // final images = imagePaths.map((i) => i.toImageFile()).toList();
//       // if(context.select((PhotoboothBloc bloc) => bloc.state.aiGeneratingStatus) == ShareStatus.loading){
//       //   images.add(ImageFile("loading", name: "loading", extension: ""));
//       // }
//       // controller.myImages = images;
//       // final firstImage = imagePaths.first;
//       //     if (firstImage.width == null || firstImage.height == null ||
//       // (firstImage.width! > firstImage.height!)) {
//       //   aspectRatio = PhotoboothAspectRatio.landscape;
//       // } else {
//       //   aspectRatio = PhotoboothAspectRatio.portrait;
//       // }
//       // if (size.width > size.height) {
//       //   gridSize = size.width / min(config.PickerWidth,images.length);
//       // } else {
//       //   mainSize = (size.height - 350) / images.length;
//       //   gridSize = (size.height / images.length) * aspectRatio;
//       // }

//       final theme = Theme.of(context);
//       return Stack(
//         fit: StackFit.expand,
//         children: [
//           PhotoboothBackground(),
//           Padding(
//               padding: EdgeInsets.symmetric(horizontal: 24),
//               child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     SizedBox(height: 60),
//                     AppTextBox(
//                       "Select which photos to project!",
//                     ),
//                     SizedBox(height: 40),
//                   ])),
//           ActionsRow(
//             retakeButton: true,
//             showLogsButton: context.read<PhotoboothBloc>().isDebugClient,
//           ),
//         ],
//       );
//     });
//   }
// }
