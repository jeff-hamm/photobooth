/// Namespace for Default Photobooth Breakpoints
abstract class PhotoboothBreakpoints {
  /// Max width for a small layout.
  static const double small = 760;

  /// Max width for a medium layout.
  static const double medium = 1644;

  /// Max width for a large layout.
  static const double large = 1920;

  static PhotoboothBreakpoint toBreakpoint(double width) {
    if (width <= small) {
      return PhotoboothBreakpoint.small;
    }
    if (width <= medium) {
      return PhotoboothBreakpoint.medium;
    }
    if (width <= large) {
      return PhotoboothBreakpoint.large;
    }
    return PhotoboothBreakpoint.xLarge;
  }
  static double fromBreakpoint(PhotoboothBreakpoint breakpoint) {
    switch (breakpoint) {
      case PhotoboothBreakpoint.small:
        return small;
      case PhotoboothBreakpoint.medium:
        return medium;
      case PhotoboothBreakpoint.large:
        return large;
      case PhotoboothBreakpoint.xLarge:
        return double.infinity;
    }
  }
}

enum PhotoboothBreakpoint {
  small,
  medium,
  large,
  xLarge,
}