import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:io_photobooth/photobooth/view/camera.dart';
import 'package:json_annotation/json_annotation.dart';

import 'camera_service.dart';

part 'camera_service_value.g.dart';

class CameraDescriptionJsonConverter
    extends JsonConverter<CameraDescription?, Map<String, dynamic>?> {
  const CameraDescriptionJsonConverter();
  @override
  CameraDescription? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return CameraDescription(
        name: json['name'] as String ?? '',
        lensDirection: CameraLensDirection.values
            .byName(json['lenseDirection'] as String? ?? "front"),
        sensorOrientation: json['sensorOrientation'] as int? ?? 0);
  }

  @override
  Map<String, dynamic>? toJson(CameraDescription? object) {
    if (object == null) return null;
    return {
      'name': object.name,
      'lenseDirection': object.lensDirection.name,
      'sensorOrientation': object.sensorOrientation
    };
  }
}

class CameraValueJsonConverter extends JsonConverter<CameraValue, String> {
  const CameraValueJsonConverter();
  @override
  CameraValue fromJson(String json) {
    return CameraValue.uninitialized(uninitializedCameraDescription);
  }

  @override
  String toJson(CameraValue object) {
    return object.toString();
  }
}

class CameraExceptionJsonConverter
    extends JsonConverter<CameraException?, Map<String, String?>?> {
  const CameraExceptionJsonConverter();
  @override
  CameraException? fromJson(Map<String, String?>? json) {
    if (json == null) return null;
    return CameraException(json['code'] ?? '', json['description'] ?? '');
  }

  @override
  Map<String, String?>? toJson(CameraException? object) {
    if (object == null) return null;
    return {
      'code': object.code,
      'description': object.description,
    };
  }
}

final CameraException noException = CameraException('', ''); 

@JsonSerializable(checked: true)
class CameraServiceValue extends Equatable {
  const CameraServiceValue(this.camera, this.controllerValue,
      {this.requestOrientation,
      this.cameraError,
      this.cameraId,
      this.cameraSelectorStatus = CameraStatus.uninitialized});
  const CameraServiceValue.uninitialized()
      : this(null,
            const CameraValue.uninitialized(uninitializedCameraDescription));
  @CameraDescriptionJsonConverter()
  final CameraDescription? camera;
  @CameraValueJsonConverter()
  final CameraValue controllerValue;
  final Orientation? requestOrientation;
  @CameraExceptionJsonConverter()
  final CameraException? cameraError;
  final int? cameraId;
  final CameraStatus? cameraSelectorStatus;
  Map<String, dynamic> toJson() => _$CameraServiceValueToJson(this);
  factory CameraServiceValue.fromJson(Map<String, dynamic> json) =>
      _$CameraServiceValueFromJson(json);

  CameraServiceValue copyWith(
      {CameraDescription? camera,
      CameraValue? controllerValue,
      Orientation? requestOrientation,
      CameraException? cameraError,
      int? cameraId,
      CameraStatus? cameraSelectorStatus}) {
    return CameraServiceValue(
        camera ?? this.camera, controllerValue ?? this.controllerValue,
        requestOrientation: requestOrientation ?? this.requestOrientation,
        cameraError: cameraError != null
          ? ((cameraError.code == noException.code && cameraError.description == noException.description) ? null : cameraError) :
           this.cameraError,
        cameraId: cameraId ?? this.cameraId,
        cameraSelectorStatus:
            cameraSelectorStatus ?? this.cameraSelectorStatus);
  }

  @override
  List<Object?> get props => [
        camera?.name,
        camera?.lensDirection,
        camera?.sensorOrientation,
        controllerValue.isInitialized,
        controllerValue.hasError,
        controllerValue.description.name,
        controllerValue.description.lensDirection,
        controllerValue.description.sensorOrientation,
        requestOrientation,
        cameraError,
        controllerValue.isPreviewPaused,
        cameraId,
        cameraSelectorStatus,
        controllerValue.deviceOrientation
      ];
}
