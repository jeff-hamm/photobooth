import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:io_photobooth/common/models/ImagePath.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;
//import 'package:io_photobooth/common/gradio.dart';
import 'package:io_photobooth/common/serverless.dart';
import 'package:io_photobooth/common/widgets.dart';
import './photos_repository.dart';
import 'package:http_parser/http_parser.dart';
// import 'package:js/js_util.dart';
import 'dart:async';
import '../config.dart' as config;
enum ImageType {
    controlNet,
    upload,
    output,
    infinite,
    camera,
    temp,
    thumbnail,
    photo
}
class ButtsPhotosRepository extends PhotosRepository<ImagePath> {
  ButtsPhotosRepository({
    super.imageCompositor,
  });

  @override
  ImagePath getFileReference(String fileName) {
    return ImagePath.parse(fileName);
  }
  
  @override
  Future<bool> photoExists(ImagePath reference) async {
      return false;
  }
  
  Future<ImagePath> uploadPhoto(String imageId, ImagePath fileName, Uint8List data) async {
    final path = await _uploadPhotoInternal(fileName,imageType: config.DefaultImageType, data, imageId: imageId);
    return path;
  }

  Future<ImagePath> _uploadPhotoInternal(ImagePath fileName, Uint8List data, {String? imageId=null, String? prompt=null,ImageType? imageType=null, String? inputImage=null}) async {
    try {
      final request = http.MultipartRequest("POST",config.ShareUrl)
          ..fields['code'] = imageId ?? UniqueKey().toString();
      if(imageType != null) {
          request.fields['imageType'] = imageType.toString().split('.').last; 
      }
      if(inputImage != null) {
          request.fields['inputImage'] = inputImage;
      }
      if(prompt != null) {
          request.fields['prompt'] = prompt;
      }
      request.files.add(http.MultipartFile.fromBytes('file',data,filename: fileName.toFileName(),
        contentType: MediaType('image', 'jpeg')));
      final response = await http.Response.fromStream(await request.send());
      final uploadResult = jsonDecode(response.body) as Map<String, dynamic>;
      final path = config.ImageServer + "/" + uploadResult['path'].toString().replaceAll(RegExp(r'\\'),'/');
       // fire and forget
       return ImagePath.parse(path);
    } catch (e, st) {
      throw UploadPhotoException(
        'Uploading photo failed. '
        'Error: $e. StackTrace: $st',
      );
    }

  }
  @override
  Future<List<ImagePath>> generateAiPhoto({
    required ImagePath? imagePath, 
    required String prompt, required String negative,
    String? imageId, 
    Uint8List? data, 
    }) async{
    aiGenerator.configure(config.GradioUrl, config.ServerlessToken);
    if(imagePath == null) {
      if(data == null) {
        throw ArgumentError('Either imageUrl or data must be provided');
      }
      imagePath ??= ImagePath.fromData(data);
    }
//    final images = ((await promiseToFuture(aiGenerator.generate(fileName, prompt,negative))) as List<dynamic>).map((v) => v as String).toList();
    final images = await aiGenerator.generate(imageId,imagePath, prompt,negative);
    // await showAppModal(context: context, 
    //   portraitChild: Image.network(images[0] as String), 
    //   landscapeChild: Image.network(images[0] as String),
    // );
    return images;
  }
  
  @override
  String getSharePhotoUrl(ImagePath ref) => config.ImageServer + "/" + ref.toFileName();
}

class UploadResult
{
    String? hash;
    String? path;
    String? error;
    bool uploaded =false;
}