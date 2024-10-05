import 'package:flutter/widgets.dart';
import 'package:io_photobooth/common/widgets.dart';
import 'package:io_photobooth/theme_config.dart';

import 'colors.dart';
import 'font_weights.dart';

/// Photobooth Text Style Definitions
class PhotoboothTextStyle {
  static const _baseTextStyle = TextStyle(
//    package: 'photobooth_ui',
    fontFamily: 'Playfair',
    color: PhotoboothColors.black,
    fontWeight: PhotoboothFontWeight.regular,
  );

  /// Headline 1 Text Style
  static TextStyle get headline1 {
    return _baseTextStyle.copyWith(
      fontSize: AppTheme.highResLargeTextSize,
      fontWeight: AppTheme.highResLargeFontWeight,
    );
  }

  /// Headline 2 Text Style
  static TextStyle get headline2 {
    return _baseTextStyle.copyWith(
      fontSize: AppTheme.highResMediumTextSize,
      fontWeight: PhotoboothFontWeight.regular,
    );
  }

  /// Headline 3 Text Style
  static TextStyle get headline3 {
    return _baseTextStyle.copyWith(
      fontSize: AppTheme.highResSmallTextSize,
      fontWeight: PhotoboothFontWeight.regular,
    );
  }

  /// Headline 4 Text Style
  static TextStyle get headline4 {
    return _baseTextStyle.copyWith(
      fontSize: 22,
      fontWeight: PhotoboothFontWeight.bold,
    );
  }

  /// Headline 5 Text Style
  static TextStyle get headline5 {
    return _baseTextStyle.copyWith(
      fontSize: 22,
      fontWeight: PhotoboothFontWeight.medium,
    );
  }

  /// Headline 6 Text Style
  static TextStyle get headline6 {
    return _baseTextStyle.copyWith(
      fontSize: 22,
      fontWeight: PhotoboothFontWeight.bold,
    );
  }

  /// Subtitle 1 Text Style
  static TextStyle get subtitle1 {
    return _baseTextStyle.copyWith(
      fontSize: 16,
      fontWeight: PhotoboothFontWeight.bold,
    );
  }

  /// Subtitle 2 Text Style
  static TextStyle get subtitle2 {
    return _baseTextStyle.copyWith(
      fontSize: 14,
      fontWeight: PhotoboothFontWeight.bold,
    );
  }

  /// Body Text 1 Text Style
  static TextStyle get bodyText1 {
    return _baseTextStyle.copyWith(
      fontSize: 18,
      fontWeight: PhotoboothFontWeight.medium,
    );
  }

  /// Body Text 2 Text Style (the default)
  static TextStyle get bodyText2 {
    return _baseTextStyle.copyWith(
      fontSize: 16,
      fontWeight: PhotoboothFontWeight.regular,
    );
  }

  /// Caption Text Style
  static TextStyle get caption {
    return _baseTextStyle.copyWith(
      fontSize: 14,
      fontWeight: PhotoboothFontWeight.regular,
    );
  }

  /// Overline Text Style
  static TextStyle get overline {
    return _baseTextStyle.copyWith(
      fontSize: 16,
      fontWeight: PhotoboothFontWeight.regular,
    );
  }

  /// Button Text Style
  static TextStyle get button {
    return _baseTextStyle.copyWith(
      fontSize: 18,
      fontWeight: PhotoboothFontWeight.medium,
    );
  }
}
