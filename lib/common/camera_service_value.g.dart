// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'camera_service_value.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CameraServiceValue _$CameraServiceValueFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'CameraServiceValue',
      json,
      ($checkedConvert) {
        final val = CameraServiceValue(
          $checkedConvert(
              'camera',
              (v) => const CameraDescriptionJsonConverter()
                  .fromJson(v as Map<String, dynamic>?)),
          $checkedConvert('controllerValue',
              (v) => const CameraValueJsonConverter().fromJson(v as String)),
          requestOrientation: $checkedConvert('requestOrientation',
              (v) => $enumDecodeNullable(_$OrientationEnumMap, v)),
          cameraError: $checkedConvert(
              'cameraError',
              (v) => const CameraExceptionJsonConverter()
                  .fromJson(v as Map<String, String?>?)),
          cameraId: $checkedConvert('cameraId', (v) => (v as num?)?.toInt()),
          cameraSelectorStatus: $checkedConvert(
              'cameraSelectorStatus',
              (v) =>
                  $enumDecodeNullable(_$CameraStatusEnumMap, v) ??
                  CameraStatus.uninitialized),
        );
        return val;
      },
    );

Map<String, dynamic> _$CameraServiceValueToJson(CameraServiceValue instance) =>
    <String, dynamic>{
      'camera': const CameraDescriptionJsonConverter().toJson(instance.camera),
      'controllerValue':
          const CameraValueJsonConverter().toJson(instance.controllerValue),
      'requestOrientation': _$OrientationEnumMap[instance.requestOrientation],
      'cameraError':
          const CameraExceptionJsonConverter().toJson(instance.cameraError),
      'cameraId': instance.cameraId,
      'cameraSelectorStatus':
          _$CameraStatusEnumMap[instance.cameraSelectorStatus],
    };

const _$OrientationEnumMap = {
  Orientation.portrait: 'portrait',
  Orientation.landscape: 'landscape',
};

const _$CameraStatusEnumMap = {
  CameraStatus.uninitialized: 'uninitialized',
  CameraStatus.available: 'available',
  CameraStatus.unavailable: 'unavailable',
};
