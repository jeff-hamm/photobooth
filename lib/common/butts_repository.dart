import 'package:path/path.dart' as p;
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:io_photobooth/common/gradio.dart';
import 'package:photobooth_ui/photobooth_ui.dart';
import './photos_repository.dart';
import 'package:http_parser/http_parser.dart';
import 'package:js/js_util.dart';
import 'dart:async';
import '../config.dart' as config;
enum ImageType {
    controlNet,
    upload,
    output,
    infinite,
    camera,
    temp,
    thumbnail
}
class ButtsPhotosRepository extends PhotosRepository<String> {
  ButtsPhotosRepository({
    super.imageCompositor,
  });

  @override
  String getFileReference(String fileName) {
    return fileName;
  }
  
  @override
  Future<bool> photoExists(String reference) async {
      return false;
  }
  
  Future<String> uploadPhoto(String fileName, Uint8List data) async {
    final path = await _uploadPhotoInternal(fileName, data);
    if(config.EnableAi) {
      generateAi(path, data);
    }
    return path;
  }

  Future<String> _uploadPhotoInternal(String fileName, Uint8List data, {String? prompt=null,ImageType? imageType=null, String? inputImage=null}) async {
    try {
      final request = http.MultipartRequest("POST",config.ShareUrl)
          ..fields['code'] = UniqueKey().toString();
      if(imageType != null) {
          request.fields['imageType'] = imageType.toString().split('.').last; 
      }
      if(inputImage != null) {
          request.fields['inputImage'] = inputImage;
      }
      if(prompt != null) {
          request.fields['prompt'] = config.AiPrompt;
      }
      request.files.add(http.MultipartFile.fromBytes('file',data,filename: fileName,
        contentType: MediaType('image', 'jpeg')));
      final response = await http.Response.fromStream(await request.send());
      final uploadResult = jsonDecode(response.body) as Map<String, dynamic>;
      final path = response.headers['location'] ?? config.ImageServer + "/" + uploadResult['path'].toString().replaceAll(RegExp(r'\\'),'/')
       ?? config.ImageServer + "/" + fileName;
       // fire and forget
       return path;
    } catch (e, st) {
      throw UploadPhotoException(
        'Uploading photo failed. '
        'Error: $e. StackTrace: $st',
      );
    }

  }

  Future<List<String>> generateAi(String fileName, Uint8List data) async {
    gradio.configure(config.GradioUrl);
    final images = ((await promiseToFuture(gradio.generate(fileName, config.AiPrompt, config.AiPrompt))) as List<dynamic>).map((v) => v as String).toList();
    for(final image in images) {
      final ext = p.extension(image);
      Uint8List bytes = (await http.get(Uri.parse(image))).bodyBytes;

      await _uploadPhotoInternal(shortHash(UniqueKey()) + ext, bytes,prompt:config.AiPrompt, inputImage: fileName);
    }
    // await showAppModal(context: context, 
    //   portraitChild: Image.network(images[0] as String), 
    //   landscapeChild: Image.network(images[0] as String),
    // );
    return images;
  }
  
  @override
  String getSharePhotoUrl(String ref) => ref;
}

class UploadResult
{
    String? hash;
    String? path;
    String? error;
    bool uploaded =false;
}