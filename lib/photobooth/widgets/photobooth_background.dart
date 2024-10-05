import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:io_photobooth/common/booth_background_image.dart';

class PhotoboothBackground extends StatelessWidget {
  const PhotoboothBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      fit: StackFit.expand,
      children: [
        const BoothBackgroundImage(),
        // Positioned(
        //   left: 50,
        //   bottom: size.height * 0.2,
        //   child: Image.asset(
        //     'assets/backgrounds/red_box.png',
        //     height: 150,
        //   ),
        // ),
        // Positioned(
        //   right: -50,
        //   top: size.height * 0.1,
        //   child: Image.asset(
        //     'assets/backgrounds/blue_circle.png',
        //     height: 150,
        //   ),
        // ),
        // Positioned(
        //   right: 50,
        //   bottom: size.height * 0.1,
        //   child: Image.asset(
        //     'assets/backgrounds/yellow_plus.png',
        //     height: 150,
        //   ),
        // ),
      ],
    );
  }
}
