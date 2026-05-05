import 'package:flutter/material.dart';

export '../design_system/tokens/index.dart';

class AppDurations {
  const AppDurations._();

  static const Duration short = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 200);
  static const Duration long = Duration(milliseconds: 250);
}

extension ColorOpacityHelper on Color {
  Color withAlphaPercent(double percent) =>
      withAlpha((percent * 255).round().clamp(0, 255));
}

extension BuildContextThemeX on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
