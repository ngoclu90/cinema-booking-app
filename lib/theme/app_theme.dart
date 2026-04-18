import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'design_tokens.dart';

class AppTheme {
  static const Color brandRed = Color(0xFFE12636);
  static const Color brandRedDeep = Color(0xFF8F101F);
  static const Color pureWhite = Colors.white;
  static const Color pureBlack = Colors.black;
  static const Color lightLayer = Color(0xFFF5F5F5);
  static const Color lightLayerStrong = Color(0xFFEDEDED);
  static const Color darkLayer = Color(0xFF0E0E0E);
  static const Color darkLayerStrong = Color(0xFF161616);

  static final TextTheme _textTheme = GoogleFonts.beVietnamProTextTheme(
    const TextTheme(
      displaySmall: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
        height: 1.08,
      ),
      headlineMedium: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        height: 1.14,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.15,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.55,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.55,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.45,
      ),
      labelLarge: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    ),
  );

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: pureWhite,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: brandRed,
      onPrimary: Colors.white,
      secondary: Color(0xFF101010),
      onSecondary: Colors.white,
      surface: pureWhite,
      onSurface: Color(0xFF121212),
      error: Color(0xFFB00020),
      onError: Colors.white,
      primaryContainer: Color(0xFFFFE8EB),
      onPrimaryContainer: brandRedDeep,
      secondaryContainer: lightLayer,
      onSecondaryContainer: Color(0xFF181818),
    ),
    appBarTheme: const AppBarTheme(
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.black,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      elevation: 0,
      color: lightLayer,
      shadowColor: const Color(0x14000000),
    ),
    textTheme: _textTheme.apply(
      bodyColor: const Color(0xFF111111),
      displayColor: const Color(0xFF111111),
    ),
    dividerColor: const Color(0xFFE9E9E9),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightLayer,
      hintStyle: const TextStyle(color: Color(0xFF8A8A8A)),
      prefixIconColor: const Color(0xFF8A8A8A),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        borderSide: const BorderSide(color: brandRed, width: 1.2),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: lightLayer,
      selectedColor: brandRed,
      secondarySelectedColor: brandRed,
      labelStyle: const TextStyle(
        color: Color(0xFF101010),
        fontWeight: FontWeight.w600,
      ),
      secondaryLabelStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: brandRed,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
        elevation: 0,
        minimumSize: const Size.fromHeight(56),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF141414),
        backgroundColor: lightLayer,
        minimumSize: const Size.fromHeight(56),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
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
      surface: pureBlack,
      onSurface: Colors.white,
      error: Color(0xFFCF6679),
      onError: Colors.black,
      primaryContainer: Color(0xFF420912),
      onPrimaryContainer: Color(0xFFFFCFCF),
      secondaryContainer: darkLayer,
      onSecondaryContainer: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      elevation: 0,
      color: darkLayer,
      shadowColor: Colors.black45,
    ),
    textTheme: _textTheme.apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    dividerColor: const Color(0xFF1C1C1C),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkLayerStrong,
      hintStyle: const TextStyle(color: Color(0xFF7E7E7E)),
      prefixIconColor: const Color(0xFF7E7E7E),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        borderSide: const BorderSide(color: brandRed, width: 1.2),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: darkLayerStrong,
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
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: brandRed,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
        elevation: 0,
        minimumSize: const Size.fromHeight(56),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: darkLayerStrong,
        minimumSize: const Size.fromHeight(56),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
  );

  static Color surfaceLayer(BuildContext context, {int level = 1}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      switch (level) {
        case 0:
          return pureBlack;
        case 1:
          return darkLayer;
        default:
          return darkLayerStrong;
      }
    }

    switch (level) {
      case 0:
        return pureWhite;
      case 1:
        return lightLayer;
      default:
        return lightLayerStrong;
    }
  }
}
