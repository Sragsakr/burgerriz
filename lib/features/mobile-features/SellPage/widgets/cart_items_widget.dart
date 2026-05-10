import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiosk_point_of_sale/core/colors/app_colors.dart';
import 'package:kiosk_point_of_sale/core/colors/color_manager.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/currency_display_widget.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_theme.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_dialogs.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/clear_cart_with_prices.dart';
import 'package:kiosk_point_of_sale/core/helpers/selected_variant_grouping.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/core/helpers/responsive_helper.dart';
import 'package:kiosk_point_of_sale/core/services/order_services/free_item_service.dart';
import 'package:kiosk_point_of_sale/data/models/cart_item.dart';
import 'package:kiosk_point_of_sale/data/models/menu_item/item_customization_result.dart';
import 'package:kiosk_point_of_sale/data/models/menu_item/menu_item_details.dart';
import 'package:kiosk_point_of_sale/data/models/sale_types/sale_type_price_list_model.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/sale_type_tables/sale_type_price_list_table.dart';
import 'package:kiosk_point_of_sale/features/shared-features/customization/product_customization_host.dart';
import 'package:kiosk_point_of_sale/features/mobile-features/SellPage/widgets/custom_quantity_textfield.dart';
import 'package:kiosk_point_of_sale/providers/cart_provider.dart';
import 'package:kiosk_point_of_sale/providers/menu_providers.dart';
import 'package:kiosk_point_of_sale/providers/order_summary_provider.dart';
import 'package:kiosk_point_of_sale/providers/payment_breakdown_provider.dart';
import 'package:kiosk_point_of_sale/providers/promotion_provider.dart';
import 'package:kiosk_point_of_sale/repository/menu_item_sync_repository.dart';

import '../../../../data/models/sales_models/sales_items_model.dart';

final ScrollController scrollController = ScrollController();

void scrollToBottom() {
  scrollController.animateTo(
    scrollController.position.maxScrollExtent,
    duration: const Duration(milliseconds: 500),
    curve: Curves.easeOut,
  );
}

