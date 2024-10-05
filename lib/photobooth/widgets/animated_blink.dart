import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:io_photobooth/photobooth/bloc/photobooth_bloc.dart';

class AnimatedBlink extends StatefulWidget {
  const AnimatedBlink({required this.duration, required this.child, super.key});
  final Duration duration;
  final Widget child;
  @override
  State<AnimatedBlink> createState() => _AnimatedBlinkState();
}

class _AnimatedBlinkState extends State<AnimatedBlink> {
  double opacity = 1.0;
  bool isRunning = false;
  String? mostRecentImage;
  @override
  void initState() {
    super.initState();
    opacity = 1.0;
    isRunning = false;
  }

  @override
  Widget build(BuildContext context) {
    final image = context.watch<PhotoboothBloc>().state.mostRecentImage;
    return LayoutBuilder(builder: (context, constraints) {
      if (image != null && mostRecentImage != image && !isRunning) {
        mostRecentImage = image.path;
        opacity = 0.0;
        isRunning = true;
      }
      //  return AnimatedCrossFade(
      //   duration: widget.duration,
      //   crossFadeState: isRunning ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      //   firstChild: widget.child,
      //   secondChild: Image.network(
      //   image!.data,
      //   filterQuality: FilterQuality.high,
      //   isAntiAlias: true,
      //   fit: BoxFit.cover,
      //   height: image?.height as double?,
      //   width: image?.width as double?,
      //   errorBuilder: (context, error, stackTrace) {
      //     return Text(
      //       '$error, $stackTrace',
      //       key: const Key('previewImage_errorText'),
      //     );
      // }));
      return AnimatedOpacity(
          opacity: opacity,
          duration: widget.duration,
          child: widget.child,
          alwaysIncludeSemantics: true,
          onEnd: () {
            setState(() {
              if (opacity == 0.0) {
                opacity = 1.0;
              } else if (opacity == 1.0) {
                isRunning = false;
              }
            });
          });
    });
  }
}
// opacity: 1.0,
// duration: const Duration(milliseconds: 300),
// alwaysIncludeSemantics: true,
// child: Stack(
