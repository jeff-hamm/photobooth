import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:io_photobooth/app/app.dart';
import 'package:io_photobooth/common/camera_service.dart';
import 'package:io_photobooth/stickers/view/stickers_page.dart';

typedef PlaceholderBuilder = Widget Function(BuildContext);
typedef PreviewBuilder = Widget Function(BuildContext, Widget);
typedef ErrorBuilder = Widget Function(BuildContext, String);

enum CameraStatus { uninitialized, available, unavailable }



class Camera extends StatefulWidget {
  Camera({
    PlaceholderBuilder? placeholder,
    PreviewBuilder? preview,
    ErrorBuilder? error,
    super.key,
  })  : placeholder = (placeholder ?? (_) => const SizedBox()),
        preview = (preview ?? (_, preview) => preview),
        error = (error ?? (_, __) => const SizedBox());

  final PlaceholderBuilder placeholder;
  final PreviewBuilder preview;
  final ErrorBuilder error;

  @override
  State<Camera> createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  Widget? _preview;
  int? cameraId;
  Widget get preview {
     var svc = context.read<CameraService>();
    if(_preview == null || svc.value.cameraId != cameraId) {
      cameraId = svc.value.cameraId;
      _preview = svc.buildPreview();
    }
    return _preview ??= svc.buildPreview();
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: context.read<CameraService>(),
      builder: (BuildContext context, CameraServiceValue state, _) {
        if(!state.controllerValue.isInitialized){
            return widget.placeholder(context);
        }
          if(state.cameraError !=null) {
            return widget.error(context, state.cameraError!.description ?? state.cameraError!.code);
          }
          return widget.preview(context, preview);
      },
    );
  }
}
