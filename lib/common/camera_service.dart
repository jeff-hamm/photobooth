import 'dart:async';

import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:io_photobooth/photobooth/view/camera.dart';
import '../config.dart' as config; 
const uninitializedCameraDescription = CameraDescription(lensDirection: CameraLensDirection.front,name: "uninitialized", sensorOrientation: 0);
class CameraServiceValue extends Equatable {
  const CameraServiceValue(this.camera,this.controllerValue, {this.requestOrientation, this.cameraError, this.cameraId, this.cameraSelectorStatus = CameraStatus.uninitialized});
   const CameraServiceValue.uninitialized()
      : this(null, const CameraValue.uninitialized(uninitializedCameraDescription));
  final CameraDescription? camera;
  final CameraValue controllerValue;
  final Orientation? requestOrientation;
  final CameraException? cameraError;
  final int? cameraId;
  final CameraStatus? cameraSelectorStatus;

  CameraServiceValue copyWith({
    CameraDescription? camera,
    CameraValue? controllerValue,
    Orientation? requestOrientation,
    CameraException? cameraError,
    int? cameraId,
    CameraStatus? cameraSelectorStatus
  }) {
    return CameraServiceValue(
      camera ?? this.camera,
      controllerValue ?? this.controllerValue,
      requestOrientation: requestOrientation ?? this.requestOrientation,
      cameraError: cameraError ?? this.cameraError,
      cameraId: cameraId ?? this.cameraId,
      cameraSelectorStatus: cameraSelectorStatus ?? this.cameraSelectorStatus
    );
    
  }
  
  @override
  List<Object?> get props => [camera?.name,camera?.lensDirection,camera?.sensorOrientation,
    controllerValue.isInitialized, controllerValue.hasError,controllerValue.description.name,
    controllerValue.description.lensDirection,controllerValue.description.sensorOrientation,
    requestOrientation, cameraError, controllerValue.isPreviewPaused, cameraId, cameraSelectorStatus];
}
enum CameraInitializationStatus {
  uninitialized,
  initializing,
  available,
  unavailable,
}
class CameraCapabilities {
  CameraCapabilities();
}
class CameraSelector {
  CameraSelector();
  bool isInitializing = false;
  CameraStatus status = CameraStatus.uninitialized;
  CameraException? error;
  bool isAvailable() => status == CameraStatus.available; 
  bool hasCameras() => isAvailable() && cameras.isNotEmpty;
  late final List<CameraDescription> cameras;
  Future<CameraStatus> init() async {
    if(isAvailable()) return status;
    if(isInitializing) return CameraStatus.uninitialized;
    isInitializing = true;
    try {
      cameras = await availableCameras();
      status = CameraStatus.available;
    }
    on CameraException catch (e) {
      status = CameraStatus.unavailable;
      error = e;
    }
    finally {
      isInitializing = false;
    }
    return status;
  }
  bool cameraExists({Orientation? mediaOrientation,DeviceOrientation? deviceOrientation, CameraLensDirection? lense}) {
    if(!hasCameras()) return false;
    final degrees = mediaOrientationToDegrees(mediaOrientation) ??
       orientationToDegrees(deviceOrientation);
    for(final camera in cameras) {
      if((lense == null || camera.lensDirection == lense) && 
        (degrees == null || camera.sensorOrientation == degrees)) {
        return true;
      }
    }
    return false;    
  }
  CameraDescription select(CameraDescription? current, {Orientation? mediaOrientation,DeviceOrientation? deviceOrientation, CameraLensDirection? lense}) {
    if(!hasCameras()) return uninitializedCameraDescription;
    final degrees = mediaOrientationToDegrees(mediaOrientation) ??
       orientationToDegrees(deviceOrientation) ??
       current?.sensorOrientation ?? 0;
    lense ??= current?.lensDirection ?? CameraLensDirection.front;
    CameraDescription? bestCamera;
    for(final camera in cameras) {
      if(camera.lensDirection == lense) {
        if(camera.sensorOrientation == degrees) return camera;
        if(bestCamera?.lensDirection != lense) {
          bestCamera = camera;
        } 
        continue;
      }
      if(camera.sensorOrientation == degrees && bestCamera?.sensorOrientation != degrees) {
        bestCamera = camera;
      }
    }
    return current ?? cameras.first;
  }
  void ensureValidCamera() {
    if(status == CameraStatus.uninitialized) {
      throw CameraException('CameraNotReady','Camera not initialized');
    }
    if(status == CameraStatus.unavailable) {
      throw CameraException('CameraAccessDenied',"Camera access denied");
    }
    if(!hasCameras()) {
      throw new CameraException("CameraNotFound", "No cameras available");
    }
  }

