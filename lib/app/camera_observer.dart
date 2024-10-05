import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:io_photobooth/common/camera_service.dart';
import 'package:io_photobooth/main.dart';
import 'package:map_diff/map_diff.dart';

class AppCameraObserver {
  AppCameraObserver(this.cameraService) {
   cameraService.addListener(listener);
  }
  final CameraService cameraService;

  Map<String, dynamic> previousProps = {};
  Map<int, bool> cameraIds = {};
  void listener() {
    final props = cameraService.value.toJson();
    final diff = mapDiff(previousProps, props);
    final message = 'Camera Changed: ${diff}';
    errorHandler.onDebug(message);
    if(cameraService.value.cameraError != null || cameraService.value.controllerValue.errorDescription != null) {
      errorHandler.onError('Camera Error: ${cameraService.value.cameraError}, ${cameraService.value.controllerValue.errorDescription}');
    }
    if(cameraService.value.cameraId != null) {
      if(cameraService.value.cameraId == -1) {
        final previousCamera = previousProps['cameraId'] as int?;

        if(previousCamera != null && previousCamera > -1 && cameraIds.containsKey(previousCamera)) {
          cameraIds.remove(previousCamera);
          errorHandler.onDebug('Disposed cameraId: ${previousCamera}');
        }
      }else {
        if(!cameraIds.containsKey(cameraService.value.cameraId)) {
          cameraIds[cameraService.value.cameraId!] = true;
          errorHandler.onDebug('created cameraId: ${cameraService.value.cameraId}');
        }
      }
    }
    previousProps = props;
  }

  void dispose() {
     cameraService.removeListener(listener);
  }
}
