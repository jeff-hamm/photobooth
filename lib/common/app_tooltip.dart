import 'package:flutter/material.dart';
import 'package:io_photobooth/common/app_text_box.dart';
import 'package:io_photobooth/common/widgets.dart';

/// {@template app_tooltip}
/// A custom [Tooltip] for the photobooth_ui toolkit.
/// {@endtemplate}
class AppTooltip extends StatelessWidget {
  /// {@macro app_tooltip}
  const AppTooltip({
    required String message,
    required Widget child,
    EdgeInsets? padding,
    TextStyleName? textStyleName,
    Key? key,
  }) : this._(
          key: key,
          message: message,
          child: child,
          padding: padding,
          textStyleName: textStyleName,
        );

  const AppTooltip._({
    required this.message,
    required this.child,
    this.visible = false,
    this.padding,
    this.verticalOffset,
    this.textStyleName,
    super.key,
  });

  /// {@macro app_tooltip}
  const AppTooltip.custom({
    required String message,
    required bool visible,
    EdgeInsets? padding,
    double? verticalOffset,
    TextStyleName? textStyleName,
    Widget? child,
    Key? key,
  }) : this._(
          key: key,
          message: message,
          visible: visible,
          padding: padding,
          verticalOffset: verticalOffset,
          textStyleName: textStyleName,
          child: child,
        );

  /// The tooltip message.
  final String message;

  /// Whether or not the tooltip is currently visible.
  final bool visible;

  /// An optional padding.
  final EdgeInsets? padding;

  /// An optional vertical offset.
  final double? verticalOffset;
  final TextStyleName? textStyleName;
  /// An optional child widget.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final child = this.child;

    if (visible) {
      return AppTextBox(message, textStyleName: textStyleName ?? TextStyleName.displayMedium);
    }
    return Tooltip(
      message: message,
      verticalOffset: verticalOffset,
      child: child,
    );
  }
}
