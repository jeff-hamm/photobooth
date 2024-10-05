import 'package:flutter/material.dart';
import 'package:io_photobooth/photobooth/photobooth.dart';
import 'package:io_photobooth/stickers/widgets/preview_image.dart';
import 'package:io_photobooth/common/widgets.dart';

/// A widget that displays [CharactersLayer] and [StickersLayer] on top of
/// the raw [image] took from the camera.
class PhotoboothPhoto extends StatelessWidget {
  const PhotoboothPhoto({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        PreviewAiImage(),
        const CharactersLayer(),
        const StickersLayer(),
      ],
    );
  }
}
