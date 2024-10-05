// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'serverless.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RunpodResponse _$RunpodResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'RunpodResponse',
      json,
      ($checkedConvert) {
        final val = RunpodResponse();
        $checkedConvert(
            'delayTime', (v) => val.delayTime = (v as num?)?.toInt());
        $checkedConvert(
            'executionTime', (v) => val.executionTime = (v as num?)?.toInt());
        $checkedConvert('id', (v) => val.id = v as String?);
        $checkedConvert('status', (v) => val.status = v as String?);
        $checkedConvert(
            'output',
            (v) => val.output =
                (v as List<dynamic>?)?.map((e) => e as String).toList());
        return val;
      },
    );

Map<String, dynamic> _$RunpodResponseToJson(RunpodResponse instance) =>
    <String, dynamic>{
      'delayTime': instance.delayTime,
      'executionTime': instance.executionTime,
      'id': instance.id,
      'status': instance.status,
      'output': instance.output,
    };

GenerateImageReponse _$GenerateImageReponseFromJson(
        Map<String, dynamic> json) =>
    $checkedCreate(
      'GenerateImageReponse',
      json,
      ($checkedConvert) {
        final val = GenerateImageReponse();
        $checkedConvert(
            'images',
            (v) => val.images =
                (v as List<dynamic>).map((e) => e as String).toList());
        $checkedConvert('image_url', (v) => val.image_url = v as String?);
        $checkedConvert('seed', (v) => val.seed = (v as num?)?.toInt());
        return val;
      },
    );

Map<String, dynamic> _$GenerateImageReponseToJson(
        GenerateImageReponse instance) =>
    <String, dynamic>{
      'images': instance.images,
      'image_url': instance.image_url,
      'seed': instance.seed,
    };

GenerateApiRequest _$GenerateApiRequestFromJson(Map<String, dynamic> json) =>
    GenerateApiRequest(
      json['image_id'] as String,
      json['prompt'] as String,
      negative_prompt: json['negative_prompt'] as String?,
      image_url: json['image_url'] as String?,
      use_refiner: json['use_refiner'] as bool?,
      controlnet_type: json['controlnet_type'] as String?,
      controlnet_image_resolution:
          (json['controlnet_image_resolution'] as num?)?.toInt(),
    )
      ..type = json['type'] as String?
      ..height = (json['height'] as num?)?.toInt()
      ..width = (json['width'] as num?)?.toInt()
      ..num_inference_steps = (json['num_inference_steps'] as num?)?.toInt()
      ..refiner_inference_steps =
          (json['refiner_inference_steps'] as num?)?.toInt()
      ..guidance_scale = (json['guidance_scale'] as num?)?.toDouble()
      ..strength = (json['strength'] as num?)?.toDouble()
      ..num_images = (json['num_images'] as num?)?.toInt()
      ..model_type = json['model_type'] as String?
      ..controlnet_low_threshold =
          (json['controlnet_low_threshold'] as num?)?.toInt()
      ..controlnet_high_threshold =
          (json['controlnet_high_threshold'] as num?)?.toInt()
      ..controlnet_conditioning_scale =
          (json['controlnet_conditioning_scale'] as num?)?.toDouble();

Map<String, dynamic> _$GenerateApiRequestToJson(GenerateApiRequest instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('type', instance.type);
  val['image_id'] = instance.image_id;
  val['prompt'] = instance.prompt;
  writeNotNull('image_url', instance.image_url);
  writeNotNull('negative_prompt', instance.negative_prompt);
  writeNotNull('height', instance.height);
  writeNotNull('width', instance.width);
  writeNotNull('num_inference_steps', instance.num_inference_steps);
  writeNotNull('refiner_inference_steps', instance.refiner_inference_steps);
  writeNotNull('guidance_scale', instance.guidance_scale);
  writeNotNull('strength', instance.strength);
  writeNotNull('num_images', instance.num_images);
  writeNotNull('model_type', instance.model_type);
  writeNotNull('use_refiner', instance.use_refiner);
  writeNotNull('controlnet_type', instance.controlnet_type);
  writeNotNull(
      'controlnet_image_resolution', instance.controlnet_image_resolution);
  writeNotNull('controlnet_low_threshold', instance.controlnet_low_threshold);
  writeNotNull('controlnet_high_threshold', instance.controlnet_high_threshold);
  writeNotNull(
      'controlnet_conditioning_scale', instance.controlnet_conditioning_scale);
  return val;
}

GenerateControlnetApiRequest _$GenerateControlnetApiRequestFromJson(
        Map<String, dynamic> json) =>
    GenerateControlnetApiRequest(
      model: json['model'] as String? ?? "canny",
      conditioning_scale:
          (json['conditioning_scale'] as num?)?.toDouble() ?? 0.5,
    )
      ..image_resolution = (json['image_resolution'] as num?)?.toInt()
      ..low_threshold = (json['low_threshold'] as num?)?.toInt()
      ..high_threshold = (json['high_threshold'] as num?)?.toInt();

Map<String, dynamic> _$GenerateControlnetApiRequestToJson(
    GenerateControlnetApiRequest instance) {
  final val = <String, dynamic>{
    'model': instance.model,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('conditioning_scale', instance.conditioning_scale);
  writeNotNull('image_resolution', instance.image_resolution);
  writeNotNull('low_threshold', instance.low_threshold);
  writeNotNull('high_threshold', instance.high_threshold);
  return val;
}
