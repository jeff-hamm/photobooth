import 'package:flutter/material.dart';
import 'package:io_photobooth/common/widgets.dart';
import 'package:io_photobooth/theme_config.dart';
import 'colors.dart';
import 'text_styles.dart';
export './colors.dart';
export './typography.dart';
export './layout.dart';
const _smallTextScaleFactor = AppTheme.lowResTextScaleFactor;

enum TextStyleName {
  displayLarge,
  displayMedium,
  displaySmall,
  headlineMedium,
  headlineSmall,
  titleLarge,
  titleMedium,
  titleSmall,
  bodyLarge,
  bodyMedium,
  bodySmall,
  labelSmall,
  labelLarge,
}

/// Namespace for the Photobooth [ThemeData].
class PhotoboothTheme {
  /// Standard `ThemeData` for Photobooth UI.
  static ThemeData get standard {
    return ThemeData(
      colorScheme: 
        AppTheme.colorScheme,
      // ColorScheme.fromSwatch(
      //   primarySwatch: PhotoboothColors.primary,
      //   accentColor: PhotoboothColors.accent),
      appBarTheme: _appBarTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      fontFamily: 'Playfair',
      textTheme: _textTheme,
      dialogBackgroundColor: PhotoboothColors.whiteBackground,
      dialogTheme: _dialogTheme,
      tooltipTheme: _tooltipTheme,
      bottomSheetTheme: _bottomSheetTheme,
      tabBarTheme: _tabBarTheme,
      dividerTheme: _dividerTheme,
      iconButtonTheme: _iconButtonTheme(_standardIconSize),
      iconTheme: _iconTheme(_standardIconSize), 
    );
  }

  /// `ThemeData` for Photobooth UI for small screens.
  static ThemeData get small {
    return standard.copyWith(
      textTheme: _smallTextTheme,
      iconButtonTheme: _iconButtonTheme(_smallIconSize),
      iconTheme: _iconTheme(_smallIconSize)
    );
  }

  /// `ThemeData` for Photobooth UI for medium screens.
  static ThemeData get medium {
    return standard.copyWith(
      textTheme: _smallTextTheme,
      iconButtonTheme: _iconButtonTheme(_mediumIconSize),
      iconTheme: _iconTheme(_mediumIconSize)
    );
  }
  static const double _standardIconSize = 40;
  static const double _mediumIconSize = 30;
  static const double _smallIconSize = 20;

  static IconButtonThemeData _iconButtonTheme(double iconSize) {
    return IconButtonThemeData( style: ButtonStyle(
        alignment: Alignment.center,
//        backgroundColor: const WidgetStatePropertyAll(PhotoboothColors.white),
        iconColor: const WidgetStatePropertyAll(PhotoboothColors.primary),
        padding: const WidgetStatePropertyAll(EdgeInsets.all(10)),
        iconSize: WidgetStatePropertyAll(iconSize + 30),  
//        fixedSize: WidgetStatePropertyAll(Size(iconSize + 40,iconSize + 80)),
        // maximumSize: const WidgetStatePropertyAll(Size(200,200)),
        // iconSize: WidgetStatePropertyAll(iconSize)
      ));

  }
  static IconThemeData _iconTheme(double iconSize) =>
      IconThemeData(
        color: PhotoboothColors.primary,
        applyTextScaling: true,
        size: iconSize
      );
  static TextTheme get _textTheme {
    return TextTheme(
      displayLarge: PhotoboothTextStyle.headline1,
      displayMedium: PhotoboothTextStyle.headline2,
      displaySmall: PhotoboothTextStyle.headline3,
      headlineMedium: PhotoboothTextStyle.headline4,
      headlineSmall: PhotoboothTextStyle.headline5,
      titleLarge: PhotoboothTextStyle.headline6,
      titleMedium: PhotoboothTextStyle.subtitle1,
      titleSmall: PhotoboothTextStyle.subtitle2,
      bodyLarge: PhotoboothTextStyle.bodyText1,
      bodyMedium: PhotoboothTextStyle.bodyText2,
      bodySmall: PhotoboothTextStyle.caption,
      labelSmall: PhotoboothTextStyle.overline,
      labelLarge: PhotoboothTextStyle.button,
    );
  }

