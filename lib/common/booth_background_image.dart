import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:io_photobooth/common/image_color_switcher.dart';
import 'package:io_photobooth/common/widgets.dart';

class BoothBackgroundImage extends StatelessWidget {
    const BoothBackgroundImage({super.key});
  Widget build(BuildContext context) {
    return 
    ImageFiltered(imageFilter: ImageFilter.blur(
sigmaX: 5,
sigmaY: 5
    ),
    enabled: true,
    child: Image.asset(
          'assets/backgrounds/photobooth_background.jpg',

//          repeat: ImageRepeat.repeatY,
          fit: BoxFit.cover,
 
          filterQuality: FilterQuality.high,

        ));

  }
}
