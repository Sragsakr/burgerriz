import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/currency_display_widget.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/menu_widget/components/kiosk_quantity_textfield.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/menu_widget/components/kiosk_product_image_helpers.dart';
import 'package:kiosk_point_of_sale/core/colors/app_colors.dart';
import 'package:kiosk_point_of_sale/core/colors/color_manager.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_theme.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_dialogs.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/clear_cart_with_prices.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/core/helpers/responsive_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/selected_variant_grouping.dart';
import 'package:kiosk_point_of_sale/core/services/order_services/free_item_service.dart';
import 'package:kiosk_point_of_sale/data/models/cart_item.dart';
import 'package:kiosk_point_of_sale/data/models/menu_item/item_customization_result.dart';
import 'package:kiosk_point_of_sale/data/models/menu_item/menu_item_details.dart';
import 'package:kiosk_point_of_sale/data/models/sale_types/sale_type_price_list_model.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_items_model.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/sale_type_tables/sale_type_price_list_table.dart';
import 'package:kiosk_point_of_sale/providers/cart_provider.dart';
import 'package:kiosk_point_of_sale/providers/menu_providers.dart';
import 'package:kiosk_point_of_sale/providers/payment_breakdown_provider.dart';
import 'package:kiosk_point_of_sale/providers/promotion_provider.dart';
import 'package:kiosk_point_of_sale/repository/menu_item_sync_repository.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/menu_widget/components/item_customization/kiosk_product_customization_host_local.dart';

/// Removes a manual promotion when no sales line still references it (same logic as [CartWidget.removePromotion]).
void removeCartLinePromotion(
    int promotionId, WidgetRef ref, List<SalesItemsModel> orderItems) {
  final isAnySalesItemHaveThisPromotion =
      orderItems.any((e) => e.promotionCodeId == promotionId);
  if (isAnySalesItemHaveThisPromotion) return;
  final manualPromos = ref.watch(appliedPromotionsProvider);
  ref.read(appliedPromotionsProvider.notifier).state =
      manualPromos.where((p) => p.promotionCodeId != promotionId).toList();
  ref.read(appliedPromotionsProvider.notifier).state =
      List.from(ref.read(appliedPromotionsProvider));
}

/// Cart line UI shared by [CartWidget] and menu cart summary sheet — matches full cart row layout/behavior.
class KioskCartLineItem extends ConsumerWidget {
  const KioskCartLineItem({
    super.key,
    required this.item,
    required this.isEnglish,
    required this.salesItem,
    required this.cartIndex,
    required this.orderItems,
    this.enableDismissible = true,
  });

  final CartItem item;
  final bool isEnglish;
  final SalesItemsModel? salesItem;
  final int cartIndex;
  final List<SalesItemsModel> orderItems;
  final bool enableDismissible;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final card = _buildCard(context, ref);

    if (!enableDismissible) {
      return card;
    }

