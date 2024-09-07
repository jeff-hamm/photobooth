import 'package:flutter/material.dart';

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
    final mediaSize = MediaQuery.of(context).size;
    final scale = 1 / (aspectRatio * mediaSize.aspectRatio);
    return ClipRect(
          clipper: _MediaSizeClipper(mediaSize),
          child:
          FittedBox(
    fit: BoxFit.fitWidth,  // This ensures the width is fully covered without stretching.
    child: SizedBox(
      width: mediaSize.width,
      height: mediaSize.height,
      child: child,
    ),
  ),
    //       child: Transform.scale(scale: scale,
    //   alignment: alignment,
    // child: child,
    // )
    );
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