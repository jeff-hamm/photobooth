import 'package:flutter/material.dart';
import 'package:io_photobooth/common/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:io_photobooth/photobooth/photobooth.dart';
import 'package:io_photobooth/config.dart' as config;

class PhotoApertureOverlay  extends StatefulWidget {
  const PhotoApertureOverlay({super.key});
  @override
  State<StatefulWidget> createState() => _PhotoApertureOverlayState();
}

class _PhotoApertureOverlayState extends State<PhotoApertureOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController animationController;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
        vsync: this, duration: config.ShutterDuration,
        );

    animationController.addStatusListener(animationListener);
    animationController.stop();
    lastImageId = context.read<PhotoboothBloc>().state.imageId;
//    ..forward();
  }

  void animationListener(dynamic status) {
    if (status == AnimationStatus.completed) {
      Future. delayed(const Duration(milliseconds: 0), () {
        animationController.reverse();
      });
    } 
    // else if (status == AnimationStatus.dismissed) {
    //   Future.delayed(const Duration(milliseconds: 100), () {
    //     animationController.forward();
    //   });
  //      }
  }

  @override
  void dispose() {
    animationController..removeStatusListener(animationListener)
    ..dispose();

    super.dispose();
  }
  String? lastImageId;
  @override
  Widget build(BuildContext context) {
    final imageId = context.select((PhotoboothBloc bloc) => bloc.state.imageId);
    if(
      !animationController.isAnimating &&
      imageId != lastImageId && context.select((PhotoboothBloc bloc) => bloc.state.isInPhotoStream)) {
      lastImageId = imageId;
      animationController.forward(from: 0);
    }

    return Aperture(
                  animationController: animationController,
                  //child: Image.asset('images/dope.png'),
                );
  }
}
