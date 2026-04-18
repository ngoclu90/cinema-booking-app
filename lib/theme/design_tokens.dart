import 'package:flutter/material.dart';

class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 18;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 40;
}

class AppRadius {
  static const double small = 10;
  static const double medium = 14;
  static const double card = 16;
  static const double large = 18;
  static const double hero = 22;
  static const double pill = 999;
}

class AppDurations {
  static const Duration short = Duration(milliseconds: 220);
  static const Duration medium = Duration(milliseconds: 360);
  static const Duration long = Duration(milliseconds: 520);
}

class AppShadows {
  static const BoxShadow soft = BoxShadow(
    color: Colors.black12,
    blurRadius: 18,
    offset: Offset(0, 10),
  );

  static const BoxShadow ambient = BoxShadow(
    color: Color(0x14000000),
    blurRadius: 30,
    offset: Offset(0, 16),
  );
}

extension ColorOpacityHelper on Color {
  Color withAlphaPercent(double percent) =>
      withAlpha((percent * 255).round().clamp(0, 255));
}

extension BuildContextThemeX on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
