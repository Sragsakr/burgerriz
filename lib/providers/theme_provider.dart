import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiosk_point_of_sale/core/colors/app_colors.dart';
import 'package:kiosk_point_of_sale/core/config/app_config.dart';
import 'package:kiosk_point_of_sale/core/helpers/logger.dart';
import 'package:kiosk_point_of_sale/data/models/theme/device_theme_setting_model.dart';
import 'package:kiosk_point_of_sale/repository/theme_repository.dart';

final themeRepositoryProvider = Provider<ThemeRepository>((ref) {
  return ThemeRepository();
});

final appThemeProvider =
    StateNotifierProvider<AppThemeNotifier, ThemeData>((ref) {
  return AppThemeNotifier(ref.read(themeRepositoryProvider));
});

class AppThemeNotifier extends StateNotifier<ThemeData> {
  final ThemeRepository _repository;

  AppThemeNotifier(this._repository) : super(AppConfig.lightTheme);

  Future<void> loadTheme() async {
    final result = await _repository.getThemes();
    result.fold(
      (failure) {
        AppLogger.warning('AppThemeNotifier',
            'Using default theme (${failure.code}: ${failure.message})');
      },
      (themes) {
        state = _mapTheme(themes);
      },
    );
  }

  ThemeData _mapTheme(List<DeviceThemeSettingModel> themes) {
    final DeviceThemeSettingModel selected = themes.firstWhere(
      (theme) => theme.isActive,
      orElse: () => themes.first,
    );

    final background = _parseHexColor(selected.backgoundColor) ?? AppColors.backgroundLight;
    final foreground = _parseHexColor(selected.forgroundColor) ?? AppColors.primary;
    final fontColor = _parseHexColor(selected.fontColor) ?? AppColors.textPrimary;
    final size = (selected.fontSize ?? 14).clamp(10, 28).toDouble();

    return AppConfig.lightTheme.copyWith(
      scaffoldBackgroundColor: background,
      primaryColor: foreground,
      colorScheme: AppConfig.lightTheme.colorScheme.copyWith(
        primary: foreground,
        onPrimary: AppColors.buttonText,
        surface: background,
        onSurface: fontColor,
      ),
      textTheme: _safeScaledTextTheme(
        AppConfig.lightTheme.textTheme,
        fontColor,
        size / 14,
      ),
    );
  }

  TextTheme _safeScaledTextTheme(
    TextTheme baseTheme,
    Color fontColor,
    double sizeFactor,
  ) {
    TextStyle? scale(TextStyle? style) {
      if (style == null) return null;
      final currentSize = style.fontSize;
      return style.copyWith(
        color: fontColor,
        fontSize: currentSize != null ? currentSize * sizeFactor : null,
      );
    }

    return baseTheme.copyWith(
      displayLarge: scale(baseTheme.displayLarge),
      displayMedium: scale(baseTheme.displayMedium),
      displaySmall: scale(baseTheme.displaySmall),
      headlineLarge: scale(baseTheme.headlineLarge),
      headlineMedium: scale(baseTheme.headlineMedium),
      headlineSmall: scale(baseTheme.headlineSmall),
      titleLarge: scale(baseTheme.titleLarge),
      titleMedium: scale(baseTheme.titleMedium),
      titleSmall: scale(baseTheme.titleSmall),
      bodyLarge: scale(baseTheme.bodyLarge),
      bodyMedium: scale(baseTheme.bodyMedium),
      bodySmall: scale(baseTheme.bodySmall),
      labelLarge: scale(baseTheme.labelLarge),
      labelMedium: scale(baseTheme.labelMedium),
      labelSmall: scale(baseTheme.labelSmall),
    );
  }

  Color? _parseHexColor(String? value) {
    if (value == null || value.isEmpty) return null;
    final normalized = value.replaceAll('#', '').trim();
    if (normalized.length != 6 && normalized.length != 8) return null;
    final full = normalized.length == 6 ? 'FF$normalized' : normalized;
    final parsed = int.tryParse(full, radix: 16);
    if (parsed == null) return null;
    return Color(parsed);
  }
}
