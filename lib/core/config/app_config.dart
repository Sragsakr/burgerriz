import 'package:flutter/material.dart';
import 'package:kiosk_point_of_sale/core/colors/app_colors.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kiosk_point_of_sale/providers/payment_breakdown_provider.dart';

import '../flutter_flow/internationalization.dart';

enum AppMode { handheld, kiosk }

class AppConfig {
  static const String appTitle = 'Posmena';
  static AppMode mode = AppMode.handheld;
  static const bool useNewInstallLoginFlow = true;
  static bool get isMobile => mode == AppMode.handheld;
  static bool get isKiosk => mode == AppMode.kiosk;
  static const DecimalsNumbers decimalsNumbers = DecimalsNumbers.two;
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ar'),
  ];

  static const List<LocalizationsDelegate> localizationsDelegates = [
    FFLocalizationsDelegate(),
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.backgroundLight,
    primaryColor: AppColors.primary,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.buttonText,
      surface: AppColors.backgroundSecondary,
      onSurface: AppColors.textPrimary,
      error: AppColors.error,
    ),
  );
}
