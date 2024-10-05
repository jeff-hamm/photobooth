import 'package:flutter/material.dart';
import 'package:io_photobooth/common/widgets.dart';

class AnimatedDash extends AnimatedSprite {
  const AnimatedDash({super.key})
      : super(
          loadingIndicatorColor: PhotoboothColors.accent,
          sprites: const Sprites(
            asset: 'dash_spritesheet.png',
            size: Size(650, 587),
            frames: 25,
            stepTime: 2 / 25,
          ),
        );
}
