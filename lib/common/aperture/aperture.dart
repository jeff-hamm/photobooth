/*
 * Created by Alfonso Cejudo, Saturday, July 13th 2019.
 */

import 'package:flutter/material.dart';
import 'package:io_photobooth/common/theme/theme.dart';
import 'aperture_blades.dart';

class Aperture extends StatelessWidget {

  const Aperture(
      {super.key, this.child,
      this.animationController,
      this.curvedAnimation,
      this.startOpened = true});
  /// The optional child is visible when the Aperture is not fully closed, and
  /// is wrapped inside a clipped container so that its contents only appear
  /// within the Aperture bounds.
  final Widget? child;

  /// Set the starting position of the Aperture to be opened (default) or
  /// closed.
  final bool startOpened;

  final AnimationController? animationController;
  final Animation<double>? curvedAnimation;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bladeWidth = constraints.maxWidth; 
//        * 0.78;

        return 
          IgnorePointer(child:
        Stack(
          alignment: Alignment.center,
          children: <Widget>[
            if (child != null)
              ClipOval(
                clipBehavior: Clip.antiAlias,
                child: Container(
                  alignment: Alignment.center,
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: child,
                ),
              ),

               ApertureBlades(
                bladeWidth: bladeWidth,
                animationController: animationController,
                curvedAnimation: curvedAnimation,
                startOpened: startOpened,
              ),
          ],
        ));
      },
    );
  }
}