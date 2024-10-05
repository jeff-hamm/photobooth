import 'package:flutter/material.dart';
import 'package:io_photobooth/common/widgets.dart';

class AnimatedAndroid extends AnimatedSprite {
  const AnimatedAndroid({super.key})
      : super(
          loadingIndicatorColor: PhotoboothColors.green,
          sprites: const Sprites(
            asset: 'android_spritesheet.png',
            size: Size(450, 658),
            frames: 25,
            stepTime: 2 / 25,
          ),
        );
}
