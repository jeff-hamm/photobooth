import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:io_photobooth/common/camera_image_blob.dart';
import 'package:io_photobooth/photopicker/image_picker_file.dart';
import 'package:multi_image_picker_view/multi_image_picker_view.dart';
import 'package:path/path.dart' as p;
import '../../config.dart' as config;

class ImagePath extends Equatable {
  const ImagePath(this._path,
      {required this.imageId, Uri? uri, this.width, this.height, this.aiPrompt})
      : _uri = uri;
  final String imageId;
  final String _path;
  final Uri? _uri;
  final double? width;
  final double? height;
  static const ImagePath empty = const ImagePath('', imageId: '');
  static const ImagePath loading = const ImagePath('', imageId: 'loading');

  static ImagePath from(CameraImageBlob path, {String? imageId}) {
    return path.data.copyWith(imageId: imageId);
  }

  static ImagePath parse(String path,
      {String? imageId, double? width, double? height}) {
    final uri = Uri.tryParse(path);

    return ImagePath(path,
        width: width,
        height: height,
        uri: uri,
        imageId: imageId ?? shortHash(UniqueKey()));
  }

  ImagePath copyWith({String? path, String? imageId}) {
    return ImagePath(path ?? _path,
        imageId: imageId ?? this.imageId,
        aiPrompt: aiPrompt,
        height: height,
        uri: _uri,
        width: width);
  }

  Widget toImage(double? width, double? height) {
    if (isEmpty) {
      return SizedBox(width: width, height: height);
    }
    if (isNetwork) {
      return Image.network(_path,
          filterQuality: FilterQuality.high,
          isAntiAlias: true,
          fit: BoxFit.cover,
          height: height,
          width: width, errorBuilder: (context, error, stackTrace) {
        return Text(
          '$error, $stackTrace',
          key: const Key('previewImage_errorText'),
        );
      });
    } else {
      return Image.file(File(_path),
          filterQuality: FilterQuality.high,
          isAntiAlias: true,
          fit: BoxFit.cover,
          height: height,
          width: width, errorBuilder: (context, error, stackTrace) {
        return Text(
          '$error, $stackTrace',
          key: const Key('previewImage_errorText'),
        );
      });
    }
  }

//  Uint8List? _bytes;
  Future<Uint8List> toBytes() async {
    // if(_bytes != null) {
    //   return _bytes!;
    // }
    if (isFile) {
      //return _bytes =
      return await File(_path).readAsBytes();
    }
    if (isDataUrl) {
      return _toDataUrlBytes();
    }
    if (_uri == null) {
      throw Exception('Cannot convert to bytes');
    }
    final response = await http.get(_uri!);
    if (response.statusCode != 200) {
      throw Exception(
          'Failed to load image: ${response.statusCode}, ${response.body}');
    }
    return response.bodyBytes;
  }

  bool get isEmpty => _path.isEmpty;
  bool get isNotEmpty => !isEmpty;
  bool get isBlob => _uri?.scheme == 'blob';
  bool get isDataUrl => _uri?.scheme == 'data';
  bool get isFile => !isNetwork;
  bool get isNetwork => _uri?.host.isNotEmpty == true || isDataUrl || isBlob;

  @override
  // TODO: implement props
  List<Object?> get props => [_path];

  String get fileExtension => isDataUrl && _uri != null
      ? ".${_path.split(';').first.split('/').last}"
      : p.extension(_path).isNotEmpty
          ? p.extension(_path)
          : ".${config.CameraImageFormat.name}";

  String get path => _path;

  final String? aiPrompt;
  String? toFilePath() {
    if (isFile) {
      return _path;
    }
    return null;
  }

  String toFileName() {
    return '${imageId}${fileExtension}';
  }

  Future<String> toNetworkUrl() async {
    if (isFile || isBlob) {
      return bytesToDataUrl(await toBytes(),
          imageType: fileExtension.substring(1));
    }
    return _path;
  }

  static String bytesToDataUrl(Uint8List data, {String? imageType}) {
    return 'data:image/${imageType ?? config.CameraImageFormat.name};base64,${base64Encode(data)}';
  }

  static ImagePath fromData(Uint8List data, {String? imageType}) {
    return ImagePath.parse(bytesToDataUrl(data, imageType: imageType));
  }

  Uint8List _toDataUrlBytes() {
    return base64Decode(_path.split(';').last.split(',').last);
  }
}
