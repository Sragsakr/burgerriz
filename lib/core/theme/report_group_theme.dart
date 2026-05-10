import 'package:flutter/material.dart';
import 'package:kiosk_point_of_sale/core/assets/app_assets.dart';
import 'package:kiosk_point_of_sale/core/colors/app_colors.dart';
import 'package:kiosk_point_of_sale/data/models/store/store_info.dart';

/// Resolved branding for the current order session (accent, logos, header art).
///
/// Single source for UI and printing — do not scatter `reportGroupId == 5` checks.
@immutable
class ReportGroupThemeData {
  final Color accentColor;
  final String logoAsset;
  final String headerBackgroundAsset;
  final bool isDarkBackground;

  /// Session report group when kiosk multi-store branding applies; null on mobile or unset.
  final int? reportGroupId;

  const ReportGroupThemeData({
    required this.accentColor,
    required this.logoAsset,
    required this.headerBackgroundAsset,
    required this.isDarkBackground,
    this.reportGroupId,
  });

  /// Legacy flag kept for layout compatibility. Single-store kiosk never uses steak-specific layout.
  bool get isSteakHouseBrand => false;
}

class ReportGroupTheme {
  ReportGroupTheme._();

  /// Single-store default used across kiosk and mobile after report-group removal.
  static const ReportGroupThemeData defaultSession = ReportGroupThemeData(
    accentColor: AppColors.primary,
    logoAsset: AppAssets.bur_logo,
    headerBackgroundAsset: AppAssets.saleBackground,
    isDarkBackground: false,
    reportGroupId: null,
  );

  static ReportGroupThemeData resolve({
    StoreInfo? storeInfo,
    int? reportGroupId,
  }) {
    return defaultSession;
  }
}

class ReportGroupSession {
  ReportGroupSession._();

  static int? effectiveCatalogReportGroupId({
    required bool isMobile,
    int? selectedReportGroupId,
  }) {
    return null;
  }

  static ReportGroupThemeData themeForSession({
    required bool isMobile,
    StoreInfo? storeInfo,
    int? reportGroupId,
  }) {
    return ReportGroupTheme.defaultSession;
  }
}
