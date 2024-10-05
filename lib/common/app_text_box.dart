import 'package:flutter/material.dart';
import 'package:io_photobooth/common/theme/theme.dart';
import 'package:io_photobooth/config.dart';

class AppTextBox extends StatelessWidget {
  const AppTextBox(this.message,{ 
    this.padding = AppTheme.textBoxPadding, 
    this.boxColor = PhotoboothColors.textBackground, 
    this.textColor = PhotoboothColors.text, 
    this.borderRadius = AppTheme.textBoxCorners,
    this.textStyleName,
    this.textStyle,
    this.opacity,
    this.fontFamily = AppTheme.fontFamily,
    this.textAlign = TextAlign.center,
    this.fontWeight,// = FontWeight.bold,
    this.child,
    super.key});
    /// {@macro app_tooltip}
  AppTextBox.medium(String message) : this(message,textStyle: PhotoboothTheme.medium.textTheme.displayMedium);

  final TextStyleName? textStyleName;
  final String message;
  final Widget? child;
  final EdgeInsetsGeometry padding;
  final Color boxColor;
  final Color textColor;
  final Radius borderRadius;
  final TextStyle? textStyle;
  final double? opacity;
  final String? fontFamily;
  final TextAlign textAlign;
  final FontWeight? fontWeight;
  TextStyle? _getTextStyle(BuildContext context) {
    if(textStyle != null) return textStyle!;
    final textTheme=Theme.of(context).textTheme;
    if(textStyleName != null) {
      switch(textStyleName) {
        case TextStyleName.displayLarge:
          return textTheme.displayLarge;
        case TextStyleName.displayMedium:
          return textTheme.displayMedium; 
        case TextStyleName.displaySmall:  
          return textTheme.displaySmall;
        case TextStyleName.bodyLarge:
          return textTheme.bodyLarge;
        case TextStyleName.bodyMedium:
          return textTheme.bodyMedium;  
        case TextStyleName.bodySmall:
          return textTheme.bodySmall;
        case TextStyleName.headlineMedium:
          return textTheme.headlineMedium;
        case TextStyleName.headlineSmall:
          return textTheme.headlineSmall; 
        case TextStyleName.titleLarge:
          return textTheme.titleLarge;  
        case TextStyleName.titleMedium: 
          return textTheme.titleMedium; 
        case TextStyleName.titleSmall:  
          return textTheme.titleSmall;
        case TextStyleName.labelLarge:
          return textTheme.labelLarge;
        case TextStyleName.labelSmall:  
          return textTheme.labelSmall;
      }
    } 
    return textTheme.displayMedium;
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (child != null) child!,
          Container(
            decoration: BoxDecoration(
              color: opacity != null ? boxColor.withOpacity(opacity!) : boxColor,
              borderRadius: BorderRadius.all(borderRadius),
            ),
            padding: padding,
            child: Text(
              message,
              style: _getTextStyle(context)
                  ?.copyWith(
                    color: textColor,
                    fontFamily: fontFamily,
                    fontWeight: fontWeight
                  ),
              textAlign: textAlign,
            ),
          ),
        ],
      );
    // return DecoratedBox(
    //     decoration: BoxDecoration(
    //       color: PhotoboothColors.gray.withOpacity(0.5),
    //       borderRadius: BorderRadius.circular(10),
    //     ),
    //     child: Container(
    //         padding: EdgeInsets.all(15),
    //         child: Text(
    //           message,
    //           style: theme.textTheme.displayLarge?.copyWith(
    //               color: PhotoboothColors.accent, fontFamily: 'Playfair'),
    //           textAlign: TextAlign.center,
    //         )));
  }
}
