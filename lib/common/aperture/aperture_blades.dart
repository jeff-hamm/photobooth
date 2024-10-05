/*
 * Created by Alfonso Cejudo, Saturday, July 13th 2019.
 */

import 'dart:math' as math;

import 'package:flutter/material.dart';
import './aperture_blades_painter.dart';

class ApertureBlades extends StatefulWidget {
  final double bladeWidth;
  final AnimationController? animationController;
  final Animation<double>? curvedAnimation;
  final bool startOpened;

  ApertureBlades(
      {required this.bladeWidth,
      this.animationController,
      this.curvedAnimation,
      this.startOpened = true});

  @override
  State createState() => _ApertureBladesState();
}

class _ApertureBladesState extends State<ApertureBlades>
    with SingleTickerProviderStateMixin {
  static const apertureBorderWidth = 2.0;
  static const open1 = 0.78;
  static const open2 = 0.33;

  late final AnimationController animationController;
  late final Animation<double> curvedAnimation;

  late final Animation<Offset> _slide1;
  late final Animation<Offset> _slide2;
  late final Animation<Offset> _slide3;
  late final Animation<Offset> _slide4;
  late final Animation<Offset> _slide5;
  late final Animation<Offset> _slide6;

  @override
  void initState() {
    super.initState();

    animationController = widget.animationController != null
        ? widget.animationController!
        : AnimationController(
            vsync: this, duration: const Duration(milliseconds: 250));

    animationController.addStatusListener(animationListener);
    curvedAnimation = widget.curvedAnimation != null
        ? widget.curvedAnimation!
        : CurvedAnimation(
            parent: animationController, curve: Curves.easeInSine);

    _slide1 = widget.startOpened
        ? Tween(begin: const Offset(open1, 0.0), end: Offset.zero)
            .animate(curvedAnimation)
        : Tween(begin: Offset.zero, end: const Offset(open1, 0.0))
            .animate(curvedAnimation);
    _slide2 = widget.startOpened
        ? Tween(begin: const Offset(open2, open1), end: Offset.zero)
            .animate(curvedAnimation)
        : Tween(begin: Offset.zero, end: const Offset(open2, open1))
            .animate(curvedAnimation);
    _slide3 = widget.startOpened
        ? Tween(begin: const Offset(-open2, open1), end: Offset.zero)
            .animate(curvedAnimation)
        : Tween(begin: Offset.zero, end: const Offset(-open2, open1))
            .animate(curvedAnimation);
    _slide4 = widget.startOpened
        ? Tween(begin: const Offset(-open1, 0.0), end: Offset.zero)
            .animate(curvedAnimation)
        : Tween(begin: Offset.zero, end: const Offset(-open1, 0.0))
            .animate(curvedAnimation);
    _slide5 = widget.startOpened
        ? Tween(begin: const Offset(-open2, -open1), end: Offset.zero)
            .animate(curvedAnimation)
        : Tween(begin: Offset.zero, end: const Offset(-open2, -open1))
            .animate(curvedAnimation);
    _slide6 = widget.startOpened
        ? Tween(begin: const Offset(open2, -open1), end: Offset.zero)
            .animate(curvedAnimation)
        : Tween(begin: Offset.zero, end: const Offset(open2, -open1))
            .animate(curvedAnimation);

    if (widget.animationController == null) {
      animationController.forward();
    }
  }

  void animationListener(dynamic status) {
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    this.animationController.removeStatusListener(animationListener);
    if (widget.animationController == null) {
      animationController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final boxWidth = widget.bladeWidth;
    final bladeHeight =
        math.sqrt((math.pow(boxWidth, 2) - math.pow((boxWidth / 2), 2)));
    final heightDelta = boxWidth - bladeHeight;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final centerX = constraints.maxWidth * 0.5;
        final centerY = constraints.maxHeight * 0.5;

        return Container(
            color: Colors.transparent,
            child: animationController.isAnimating
                ?
                //          ClipOval(
                //  clipBehavior: Clip.antiAlias,
                //  child:

                Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Positioned(
                        left: centerX + (boxWidth / 2),
                        top: centerY + heightDelta,
                        child: AnimatedBuilder(
                          animation: animationController,
                          child: FittedBox(
                            fit: BoxFit.none,
                            child: SizedBox(
                              width: boxWidth,
                              height: boxWidth,
                              child: CustomPaint(
                                painter: ApertureBladePainter(
                                    borderWidth: apertureBorderWidth,
                                    rotationRadians: math.pi),
                              ),
                            ),
                          ),
                          builder: (context, child) => SlideTransition(
                            position: _slide1,
                            child: child,
                          ),
                        ),
                      ),
                      Positioned(
                        left: centerX - apertureBorderWidth,
                        top: centerY -
                            (boxWidth - bladeHeight) -
                            bladeHeight +
                            (apertureBorderWidth / 2),
                        child: AnimatedBuilder(
                          animation: animationController,
                          child: FittedBox(
                            fit: BoxFit.none,
                            child: SizedBox(
                              width: boxWidth,
                              height: boxWidth,
                              child: CustomPaint(
                                painter: ApertureBladePainter(
                                    borderWidth: apertureBorderWidth),
                              ),
                            ),
                          ),
                          builder: (context, child) =>
                              SlideTransition(position: _slide2, child: child),
                        ),
                      ),
                      Positioned(
                        left: centerX + boxWidth - apertureBorderWidth,
                        top: centerY + heightDelta + bladeHeight,
                        child: AnimatedBuilder(
                          animation: animationController,
                          child: FittedBox(
                            fit: BoxFit.none,
                            child: SizedBox(
                              width: boxWidth,
                              height: boxWidth,
                              child: CustomPaint(
                                painter: ApertureBladePainter(
                                    borderWidth: apertureBorderWidth,
                                    rotationRadians: math.pi),
                              ),
                            ),
                          ),
                          builder: (context, child) => SlideTransition(
                            position: _slide3,
                            child: child,
                          ),
                        ),
                      ),
                      Positioned(
                        left: centerX - (boxWidth * 0.5),
                        top: centerY - heightDelta,
                        child: AnimatedBuilder(
                          animation: animationController,
                          child: FittedBox(
                            fit: BoxFit.none,
                            child: SizedBox(
                              width: boxWidth,
                              height: boxWidth,
                              child: CustomPaint(
                                painter: ApertureBladePainter(
                                    borderWidth: apertureBorderWidth),
                              ),
                            ),
                          ),
                          builder: (context, child) => SlideTransition(
                            position: _slide4,
                            child: child,
                          ),
                        ),
                      ),
                      Positioned(
                        left: centerX + apertureBorderWidth,
                        top: centerY + heightDelta + bladeHeight,
                        child: AnimatedBuilder(
                          animation: animationController,
                          child: FittedBox(
                            fit: BoxFit.none,
                            child: SizedBox(
                              width: boxWidth,
                              height: boxWidth,
                              child: CustomPaint(
                                painter: ApertureBladePainter(
                                    borderWidth: apertureBorderWidth,
                                    rotationRadians: math.pi),
                              ),
                            ),
                          ),
                          builder: (context, child) => SlideTransition(
                            position: _slide5,
                            child: child,
                          ),
                        ),
                      ),
                      Positioned(
                        left: centerX - boxWidth + apertureBorderWidth,
                        top: centerY -
                            heightDelta -
                            bladeHeight +
                            (apertureBorderWidth / 2),
                        child: AnimatedBuilder(
                          animation: animationController,
                          child: FittedBox(
                            fit: BoxFit.none,
                            child: SizedBox(
                              width: boxWidth,
                              height: boxWidth,
                              child: CustomPaint(
                                painter: ApertureBladePainter(
                                    borderWidth: apertureBorderWidth),
                              ),
                            ),
                          ),
                          builder: (context, child) => SlideTransition(
                            position: _slide6,
                            child: child,
                          ),
                        ),
                      ),
                    ],
                  )
//        )
                : const SizedBox());
      },
    );
  }
}
