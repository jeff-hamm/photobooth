import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:io_photobooth/app/router.dart';
import 'package:io_photobooth/app/router.gr.dart';
import 'package:io_photobooth/common/camera_service.dart';
import 'package:io_photobooth/l10n/l10n.dart';
import 'package:io_photobooth/photobooth/photobooth.dart';
import 'package:io_photobooth/photobooth/view/photobooth_page.dart';
import 'package:io_photobooth/common/image_color_switcher.dart';
import 'package:io_photobooth/common/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import '../../../config.dart' as config;
import '../../app/app.dart';

class RetakeButton extends StatefulWidget {
  const RetakeButton(
      {this.onCountdownComplete, super.key, this.isStickers = false});
  final bool isStickers;
  final VoidCallback? onCountdownComplete;

  @override
  State<RetakeButton> createState() => _RetakeButtonState();
}

class _RetakeButtonState extends State<RetakeButton>
    with TickerProviderStateMixin {
  late final AnimationController controller;

  void _onAnimationStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.dismissed) {
      widget.onCountdownComplete?.call();
//      final photoboothBloc =
//      context.read<PhotoboothBloc>()
//        ..add(const PhotoClearAllTapped());
//      final svc = context.read<CameraService>();
//       unawaited(Future<void>(() async {

// //        await svc.disposeController();
//        await svc.stop();
//        await svc.play();
//          AutoRouter.of(context).popForced();
//            .pushNamed("/booth/prview", includePrefixMatches: true);
//          .pushNamed("/booth/preview", includePrefixMatches: true);
//          context.router.maybePop();
//                  unawaited(context.router.popAndPush(const PhotobothViewRoute()));
//        context.router.pushAndPopUntil(const PhotobothViewRoute(),
      //      predicate: (route) =>
      //      route.settings.name == PhotoboothRoute.name);
      AutoRouter.of(context)
          .navigateNamed("/booth/preview", includePrefixMatches: true);
//        replaceAll([const PhotobothViewRoute()]);
//      appRouter.navigateNamed("/", includePrefixMatches: true);
//       final navigator = Navigator.of(context);
//         await navigator.pushReplacement(PhotoboothPage.route());
// //        await svc.initState();
//        }));
    }
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration:
          widget.isStickers ? config.TimeoutDuration : config.ShareDuration,
      value: 1,
    )..addStatusListener(_onAnimationStatusChanged);
    controller.reverse(from: 1);
  }

  @override
  void dispose() {
    controller
      ..removeStatusListener(_onAnimationStatusChanged)
      ..dispose();
    super.dispose();
  }

  // Future<void> _onShutterPressed() async {
  //   unawaited(controller.reverse(from: 1));
  // }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Column(children: [
          _RetakeButton(isStickers: widget.isStickers),
          CountdownTimer(
              duration: widget.isStickers
                  ? config.TimeoutDuration
                  : config.ShareDuration,
              controller: controller)
        ]);
      },
    );
  }
}

class CountdownTimer extends StatelessWidget {
  const CountdownTimer(
      {required this.controller, required this.duration, super.key});

  final Duration duration;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    final seconds = (duration.inSeconds * controller.value).ceil();
    final theme = Theme.of(context);
    if (seconds > 15) {
      return const SizedBox();
    }
    var color = PhotoboothColors.green;
    if (seconds > 5) {
      color = PhotoboothColors.orange;
    } else {
      color = PhotoboothColors.red;
    }
    return Container(
//      height: 40,
//      width: 70,
//      margin: const EdgeInsets.only(bottom: 15),
      child: Column(children: [
        Text(
          'Restart in',
          style: theme.textTheme.displaySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text('$seconds',
            style: theme.textTheme.displaySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ))
      ]),
    );
  }
}

class _RetakeButton extends StatelessWidget {
  const _RetakeButton({super.key, this.isStickers = false, this.onPressed});

