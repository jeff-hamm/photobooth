import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:io_photobooth/theme_config.dart';
/// Defines the color palette for the Photobooth UI.
abstract class PhotoboothColors {
  /// Black
  static const Color black = Color(0xFF202124);

  /// Black 54% opacity
  static const Color black54 = Color(0x8A000000);

  /// Black 25% opacity
  static const Color black25 = Color(0x40202124);

  /// Gray
  static const Color gray = Color(0xFFCFCFCF);

  /// White
  static const Color white = Color(0xFFFFFFFF);

  /// WhiteBackground
  static const Color whiteBackground = Color(0xFFE8EAED);

  /// Transparent
  static const Color transparent = Color(0x00000000);
  static const Color primary = AppTheme.primary; 
  static const Color blue = Color(0xFF428EFF);
  /// Blue
  static const Color accent = AppTheme.accent;
  static const Color text = AppTheme.text;
  static const Color selected = AppTheme.selected;
  static const Color textBackground = AppTheme.textBackground;

  static const Color blueTransparent = Color.fromARGB(135, 23, 34, 49);

  /// Red
  static const Color red = Color(0xFFFB5246);

  /// Green
  static const Color green_prev = Color(0xFF3fBC5C);
  static const Color green = AppTheme.green;
  /// Orange
  static const Color orange = Color(0xFFFFBB00);

  /// Charcoal
  static const Color charcoal = Color(0xBF202124);

  static const Color secondary = AppTheme.accent;
}
