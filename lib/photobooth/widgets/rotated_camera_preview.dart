import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:io_photobooth/common/camera_service.dart';
import 'package:io_photobooth/common/theme/aspect_ratio.dart';
import 'package:provider/provider.dart';
import 'package:io_photobooth/config.dart' as config;

/// A widget showing a live camera preview.
class RotatedCameraPreview extends StatelessWidget {
  /// Creates a preview widget for the given camera controller.
  const RotatedCameraPreview(this.controller, {super.key, this.child});

  /// The controller for the camera that the preview is shown for.
  final CameraController controller;

  /// A widget to overlay on top of the camera preview
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final service = context.watch<CameraService>();
    ;
    return service.controller != null && controller.value.isInitialized
        ? ValueListenableBuilder<CameraValue>(
            valueListenable: controller,
            builder: (BuildContext context, Object? value, Widget? child) {
              return RotatedBox(
                  quarterTurns: service.cameraOffset,
                  child: AspectRatio(
                    aspectRatio: _isLandscape()
                        ? controller?.value?.aspectRatio ??
                            PhotoboothAspectRatio.landscape
                        : (1 /
                            (controller?.value?.aspectRatio ??
                                PhotoboothAspectRatio.landscape)),
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        _wrapInRotatedBox(child: controller.buildPreview()),
                        child ?? Container(),
                      ],
                    ),
                  ));
            },
            child: child,
          )
        : Container();
  }

  Widget _wrapInRotatedBox({required Widget child}) {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return child;
    }

    return RotatedBox(
      quarterTurns: _getQuarterTurns(),
      child: child,
    );
  }

  bool _isLandscape() {
    return <DeviceOrientation>[
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ].contains(_getApplicableOrientation());
  }

  int _getQuarterTurns() {
    final Map<DeviceOrientation, int> turns = <DeviceOrientation, int>{
      DeviceOrientation.portraitUp: 0,
      DeviceOrientation.landscapeRight: 1,
      DeviceOrientation.portraitDown: 2,
      DeviceOrientation.landscapeLeft: 3,
    };
    return turns[_getApplicableOrientation()]!;
  }

  DeviceOrientation _getApplicableOrientation() {
    return controller.value.isRecordingVideo
        ? controller.value.recordingOrientation!
        : (controller.value.previewPauseOrientation ??
            controller.value.lockedCaptureOrientation ??
            controller.value.deviceOrientation);
  }
}