  final VoidCallback? onPressed;
  final bool isStickers;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final navigator = AutoRouter.of(context);
    return AppTooltipButton(
      key: const Key('sharePage_retake_appTooltipButton'),
      onPressed: () async {
        final photoboothBloc = context.read<PhotoboothBloc>();
//            final navigator = Navigator.of(context);

        final confirmed = !isStickers ||
            (await showAppModal<bool>(
                    context: context,
                    landscapeChild:
                        const _StickersRetakeConfirmationDialogContent(),
                    portraitChild:
                        const _StickersRetakeConfirmationBottomSheet()) ??
                false);

        if (confirmed) {
          photoboothBloc.add(const PhotoClearAllTapped());
          Navigator.of(context).pop(true);
//          context.maybePop(true);
//              navigator.replace(const PhotobothViewRoute());
//              navigator.popUntil((route) => route.isFirst || route.settings.name == PhotobothViewRoute.name);
//              unawaited(navigator.replaceAll([const PhotobothViewRoute()]));
          //        unawaited(AutoRouter.of(context).navigate(const PhotobothViewRoute()));
//              unawaited(navigator.pushReplacement(PhotoboothPage.route()));
        }
      },
      message: l10n.retakeButtonTooltip,
      child: const IconAssetColorSwitcher(
        'assets/icons/retake_button_icon.png',
      ),
    );
  }
}

class _StickersRetakeConfirmationDialogContent extends StatelessWidget {
  const _StickersRetakeConfirmationDialogContent();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(60),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.stickersRetakeConfirmationHeading,
                textAlign: TextAlign.center,
                style: theme.textTheme.displayLarge,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.stickersRetakeConfirmationSubheading,
                textAlign: TextAlign.center,
                style: theme.textTheme.displaySmall,
              ),
              const SizedBox(height: 24),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 24,
                runSpacing: 24,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: PhotoboothColors.black),
                    ),
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      l10n.stickersRetakeConfirmationCancelButtonText,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: PhotoboothColors.black,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(
                      l10n.stickersRetakeConfirmationConfirmButtonText,
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfirmationDialogContent extends StatelessWidget {
  const _ConfirmationDialogContent();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(60),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.shareRetakeConfirmationHeading,
                textAlign: TextAlign.center,
                style: theme.textTheme.displayLarge,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.shareRetakeConfirmationSubheading,
                textAlign: TextAlign.center,
                style: theme.textTheme.displaySmall,
              ),
              const SizedBox(height: 24),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 24,
                runSpacing: 24,
                children: [
                  OutlinedButton(
                    key: const Key('sharePage_retakeCancel_elevatedButton'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: PhotoboothColors.black),
                    ),
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      l10n.shareRetakeConfirmationCancelButtonText,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: PhotoboothColors.black,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    key: const Key('sharePage_retakeConfirm_elevatedButton'),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(l10n.shareRetakeConfirmationConfirmButtonText),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfirmationBottomSheet extends StatelessWidget {
  const _ConfirmationBottomSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 30),
      decoration: const BoxDecoration(
        color: PhotoboothColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Stack(
        children: [
          const _ConfirmationDialogContent(),
          Positioned(
            right: 24,
            top: 24,
            child: IconButton(
              icon: const Icon(Icons.clear, color: PhotoboothColors.black54),
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ),
        ],
      ),
    );
  }
}

class _StickersRetakeConfirmationBottomSheet extends StatelessWidget {
  const _StickersRetakeConfirmationBottomSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 30),
      decoration: const BoxDecoration(
        color: PhotoboothColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Stack(
        children: [
          const _StickersRetakeConfirmationDialogContent(),
          Positioned(
            right: 24,
            top: 24,
            child: IconButton(
              icon: const Icon(Icons.clear, color: PhotoboothColors.black54),
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ),
        ],
      ),
    );
  }
}

class TimerPainter extends CustomPainter {
  const TimerPainter({
    required this.animation,
    required this.countdown,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final int countdown;
  @visibleForTesting
  Color calculateColor() {
    if (countdown == 3) return PhotoboothColors.primary;
    if (countdown == 2) return PhotoboothColors.secondary;
    return PhotoboothColors.green;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final progressColor = calculateColor();
    final progress = ((1 - animation.value) * (2 * math.pi) * 3) -
        ((3 - countdown) * (2 * math.pi));

    final paint = Paint()
      ..color = progressColor
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(size.center(Offset.zero), size.width / 2.0, paint);
    paint.color = PhotoboothColors.white;
    canvas.drawArc(Offset.zero & size, math.pi * 1.5, progress, false, paint);
  }

  @override
  bool shouldRepaint(TimerPainter oldDelegate) => false;
}
