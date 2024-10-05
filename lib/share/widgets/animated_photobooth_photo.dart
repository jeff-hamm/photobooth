import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:io_photobooth/common/camera_image_blob.dart';
import 'package:io_photobooth/common/theme.dart';
import 'package:io_photobooth/photobooth/photobooth.dart';
import 'package:io_photobooth/common/models/ImagePath.dart';
import 'package:io_photobooth/common/widgets.dart';


class AnimatedPhotoboothPhoto extends StatefulWidget {
  const AnimatedPhotoboothPhoto({
    required this.image,
    super.key,
  });

  final ImagePath? image;

  @override
  State<AnimatedPhotoboothPhoto> createState() =>
      _AnimatedPhotoboothPhotoState();
}

class _AnimatedPhotoboothPhotoState extends State<AnimatedPhotoboothPhoto> {
  late final Timer timer;
  var _isPhotoVisible = false;

  @override
  void initState() {
    super.initState();

    timer = Timer(const Duration(seconds: 2), () {
      setState(() {
        _isPhotoVisible = true;
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final aspectRatio = context.select(
      (PhotoboothBloc bloc) => bloc.state.aspectRatio,
    );
    if(widget.image == null) {
      return const SizedBox();
    }
    if (aspectRatio <= PhotoboothAspectRatio.portrait) {
      return AnimatedPhotoboothPhotoPortrait(
        isPhotoVisible: _isPhotoVisible,
      );
    } else {
      return AnimatedPhotoboothPhotoLandscape(
        isPhotoVisible: _isPhotoVisible,
      );
    }
  }
}

@visibleForTesting
class AnimatedPhotoboothPhotoLandscape extends StatelessWidget {
  const AnimatedPhotoboothPhotoLandscape({
    required this.isPhotoVisible,
    super.key,
  });

  final bool isPhotoVisible;

  static const sprite = AnimatedSprite(
    mode: AnimationMode.oneTime,
    sprites: Sprites(
      asset: 'photo_frame_spritesheet_landscape.jpg',
      size: Size(1308, 1038),
      frames: 19,
      stepTime: 2 / 19,
    ),
    showLoadingIndicator: false,
  );
  static const aspectRatio = PhotoboothAspectRatio.landscape;
  static const left = 129.0;
  static const top = 88.0;
  static const right = 118.0;
  static const bottom = 154.0;

  @override
  Widget build(BuildContext context) {
    final scaleX = (double scaleX) => scaleX * 1.34;



    final smallPhoto = _AnimatedPhotoboothPhoto(
      aspectRatio: aspectRatio,
      isPhotoVisible: isPhotoVisible,
      sprite: sprite,
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      scaleX: scaleX(0.33),
      scaleY: 0.33,
    );
    final mediumPhoto = _AnimatedPhotoboothPhoto(
      aspectRatio: aspectRatio,
      isPhotoVisible: isPhotoVisible,
      sprite: sprite,
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      scaleX: scaleX(0.47),
      scaleY: 0.47,
    );
    final largePhoto = _AnimatedPhotoboothPhoto(
      aspectRatio: aspectRatio,
      isPhotoVisible: isPhotoVisible,
      sprite: sprite,
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      scaleX: scaleX(0.6),
      scaleY: 0.6,
    );
    final xLargePhoto = _AnimatedPhotoboothPhoto(
      aspectRatio: aspectRatio,
      isPhotoVisible: isPhotoVisible,
      sprite: sprite,
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      scaleX: scaleX(0.7),
      scaleY: 0.7,
    );

    return ResponsiveLayoutBuilder(
      small: (context, _) => smallPhoto,
      medium: (context, _) => mediumPhoto,
      large: (context, _) => largePhoto,
      xLarge: (context, _) => xLargePhoto,
    );
  }
}

@visibleForTesting
class AnimatedPhotoboothPhotoPortrait extends StatelessWidget {
  const AnimatedPhotoboothPhotoPortrait({
    required this.isPhotoVisible,
    super.key,
  });

  final bool isPhotoVisible;

  static const sprite = AnimatedSprite(
    mode: AnimationMode.oneTime,
    sprites: Sprites(
      asset: 'photo_frame_spritesheet_portrait.png',
      size: Size(520, 698),
      frames: 38,
      stepTime: 0.05,
    ),
    showLoadingIndicator: false,
  );
  static const aspectRatio = PhotoboothAspectRatio.portrait;
  static const left = 93.0;
  static const top = 120.0;
  static const right = 79.0;
  static const bottom = 107.0;

  @override
  Widget build(BuildContext context) {
    final scaleY = (double scaleX) => scaleX * 1.34;
    final smallPhoto = _AnimatedPhotoboothPhoto(
      aspectRatio: aspectRatio,
      isPhotoVisible: isPhotoVisible,
      sprite: sprite,
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      scaleX: 0.8,
      scaleY: scaleY(0.8),
    );
    final largePhoto = _AnimatedPhotoboothPhoto(
      aspectRatio: aspectRatio,
      isPhotoVisible: isPhotoVisible,
      sprite: sprite,
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      scaleX: 1.6,
      scaleY: scaleY(1.6),
    );
    return ResponsiveLayoutBuilder(
      small: (context, _) => smallPhoto,
      large: (context, _) => largePhoto,
    );
  }
}

class _AnimatedPhotoboothPhoto extends StatelessWidget {
  const _AnimatedPhotoboothPhoto({
    required this.sprite,
    required this.isPhotoVisible,
    required this.aspectRatio,
    this.top = 0.0,
    this.left = 0.0,
    this.right = 0.0,
    this.bottom = 0.0,
    this.scaleX = 1.0,
    this.scaleY = 1.0,
  });

  final AnimatedSprite sprite;
  final bool isPhotoVisible;
  final double aspectRatio;
  final double top;
  final double left;
  final double right;
  final double bottom;
  final double scaleX;
  final double scaleY;

  @override
  Widget build(BuildContext context) {
    final newHeight = sprite.sprites.size.height * scaleY;
    final newInsideHeight = (sprite.sprites.size.height - (top+bottom)) * scaleY;
    final newWidth = sprite.sprites.size.width * scaleX;
    final newInsideWidth = (sprite.sprites.size.width - (left+right)) * scaleX;
    final newTop = (newHeight-newInsideHeight)/2;
    final newLeft = (newWidth-newInsideWidth)/2;
    final mediaSize = MediaQuery.of(context).size;
    final scale = mediaSize.width / newWidth;
    return 
      Transform.scale(
        scale: scale,
    child:Stack(
        fit: StackFit.loose,
        alignment: Alignment.center,
        children: [
          Transform.scale(
            scaleX: scaleX,
            scaleY: scaleY,
          child: SizedBox(
            width: sprite.sprites.size.width,
            height: sprite.sprites.size.height,
              child: sprite,
              // width: newWidth,
              // height: newHeight
            )),
            Align(alignment: Alignment(0, -.05),
            child:SizedBox(
              child: AnimatedOpacity(
                duration: const Duration(seconds: 2),
                opacity: isPhotoVisible ? 1 : 0,
                child: PhotoboothPhoto()
              ),
              // top: newTop,
              // left: newLeft,
              width: newInsideWidth,
              height: newInsideHeight
            ))
          ]
          )
      )
      ;
  }
}