  static TextTheme get _smallTextTheme {
    return TextTheme(
      displayLarge: PhotoboothTextStyle.headline1.copyWith(
        fontSize: _textTheme.displayLarge!.fontSize! * _smallTextScaleFactor,
      ),
      displayMedium: PhotoboothTextStyle.headline2.copyWith(
        fontSize: _textTheme.displayMedium!.fontSize! * _smallTextScaleFactor,
      ),
      displaySmall: PhotoboothTextStyle.headline3.copyWith(
        fontSize: _textTheme.displaySmall!.fontSize! * _smallTextScaleFactor,
      ),
      headlineMedium: PhotoboothTextStyle.headline4.copyWith(
        fontSize: _textTheme.headlineMedium!.fontSize! * _smallTextScaleFactor,
      ),
      headlineSmall: PhotoboothTextStyle.headline5.copyWith(
        fontSize: _textTheme.headlineSmall!.fontSize! * _smallTextScaleFactor,
      ),
      titleLarge: PhotoboothTextStyle.headline6.copyWith(
        fontSize: _textTheme.titleLarge!.fontSize! * _smallTextScaleFactor,
      ),
      titleMedium: PhotoboothTextStyle.subtitle1.copyWith(
        fontSize: _textTheme.titleMedium!.fontSize! * _smallTextScaleFactor,
      ),
      titleSmall: PhotoboothTextStyle.subtitle2.copyWith(
        fontSize: _textTheme.titleSmall!.fontSize! * _smallTextScaleFactor,
      ),
      bodyLarge: PhotoboothTextStyle.bodyText1.copyWith(
        fontSize: _textTheme.bodyLarge!.fontSize! * _smallTextScaleFactor,
      ),
      bodyMedium: PhotoboothTextStyle.bodyText2.copyWith(
        fontSize: _textTheme.bodyMedium!.fontSize! * _smallTextScaleFactor,
      ),
      bodySmall: PhotoboothTextStyle.caption.copyWith(
        fontSize: _textTheme.bodySmall!.fontSize! * _smallTextScaleFactor,
      ),
      labelSmall: PhotoboothTextStyle.overline.copyWith(
        fontSize: _textTheme.labelSmall!.fontSize! * _smallTextScaleFactor,
      ),
      labelLarge: PhotoboothTextStyle.button.copyWith(
        fontSize: _textTheme.labelLarge!.fontSize! * _smallTextScaleFactor,
      ),
    );
  }

  static AppBarTheme get _appBarTheme {
    return const AppBarTheme(color: PhotoboothColors.primary);
  }

  static ElevatedButtonThemeData get _elevatedButtonTheme {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        foregroundColor: PhotoboothColors.black,
        backgroundColor: PhotoboothColors.primary,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        minimumSize: const Size(208, 54),
      ),
    );
  }

  static OutlinedButtonThemeData get _outlinedButtonTheme {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: PhotoboothColors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
        ),
        side: const BorderSide(color: PhotoboothColors.white, width: 2),
        padding: const EdgeInsets.symmetric(vertical: 16),
        minimumSize: const Size(208, 54),
      ),
    );
  }

  static TooltipThemeData get _tooltipTheme {
    return const TooltipThemeData(
      decoration: BoxDecoration(
        color: PhotoboothColors.textBackground,
        borderRadius: BorderRadius.all(AppTheme.textBoxCorners),
      ),
      padding: EdgeInsets.all(10),
      textStyle: TextStyle(color: PhotoboothColors.white),
    );
  }

  static DialogTheme get _dialogTheme {
    return DialogTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  static BottomSheetThemeData get _bottomSheetTheme {
    return const BottomSheetThemeData(
      backgroundColor: PhotoboothColors.whiteBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
    );
  }

  static TabBarTheme get _tabBarTheme {
    return const TabBarTheme(
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(
          width: 2,
          color: PhotoboothColors.accent,
        ),
      ),
      labelColor: PhotoboothColors.accent,
      unselectedLabelColor: PhotoboothColors.black25,
      indicatorSize: TabBarIndicatorSize.tab,
    );
  }

  static DividerThemeData get _dividerTheme {
    return const DividerThemeData(
      space: 0,
      thickness: 1,
      color: PhotoboothColors.black25,
    );
  }
}