void scrollToIndex(int index) {
  try {
    const itemHeight = 50.0;
    scrollController.animateTo(
      index * itemHeight,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  } catch (e, t) {
    dPrint(e.toString());
    dPrint(t.toString());
  }
}

class CartItemsWidget extends ConsumerWidget {
  bool isExpanded;

  CartItemsWidget({super.key, this.isExpanded = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    registerCartScrollCallback(scrollToIndex);
    final orderSummaryAsync = ref.watch(orderSummaryProvider);
    return orderSummaryAsync.when(
      data: (orderSummary) {
        final orderItems = orderSummary.salesInvoice.salesOrderItems;
        return itemsContent(ref, context, orderItems: orderItems);
      },
      loading: () => itemsContent(ref, context),
      error: (error, stack) {
        dPrint('Stack Trace: $stack');
        return _buildErrorContent(context, error);
      },
    );
  }

  Container itemsContent(
    WidgetRef ref,
    BuildContext context, {
    List<SalesItemsModel> orderItems = const [],
  }) {
    final cartItems = ref.watch(cartProvider);
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final discount = ref.watch(discountAmountProvider);
    final isLandscape = ResponsiveHelper.isTablet(context);
    return Container(
      width: MediaQuery.sizeOf(context).width,
      height: isExpanded
          ? MediaQuery.sizeOf(context).height * (discount != 0 ? 0.18 : 0.23)
          : MediaQuery.sizeOf(context).height * 0.55,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(4, 4, 4, 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Scrollbar(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    final salesItem = orderItems.isNotEmpty
                        ? orderItems
                            .where((e) => e.productId == item.productId)
                            .firstOrNull
                        : null;
                    return _buildLine(
                      context,
                      ref,
                      item: item,
                      isEnglish: isEnglish,
                      salesItem: salesItem,
                      cartIndex: index,
                      orderItems: orderItems,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _removeCartLinePromotion(
    int promotionId,
    WidgetRef ref,
    List<SalesItemsModel> orderItems,
  ) {
    final stillReferenced =
        orderItems.any((e) => e.promotionCodeId == promotionId);
    if (stillReferenced) return;
    final manualPromos = ref.read(appliedPromotionsProvider);
    ref.read(appliedPromotionsProvider.notifier).state =
        manualPromos.where((p) => p.promotionCodeId != promotionId).toList();
    ref.read(appliedPromotionsProvider.notifier).state =
        List.from(ref.read(appliedPromotionsProvider));
  }

  Widget _buildLine(
    BuildContext context,
    WidgetRef ref, {
    required CartItem item,
    required bool isEnglish,
    required SalesItemsModel? salesItem,
    required int cartIndex,
    required List<SalesItemsModel> orderItems,
  }) {
    final lineTotal =
        (item.price * item.quantity).roundToTwoDecimals().toStringAsFixed(2);

    return Dismissible(
      key: ValueKey('mobile_cart_${item.productId}_${item.unitId}_$cartIndex'),
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
        if (salesItem?.promotionCodeId != null) {
          _removeCartLinePromotion(
              salesItem!.promotionCodeId!, ref, orderItems);
        }
        if (salesItem != null && salesItem.isFreeItemSelected()) {
          FreeItemService.resetFreeProductSelection(salesItem);
        }
        if (salesItem != null) {
          FreeItemService.clearFreeItemState(salesItem, cartIndex);
        }
        resetPaymentValues(ref);
      },
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 5),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${isEnglish ? item.nameEn : item.nameAr}${_unitNameSuffix(item, isEnglish)}',
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.copyWith(
                                    fontSize: ResponsiveHelper.isMobile(context)
                                        ? 16
                                        : 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        if (salesItem != null &&
                            salesItem.promotionValue != null &&
                            salesItem.promotionValue! > 0)
                          Text(
                            '${translator(arText: 'خصم :', enText: 'Discount :')} (${salesItem.promotionValue!.toStringAsFixed(2)})',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .copyWith(
                                  color: Colors.red,
                                  decoration: TextDecoration.lineThrough,
                                  fontSize: ResponsiveHelper.isMobile(context)
                                      ? 14
                                      : 18,
                                ),
                          ),
                        if (item.hasVariations)
                          _buildVariationsList(item, isEnglish, context),
                        if (item.hasComboItems)
                          _buildComboMealItemsList(item, isEnglish, context),
                        if ((salesItem != null &&
                                salesItem.isFreeItemSelected()) ||
                            item.isFreeItemSelected())
                          _buildFreeProductInfo(
                            salesItem ?? _createSalesItemFromCartItem(item),
                            isEnglish,
                            context,
                          ),
                        if (item.selectedVariants.isNotEmpty &&
                            !item.isComboMeal)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: TextButton.icon(
                              onPressed: () => _handleEditItem(
                                  context, ref, item, cartIndex),
                              style: TextButton.styleFrom(
                                backgroundColor: const Color(0xFFFFB300),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 6.0,
                                ),
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
                                  enText: 'Edit Options',
                                ),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
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
                          onDelete: () {
                            ref.read(cartProvider.notifier).removeItem(
                                  item.productId,
                                  item.unitId,
                                  item.variations,
                                  selectedVariants: item.selectedVariants,
                                  comboItems: item.comboItems,
                                  isComboMeal: item.isComboMeal,
                                );
                            if (salesItem?.promotionCodeId != null) {
                              _removeCartLinePromotion(
                                salesItem!.promotionCodeId!,
                                ref,
                                orderItems,
                              );
                            }
                            if (salesItem != null &&
                                salesItem.isFreeItemSelected()) {
                              FreeItemService.resetFreeProductSelection(
                                salesItem,
                              );
                            }
                            if (salesItem != null) {
                              FreeItemService.clearFreeItemState(
                                salesItem,
                                cartIndex,
                              );
                            }
                            resetPaymentValues(ref);
                          },
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lineTotal,
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.copyWith(
                                    fontSize: ResponsiveHelper.isMobile(context)
                                        ? 16
                                        : 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (item.hasVariations) ...[
                const Divider(
                  height: 8,
                  thickness: 0.5,
                  color: Color(0xFFE0E0E0),
                ),
              ],
            ],
          ),
        ),
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

  static Widget _buildVariationsList(
    CartItem item,
    bool isEnglish,
    BuildContext context,
  ) {
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
                Icon(
                  Icons.check_circle_outline,
                  size: ResponsiveHelper.isMobile(context) ? 16 : 20,
                  color: const Color(0xFFAF2A26),
                ),
                const SizedBox(width: 4),
                Text(
                  name,
                  style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                        fontSize: ResponsiveHelper.isMobile(context) ? 10 : 16,
                        color: Colors.grey.shade700,
                      ),
                ),
                Text(
                  '($mainTranslation)',
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
    CartItem item,
    bool isEnglish,
    BuildContext context,
  ) {
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
    SalesItemsModel salesItem,
    bool isEnglish,
    BuildContext context,
  ) {
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
                          'الكمية: ${salesItem.selectedFreeProductQuantity}',
                      enText: 'Qty: ${salesItem.selectedFreeProductQuantity}',
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
      currentSaleType?.saleTypeId ?? 0,
    );
    final priceListId = saleTypePriceList?.priceListId ?? 1;

    final variantsFuture = repo.fetchMenuItemVariants(menuItemId, priceListId);
    final detailsFuture = ref.read(
      menuItemDetailsProvider(
        MenuItemDetailsParams(menuItemId, priceListId),
      ).future,
    );

    final results = await Future.wait([variantsFuture, detailsFuture]);
    final variants = results[0] as Map<String, dynamic>;
    final menuItemDetails = results[1] as List<MenuItemDetails>;

    if (menuItemDetails.isEmpty) {
      dPrint('CartItemsWidget: no UOM for item $menuItemId — cannot edit');
      return;
    }

    final hasVariants = variants['status'] == 'Valid' &&
        (variants['variants'] as List).isNotEmpty;
    if (!hasVariants) {
      dPrint('CartItemsWidget: item $menuItemId has no variants — cannot edit');
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

    final result = await ProductCustomizationHost.show(
      context,
      product: syncProductStubFromCartItem(item),
      unitOptions: menuItemDetails,
      variants: variantList,
      isVatExclusive: isVatExclusive,
      taxRate: taxRate,
      themeColor: themeColor,
      initialQuantity: item.quantity.round().clamp(1, 999),
      isEditMode: true,
      initialSelectedUnit: initialUnit,
      initialSelectedVariants: item.selectedVariants,
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
  }

  Widget _buildErrorContent(BuildContext context, Object error) {
    return Container(
      width: MediaQuery.sizeOf(context).width,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 6, 16, 6),
        child: Center(
          child: Text(
            'Error: ${error.toString()}',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'Inter Tight',
                  color: Colors.red,
                ),
          ),
        ),
      ),
    );
  }
}
