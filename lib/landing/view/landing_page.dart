import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:io_photobooth/app/app.dart';
import 'package:io_photobooth/common/camera_service.dart';
import 'package:io_photobooth/footer/footer.dart';
import 'package:io_photobooth/landing/landing.dart';
import 'package:io_photobooth/landing/widgets/loading_body.dart';
import 'package:io_photobooth/photobooth/photobooth.dart';
import 'package:io_photobooth/photobooth/view/camera.dart';
import 'package:photobooth_ui/photobooth_ui.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: PhotoboothColors.white,
      body: LandingView(),
    );
  }
}

class LandingView extends StatelessWidget {
  const LandingView({super.key});

  @override
  Widget build(BuildContext context) {
    return 
     TimedTransition(
      duration: const Duration(seconds: 3),
      transitionTo: () => const PhotoboothPage(),
      child:const Scaffold(
      body: LoadingBody(),
    ));
  }
}


class TimedTransition extends StatefulWidget {
  const TimedTransition({
    required this.duration,
    required this.child,
    required this.transitionTo,
    Duration? transitionDuration,
    Key? key,
  }) : transitionDuration = transitionDuration ?? const Duration(seconds: 1), super(key: key);

  final Duration duration;
  final Duration transitionDuration;
  final Widget child;
  final Widget Function() transitionTo;

  @override
  State<TimedTransition> createState() => _TimedTransitionState();
}

class _TimedTransitionState extends State<TimedTransition>
  {
    _TimedTransitionState();
  late final Timer timer;

  late final Route _route;
  var _navigate = false;
  @override
  void initState() {
    super.initState();

    final service = context.read<CameraService>();
    service.addListener(_tryNavigate);
    timer = Timer(widget.duration, () {
      _navigate =true;  
      _tryNavigate();
    });
  }

  void _tryNavigate() {
    final service=context.read<CameraService>();
      if(_navigate && service.value.cameraSelectorStatus == CameraStatus.available) {
        service.removeListener(_tryNavigate);
        Navigator.of(context).pushReplacement(_createRoute());
      } 
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => widget.transitionTo(),
      transitionDuration: widget.transitionDuration,
      transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
      // transitionsBuilder: (context, animation, secondaryAnimation, child) {
      //   return AppAnimatedCrossFade(crossFadeState: _navigate ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      //     firstChild: widget.child,
      //     secondChild: widget.transitionTo(),
      //     duration: widget.duration,
      //   );
      // },
    );
  }
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
