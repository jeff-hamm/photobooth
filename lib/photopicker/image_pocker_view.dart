import 'dart:core';
import 'dart:math';
import 'package:io_photobooth/app/router.gr.dart';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:io_photobooth/common/buttons/retake_button.dart';
import 'package:io_photobooth/common/buttons/retake_row.dart';
import 'package:io_photobooth/common/camera_service.dart';
import 'package:io_photobooth/common/error_dialog.dart';
import 'package:io_photobooth/common/models/ImagePath.dart';
import 'package:io_photobooth/common/widgets.dart';
import 'package:io_photobooth/config.dart' as config;
import 'package:io_photobooth/config.dart';
import 'package:io_photobooth/photobooth/photobooth.dart';
import 'package:io_photobooth/share/bloc/share_bloc.dart';
import 'package:io_photobooth/stickers/widgets/regenerate_ai_button.dart';
import 'package:multi_image_picker_view/multi_image_picker_view.dart';
import 'package:provider/provider.dart';
import 'package:zoom_hover_pinch_image/zoom_hover_pinch_image.dart';

import 'image_picker_controller.dart';
import 'image_picker_file.dart';
import 'selectable_draggable_item.dart';

class ImagePickerView extends StatefulWidget {
  const ImagePickerView({super.key});

  @override
  State<StatefulWidget> createState() => _ImagePickerViewState();
}

class _ImagePickerViewState extends State<ImagePickerView> {
  late final ImagePickerController controller;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<PhotoboothBloc>();
    final state = bloc.state;
    final imageFiles = toImageFiles(state).toList();
    controller = ImagePickerController(imagePaths: imageFiles);
    controller.isLoading = config.EnableAi;
  }

  Iterable<ImagePath> toImageFiles(PhotoboothState state) {
    return state.images
        .map(ImagePath.from)
        .followedBy(state.aiImage)
        .where((i) => i.isNotEmpty);
//          .map((i) => ImagePickerFile(i, false))
//          .toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PhotoboothBloc, PhotoboothState>(
        listener: (context, state) {
      if (state.aiGeneratingStatus == ShareStatus.loading) {
        controller.isLoading = true;
      }
      if (state.aiGeneratingStatus == ShareStatus.success) {
        state.aiImage.forEach((i) => controller.addImage(i));
        controller.isLoading = false;
      }
    }, child: LayoutBuilder(builder: (context, constraints) {
      double gridSize;
      double? mainSize;
      final size = Size(constraints.maxWidth, constraints.maxHeight);
      if (size.width >= size.height) {
        gridSize = (size.width - 100) /
            min(config.PickerWidth, controller.images.length);
      } else {
        gridSize = ((size.height - 200) / 2) * controller.aspectRatio;
      }

      // final images = context.select((PhotoboothBloc bloc) =>
      //     bloc.state.images.map(ImagePath.from).followedBy(bloc.state.aiImage));
      return Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: [
            PhotoboothBackground(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 60),
                    AppTextBox(
                      "Select which photos to project!",
                    ),
                    SizedBox(height: 40),
                    Expanded(
                        child: MultiImagePickerView(
                            shrinkWrap: false,
                            controller: controller,
                            addMoreButton: null,
                            gridDelegate:
                                SliverGridDelegateWithMaxCrossAxisExtentAndMinMainAxis(
                                    maxChildCrossAxisExtent: gridSize,
                                    maxCrossAxisExtent: gridSize,
                                    minCrossAxisCount: config.PickerWidth,
                                    minMainAxisCount: 2,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    childAspectRatio: controller.aspectRatio),
                            builder: (context, ImageFile imageFile) {
                              final i = imageFile as ImagePickerFile;
                              if (i.name == ImagePickerFile.loading.name) {
                                return Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Positioned.fill(
                                          child: ColoredBox(
                                              color: PhotoboothColors.white
                                                  .withOpacity(0.5))),
                                      Container(
                                          clipBehavior: Clip.antiAlias,
                                          decoration:
                                              AppTheme.imagePickerBoxDecoration,
                                          child:
                                              const AppCircularProgressIndicator())
                                    ]);
                              }
                              // here returning DefaultDraggableItemWidget. You can also return your custom widget as well.
                              return SelectableDraggableItemWidget(
                                  controller: controller, 
                                  imageFile: imageFile as ImagePickerFile);
                            },
                            padding: const EdgeInsets.all(20))),
                    ShipItRow(controller: controller)
                  ]),
            ),
            ActionsRow(
              retakeButton: true,
              showLogsButton: context.read<PhotoboothBloc>().isDebugClient,
            )
          ]);
    }));
  }
}

