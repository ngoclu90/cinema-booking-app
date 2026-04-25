import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../design_system/tokens/index.dart';
import 'design_tokens.dart';

class AppTheme {
  static const Color brandRed = AppColors.brandPrimary;
  static const Color brandRedDeep = AppColors.brandPrimaryDark;
  static const Color pureBlack = AppColors.bgApp;

  static final TextTheme _textTheme = GoogleFonts.beVietnamProTextTheme(
    const TextTheme(
      displaySmall: AppTypography.display,
      headlineMedium: AppTypography.title,
      titleLarge: AppTypography.subtitle,
      titleMedium: AppTypography.bodyStrong,
      bodyLarge: TextStyle(fontSize: 16, height: 24 / 16),
      bodyMedium: AppTypography.body,
      bodySmall: AppTypography.caption,
      labelLarge: AppTypography.captionStrong,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: pureBlack,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: brandRed,
      onPrimary: Colors.white,
      secondary: Colors.white,
      onSecondary: Colors.black,
      surface: AppColors.bgSurface,
      onSurface: AppColors.textPrimary,
      error: AppColors.stateError,
      onError: Colors.white,
      primaryContainer: AppColors.brandPrimarySoft,
      onPrimaryContainer: AppColors.textPrimary,
      secondaryContainer: AppColors.bgSurface2,
      onSecondaryContainer: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      surfaceTintColor: Colors.transparent,
      backgroundColor: AppColors.bgApp,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      elevation: 0,
      color: AppColors.bgSurface,
      shadowColor: Colors.transparent,
    ),
    textTheme: _textTheme.apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    dividerColor: AppColors.borderDefault,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.bgSurface2,
      hintStyle: const TextStyle(color: AppColors.textMuted),
      prefixIconColor: AppColors.textMuted,
      suffixIconColor: AppColors.textMuted,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: const BorderSide(color: AppColors.borderDefault),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: const BorderSide(color: AppColors.borderDefault),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: const BorderSide(color: brandRed, width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: const BorderSide(color: AppColors.stateError),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.bgSurface2,
      selectedColor: brandRed,
      secondarySelectedColor: brandRed,
      labelStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      secondaryLabelStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      side: const BorderSide(color: AppColors.borderDefault),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: brandRed,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        elevation: 0,
        minimumSize: const Size.fromHeight(44),
        textStyle: AppTypography.bodyStrong,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: AppColors.bgSurface2,
        minimumSize: const Size.fromHeight(44),
        side: const BorderSide(color: AppColors.borderDefault),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        textStyle: AppTypography.bodyStrong,
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.bgSurface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.bgSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
    ),
  );

  static final ThemeData lightTheme = darkTheme;

  static Color surfaceLayer(BuildContext context, {int level = 1}) {
    switch (level) {
      case 0:
        return AppColors.bgApp;
      case 1:
        return AppColors.bgSurface;
      case 2:
        return AppColors.bgSurface2;
      default:
        return AppColors.bgSurface3;
    }
  }
}
