import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:io_photobooth/app/router.gr.dart';
import 'package:io_photobooth/common/camera_service.dart';
import 'package:io_photobooth/common/utils/error_dialog.dart';
import 'package:io_photobooth/landing/widgets/loading_body.dart';
import 'package:io_photobooth/main.dart';
import 'package:io_photobooth/photobooth/photobooth.dart';
import 'package:io_photobooth/photobooth/view/camera.dart';
import 'package:io_photobooth/common/widgets.dart';
import 'dart:html' as html;

@RoutePage()
class LandingPage extends StatelessWidget
//implements  AutoRouteWrapper
{
  const LandingPage({super.key});

  // @override
  // Widget wrappedRoute(BuildContext context) {
  //   return BlocProvider(create: (ctx) =>
  //     PhotoboothBloc(null, isPrimaryClient: Uri.base.queryParameters['primary'] == '1'),
  //     child: this);
  // }
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
    return TimedTransition(
        duration: const Duration(seconds: 3),
        transitionTo: () => const PhotoboothPage(),
        child: const Scaffold(
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
  })  : transitionDuration = transitionDuration ?? const Duration(seconds: 1),
        super(key: key);

  final Duration duration;
  final Duration transitionDuration;
  final Widget child;
  final Widget Function() transitionTo;

  @override
  State<TimedTransition> createState() => _TimedTransitionState();
}

class _TimedTransitionState extends State<TimedTransition> {
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
      _navigate = true;
      _tryNavigate();
    });
  }

  Future<void> _tryNavigate() async {
    final service = context.read<CameraService>();
    if (_navigate) {
      if (service.value.cameraSelectorStatus == CameraStatus.available) {
        service.removeListener(_tryNavigate);
        await AutoRouter.of(context).replace(const PhotobothViewRoute());
      } else if (service.value.cameraSelectorStatus ==
          CameraStatus.unavailable) {
        await showAppDialog<void>(
            context: context,
            child: const ErrorMessageDialog(
              text:
                  "We could not obtain permission to use your camera. Please provide permission and try again.",
              title: "No Camera!",
            ));
      }
      //TODO: maybe offer the choice to go to the selection screen with some random images

      else if (service.value.cameraSelectorStatus ==
          CameraStatus.uninitialized) {
        // still waiting
      }
    }
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          widget.transitionTo(),
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
    final v = context.select((CameraService s) => s.value);
    if (v.cameraError != null ||
        v.controllerValue.errorDescription != null ||
        v.cameraSelectorStatus == CameraStatus.unavailable) {
      errorHandler.onError(
          '${v.cameraSelectorStatus}. ${v.cameraError}, ${v.controllerValue.errorDescription}'
          "Camera is unavailable");
    }
    return widget.child;
  }
}
