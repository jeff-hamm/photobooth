import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:io_photobooth/theme_config.dart';

/// Namespace for Default Photobooth Aspect Ratios
abstract class PhotoboothAspectRatio {
  /// Aspect ratio used for landscape.
  static const landscape = AppTheme.aspectRatioLandscape;
  static double forOrientation(Orientation orientation) {
    return orientation == Orientation.landscape ? landscape : portrait;
  }
  static double forDeviceOrientation(DeviceOrientation orientation) {
    return orientation ==  DeviceOrientation.landscapeLeft || orientation == DeviceOrientation.landscapeRight ? landscape : portrait;
  }
  /// Aspect ratio used for portrait.
  static const portrait = 1/landscape;
}
