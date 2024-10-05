import 'package:flutter/material.dart';

typedef ImagePickerBuilder = Widget Function(
    BuildContext context, bool isEnlarged);

class ImagePickerEnlarge extends StatelessWidget {
  const ImagePickerEnlarge(
      {this.child,
      this.builder,
      this.backgroundColor = Colors.black,
      this.backgroundIsTransparent = true,
      this.onExpandTapped,
      this.disposeLevel})
      : assert(child != null || builder != null),
        assert(child == null || builder == null);

  final Widget? child;
  final ImagePickerBuilder? builder;
  final Color backgroundColor;
  final bool backgroundIsTransparent;
  final DisposeLevel? disposeLevel;
  final bool? Function(BuildContext context)? onExpandTapped;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          if (onExpandTapped?.call(context) == false) {
            return;
          }
          Navigator.push(
              context,
              PageRouteBuilder(
                  opaque: false,
                  barrierColor: backgroundIsTransparent
                      ? Colors.white.withOpacity(0)
                      : backgroundColor,
                  pageBuilder: (BuildContext context, _, __) {
                    return FullScreenPage(
                      child: child ?? builder!(context, true),
                      backgroundColor: backgroundColor,
                      backgroundIsTransparent: backgroundIsTransparent,
                      disposeLevel: disposeLevel,
                    );
                  }));
        },
        child: child ?? builder!(context, false));
  }
}

enum DisposeLevel { High, Medium, Low }

class FullScreenPage extends StatefulWidget {
  FullScreenPage(
      {required this.child,
      this.backgroundColor = Colors.black,
      this.backgroundIsTransparent = true,
      this.disposeLevel = DisposeLevel.Medium});

  final Widget child;
  final Color backgroundColor;
  final bool backgroundIsTransparent;
  final DisposeLevel? disposeLevel;

  @override
  _FullScreenPageState createState() => _FullScreenPageState();
}

class _FullScreenPageState extends State<FullScreenPage> {
  double? initialPositionY = 0;

  double? currentPositionY = 0;

  double positionYDelta = 0;

  double opacity = 1;

  double disposeLimit = 150;

  late Duration animationDuration;

  @override
  void initState() {
    super.initState();
    setDisposeLevel();
    animationDuration = Duration.zero;
  }

  setDisposeLevel() {
    setState(() {
      if (widget.disposeLevel == DisposeLevel.High)
        disposeLimit = 300;
      else if (widget.disposeLevel == DisposeLevel.Medium)
        disposeLimit = 200;
      else
        disposeLimit = 100;
    });
  }

  void _startVerticalDrag(DragStartDetails details) {
    setState(() {
      initialPositionY = details.globalPosition.dy;
    });
  }

  void _whileVerticalDrag(DragUpdateDetails details) {
    setState(() {
      currentPositionY = details.globalPosition.dy;
      positionYDelta = currentPositionY! - initialPositionY!;
      setOpacity();
    });
  }

  setOpacity() {
    double tmp = positionYDelta < 0
        ? 1 - ((positionYDelta / 1000) * -1)
        : 1 - (positionYDelta / 1000);
    print(tmp);

    if (tmp > 1)
      opacity = 1;
    else if (tmp < 0)
      opacity = 0;
    else
      opacity = tmp;

    if (positionYDelta > disposeLimit || positionYDelta < -disposeLimit) {
      opacity = 0.5;
    }
  }

  _endVerticalDrag(DragEndDetails details) {
    if (positionYDelta > disposeLimit || positionYDelta < -disposeLimit) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        animationDuration = Duration(milliseconds: 300);
        opacity = 1;
        positionYDelta = 0;
      });

      Future.delayed(animationDuration).then((_) {
        setState(() {
          animationDuration = Duration.zero;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundIsTransparent
          ? Colors.transparent
          : widget.backgroundColor,
      body: GestureDetector(
        onVerticalDragStart: _startVerticalDrag,
        onVerticalDragUpdate: _whileVerticalDrag,
        onVerticalDragEnd: _endVerticalDrag,
        child: Container(
          color: widget.backgroundColor.withOpacity(opacity),
          constraints: BoxConstraints.expand(
            height: MediaQuery.of(context).size.height,
          ),
          child: Stack(
            children: <Widget>[
              AnimatedPositioned(
                duration: animationDuration,
                curve: Curves.fastOutSlowIn,
                top: 0 + positionYDelta,
                bottom: 0 - positionYDelta,
                left: 0,
                right: 0,
                child: widget.child,
              )
            ],
          ),
        ),
      ),
    );
  }
}
