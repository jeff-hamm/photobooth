import 'dart:ui' as ui;
import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:crop_image/crop_image.dart';
import 'package:cross_file_image/cross_file_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:io_photobooth/common/models/ImagePath.dart';
import 'package:io_photobooth/common/theme/aspect_ratio.dart';
import 'package:io_photobooth/photobooth/view/camera.dart';
import 'package:permission_handler/permission_handler.dart';

import '../config.dart' as config;
import 'camera_image_blob.dart';
import 'camera_service_value.dart';

const uninitializedCameraDescription = CameraDescription(
    lensDirection: CameraLensDirection.front,
    name: "uninitialized",
    sensorOrientation: 0);

enum CameraInitializationStatus {
  uninitialized,
  initializing,
  available,
  unavailable,
}

class ImageSize {
  final Size size;
  final BoxFit fit;
  const ImageSize(this.size, this.fit);
}


class CameraCapabilities {
  CameraCapabilities();
}
//
// class CameraPermissionValue extends Equatable {
//   CameraPermissionValue(this.isDialogOpen);
//
//   final bool isDialogOpen;
//   final PermissionStatus? permissionStatus;
//   final wasDeclined;
//
// }
//
// class CameraPermissionService extends ValueNotifier<CameraPermissionValue> {
//   const CameraPermissionService();
//   Future<T> requestPermission() async {
//     try {
//       if (kIsWeb) {
//
//       }
//       else {
//         const permissionStatus = await Permission.camera.request();
//         const wasGranted = permissionStatus != PermissionStatus.provisional &&
//               permissionStatus != PermissionStatus.granted;
//         errorHandler.onLog(wasGranted ? Level.denbug : Level.warning, 'Camera permission: ${permissionStatus}');
//       }
//     }
//   }
// }

class CameraSelector {
  CameraSelector();
  bool isInitializing = false;
  CameraStatus status = CameraStatus.uninitialized;
  CameraException? error;
  bool isAvailable() => status == CameraStatus.available;
  bool hasCameras() => isAvailable() && cameras.isNotEmpty;
  late final List<CameraDescription> cameras;
  Future<CameraStatus> init() async {
    if (isAvailable()) return status;
    if (isInitializing) return CameraStatus.uninitialized;
    isInitializing = true;
    try {
      cameras = await availableCameras();
      status = CameraStatus.available;
    } on CameraException catch (e) {
      status = CameraStatus.unavailable;
      error = e;
    } finally {
      isInitializing = false;
    }
    return status;
  }

  bool cameraExists(
      {Orientation? mediaOrientation,
      DeviceOrientation? deviceOrientation,
      CameraLensDirection? lense}) {
    if (!hasCameras()) return false;
    final degrees = mediaOrientationToDegrees(mediaOrientation) ??
        orientationToDegrees(deviceOrientation);
    for (final camera in cameras) {
      if ((lense == null || camera.lensDirection == lense) &&
          (degrees == null || camera.sensorOrientation == degrees)) {
        return true;
      }
    }
    return false;
  }

  int? cameraOffset;
  Future<CameraDescription> select(CameraDescription? current,
      {Orientation? mediaOrientation,
      DeviceOrientation? deviceOrientation,
      CameraLensDirection? lense}) async {
    if (!hasCameras()) return uninitializedCameraDescription;
    final degrees = mediaOrientationToDegrees(mediaOrientation) ??
        orientationToDegrees(deviceOrientation) ??
        current?.sensorOrientation;
    lense ??= current?.lensDirection ?? CameraLensDirection.front;
    CameraDescription? bestCamera;
    for (final camera in cameras) {
      if (camera.lensDirection == lense) {
        if (camera.sensorOrientation == degrees) return camera;
        if (bestCamera?.lensDirection != lense) {
          bestCamera = camera;
        }
        continue;
      }
      if (camera.sensorOrientation == degrees &&
          bestCamera?.sensorOrientation != degrees &&
          bestCamera == current) {
        bestCamera = camera;
      }
    }
    // if (deviceOrientation != null) {
    //   await SystemChrome.setPreferredOrientations([deviceOrientation]);
    // } else if (mediaOrientation != null) {
    //   await SystemChrome.setPreferredOrientations(
    //       mediaOrientation == Orientation.portrait
    //           ? [
    //               DeviceOrientation.portraitDown,
    //               DeviceOrientation.portraitUp,
    //             ]
    //           : [
    //               DeviceOrientation.landscapeLeft,
    //               DeviceOrientation.landscapeRight,
    //             ]);
    // }

    bestCamera ??= cameras.first;
//    if (degrees != bestCamera.sensorOrientation) {
    cameraOffset = bestCamera.sensorOrientation;
    //  } else {
    //  cameraOffset = 0;
    //}
    return CameraDescription(
        name: bestCamera.name,
        lensDirection: bestCamera.lensDirection,
        sensorOrientation: degrees ?? bestCamera.sensorOrientation);
  }

