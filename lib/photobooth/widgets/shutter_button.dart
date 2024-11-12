import 'dart:async';
import 'dart:math' as math;
import 'package:io_photobooth/theme_config.dart';
import 'package:flutter/material.dart';
import 'package:io_photobooth/common/camera_button.dart';
import 'package:just_audio/just_audio.dart';
import 'package:io_photobooth/common/widgets.dart';

import '../../config.dart' as config;
AudioPlayer _getAudioPlayer() => AudioPlayer();

class ShutterButton extends StatefulWidget {
  const ShutterButton({
    required this.onCountdownComplete,
    required this.onAllPhotosComplete,
    this.onPressed,
    this.photosPerPress = 1,
    super.key,
    ValueGetter<AudioPlayer>? audioPlayer,
  }) : _audioPlayer = audioPlayer ?? _getAudioPlayer;
  final int photosPerPress;
  final VoidCallback? onPressed;
  final Future<void> Function() onCountdownComplete;
  final VoidCallback onAllPhotosComplete;
  final ValueGetter<AudioPlayer> _audioPlayer;
  @override
  State<ShutterButton> createState() => _ShutterButtonState();
}

class _ShutterButtonState extends State<ShutterButton>
    with TickerProviderStateMixin {
  late final AnimationController controller;
  late final AudioPlayer audioPlayer;
  Future<void> _onAnimationStatusChanged(AnimationStatus status) async {
    if (status == AnimationStatus.dismissed) {
      await widget.onCountdownComplete();
      await Future.delayed(const Duration(milliseconds: 300));
      photoCount++;
      if (photoCount < widget.photosPerPress) {
        unawaited(controller.reverse(from: 1));
      } else {
        widget.onAllPhotosComplete();
        photoCount = 0;
      }
    }

  }

  int photoCount = 0;
  @override
  void initState() {
    super.initState();
    photoCount = 0;
    audioPlayer = widget._audioPlayer()..setAsset('assets/audio/camera.mp3');
    controller = AnimationController(
      vsync: this,
      duration: config.CountdownDuration,
    )..addStatusListener(_onAnimationStatusChanged);
    unawaited(audioPlayer.play());
    audioPlayer.playerStateStream.listen((event) {
      if (event.processingState == ProcessingState.ready) {
        audioPlayer.pause();
      }
    });
  }

  @override
  void dispose() {
    controller
      ..removeStatusListener(_onAnimationStatusChanged)
      ..dispose();
    audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _onShutterPressed() async {
    photoCount = 0;
    await audioPlayer.seek(null);
    unawaited(audioPlayer.play());
    widget.onPressed?.call();
    unawaited(controller.reverse(from: 1));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return controller.isAnimating
            ? CountdownTimer(controller: controller)
            : CameraButton(onPressed: _onShutterPressed);
      },
    );
  }
}

class CountdownTimer extends StatelessWidget {
  const CountdownTimer({required this.controller, super.key});

  final AnimationController controller;

  Size? toSize(WidgetStateProperty<double?>? iconSize) {
    final size = iconSize?.resolve({});
    if (size == null) {
      return null;
    }
    return Size(size, size);
  }
  @override
  Widget build(BuildContext context) {
    final seconds =
        (config.CountdownDuration.inSeconds * controller.value).ceil();
    final theme = Theme.of(context);
    final iconSize = (theme.iconButtonTheme.style?.fixedSize?.resolve({}) ??
        toSize(theme.iconButtonTheme.style?.iconSize) ??
        Size(theme.iconTheme!.size!, theme.iconTheme!.size!))!;

    return Container(
      height: iconSize.height + AppTheme.assetIconPadding + 80,
      width: iconSize.width + AppTheme.assetIconPadding + 80,
      margin: const EdgeInsets.only(bottom: 15, top: 15),
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          Center(
            child: Text(
              '$seconds',
              style: theme.textTheme.displayLarge?.copyWith(
                  color: PhotoboothColors.primary,
                fontWeight: FontWeight.w500,
                  fontSize: 80
              ),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: TimerPainter(animation: controller, countdown: seconds),
            ),
          )
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
    if (countdown > 3) return PhotoboothColors.primary;
    if (countdown == 2) return PhotoboothColors.orange;
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
