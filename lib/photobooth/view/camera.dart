import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';

typedef PlaceholderBuilder = Widget Function(BuildContext);
typedef PreviewBuilder = Widget Function(BuildContext, Widget);
typedef ErrorBuilder = Widget Function(BuildContext, String);

enum CameraStatus { uninitialized, available, unavailable }



class Camera extends StatefulWidget {
  Camera({
    required this.controller,
    PlaceholderBuilder? placeholder,
    PreviewBuilder? preview,
    ErrorBuilder? error,
    super.key,
  })  : placeholder = (placeholder ?? (_) => const SizedBox()),
        preview = (preview ?? (_, preview) => preview),
        error = (error ?? (_, __) => const SizedBox());

  final CameraController controller;
  final PlaceholderBuilder placeholder;
  final PreviewBuilder preview;
  final ErrorBuilder error;

  @override
  State<Camera> createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  Widget? _preview;
  Widget get preview {
    return _preview ??=
        CameraPlatform.instance.buildPreview(widget.controller.cameraId);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.controller,
      builder: (BuildContext context, CameraValue state, _) {
        if(!state.isInitialized){
            return widget.placeholder(context);
        }
          if(state.hasError) {
            return widget.error(context, state.errorDescription!);
          }
          return widget.preview(context, preview);
      },
    );
  }
}
