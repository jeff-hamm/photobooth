import 'package:flutter/material.dart';
import 'package:io_photobooth/common/theme.dart';

typedef AspectWidgetBuilder = Widget Function(BuildContext context, Orientation orientation, double aspectRatio, 
  bool isNew);

class AspectBuilder extends StatefulWidget {
  /// Creates an orientation builder.
  const AspectBuilder({
    required this.builder, super.key,
  });

  /// Builds the widgets below this widget given this widget's orientation.
  ///
  /// A widget's orientation is a factor of its width relative to its
  /// height. For example, a [Column] widget will have a landscape orientation
  /// if its width exceeds its height, even though it displays its children in
  /// a vertical array.
  final AspectWidgetBuilder builder;


  @override
  State<StatefulWidget> createState() => _AspectBuilderState();
}

class _AspectBuilderState extends State<AspectBuilder> {
  double? aspectRatio;
  @override
  Widget build(BuildContext context) {

    return OrientationBuilder(builder: (context, orientation) {
      final newRatio = PhotoboothAspectRatio.forOrientation(orientation);
      var isNew = false;
      if (aspectRatio == null || aspectRatio != newRatio) {
        aspectRatio = newRatio;
        isNew = true;
      }
      return widget.builder(context, orientation, newRatio, isNew);
    });
  }
}