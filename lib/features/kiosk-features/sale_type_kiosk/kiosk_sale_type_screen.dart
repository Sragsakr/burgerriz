// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:kiosk_point_of_sale/core/assets/app_assets.dart';
import 'package:kiosk_point_of_sale/core/extentions/app_extentions.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/login_helpers.dart';
import 'package:kiosk_point_of_sale/core/helpers/responsive_helper.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/entry_widget/entry_widget.dart';
import 'package:kiosk_point_of_sale/providers/payment_breakdown_provider.dart';
import 'package:kiosk_point_of_sale/repository/menu_catalog_preload_helper.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/menu_widget/menu_widget.dart';

class KioskSaleTypeScreen extends ConsumerStatefulWidget {
  const KioskSaleTypeScreen({super.key});

  static const String routePath = '/kiosk-sale-type';
  static const String routeName = 'KioskSaleType';

  @override
  ConsumerState<KioskSaleTypeScreen> createState() => _KioskSaleTypeScreenState();
}

class _KioskSaleTypeScreenState extends ConsumerState<KioskSaleTypeScreen> {
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final saleTypes = await generateSaleTypeList();
      ref.read(availableSaleTypesProvider.notifier).state = saleTypes;
    });
  }

  Future<void> _loadFilteredMenu(SaleType saleType) async {
    setState(() => _loading = true);
    await MenuCatalogPreloadHelper.loadCatalogForSaleType(
      ref,
      saleType,
      resetPaymentAndCart: true,
    );
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _handleSaleTypeSelection(SaleType saleType) async {
    await _loadFilteredMenu(saleType);
    if (mounted) context.go(MenuWidget.routePath);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(reportGroupThemeProvider);

    final textColor = !theme.isDarkBackground ? Colors.white : Colors.black87;
    final cardBorderColor = !theme.isDarkBackground ? Colors.white54 : Colors.black26;
    final saleTypes = ref.watch(availableSaleTypesProvider);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(theme.headerBackgroundAsset, fit: BoxFit.cover),
          SafeArea(
            child: Column(
              children: [
                // Back button row
                Align(
                  alignment: AlignmentDirectional.topStart,
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: textColor,
                      size: 28,
                    ),
                    onPressed: () => context.go(EntryWidget.routePath),
                  ),
                ),
                SizedBox(height: 5.h),
                // Store logo
                Image.asset(
                  theme.logoAsset,
                  height: 20.h,
                  width: 50.w,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 5.h),
                // Title
                SizedBox(
                  width: 65.w,
                  child: Text(
                    translator(arText: 'ما الخيار الذي ستختاره اليوم؟', enText: 'Where will you be eating today?'),
                    maxLines: 2,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 19.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 5.h),
                // Sale type cards
                if (saleTypes.isEmpty)
                  CircularProgressIndicator(color: theme.accentColor)
                else
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        runAlignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 24,
                        runSpacing: 24,
                        children: saleTypes.map((saleType) {
                          final isPickup = saleType.saleNature == 1;
                          final iconAsset = isPickup
                              ? (!theme.isDarkBackground ? AppAssets.takeAwayIconWhite : AppAssets.takeAwayIconBlack)
                              : (!theme.isDarkBackground ? AppAssets.dineInIconWhite : AppAssets.dineInIconBlack);
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 0),
                            child: _SaleTypeCard(
                              saleType: saleType,
                              iconAsset: iconAsset,
                              accentColor: Colors.green,
                              textColor: textColor,
                              cardBorderColor: cardBorderColor,
                              onTap: () => _handleSaleTypeSelection(saleType),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                // Language toggle
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: InkWell(
                    onTap: () async {
                      await switchAppLanguage(ref, context);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.language,
                            size: ResponsiveHelper.getResponsiveSize(context, 30),
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            translator(arText: 'English', enText: 'العربية'),
                            style: GoogleFonts.inter(
                              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18.0),
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          if (_loading)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

class _SaleTypeCard extends StatefulWidget {
  final SaleType saleType;
  final String iconAsset;
  final Color accentColor;
  final Color textColor;
  final Color cardBorderColor;
  final VoidCallback onTap;

  const _SaleTypeCard({
    required this.saleType,
    required this.iconAsset,
    required this.accentColor,
    required this.textColor,
    required this.cardBorderColor,
    required this.onTap,
  });

  @override
  State<_SaleTypeCard> createState() => _SaleTypeCardState();
}

class _SaleTypeCardState extends State<_SaleTypeCard> {
  @override
  Widget build(BuildContext context) {
    final label = isAr() ? widget.saleType.nameAr : widget.saleType.nameEn;
    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 12),
            child: Image.asset(widget.iconAsset, height: 28.h),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: ElevatedButton(
              onPressed: widget.onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.accentColor,
                minimumSize: const Size(160, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