  void ensureValidCamera() {
    if (status == CameraStatus.uninitialized) {
      throw CameraException('CameraNotReady', 'Camera not initialized');
    }
    if (status == CameraStatus.unavailable) {
      throw CameraException('CameraAccessDenied', "Camera access denied");
    }
    if (!hasCameras()) {
      throw new CameraException("CameraNotFound", "No cameras available");
    }
  }

  int? mediaOrientationToDegrees(Orientation? orientation) {
    if (orientation == null) return null;
    switch (orientation) {
      case Orientation.landscape:
        return 90;
      case Orientation.portrait:
        return 0;
    }
  }

  int? orientationToDegrees(DeviceOrientation? orientation) {
    if (orientation == null) return null;
    switch (orientation) {
      case DeviceOrientation.portraitUp:
        return 0;
      case DeviceOrientation.landscapeLeft:
        return 90;
      case DeviceOrientation.portraitDown:
        return 180;
      case DeviceOrientation.landscapeRight:
        return 270;
      default:
        return 0;
    }
  }
}

bool isEqual(CameraDescription? a, CameraDescription? b) {
  if (a == null || b == null) return false;
  return a.name == b.name && a.lensDirection == b.lensDirection;
  //&&
  //a.sensorOrientation == b.sensorOrientation;
}

DeviceOrientation? degreesToOrientation(int? degrees, int? offset) {
  if (degrees == null) return null;
  degrees = (degrees - (offset ?? 0)) % 360;
  switch (degrees) {
    case -90:
      return DeviceOrientation.landscapeRight;
    case 0:
      return DeviceOrientation.portraitUp;
    case 90:
      return DeviceOrientation.landscapeLeft;
    case 180:
      return DeviceOrientation.portraitDown;
    case 270:
      return DeviceOrientation.landscapeRight;
    default:
      return DeviceOrientation.portraitUp;
  }
}

class CameraService extends ValueNotifier<CameraServiceValue> {
  CameraService._() : super(const CameraServiceValue.uninitialized());

  factory CameraService() {
    final service = CameraService._();
    unawaited(service._init());
    return service;
  }
  final CameraSelector _cameraSelector = CameraSelector();
  bool _isCameraChangePending = false;
  bool _isInitComplete = false;
  CameraController? _controller;
//  bool _controllerInitialized = false;
  bool get isCameraInitialized =>
      _cameraSelector.isAvailable() &&
      (_controller?.value.isInitialized ?? false) &&
      this._isInitComplete;
  bool get isCameraAvailable =>
      isCameraInitialized && _cameraSelector.hasCameras();
  CameraController? get controller => _controller;
  Future<void> _init() async {
    _isInitComplete = false;
    value = value.copyWith(
        cameraSelectorStatus: CameraStatus.uninitialized,
        cameraError: noException,
        controllerValue:
            const CameraValue.uninitialized(uninitializedCameraDescription));
    if (await _cameraSelector.init() == CameraStatus.unavailable) {
      value = value.copyWith(
          cameraError: _cameraSelector.error,
          cameraSelectorStatus: _cameraSelector.status);
      return;
    }
    await initState();
    value = value.copyWith(cameraSelectorStatus: _cameraSelector.status);
  }

  Future<void> disposeController() async {
    final controller = _controller;
    _controller = null;
    if (controller != null) {
      controller!.removeListener(_onControllerChanged);
      await stop();
      final nextValue = CameraServiceValue(
          controller?.description,
          CameraValue.uninitialized(
              controller?.description ?? uninitializedCameraDescription),
          requestOrientation: value.requestOrientation,
          cameraError: value.cameraError,
          cameraSelectorStatus: value.cameraSelectorStatus,
          cameraId: -1);
      await controller!.dispose();
      value = nextValue;
    }
  }

