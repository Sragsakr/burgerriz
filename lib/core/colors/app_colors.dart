import 'package:flutter/material.dart';

/// Centralized color management for the entire application
/// This class provides a single source of truth for all color values
/// Works alongside the existing FlutterFlowTheme system
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // ============================================================================
  // BRAND COLORS
  // ============================================================================
  
  /// Primary brand color - Blue
  static const Color primary = Color(0xFFAF2A26);
  
  /// Secondary brand color - Teal
  static const Color secondary = Color(0xFF39D2C0);
  
  /// Tertiary brand color - Orange
  static const Color tertiary = Color(0xFFEE8B60);
  
  /// Success color - Green
  static const Color success = Color(0xFF249689);

  static const Color piatto = Color(0xFF189e55);
  
  /// Warning color - Yellow
  static const Color warning = Color(0xFFF9CF58);
  
  /// Error color - Red
  static const Color error = Color(0xFFFF5963);
  
  /// Info color - Blue
  static const Color info = Color(0xFF4B39EF);

  // ============================================================================
  // NEUTRAL COLORS
  // ============================================================================
  
  /// Pure white
  static const Color white = Color(0xFFFFFFFF);
  
  /// Pure black
  static const Color black = Color(0xFF000000);
  
  /// Light gray
  static const Color gray100 = Color(0xFFF7FAFC);
  static const Color gray200 = Color(0xFFDBE2E7);
  static const Color gray300 = Color(0xFFCBD5E0);
  static const Color gray400 = Color(0xFFA0AEC0);
  static const Color gray500 = Color(0xFF718096);
  static const Color gray600 = Color(0xFF4A5568);
  static const Color gray700 = Color(0xFF2D3748);
  static const Color gray800 = Color(0xFF1A202C);
  static const Color gray900 = Color(0xFF171923);

  // ============================================================================
  // SEMANTIC COLORS
  // ============================================================================
  
  /// Background colors
  static const Color backgroundLight = Color(0xFFF1F4F8);
  static const Color backgroundDark = Color(0xFF1D2428);
  static const Color backgroundSecondary = Color(0xFFFFFFFF);
  static const Color backgroundSecondaryDark = Color(0xFF14181B);
  
  /// Text colors
  static const Color textPrimary = Color(0xFF14181B);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF57636C);
  static const Color textSecondaryDark = Color(0xFF95A1AC);
  
  /// Border and line colors
  static const Color border = Color(0xFFE0E3E7);
  static const Color borderDark = Color(0xFF262D34);
  static const Color lineColor = Color(0xFFE0E3E7);
  static const Color lineColorDark = Color(0xFF22282F);

  // ============================================================================
  // UI COMPONENT COLORS
  // ============================================================================
  
  /// Button colors
  static const Color buttonPrimary = Color(0xFF4B39EF);
  static const Color buttonSecondary = Color(0xFF39D2C0);
  static const Color buttonTertiary = Color(0xFFEE8B60);
  static const Color buttonText = Color(0xFFFFFFFF);
  static const Color buttonDisabled = Color(0xFFCBD5E0);
  
  /// Card colors
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBackgroundDark = Color(0xFF1D2428);
  static const Color cardBorder = Color(0xFFE0E3E7);
  static const Color cardBorderDark = Color(0xFF262D34);
  
  /// Input field colors
  static const Color inputBackground = Color(0xFFFFFFFF);
  static const Color inputBackgroundDark = Color(0xFF1D2428);
  static const Color inputBorder = Color(0xFFE0E3E7);
  static const Color inputBorderDark = Color(0xFF262D34);
  static const Color inputBorderFocused = Color(0xFF4B39EF);
  static const Color inputPlaceholder = Color(0xFFA0AEC0);

  // ============================================================================
  // STATUS COLORS
  // ============================================================================
  
  /// Success states
  static const Color successLight = Color(0xFFE6FFFA);
  static const Color successDark = Color(0xFF1A365D);
  static const Color successBorder = Color(0xFF249689);
  
  /// Warning states
  static const Color warningLight = Color(0xFFFFFBF0);
  static const Color warningDark = Color(0xFF744210);
  static const Color warningBorder = Color(0xFFF9CF58);
  
  /// Error states
  static const Color errorLight = Color(0xFFFED7D7);
  static const Color errorDark = Color(0xFF742A2A);
  static const Color errorBorder = Color(0xFFFF5963);
  
  /// Info states
  static const Color infoLight = Color(0xFFEBF8FF);
  static const Color infoDark = Color(0xFF2A4365);
  static const Color infoBorder = Color(0xFF4B39EF);

  // ============================================================================
  // OVERLAY COLORS
  // ============================================================================
  
  /// Overlay colors for modals, dialogs, etc.
  static const Color overlayLight = Color(0xB3FFFFFF);
  static const Color overlayDark = Color(0xB314181B);
  static const Color overlayTransparent = Color(0x00FFFFFF);
  static const Color overlayDarkTransparent = Color(0x000B191E);

  // ============================================================================
  // CUSTOM BRAND COLORS
  // ============================================================================
  
  /// Custom colors specific to the app
  static const Color customRed = Color(0xFFDF3F3F);
  static const Color customGreen = Color(0xFF2FB73C);
  static const Color customBlue = Color(0xFF452FB7);
  static const Color customDark = Color(0xFF090F13);
  static const Color customTeal = Color(0xFF2E8B8B);
  static const Color customBrown = Color(0xFF877350);
  static const Color customDarkBlue = Color(0xFF263645);

  // ============================================================================
  // ACCENT COLORS
  // ============================================================================
  
  /// Accent colors with transparency
  static const Color accent1 = Color(0x4C4B39EF);
  static const Color accent2 = Color(0x4D39D2C0);
  static const Color accent3 = Color(0x4DEE8B60);
  static const Color accent4 = Color(0xCCFFFFFF);
  static const Color accent4Dark = Color(0xB2262D34);

  // ============================================================================
  // COLOR VARIATIONS
  // ============================================================================
  
  /// Primary color variations
  static const Color primary600 = Color(0xFF336A4A);
  static const Color primary30 = Color(0x4D4B986C);
  
  /// Secondary color variations
  static const Color secondary600 = Color(0xFF6D604A);
  static const Color secondary30 = Color(0x4D928163);
  static const Color secondary400 = Color(0xFF39D2C0);
  
  /// Tertiary color variations
  static const Color tertiary600 = Color(0xFF0C2533);
  
  /// Gray variations
  static const Color grayIcon = Color(0xFF95A1AC);
  static const Color black600 = Color(0xFF090F13);
  static const Color darkBGstatic = Color(0xFF0D1E23);

  // ============================================================================
  // COLOR CATEGORIES FOR DYNAMIC ACCESS
  // ============================================================================
  
  /// Get all brand colors
  static List<Color> get brandColors => [
    primary,
    secondary,
    tertiary,
    success,
    warning,
    error,
    info,
  ];

  /// Get all neutral colors
  static List<Color> get neutralColors => [
    white,
    black,
    gray100,
    gray200,
    gray300,
    gray400,
    gray500,
    gray600,
    gray700,
    gray800,
    gray900,
  ];

  /// Get all semantic colors
  static List<Color> get semanticColors => [
    backgroundLight,
    backgroundDark,
    textPrimary,
    textPrimaryDark,
    textSecondary,
    textSecondaryDark,
    border,
    borderDark,
  ];

  /// Get all status colors
  static List<Color> get statusColors => [
    success,
    successLight,
    successDark,
    warning,
    warningLight,
    warningDark,
    error,
    errorLight,
    errorDark,
    info,
    infoLight,
    infoDark,
  ];

  /// Get all custom colors
  static List<Color> get customColors => [
    customRed,
    customGreen,
    customBlue,
    customDark,
    customTeal,
    customBrown,
    customDarkBlue,
  ];

  /// Get all accent colors
  static List<Color> get accentColors => [
    accent1,
    accent2,
    accent3,
    accent4,
    accent4Dark,
  ];

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================
  
  /// Get color by name (case-insensitive)
  static Color? getColorByName(String name) {
    final lowerName = name.toLowerCase();
    
    final colorMap = <String, Color>{
      'primary': primary,
      'secondary': secondary,
      'tertiary': tertiary,
      'success': success,
      'warning': warning,
      'error': error,
      'info': info,
      'white': white,
      'black': black,
      'gray100': gray100,
      'gray200': gray200,
      'gray300': gray300,
      'gray400': gray400,
      'gray500': gray500,
      'gray600': gray600,
      'gray700': gray700,
      'gray800': gray800,
      'gray900': gray900,
      'backgroundlight': backgroundLight,
      'backgrounddark': backgroundDark,
      'textprimary': textPrimary,
      'textsecondary': textSecondary,
      'border': border,
      'customred': customRed,
      'customgreen': customGreen,
      'customblue': customBlue,
      'customteal': customTeal,
      'custombrown': customBrown,
      'customdarkblue': customDarkBlue,
    };
    
    return colorMap[lowerName];
  }

  /// Get random color from a category
  static Color getRandomColorFromCategory(List<Color> category) {
    if (category.isEmpty) return primary;
    final random = DateTime.now().millisecondsSinceEpoch % category.length;
    return category[random];
  }

  /// Check if color is light or dark
  static bool isLightColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5;
  }

  /// Get contrasting text color (black or white) for a background color
  static Color getContrastingTextColor(Color backgroundColor) {
    return isLightColor(backgroundColor) ? black : white;
  }

  /// Get color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }

  /// Get color with brightness adjustment
  static Color withBrightness(Color color, double brightness) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + brightness).clamp(0.0, 1.0)).toColor();
  }

  /// Get color with saturation adjustment
  static Color withSaturation(Color color, double saturation) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withSaturation((hsl.saturation + saturation).clamp(0.0, 1.0)).toColor();
  }

  /// Create a gradient from two colors
  static LinearGradient createGradient(Color startColor, Color endColor, {
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      colors: [startColor, endColor],
      begin: begin,
      end: end,
    );
  }

  /// Create a gradient from multiple colors
  static LinearGradient createMultiColorGradient(List<Color> colors, {
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
    List<double>? stops,
  }) {
    return LinearGradient(
      colors: colors,
      begin: begin,
      end: end,
      stops: stops,
    );
  }
}
