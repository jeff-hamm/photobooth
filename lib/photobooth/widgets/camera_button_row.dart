import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:io_photobooth/common/app_text_box.dart';
import 'package:io_photobooth/common/camera_button.dart';
import 'package:io_photobooth/common/camera_service.dart';
import 'package:io_photobooth/photobooth/photobooth.dart';
import 'package:io_photobooth/common/widgets.dart';
import '../../config.dart' as config;

class ShutterButtonFooter extends StatelessWidget {
  const ShutterButtonFooter({
    super.key,
    required this.onTakePhoto,
    required this.onFlipPressed,
    required this.onAllPhotosComplete,
    this.onPressed,
    this.photosPerPress = 1,
  });

  final VoidCallback? onPressed;
  final VoidCallback onAllPhotosComplete;
  final Future<void> Function() onTakePhoto;
  final VoidCallback onFlipPressed;
  final int photosPerPress;
  @override
  Widget build(BuildContext context) {
    final booth = context.watch<PhotoboothBloc>();
    final state = booth.state;
    final service = context.watch<CameraService>();
    final theme = Theme.of(context);
        return Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if(config.PhotosPerPress > 1)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    LayoutBuilder(builder: (context, constraints) {
                      final remaining = config.PhotosPerPress - state.images.length;
                      var suffix = "s";
                      if(remaining == 0)
                        return const SizedBox();
                      if(remaining == 1) 
                        suffix = "";
                    return 
                    AppTextBox(state.images.length == 0 && !state.isInPhotoStream
                              ? "Tap to take ${config.PhotosPerPress} photos!"
                              : "${remaining} photo${suffix} remaining!",
                              textStyleName: TextStyleName.displayLarge,
                              fontWeight: FontWeight.bold
                              ,);
                    }
                    )
                  ]),
               Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ShutterButton(
        key: const Key('photoboothPreview_photo_shutterButton'),
        onCountdownComplete: onTakePhoto,
        onAllPhotosComplete: () {
          booth.add(const PhotoSetCaptureCompleted());
          onAllPhotosComplete.call();
        },
        onPressed: () {
          booth.add(const PhotoSetCaptureStarted());
          onPressed?.call();
        },
        photosPerPress: photosPerPress,
      ),
      if(!state.isInPhotoStream && service.canFlip())
        CameraButton(onPressed: onFlipPressed,icon: 'assets/icons/retake_button_icon.png',)
    ])
    ])
    );
  }
}
