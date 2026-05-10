import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Advanced color manager for dynamic color operations and theme management
/// Provides utilities for color manipulation, theme switching, and dynamic color generation
class ColorManager {
  // Private constructor to prevent instantiation
  ColorManager._();

  // Cache for computed colors
  static final Map<String, Color> _colorCache = {};
  static final Map<String, LinearGradient> _gradientCache = {};

  // ============================================================================
  // THEME-AWARE COLOR METHODS
  // ============================================================================

  /// Get theme-aware color based on current brightness
  static Color getThemeAwareColor(
    BuildContext context, {
    required Color lightColor,
    required Color darkColor,
  }) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.light ? lightColor : darkColor;
  }

  /// Get theme-aware background color
  static Color getBackgroundColor(BuildContext context) {
    return getThemeAwareColor(
      context,
      lightColor: AppColors.backgroundLight,
      darkColor: AppColors.backgroundDark,
    );
  }

  /// Get theme-aware text color
  static Color getTextColor(BuildContext context) {
    return getThemeAwareColor(
      context,
      lightColor: AppColors.textPrimary,
      darkColor: AppColors.textPrimaryDark,
    );
  }

  /// Get theme-aware secondary text color
  static Color getSecondaryTextColor(BuildContext context) {
    return getThemeAwareColor(
      context,
      lightColor: AppColors.textSecondary,
      darkColor: AppColors.textSecondaryDark,
    );
  }

  /// Get theme-aware border color
  static Color getBorderColor(BuildContext context) {
    return getThemeAwareColor(
      context,
      lightColor: AppColors.border,
      darkColor: AppColors.borderDark,
    );
  }

  /// Get theme-aware card background color
  static Color getCardBackgroundColor(BuildContext context) {
    return getThemeAwareColor(
      context,
      lightColor: AppColors.cardBackground,
      darkColor: AppColors.cardBackgroundDark,
    );
  }

  // ============================================================================
  // DYNAMIC COLOR GENERATION
  // ============================================================================

  /// Generate color with opacity
  static Color withOpacity(Color color, double opacity) {
    final cacheKey = '${color.value}_opacity_$opacity';
    if (_colorCache.containsKey(cacheKey)) {
      return _colorCache[cacheKey]!;
    }

    final result = color.withValues(alpha: opacity);
    _colorCache[cacheKey] = result;
    return result;
  }

  /// Generate lighter version of color
  static Color lighten(Color color, [double amount = 0.1]) {
    final cacheKey = '${color.value}_lighten_$amount';
    if (_colorCache.containsKey(cacheKey)) {
      return _colorCache[cacheKey]!;
    }

    final hsl = HSLColor.fromColor(color);
    final result = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
    _colorCache[cacheKey] = result;
    return result;
  }

  /// Generate darker version of color
  static Color darken(Color color, [double amount = 0.1]) {
    final cacheKey = '${color.value}_darken_$amount';
    if (_colorCache.containsKey(cacheKey)) {
      return _colorCache[cacheKey]!;
    }

    final hsl = HSLColor.fromColor(color);
    final result = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
    _colorCache[cacheKey] = result;
    return result;
  }

  /// Generate color with adjusted saturation
  static Color adjustSaturation(Color color, double amount) {
    final cacheKey = '${color.value}_saturation_$amount';
    if (_colorCache.containsKey(cacheKey)) {
      return _colorCache[cacheKey]!;
    }

    final hsl = HSLColor.fromColor(color);
    final result = hsl.withSaturation((hsl.saturation + amount).clamp(0.0, 1.0)).toColor();
    _colorCache[cacheKey] = result;
    return result;
  }

  /// Generate color with adjusted hue
  static Color adjustHue(Color color, double amount) {
    final cacheKey = '${color.value}_hue_$amount';
    if (_colorCache.containsKey(cacheKey)) {
      return _colorCache[cacheKey]!;
    }

    final hsl = HSLColor.fromColor(color);
    final result = hsl.withHue((hsl.hue + amount) % 360).toColor();
    _colorCache[cacheKey] = result;
    return result;
  }

  // ============================================================================
  // GRADIENT GENERATION
  // ============================================================================

  /// Create linear gradient with caching
  static LinearGradient createLinearGradient(
    Color startColor,
    Color endColor, {
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
    List<double>? stops,
  }) {
    final cacheKey = '${startColor.value}_${endColor.value}_${begin.toString()}_${end.toString()}_${stops?.join(',')}';
    if (_gradientCache.containsKey(cacheKey)) {
      return _gradientCache[cacheKey]!;
    }

    final gradient = LinearGradient(
      colors: [startColor, endColor],
      begin: begin,
      end: end,
      stops: stops,
    );
    _gradientCache[cacheKey] = gradient;
    return gradient;
  }

  /// Create radial gradient
  static RadialGradient createRadialGradient(
    Color centerColor,
    Color edgeColor, {
    AlignmentGeometry center = Alignment.center,
    double radius = 0.5,
    List<double>? stops,
  }) {
    return RadialGradient(
      colors: [centerColor, edgeColor],
      center: center,
      radius: radius,
      stops: stops,
    );
  }

  /// Create multi-color gradient
  static LinearGradient createMultiColorGradient(
    List<Color> colors, {
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
    List<double>? stops,
  }) {
    final cacheKey = 'multi_${colors.map((c) => c.value).join('_')}_${begin.toString()}_${end.toString()}_${stops?.join(',')}';
    if (_gradientCache.containsKey(cacheKey)) {
      return _gradientCache[cacheKey]!;
    }

    final gradient = LinearGradient(
      colors: colors,
      begin: begin,
      end: end,
      stops: stops,
    );
    _gradientCache[cacheKey] = gradient;
    return gradient;
  }

  // ============================================================================
  // STATUS COLOR HELPERS
  // ============================================================================

  /// Get status color based on status type
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'completed':
      case 'active':
        return AppColors.success;
      case 'warning':
      case 'pending':
      case 'processing':
        return AppColors.warning;
      case 'error':
      case 'failed':
      case 'cancelled':
        return AppColors.error;
      case 'info':
      case 'information':
        return AppColors.info;
      default:
        return AppColors.gray500;
    }
  }

  /// Get status background color
  static Color getStatusBackgroundColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'completed':
      case 'active':
        return AppColors.successLight;
      case 'warning':
      case 'pending':
      case 'processing':
        return AppColors.warningLight;
      case 'error':
      case 'failed':
      case 'cancelled':
        return AppColors.errorLight;
      case 'info':
      case 'information':
        return AppColors.infoLight;
      default:
        return AppColors.gray100;
    }
  }

  /// Get status border color
  static Color getStatusBorderColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'completed':
      case 'active':
        return AppColors.successBorder;
      case 'warning':
      case 'pending':
      case 'processing':
        return AppColors.warningBorder;
      case 'error':
      case 'failed':
      case 'cancelled':
        return AppColors.errorBorder;
      case 'info':
      case 'information':
        return AppColors.infoBorder;
      default:
        return AppColors.gray300;
    }
  }

  // ============================================================================
  // COLOR VALIDATION AND UTILITIES
  // ============================================================================

  /// Check if color is light
  static bool isLightColor(Color color) {
    return AppColors.isLightColor(color);
  }

  /// Check if color is dark
  static bool isDarkColor(Color color) {
    return !isLightColor(color);
  }

  /// Get contrasting text color
  static Color getContrastingTextColor(Color backgroundColor) {
    return AppColors.getContrastingTextColor(backgroundColor);
  }

  /// Calculate color contrast ratio
  static double getContrastRatio(Color color1, Color color2) {
    final luminance1 = color1.computeLuminance();
    final luminance2 = color2.computeLuminance();
    
    final lighter = luminance1 > luminance2 ? luminance1 : luminance2;
    final darker = luminance1 > luminance2 ? luminance2 : luminance1;
    
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Check if colors have sufficient contrast
  static bool hasSufficientContrast(Color color1, Color color2, {double threshold = 4.5}) {
    return getContrastRatio(color1, color2) >= threshold;
  }

  /// Get accessible text color for background
  static Color getAccessibleTextColor(Color backgroundColor) {
    final whiteContrast = getContrastRatio(backgroundColor, AppColors.white);
    final blackContrast = getContrastRatio(backgroundColor, AppColors.black);
    
    return whiteContrast > blackContrast ? AppColors.white : AppColors.black;
  }

  // ============================================================================
  // COLOR BLENDING
  // ============================================================================

  /// Blend two colors
  static Color blendColors(Color color1, Color color2, double ratio) {
    final cacheKey = '${color1.value}_${color2.value}_$ratio';
    if (_colorCache.containsKey(cacheKey)) {
      return _colorCache[cacheKey]!;
    }

    final result = Color.lerp(color1, color2, ratio) ?? color1;
    _colorCache[cacheKey] = result;
    return result;
  }

  /// Mix multiple colors
  static Color mixColors(List<Color> colors) {
    if (colors.isEmpty) return AppColors.primary;
    if (colors.length == 1) return colors.first;

    Color result = colors.first;
    for (int i = 1; i < colors.length; i++) {
      result = blendColors(result, colors[i], 0.5);
    }
    return result;
  }

  // ============================================================================
  // CACHE MANAGEMENT
  // ============================================================================

  /// Clear color cache
  static void clearCache() {
    _colorCache.clear();
    _gradientCache.clear();
  }

  /// Clear specific color from cache
  static void clearColorFromCache(Color color) {
    _colorCache.removeWhere((key, value) => key.contains(color.value.toString()));
  }

  /// Get cache size information
  static Map<String, int> getCacheInfo() {
    return {
      'colors': _colorCache.length,
      'gradients': _gradientCache.length,
    };
  }

  // ============================================================================
  // PRESET COLOR SCHEMES
  // ============================================================================

  /// Get color scheme for different contexts
  static Map<String, Color> getColorScheme(String context) {
    switch (context.toLowerCase()) {
      case 'payment':
        return {
          'primary': AppColors.primary,
          'secondary': AppColors.success,
          'background': AppColors.backgroundLight,
          'text': AppColors.textPrimary,
          'border': AppColors.border,
        };
      case 'menu':
        return {
          'primary': AppColors.secondary,
          'secondary': AppColors.tertiary,
          'background': AppColors.backgroundLight,
          'text': AppColors.textPrimary,
          'border': AppColors.border,
        };
      case 'success':
        return {
          'primary': AppColors.success,
          'secondary': AppColors.white,
          'background': AppColors.successLight,
          'text': AppColors.textPrimary,
          'border': AppColors.successBorder,
        };
      case 'error':
        return {
          'primary': AppColors.error,
          'secondary': AppColors.white,
          'background': AppColors.errorLight,
          'text': AppColors.textPrimary,
          'border': AppColors.errorBorder,
        };
      default:
        return {
          'primary': AppColors.primary,
          'secondary': AppColors.secondary,
          'background': AppColors.backgroundLight,
          'text': AppColors.textPrimary,
          'border': AppColors.border,
        };
    }
  }

  /// Get random color from category
  static Color getRandomColor(String category) {
    switch (category.toLowerCase()) {
      case 'brand':
        return AppColors.getRandomColorFromCategory(AppColors.brandColors);
      case 'neutral':
        return AppColors.getRandomColorFromCategory(AppColors.neutralColors);
      case 'semantic':
        return AppColors.getRandomColorFromCategory(AppColors.semanticColors);
      case 'status':
        return AppColors.getRandomColorFromCategory(AppColors.statusColors);
      case 'custom':
        return AppColors.getRandomColorFromCategory(AppColors.customColors);
      case 'accent':
        return AppColors.getRandomColorFromCategory(AppColors.accentColors);
      default:
        return AppColors.primary;
    }
  }
}