  int? mediaOrientationToDegrees(Orientation? orientation) {
    if(orientation == null) return null;
    switch(orientation) {
      case Orientation.landscape:
        return 90;
      case Orientation.portrait:
        return 0;
    }
  }
  int? orientationToDegrees(DeviceOrientation?  orientation) {
    if(orientation == null) return null; 
    switch(orientation) {
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
  bool get isCameraInitialized => _cameraSelector.isAvailable() && (_controller?.value.isInitialized ?? false) && this._isInitComplete;  
  bool get isCameraAvailable => isCameraInitialized && _cameraSelector.hasCameras();
  Future<void> _init() async {
    _isInitComplete = false;
    value = value.copyWith(
      cameraSelectorStatus: CameraStatus.uninitialized
    );
    if(await _cameraSelector.init() == CameraStatus.unavailable){
      value = value.copyWith(
        cameraError: _cameraSelector.error,
        cameraSelectorStatus: _cameraSelector.status
      );
      return;
    }
    await initState();
    value = value.copyWith(
      cameraSelectorStatus: _cameraSelector.status
    );
  }
  Future<void> disposeController() async {
    final controller = _controller;
    _controller = null;
    if(controller != null) {
      controller!.removeListener(_onControllerChanged);
      value = CameraServiceValue(controller?.description,controller.value,requestOrientation: value.requestOrientation, cameraError: value.cameraError);
      await controller!.dispose();
    }
  }

  Future<void> replaceController() async {
    _isInitComplete = false;
    if(!_cameraSelector.isAvailable()) return;
    await disposeController();
    final controller = _controller = CameraController(
      _cameraSelector.select(null),
      config.CameraResolution,
      enableAudio: false,
      imageFormatGroup: config.CameraImageFormat,
    );
    // If the controller is updated then update the UI.
    controller
      ..addListener(_onControllerChanged);
  }
  bool _isInitializing = false;

  Future<void> initState() async {
    if(_isInitializing) return;   
    _isInitComplete = false;
    _isInitializing = true;
    CameraException? error;
    try {
    if(!_cameraSelector.isAvailable()) return;
    if(_controller == null) {
      await replaceController();
    }
    try {
      await _controller!.initialize();
      await _controller!.resumePreview();
    } on CameraException catch (e) {
      error = e;
    }
    }
    finally {
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
    if(value.requestOrientation != orientation) {
      value = value.copyWith(
        requestOrientation: orientation
      );
    }
  }
  Future<void> setCamera({Orientation? orientation, CameraLensDirection? lense}) {
    return _setCamera( mediaOrientation: orientation, 
      lense: lense);
  }
  Future<void> _setCamera({DeviceOrientation? deviceOrientation, Orientation? mediaOrientation, CameraLensDirection? lense}) async {
    final newCamera = _cameraSelector.select(
        value.camera, mediaOrientation: value.requestOrientation ?? mediaOrientation, 
        deviceOrientation: deviceOrientation, 
        lense: lense);
    if(!isCameraAvailable) return;
      CameraException? error;
        _isCameraChangePending = true;
        try {
          if(!isEqual(value.camera, newCamera)) {
            try {
              await _controller!.setDescription(newCamera);
            } on CameraException catch (e) {
              error = e;
            }
          }
            value = value.copyWith(
              cameraError: error,
              controllerValue: _controller!.value,
              camera: newCamera,
              cameraId: _controller?.cameraId
            );
        }
        finally {
          _isCameraChangePending = false;
        }
  }
  bool isEqual(CameraDescription? a, CameraDescription? b) {
    if(a == null || b == null) return false;
    return a.name == b.name && a.lensDirection == b.lensDirection;
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
    if(_controller?.value.isInitialized != true) {
      throw CameraException('CameraNotReady','Camera not initialized');
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
  Future<XFile> takePicture() {
    ensureValidCamera();
    return _controller!.takePicture();
  }

  Widget buildPreview() {
      if(!isCameraAvailable) return const SizedBox();
      return CameraPlatform.instance.buildPreview(_controller!.cameraId);
  }

  bool canFlip() {
    this.ensureValidCamera();
    final direction = value.camera?.lensDirection == CameraLensDirection.front ? CameraLensDirection.back : CameraLensDirection.front;
    return _cameraSelector.cameraExists(lense: direction);
  }

  Future<void> flipCamera() async {
    ensureValidCamera();
    final direction = value.camera?.lensDirection == CameraLensDirection.front ? CameraLensDirection.back : CameraLensDirection.front;
    await setCamera(lense: direction);
  }

  void _onControllerChanged() async {
      if(!_isCameraChangePending && isCameraInitialized){
      await _setCamera(deviceOrientation: _controller?.value.deviceOrientation);
      }
  }
}