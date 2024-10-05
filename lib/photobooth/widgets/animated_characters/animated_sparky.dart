import 'package:flutter/material.dart';
import 'package:io_photobooth/common/widgets.dart';

class AnimatedSparky extends AnimatedSprite {
  const AnimatedSparky({super.key})
      : super(
          loadingIndicatorColor: PhotoboothColors.red,
          sprites: const Sprites(
            asset: 'sparky_spritesheet.png',
            size: Size(730, 588),
            frames: 25,
            stepTime: 2 / 25,
          ),
        );
}
