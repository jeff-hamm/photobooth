
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import './photos_repository.dart';
import 'package:http_parser/http_parser.dart';

import '../config.dart' as config;
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
    try {
      final request = http.MultipartRequest("POST",config.ShareUrl);
      request.files.add(http.MultipartFile.fromBytes('file',data,filename: fileName,
        contentType: MediaType('image', 'jpeg')));
      final response = await http.Response.fromStream(await request.send());
      final uploadResult = jsonDecode(response.body) as Map<String, dynamic>;
      return response.headers['location'] ?? config.ImageServer + "/" + uploadResult['path'].toString().replaceAll(RegExp(r'\\'),'/')
       ?? config.ImageServer + "/" + fileName;
    } catch (e, st) {
      throw UploadPhotoException(
        'Uploading photo failed. '
        'Error: $e. StackTrace: $st',
      );
    }
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