  bool isProfile = false;
  Future<void> replaceController() async {
    _isInitComplete = false;
    if (!_cameraSelector.isAvailable()) return;
    await disposeController();
    final controller = _controller = CameraController(
      await _cameraSelector.select(null),
      config.CameraResolution,
      enableAudio: false,
      imageFormatGroup: config.CameraImageFormat,
    );
    await _controller!.initialize();
    isProfile = _controller!.value.deviceOrientation ==
            DeviceOrientation.portraitUp ||
        _controller!.value.deviceOrientation == DeviceOrientation.portraitDown;
    // If the controller is updated then update the UI.
    controller.addListener(_onControllerChanged);
  }

  bool _isInitializing = false;
  Future<void> _initController(Future<void> func(),
      {CameraDescription? description}) async {
    description ??= _controller!.description!;
    if (description.sensorOrientation != 0) {
//       await SystemChrome.setPreferredOrientations(
//           [degreesToOrientation(description.sensorOrientation)!]
// //           [DeviceOrientation.landscapeRight,DeviceOrientation.landscapeLeft]
//           );
    }
    if (!isEqual(value.camera, description)) {
      await func();
    }
//    if (description.sensorOrientation != 0) {
//     await _controller!.lockCaptureOrientation(degreesToOrientation(
//         description.sensorOrientation, _cameraSelector.cameraOffset)!);
//    }
//    await _controller!.setDescription(description);
//     if (description.sensorOrientation != 0) {
//       await SystemChrome.setPreferredOrientations([
//         DeviceOrientation.landscapeLeft,
//         DeviceOrientation.landscapeRight,
//         DeviceOrientation.portraitUp,
//         DeviceOrientation.portraitDown
//       ]);
//     }
  }

  ImageSize calculateMediaSize(Size screenSize, double aspectRatio) {
    var width = screenSize.width;
    var height = screenSize.height;
    BoxFit boxFit;

    if (aspectRatio >= 1) {
      if (height * aspectRatio > screenSize.width) {
        height = screenSize.width / aspectRatio;
        boxFit = BoxFit.fitWidth;
      } else {
        width = screenSize.height * aspectRatio;
        boxFit = BoxFit.fitHeight;
      }
    } else {
      final inverseRatio = 1 / aspectRatio;
      if (width * inverseRatio > screenSize.height) {
        width = screenSize.height * inverseRatio;
        boxFit = BoxFit.fitHeight;
      } else {
        height = screenSize.width * inverseRatio;
        boxFit = BoxFit.fitWidth;
      }
    }
    return ImageSize(Size(width, height), boxFit);
  }

  int get cameraOffset => isProfile || kIsWeb
      ? 0
      : (((_cameraSelector.cameraOffset ?? 0) / 90)).toInt();

  Future<void> initState() async {
    if (_isInitializing) return;
    _isInitComplete = false;
    _isInitializing = true;
    CameraException? error;
    try {
      if (!_cameraSelector.isAvailable()) return;
      final controllerWasNull = _controller == null;
      if (controllerWasNull) {
        await replaceController();
      }

      if (controllerWasNull) {
//        await _initController(() => );
        await _setCamera(
            deviceOrientation: _controller?.value.deviceOrientation);
      } else if (!isEqual(value.camera, controller!.description)) {
        await _initController(() => _controller!.setDescription(value.camera!));
      } else {}
//        awai _initController();
      // await _controller!
      //     .lockCaptureOrientation(DeviceOrientation.landscapeLeft);
//        await _controller!.resumePreview();
    } on CameraException catch (e) {
      error = e;
    } finally {
      _isInitComplete = true;
      _isInitializing = false;
    }

    value = value.copyWith(
        cameraError: error,
        camera: _controller!.description,
        controllerValue: _controller!.value,
        cameraId: _controller?.cameraId);
  }

  void lockOrientation(Orientation? orientation) {
    if (value.requestOrientation != orientation) {
      value = value.copyWith(requestOrientation: orientation);
    }
  }

  Future<void> setCamera(
      {DeviceOrientation? deviceOrientation,
      Orientation? orientation,
      CameraLensDirection? lense}) async {
    if (!isCameraAvailable || _isCameraChangePending) return;
    return await _setCamera(
        mediaOrientation: orientation,
        lense: lense,
        deviceOrientation: deviceOrientation);
  }