class ShipItRow extends StatelessWidget {
  const ShipItRow({super.key, required this.controller});

  final ImagePickerController controller;

  @override
  Widget build(BuildContext context) {
    final booth = context.watch<PhotoboothBloc>();
    final theme = Theme.of(context);
    return Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (config.PhotosPerPress > 1)
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      LayoutBuilder(builder: (context, constraints) {
                        return AppTextBox(
                          "Ship it!",
                          textStyleName: TextStyleName.displayLarge,
                          fontWeight: FontWeight.bold,
                        );
                      })
                    ]),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    RotatingShipIteButton(
                      controller: controller,
                    ),
                  ])
            ]));
  }
}

class ShipItButton extends StatelessWidget {
  const ShipItButton(
      {required this.controller,
      this.icon = 'assets/icons/flower.png',
      super.key});
  final ImagePickerController controller;
  final String icon;

  void onButtonPressed(BuildContext context) {
    final booth = context.read<PhotoboothBloc>();
    var toShip = controller.imageFiles
        .where((i) => i.isSelected)
        .map((i) => i.image)
        .toList();
    if (toShip.isEmpty) {
      toShip = controller.imageFiles.map((i) => i.image).toList();
    }
    booth.add(UploadImages(toShip));
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      focusable: true,
      button: true,
      label: "Ship It!",
      child: Material(
          clipBehavior: Clip.hardEdge,
          shape: const CircleBorder(),
          color: PhotoboothColors.transparent,
          child: InkWell(
            onTap: () => onButtonPressed(context),
            child: IconAssetColorSwitcher(this.icon),
          )
          // Image.asset(
          //   this.icon,
          //   height: 100,
          //   width: 100,
          // ),
//        ),
          ),
    );
  }
}

class RotatingShipIteButton extends StatelessWidget {
  const RotatingShipIteButton({super.key, required this.controller});
  final ImagePickerController controller;

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select(
      (PhotoboothBloc bloc) => bloc.state.imageUploadStatus.isLoading,
    );
    final image = context.watch<PhotoboothBloc>().state.selectedImage;
    return BlocListener<PhotoboothBloc, PhotoboothState>(
      listener: _onShareStateChange,
      child: RotatingWidget(
          isLoading: isLoading,
          child: ShipItButton(
            controller: controller,
          )),
    );
  }

  Future<void> _onShareStateChange(
      BuildContext context, PhotoboothState state) async {
    if (!state.imageUploadStatus.isLoading &&
        state.imageUploadStatus != ShareStatus.initial) {
      final navigator = AutoRouter.of(context);
      final photoboothBloc = context.read<PhotoboothBloc>();
      if (state.imageUploadStatus.isFailure) {
//            final navigator = Navigator.of(context);

        await showAppDialog<void>(
          child: const ErrorDialog(),
          context: context,
        );
        photoboothBloc.add(const PhotoClearAllTapped());
        Navigator.of(context).pop();
        // navigator.maybePop();
        // context.read<CameraService>().controller!.setDescription(
        //     context.read<CameraService>().controller!.value!.description);
//        navigator.replace(const PhotobothViewRoute());
//      await navigator.navigate(const PhotobothViewRoute());
        return;
      }

      photoboothBloc.add(const PhotoClearAllTapped());
      Navigator.of(context).pop();
      // navigator.replace(const PhotobothViewRoute());
      // navigator.popUntilRoot();

//      await navigator.navigate(const PhotobothViewRoute());
    }
  }
}

