import 'package:flutter/material.dart';

class StoreInfo {
  final int reportGroupId;
  final String nameEn;
  final String nameAr;
  final String backgroundAsset;
  final String logoAsset;
  final Color accentColor;

  /// true = dark background (Steakhouse) → white text/icons
  /// false = light background (Piato) → dark text/icons
  final bool isDarkBackground;

  const StoreInfo({
    required this.reportGroupId,
    required this.nameEn,
    required this.nameAr,
    required this.backgroundAsset,
    required this.logoAsset,
    required this.accentColor,
    required this.isDarkBackground,
  });
}