  Future<void> _setCamera(
      {DeviceOrientation? deviceOrientation,
      Orientation? mediaOrientation,
      CameraLensDirection? lense}) async {
    CameraException? error;
    _isCameraChangePending = true;
    try {
      final newCamera = await _cameraSelector.select(value.camera,
          mediaOrientation: value.requestOrientation ?? mediaOrientation,
          deviceOrientation: deviceOrientation,
          lense: lense);
      try {
        await _initController(() => _controller!.setDescription(newCamera),
            description: newCamera);
//          await _initController(description: newCamera);
        // await _controller!
        //     .lockCaptureOrientation(DeviceOrientation.landscapeLeft);
      } on CameraException catch (e) {
        error = e;
      }
      value = value.copyWith(
          cameraError: error,
          controllerValue: _controller!.value,
          camera: newCamera,
          cameraId: _controller?.cameraId);
    } finally {
      _isCameraChangePending = false;
    }
  }

  Future<void> play() async {
    if (!isCameraAvailable) return;
    return _controller!.resumePreview();
  }

  Future<void> stop() async {
    if (!isCameraAvailable) return;
    return _controller!.pausePreview();
  }

  void ensureValidCamera() {
    _cameraSelector.ensureValidCamera();
    if (_controller?.value.isInitialized != true) {
      throw CameraException('CameraNotReady', 'Camera not initialized');
    }
  }

  @override
  Future<void> dispose() async {
    await disposeController();
    super.dispose();
  }

  Future<void> updateLifecycle(AppLifecycleState state) async {
    // App state changed before we got the chance to initialize.
    if (!isCameraInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      await disposeController();
    } else if (state == AppLifecycleState.resumed) {
      await replaceController();
    }
  }
  Future<ui.Image> getImage(XFile file) async {
    final completer = Completer<ImageInfo>();
    final img =
        XFileImage(file).resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((info, _) {
        completer.complete(info);
      }),
    );
    final imageInfo = await completer.future;

    return imageInfo.image;
  }

  final cropper = CropController(
    aspectRatio: PhotoboothAspectRatio.landscape,
  );
  Future<CameraImageBlob> takePicture() async {
    ensureValidCamera();
    
    final aspectRatio = PhotoboothAspectRatio.forDeviceOrientation(
        value.controllerValue.deviceOrientation);
    final file = await _controller!.takePicture();
//    cropper.image = await getImage(file);
//    cropper.aspectRatio = aspectRatio;
//    final croppedFile = await cropper.croppedBitmap();
    // final byteData =
    //     await croppedFile.toByteData(format: ui.ImageByteFormat.png);

    // final buffer = byteData!.buffer.asUint8List();

    return CameraImageBlob(
        data: file.path,
        width: value.controllerValue.previewSize?.width.toInt() ?? 1,
        height: value.controllerValue.previewSize?.height.toInt() ?? 1);
  }
 
  Widget buildPreview() {
    if (!isCameraAvailable) return const SizedBox();
    return CameraPlatform.instance.buildPreview(_controller!.cameraId);
  }

  bool canFlip() {
    if (!isCameraAvailable) return false;
    this.ensureValidCamera();
    final direction = value.camera?.lensDirection == CameraLensDirection.front
        ? CameraLensDirection.back
        : CameraLensDirection.front;
    return _cameraSelector.cameraExists(lense: direction);
  }

  Future<void> flipCamera() async {
    ensureValidCamera();
    final direction = value.camera?.lensDirection == CameraLensDirection.front
        ? CameraLensDirection.back
        : CameraLensDirection.front;
    await setCamera(lense: direction);
  }

  void _onControllerChanged() async {
    if (!_isCameraChangePending && isCameraInitialized && _controller != null) {
//      await _controller?.lockCaptureOrientation();

      // value = value.copyWith(
      //   controllerValue: _controller?.value
      // );
      await setCamera(deviceOrientation: _controller?.value.deviceOrientation);
    }
  }

  Future<void> retryPermissions() async {
//     if (_cameraSelector.status == CameraStatus.unavailable &&
//         _cameraSelector.permissionStatus != PermissionStatus.granted &&
//         _cameraSelector.permissionStatus !=
//             PermissionStatus.permanentlyDenied) {
// //      await _init();
//     }
  }
}
