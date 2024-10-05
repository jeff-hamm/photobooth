import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'theme/breakpoints.dart';

/// Signature for the individual builders (`small`, `large`, etc.).
typedef ResponsiveThemeWidgetBuilder = Widget Function(BuildContext, ThemeData theme,PhotoboothBreakpoint breakpoint, Widget?);

/// {@template responsive_layout_builder}
/// A wrapper around [LayoutBuilder] which exposes builders for
/// various responsive breakpoints.
/// {@endtemplate}
class ResponsiveThemeBuilder extends StatelessWidget {
  /// {@macro responsive_layout_builder}
  const ResponsiveThemeBuilder({
    required this.builder,
    this.child,
    super.key,
  });

  final ResponsiveThemeWidgetBuilder builder;
  /// Optional child widget which will be passed
  /// to the `small`, `large` and `xLarge`
  /// builders as a way to share/optimize shared layout.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final theme = Theme.of(context);
        final breakpoint = PhotoboothBreakpoints.toBreakpoint(constraints.maxWidth);
        return builder.call(context, theme,breakpoint,child);
      },
    );
  }
}
