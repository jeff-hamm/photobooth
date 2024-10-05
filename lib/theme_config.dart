
import 'package:flutter/material.dart';
import 'package:io_photobooth/common/widgets.dart';

class AppTheme {
  static ColorScheme colorScheme = ColorScheme.fromSeed(
    seedColor: primary, secondary: secondary);
  static const Color primary = PhotoboothColors.blue;
  static const Color secondary = green;
  static const Color accent = primary;

  static const Color selected = green;
  static const Color text = primary;
  static const Color textBackground = Color(0x66FFFFFF);
  static const Radius textBoxCorners = Radius.circular(5);
  static const EdgeInsets textBoxPadding = EdgeInsets.all(10);


  static const double highResLargeTextSize = 44;
  static const double highResMediumTextSize = 35;
  static const double highResSmallTextSize = 30;

  static const num lowResTextScaleFactor = 0.80;

  static const BoxDecoration imagePickerBoxDecoration = BoxDecoration(

                              borderRadius: BorderRadius.all(Radius.circular(20)));




  static const Color green = Color(0xFF4CAF50);

  static const String fontFamily = 'Playfair';

  static const FontWeight highResLargeFontWeight = FontWeight.w800;

  static const num assetIconPadding = 40;

  static const double aspectRatioLandscape = 1/1;


}