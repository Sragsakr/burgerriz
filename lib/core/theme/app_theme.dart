import 'package:flutter/material.dart';

// Theme mode data helper
class AppThemeModeData {
  static TextStyle getTextStyleForCurrentTheme({
    required TextStyleType styleType,
    required double fontSize,
  }) {
    // Return a default text style - you can customize this based on your theme
    return TextStyle(
      fontSize: fontSize,
      color: AppThemeColors.lightScaffoldBackground,
    );
  }
}

// Theme colors
class AppThemeColors {
  static const Color lightScaffoldBackground = Color(0xFFF5F5F5);
  static const Color lightBackground = Color(0xFFFFFFFF);
  
  static Color getSecondaryTextColor() {
    return Colors.grey.shade600;
  }
}

// Text style types
enum TextStyleType {
  bodyMedium,
  bodyLarge,
  bodySmall,
  headlineLarge,
  headlineMedium,
  headlineSmall,
  titleLarge,
  titleMedium,
  titleSmall,
  labelLarge,
  labelMedium,
  labelSmall,
}
