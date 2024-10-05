import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:io_photobooth/common/camera_service.dart';
import 'package:io_photobooth/common/layout/aspect_builder.dart';


class MediaSizeClipper extends StatelessWidget {
  MediaSizeClipper({
    required this.child,
    required this.aspectRatio,
    Key? key=null,
    this.alignment=Alignment.topCenter,
  }) : super(key: key);  
  
  final Widget child;
  final double aspectRatio;
  final Alignment alignment;
 
  @override
  Widget build(BuildContext context) {
    return AspectBuilder(builder: (context, orientation, newRatio, isNew) {
      final screenSize = MediaQuery.of(context).size;
      final sizeFit = context
          .read<CameraService>()
          .calculateMediaSize(screenSize, aspectRatio);
      final mediaSize = sizeFit.size;
    final scale = 1 / (aspectRatio * mediaSize.aspectRatio);
//    final scale = 1 / (aspectRatio * mediaSize.aspectRatio);
      final cameraRatio = context.select(
          (CameraService service) => service.value.controllerValue.aspectRatio);
      return Center(
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: ClipRect(
            clipper: _MediaSizeClipper(mediaSize),
            child: FittedBox(
              fit: sizeFit
                  .fit, // This ensures the width is fully covered without stretching.
    child: SizedBox(
      width: mediaSize.width,
      height: mediaSize.height,
      child: child
                  // child: Transform.scale(
                  //   scale: scale,
                  //   child: child,
                  //  Center(
                  //   child: AspectRatio(
                  //     aspectRatio: cameraRatio,
                  //     child: child,
                  //   ),
                  // ),
                  ),
            ),
          ),
        ),
      );
    });

    // return ClipRect(
    //       clipper: _MediaSizeClipper(mediaSize),
    //       child:

//  ),
    //       child: Transform.scale(scale: scale,
    //   alignment: alignment,
    // child: child,
    // )
//    );
  }
}

class _MediaSizeClipper extends CustomClipper<Rect> {
  final Size mediaSize;
  const _MediaSizeClipper(this.mediaSize);
  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, mediaSize.width, mediaSize.height);
  }
  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return true;
  }
}