import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_dialogs.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/clear_cart_with_prices.dart';
import 'package:kiosk_point_of_sale/core/helpers/login_helpers.dart';
import 'package:kiosk_point_of_sale/core/helpers/responsive_helper.dart';
import 'package:kiosk_point_of_sale/providers/cart_provider.dart';
import 'package:kiosk_point_of_sale/providers/category_navigation_provider.dart';
import 'package:kiosk_point_of_sale/providers/payment_breakdown_provider.dart';
import 'package:kiosk_point_of_sale/repository/menu_catalog_preload_helper.dart';

/// Bar showing selected main category title and Order type dropdown.
/// Placed below the search bar; sub-categories appear below this.
class MenuCategoryAndSaleTypeBar extends ConsumerStatefulWidget {
  const MenuCategoryAndSaleTypeBar({super.key});

  @override
  ConsumerState<MenuCategoryAndSaleTypeBar> createState() =>
      _MenuCategoryAndSaleTypeBarState();
}

class _MenuCategoryAndSaleTypeBarState
    extends ConsumerState<MenuCategoryAndSaleTypeBar> {
  bool _loading = false;

  Future<void> _loadFilteredMenu(SaleType saleType) async {
    setState(() => _loading = true);
    await MenuCatalogPreloadHelper.loadCatalogForSaleType(
      ref,
      saleType,
    );
    if (mounted) setState(() => _loading = false);
  }

  Future<bool> _showClearCartDialog() async {
    final result = await showAppDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title:  Text(translator(arText: 'تغيير نوع الطلب', enText: 'Change Sale Type')),
        content:  Text(
            translator(arText: 'تغيير نوع الطلب سيمسح سلة المشتريات. استمرار؟', enText: 'Changing sale type will clear your cart. Continue?')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child:  Text(translator(arText: 'إلغاء', enText: 'Cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child:  Text(translator(arText: 'استمرار', enText: 'Continue')),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final selectedParent = ref.watch(selectedParentCategoryProvider);
    final saleTypes = ref.watch(availableSaleTypesProvider);
    final currentSaleType = ref.watch(saleTypeNotifier);
    final sessionTheme = ref.watch(reportGroupThemeProvider);
    final accentColor = sessionTheme.accentColor;
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';

    final categoryTitle = selectedParent != null
        ? (isEnglish ? selectedParent.nameEn : selectedParent.nameAr)
        : translator(arText: 'القائمة', enText: 'Menu');
    final backGroundColor = sessionTheme.accentColor;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Selected main category title
                Expanded(
                  child: AutoSizeText(
                    categoryTitle,
                    maxLines: 1,
                    minFontSize: 14,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize:
                          ResponsiveHelper.getResponsiveFontSize(context, 18),
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF121212),
                    ),
                  ),
                ),
                // Order type dropdown (pill design: white bg, subtle border, compact padding)
                if (saleTypes.length > 1)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Color(0xFFF5F5F5),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<SaleType>(
                          value: saleTypes.any((s) =>
                                  s.saleTypeId == currentSaleType?.saleTypeId)
                              ? currentSaleType
                              : null,
                          hint: Text(
                            translator(arText: 'نوع الطلب', enText: 'Order type'),
                            style: GoogleFonts.inter(
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                  context, 14),
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          dropdownColor: Colors.white,
                          isDense: true,
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: currentSaleType != null
                                ? backGroundColor
                                : Colors.grey.shade600,
                            size: 22,
                          ),
                          isExpanded: false,
                        items: saleTypes
                            .map((st) => DropdownMenuItem<SaleType>(
                                  value: st,
                                  child: Text(
                                    isAr() ? st.nameAr : st.nameEn,
                                    style: GoogleFonts.inter(
                                      color: accentColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: ResponsiveHelper
                                          .getResponsiveFontSize(context, 14),
                                    ),
                                  ),
                                ))
                            .toList(),
                        onChanged: (newSaleType) async {
                          if (newSaleType == null) return;
                          if (newSaleType.saleTypeId ==
                              currentSaleType?.saleTypeId) {
                            return;
                          }
                          final cartItems = ref.read(cartProvider);
                          if (cartItems.isNotEmpty) {
                            final confirmed = await _showClearCartDialog();
                            if (!confirmed) return;
                            ref.read(cartProvider.notifier).clearCart();
                            resetPaymentValues(ref);
                          }
                          await _loadFilteredMenu(newSaleType);
                        },
                      ),
                    ),
                    ),
                  ),
              ],
            ),
          ),
          if (_loading)
            Positioned.fill(
              child: Container(
                color: Colors.black26,
                child: Center(
                  child: CircularProgressIndicator(color: accentColor),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