class SliverGridDelegateWithMaxCrossAxisExtentAndMinMainAxis
    extends SliverGridDelegateWithMaxCrossAxisExtent {
  /// Creates a delegate that makes grid layouts with tiles that have a maximum
  /// cross-axis extent.
  ///
  /// The [maxCrossAxisExtent], [mainAxisExtent], [mainAxisSpacing],
  /// and [crossAxisSpacing] arguments must not be negative.
  /// The [childAspectRatio] argument must be greater than zero.
  const SliverGridDelegateWithMaxCrossAxisExtentAndMinMainAxis(
      {required super.maxCrossAxisExtent,
      required this.maxChildCrossAxisExtent,
      required this.minCrossAxisCount,
      required this.minMainAxisCount,
      super.mainAxisSpacing = 0.0,
      super.crossAxisSpacing = 0.0,
      super.childAspectRatio = 1.0,
      super.mainAxisExtent});

  final int minMainAxisCount;
  final double maxChildCrossAxisExtent;

  final int minCrossAxisCount;

  SliverGridRegularTileLayout getMaxCrossAxisLayout(
      SliverConstraints constraints, double maxChildCrossAxisExtent) {
    // Ensure a minimum count of 1, can be zero and result in an infinite extent
    // below when the window size is 0.
    final crossAxisCount = min(minCrossAxisCount,
        max(1, getCrossAxisCount(constraints, maxCrossAxisExtent)));
    final double usableCrossAxisExtent = max(
      0.0,
      constraints.crossAxisExtent - crossAxisSpacing * (crossAxisCount - 1),
    );
    double childCrossAxisExtent = usableCrossAxisExtent / crossAxisCount;
    if (childCrossAxisExtent > maxChildCrossAxisExtent) {
      childCrossAxisExtent = maxChildCrossAxisExtent;
    }
    final double childMainAxisExtent =
        mainAxisExtent ?? childCrossAxisExtent / childAspectRatio;
    return SliverGridRegularTileLayout(
      crossAxisCount:
          max(minCrossAxisCount, min(crossAxisCount, config.PickerWidth)),
      mainAxisStride: childMainAxisExtent + mainAxisSpacing,
      crossAxisStride: childCrossAxisExtent + crossAxisSpacing,
      childMainAxisExtent: childMainAxisExtent,
      childCrossAxisExtent: childCrossAxisExtent,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  int getCrossAxisCount(
      SliverConstraints constraints, double maxCrossAxisExtent) {
    int crossAxisCount =
        (constraints.crossAxisExtent / (maxCrossAxisExtent + crossAxisSpacing))
            .ceil();
    return crossAxisCount;
  }

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    var layout = getMaxCrossAxisLayout(constraints, maxCrossAxisExtent);
    final realCrossAxisCount =
        getCrossAxisCount(constraints, maxCrossAxisExtent);
    final mainAvailable =
        constraints.remainingPaintExtent / layout.childMainAxisExtent!;
    if (realCrossAxisCount > 1 && minMainAxisCount > mainAvailable) {
      layout = getMaxCrossAxisLayout(
          constraints,
          (constraints.remainingPaintExtent / minMainAxisCount) *
              childAspectRatio);
    } else if (mainAvailable > minMainAxisCount) {}

    return layout;
  }

  @override
  bool shouldRelayout(SliverGridDelegateWithMaxCrossAxisExtent oldDelegate) {
    return oldDelegate.maxCrossAxisExtent != maxCrossAxisExtent ||
        oldDelegate.mainAxisSpacing != mainAxisSpacing ||
        oldDelegate.crossAxisSpacing != crossAxisSpacing ||
        oldDelegate.childAspectRatio != childAspectRatio ||
        oldDelegate.mainAxisExtent != mainAxisExtent;
  }
}
