import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:io_photobooth/common/models/ImagePath.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../config.dart' as cofig;

part 'serverless.g.dart';

@JsonSerializable(checked: true)
class ImageResult {
  ImageResult();
  List<String>? images;
  int? seed;
  Map<String, dynamic>? args;

  Map<String, dynamic> toJson() => _$ImageResultToJson(this);
  factory ImageResult.fromJson(Map<String, dynamic> json) =>
      _$ImageResultFromJson(json);
}

@JsonSerializable(checked: true)
class RunpodResponse {
  RunpodResponse();
  int? delayTime;
  int? executionTime;
  String? id;
  String? status;
  @JsonKey(name: "output", fromJson: mapOutput)
  ImageResult? output;
//  GenerateImageReponse? output;
  Map<String, dynamic> toJson() => _$RunpodResponseToJson(this);
  factory RunpodResponse.fromJson(Map<String, dynamic> json) =>
      _$RunpodResponseFromJson(json);
}

ImageResult mapOutput(Object value) {
  if (value is String) {
    return ImageResult()..images = [value];
  }
  if (value is Iterable<String>) {
    return ImageResult()..images = value.toList();
  }
  if (value is Map<String, dynamic>) {
    return ImageResult.fromJson(value);
  }
  // if (value is Iterable<Map<String, dynamic>>) {
  //   return value.map(ImageResult.fromJson).toList();
  // }

  throw ArgumentError.value(value, 'value', 'Invalid value for output');
}

@JsonSerializable(checked: true)
class GenerateImageReponse {
  GenerateImageReponse();
  List<String> images = [];
  String? image_url;
  int? seed;
  Map<String, dynamic> toJson() => _$GenerateImageReponseToJson(this);
  factory GenerateImageReponse.fromJson(Map<String, dynamic> json) =>
      _$GenerateImageReponseFromJson(json);
}

@JsonSerializable(includeIfNull: false)
class GenerateApiRequest {
  GenerateApiRequest(
    this.image_id,
    this.prompt, {
    this.negative_prompt,
    this.image_url,
    this.use_refiner,
    this.controlnet_type,
    this.controlnet_image_resolution,
  });
  String? type;
  String image_id;
  final String prompt;
  String? image_url;
  String? negative_prompt;
  int? height;
  int? width;
  int? num_inference_steps;
  int? refiner_inference_steps;
  double? guidance_scale;
  double? strength;
  int? num_images;
  String? model_type;
  bool? use_refiner;
  String? controlnet_type;
  int? controlnet_image_resolution;
  int? controlnet_low_threshold;
  int? controlnet_high_threshold;
  double? controlnet_conditioning_scale;
  Map<String, dynamic> toJson() => _$GenerateApiRequestToJson(this);
  factory GenerateApiRequest.fromJson(Map<String, dynamic> json) =>
      _$GenerateApiRequestFromJson(json);
}

@JsonSerializable(includeIfNull: false)
class GenerateControlnetApiRequest {
  GenerateControlnetApiRequest(
      {this.model = "canny", this.conditioning_scale = 0.5});
  final String model;
  final double? conditioning_scale;
  int? image_resolution;
  int? low_threshold;
  int? high_threshold;
  Map<String, dynamic> toJson() => _$GenerateControlnetApiRequestToJson(this);
  factory GenerateControlnetApiRequest.fromJson(Map<String, dynamic> json) =>
      _$GenerateControlnetApiRequestFromJson(json);
}

GenerateHandlerApi _aiGenerator =
    GenerateHandlerApi(cofig.ServerlessEndpoint, cofig.ServerlessToken);

GenerateHandlerApi get aiGenerator => _aiGenerator;

class GenerateHandlerApi {
  const GenerateHandlerApi(this.baseUri, this.token);
  final String baseUri;
  final String? token;
  void configure(String uri, String token) {}
  Future<List<ImagePath>> generate(
      String? imageId, ImagePath image, String prompt, String negative) async {
    imageId ??= shortHash(UniqueKey());
    final request = GenerateApiRequest(imageId, prompt,
        image_url: await image.toNetworkUrl(), negative_prompt: negative);
    final requestBody =
        jsonEncode(<String, dynamic>{'input': request.toJson()});
    log('Posting to ${baseUri}, with token ${token} and');
    try {
      final response = await http.post(Uri.parse(baseUri),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
          body: requestBody);
      log('Response statusCode ${response.statusCode} and body: ${response.body.length}');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Successful POST request, handle the response here
        final responseData = RunpodResponse.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>);
        if (responseData.status == "COMPLETED") {
          return responseData.output?.images?.map(ImagePath.parse).toList() ??
              [];
        }
      }
    } catch (e) {
      log('Error posting: ${e}');
      rethrow;
    }

    // If the server returns an error response, throw an exception
    throw Exception('Failed to post data');
  }
}