    return Dismissible(
      key: ValueKey(
          'kiosk_cart_line_${item.productId}_${item.unitId}_$cartIndex'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        ref.read(cartProvider.notifier).removeItem(
              item.productId,
              item.unitId,
              item.variations,
              selectedVariants: item.selectedVariants,
              comboItems: item.comboItems,
              isComboMeal: item.isComboMeal,
            );
        if (salesItem != null && salesItem!.promotionCodeId != null) {
          removeCartLinePromotion(salesItem!.promotionCodeId!, ref, orderItems);
        }
        if (salesItem != null && salesItem!.isFreeItemSelected()) {
          FreeItemService.resetFreeProductSelection(salesItem!);
        }
        if (salesItem != null) {
          FreeItemService.clearFreeItemState(salesItem!, cartIndex);
        }
        resetPaymentValues(ref);
      },
      child: card,
    );
  }

  Widget _buildCard(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsetsDirectional.fromSTEB(20.0, 10.0, 20.0, 10.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 4.0,
            offset: const Offset(0.0, 2.0),
          )
        ],
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Container(
                  width: 80.0,
                  height: 80.0,
                  color: Colors.white,
                  child: Center(
                    child: buildImage(item.imageUrl, width: 80.0, height: 80.0),
                  ),
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${isEnglish ? item.nameEn : item.nameAr}${_unitNameSuffix(item, isEnglish)} ',
                      maxLines: 2,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.interTight(
                              fontWeight: FontWeight.bold,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                            fontSize:
                                ResponsiveHelper.isMobile(context) ? 16 : 20,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.bold,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                    ),
                    if (salesItem != null &&
                        salesItem!.promotionValue != null &&
                        salesItem!.promotionValue! > 0)
                      Text(
                        '${translator(arText: "خصم :", enText: "Discount :")} (${salesItem!.promotionValue!.toStringAsFixed(2)})',
                        style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                              color: Colors.red,
                              decoration: TextDecoration.lineThrough,
                              fontSize:
                                  ResponsiveHelper.isMobile(context) ? 16 : 20,
                            ),
                      ),
                    if (item.hasVariations)
                      _buildVariationsList(item, isEnglish, context),
                    if (item.hasComboItems)
                      _buildComboMealItemsList(item, isEnglish, context),
                    if ((salesItem != null &&
                            salesItem!.isFreeItemSelected()) ||
                        item.isFreeItemSelected())
                      _buildFreeProductInfo(
                        salesItem ?? _createSalesItemFromCartItem(item),
                        isEnglish,
                        context,
                      ),
                    if (item.selectedVariants.isNotEmpty && !item.isComboMeal)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: TextButton.icon(
                          onPressed: () =>
                              _handleEditItem(context, ref, item, cartIndex),
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFFFFB300),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 6.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          icon: const Icon(Icons.edit, size: 16),
                          label: Text(
                            translator(
                                arText: 'تعديل الخيارات',
                                enText: 'Edit Options'),
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  QuantityTextField(
                    allowDecimal: item.allowDecimal ?? false,
                    productId: item.productId,
                    unitId: item.unitId,
                    initialQuantity: item.quantity,
                    variations: item.variations,
                    selectedVariants: item.selectedVariants,
                    comboItems: item.comboItems,
                    isComboMeal: item.isComboMeal,
                    fromMenu: true,
                    onDelete: () {
                      ref.read(cartProvider.notifier).removeItem(
                            item.productId,
                            item.unitId,
                            item.variations,
                            selectedVariants: item.selectedVariants,
                            comboItems: item.comboItems,
                            isComboMeal: item.isComboMeal,
                          );
                      if (salesItem != null &&
                          salesItem!.promotionCodeId != null) {
                        removeCartLinePromotion(
                            salesItem!.promotionCodeId!, ref, orderItems);
                      }
                      if (salesItem != null &&
                          salesItem!.isFreeItemSelected()) {
                        FreeItemService.resetFreeProductSelection(salesItem!);
                      }
                      if (salesItem != null) {
                        FreeItemService.clearFreeItemState(
                            salesItem!, cartIndex);
                      }
                      resetPaymentValues(ref);
                    },
                  ),
                  SizedBox(width: MediaQuery.sizeOf(context).width * 0.05),
                  Row(
                    children: [
                      _currencySymbol(),
                      SizedBox(width: MediaQuery.sizeOf(context).width * 0.01),
                      Text(
                        (item.price * item.quantity)
                            .roundToTwoDecimals()
                            .toStringAsFixed(2),
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.interTight(
                                fontWeight: FontWeight.bold,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                              ),
                              fontSize:
                                  ResponsiveHelper.isMobile(context) ? 16 : 23,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.bold,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          if (item.hasVariations) ...[
            const Divider(height: 8, thickness: 0.5, color: Color(0xFFE0E0E0)),
          ],
        ],
      ),
    );
  }

  static Widget _currencySymbol() {
    return const ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
      child: CurrencyDisplayWidget(
        width: 24.0,
        height: 24.0,
      ),
    );
  }

  static String _unitNameSuffix(CartItem item, bool isEnglish) {
    final unitName = isEnglish ? item.unitNameEn : item.unitNameAr;
    if (unitName != null && unitName.isNotEmpty) {
      return ' - $unitName';
    }
    return '';
  }

  static Future<void> _handleEditItem(
    BuildContext context,
    WidgetRef ref,
    CartItem item,
    int cartIndex,
  ) async {
    final menuItemId = int.tryParse(item.productId) ?? 0;
    if (menuItemId == 0) return;

    final repo = MenuItemSyncRepository();
    final currentSaleType = ref.read(saleTypeNotifier);
    final SaleTypePriceListModel? saleTypePriceList =
        await SaleTypePriceListTable.getBySaleTypeId(
            currentSaleType?.saleTypeId ?? 0);
    final priceListId = saleTypePriceList?.priceListId ?? 1;

    final variantsFuture = repo.fetchMenuItemVariants(menuItemId, priceListId);
    final detailsFuture = ref.read(
      menuItemDetailsProvider(MenuItemDetailsParams(menuItemId, priceListId))
          .future,
    );

    final results = await Future.wait([variantsFuture, detailsFuture]);
    final variants = results[0] as Map<String, dynamic>;
    final menuItemDetails = results[1] as List<MenuItemDetails>;

    if (menuItemDetails.isEmpty) {
      dPrint(
          'KioskCartLineItem: no UOM found for item $menuItemId — cannot edit');
      return;
    }

    final hasVariants = variants['status'] == 'Valid' &&
        (variants['variants'] as List).isNotEmpty;
    if (!hasVariants) {
      dPrint(
          'KioskCartLineItem: item $menuItemId has no variants — cannot edit');
      return;
    }

    final bool isVatExclusive = variants['isVatExclusive'] as bool? ?? false;
    final double taxRate = (variants['taxRate'] as num?)?.toDouble() ?? 0.0;
    final variantList = (variants['variants'] as List<dynamic>? ?? [])
        .map((v) => v as Map<String, dynamic>)
        .toList();

    final initialUnit = menuItemDetails.firstWhere(
      (u) => u.unitOfMeasureId == item.unitId,
      orElse: () => menuItemDetails.first,
    );

    if (!context.mounted) return;
    final themeColor = ref.read(reportGroupThemeProvider).accentColor;

    final result = await showAppDialog<ItemCustomizationResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ProductCustomizationHost(
        themeColor: themeColor,
        product: syncProductStubFromCartItem(item),
        unitOptions: menuItemDetails,
        variants: variantList,
        isVatExclusive: isVatExclusive,
        taxRate: taxRate,
        initialQuantity: item.quantity.round().clamp(1, 999),
        isEditMode: true,
        initialSelectedUnit: initialUnit,
        initialSelectedVariants: item.selectedVariants,
      ),
    );

    if (result == null || result.wasCancelled) return;
    if (result.selectedUnit == null) return;

    final updatedItem = item.copyWith(
      unitId: result.selectedUnit!.unitOfMeasureId,
      unitNameEn: result.selectedUnit!.unitNameEn,
      unitNameAr: result.selectedUnit!.unitNameAr,
      price: result.totalPrice,
      selectedVariants: result.selectedVariants,
      quantity: result.quantity,
    );

    ref.read(cartProvider.notifier).updateItemAtIndex(cartIndex, updatedItem);
    resetPaymentValues(ref);

    dPrint('🛒 Cart item at index $cartIndex updated with new selections');
  }

  static Widget _buildVariationsList(
      CartItem item, bool isEnglish, BuildContext context) {
    if (item.variations.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: item.variations.map((variation) {
          final name = isEnglish
              ? variation.variationEn?.name ?? ''
              : variation.variationAr?.name ?? '';
          final mainTranslation = !isEnglish
              ? variation.mainTranslationAr?.name
              : variation.mainTranslationEn?.name;
          return Padding(
            padding: const EdgeInsets.only(left: 8, top: 2),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline,
                    size: ResponsiveHelper.isMobile(context) ? 16 : 20,
                    color: const Color(0xFFAF2A26)),
                const SizedBox(width: 4),
                Text(
                  name,
                  style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                        fontSize: ResponsiveHelper.isMobile(context) ? 10 : 16,
                        color: Colors.grey.shade700,
                      ),
                ),
                Text(
                  "($mainTranslation)",
                  style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                        fontSize: ResponsiveHelper.isMobile(context) ? 10 : 16,
                        color: Colors.grey.shade700,
                      ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    }

    if (item.selectedVariants.isNotEmpty) {
      final iconSize = ResponsiveHelper.isMobile(context) ? 14.0 : 18.0;
      final fontSize = ResponsiveHelper.isMobile(context) ? 10.0 : 16.0;
      final groups = groupSelectedVariantsByVariantId(item.selectedVariants);
      final children = <Widget>[];
      var firstGroup = true;
      for (final g in groups) {
        if (!firstGroup) {
          children.add(const SizedBox(height: 4));
        }
        firstGroup = false;
        final header =
            selectedVariantGroupHeader(g.selections.first, isEnglish);
        if (header.isNotEmpty) {
          children.add(
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 2, bottom: 2),
              child: Text(
                header,
                style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
              ),
            ),
          );
        }
        for (final sv in g.selections) {
          final name = isEnglish ? sv.nameEn : sv.nameAr;
          final qtyLabel = sv.quantity > 1 ? ' x${sv.quantity.toInt()}' : '';
          children.add(
            Padding(
              padding:
                  EdgeInsets.only(left: header.isNotEmpty ? 16.0 : 8.0, top: 2),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: iconSize,
                    color: const Color(0xFFAF2A26),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '$name$qtyLabel',
                      style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                            fontSize: fontSize,
                            color: Colors.grey.shade700,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  if (sv.isFree)
                    Text(
                      isEnglish ? 'Free' : 'مجاني',
                      style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                            fontSize: fontSize,
                            color: Colors.green.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                    )
                  else if (sv.price > 0)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CurrencyDisplayWidget(
                          width: iconSize,
                          height: iconSize,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          sv.price.toStringAsFixed(2),
                          style:
                              FlutterFlowTheme.of(context).bodySmall.copyWith(
                                    fontSize: fontSize,
                                    color: Colors.grey.shade700,
                                  ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        }
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      );
    }

    return const SizedBox.shrink();
  }

  static Widget _buildComboMealItemsList(
      CartItem item, bool isEnglish, BuildContext context) {
    if (!item.hasComboItems || item.comboItems == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 2),
          child: Text(
            isEnglish ? 'Combo Items:' : 'عناصر الوجبة:',
            style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                  fontSize: ResponsiveHelper.isMobile(context) ? 10 : 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
          ),
        ),
        ...item.comboItems!.map((comboItem) {
          final name = isEnglish ? comboItem.nameEn : comboItem.nameAr;
          final price = comboItem.price;

          return Padding(
            padding: const EdgeInsets.only(left: 8, top: 2),
            child: Row(
              children: [
                Icon(
                  Icons.fastfood_outlined,
                  size: ResponsiveHelper.isMobile(context) ? 14 : 18,
                  color: const Color(0xFF359E92),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    name,
                    style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                          fontSize:
                              ResponsiveHelper.isMobile(context) ? 10 : 14,
                          color: Colors.grey.shade700,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (price > 0)
                  Text(
                    '+${price.toStringAsFixed(2)}',
                    style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                          fontSize:
                              ResponsiveHelper.isMobile(context) ? 10 : 14,
                          color: const Color(0xFF359E92),
                          fontWeight: FontWeight.w500,
                        ),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }

  static SalesItemsModel _createSalesItemFromCartItem(CartItem item) {
    return SalesItemsModel(
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
      productId: item.productId,
      categoryId: item.categoryId,
      productNameEn: item.nameEn,
      productNameAr: item.nameAr,
      unitOfMeasureId: item.unitId.toString(),
      quantity: item.quantity.toString(),
      price: item.price.toString(),
      tax: '0',
      total: (item.price * item.quantity).toString(),
      note: '',
      isRefund: 0,
      userId: '',
      tenantId: '',
      invoiceId: '',
      uniqueId: '',
      isExclusive: item.inclusive,
      selectedFreeProductId: item.selectedFreeProductId,
      selectedFreeProductName: item.selectedFreeProductName,
      selectedFreeProductNameAr: item.selectedFreeProductNameAr,
      selectedFreeProductQuantity: item.selectedFreeProductQuantity,
      selectedFreeProductPrice: item.selectedFreeProductPrice,
      selectedFreeItemId: item.selectedFreeItemId,
      freeItemSelectionState: item.freeItemSelectionState,
    );
  }

  static Widget _buildFreeProductInfo(
      SalesItemsModel salesItem, bool isEnglish, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: ColorManager.withOpacity(AppColors.error, 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: ColorManager.withOpacity(AppColors.error, 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.card_giftcard,
            size: ResponsiveHelper.isMobile(context) ? 16 : 20,
            color: const Color(0xFFAF2A26),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEnglish
                      ? salesItem.selectedFreeProductName ?? ''
                      : salesItem.selectedFreeProductNameAr ?? '',
                  style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                        fontSize: ResponsiveHelper.isMobile(context) ? 12 : 14,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                if (salesItem.selectedFreeProductQuantity != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    translator(
                      arText:
                          "الكمية: ${salesItem.selectedFreeProductQuantity}",
                      enText: "Qty: ${salesItem.selectedFreeProductQuantity}",
                    ),
                    style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                          fontSize:
                              ResponsiveHelper.isMobile(context) ? 10 : 12,
                          color: Colors.grey.shade600,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
