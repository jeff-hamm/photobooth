import 'dart:io';

import 'package:flutter/material.dart';
import 'package:io_photobooth/photobooth/photobooth.dart';
import 'package:provider/provider.dart';

/// {@template preview_image}
/// A wrapper around [Image.memory]
/// {@endtemplate}
class PreviewAiImage extends StatelessWidget {
  /// {@macro preview_image}
  const PreviewAiImage({
    this.height,
    this.width,
    super.key,
  });

  /// [double?] representing the height of the image
  final double? height;

  /// [double?] representing the width of the image
  final double? width;

  @override
  Widget build(BuildContext context) {
    final image = context.watch<PhotoboothBloc>().state.selectedImage;
    return LayoutBuilder(builder: (context, constraints) {
      return image.toImage(width, height);
      // if (isNetworkImage(image)) {
      //   return Image.network(image,
      //       filterQuality: FilterQuality.high,
      //       isAntiAlias: true,
      //       fit: BoxFit.cover,
      //       height: height,
      //       width: width, 
      //       errorBuilder: (context, error, stackTrace) {
      //     return Text(
      //       '$error, $stackTrace',
      //       key: const Key('previewImage_errorText'),
      //     );
      //   });
      // } else {
      //   return Image.file(File(image),
      //       filterQuality: FilterQuality.high,
      //       isAntiAlias: true,
      //       fit: BoxFit.cover,
      //       height: height,
      //       width: width, errorBuilder: (context, error, stackTrace) {
      //     return Text(
      //       '$error, $stackTrace',
      //       key: const Key('previewImage_errorText'),
      //     );
      //   });
//      }
    });
  }
}
