import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/custom_snackbar_widget.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/internationalization.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_dialogs.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/tables/combo_meal_definitions_table.dart';
import 'package:kiosk_point_of_sale/data/models/cart_item.dart';
import 'package:kiosk_point_of_sale/data/models/menu_item/item_customization_result.dart';
import 'package:kiosk_point_of_sale/data/models/sync_product/sync_product_model.dart';
import 'package:kiosk_point_of_sale/providers/cart_provider.dart';
import 'package:kiosk_point_of_sale/providers/order_summary_provider.dart';
import 'package:kiosk_point_of_sale/providers/combo_meal_provider.dart';
import 'package:kiosk_point_of_sale/providers/payment_breakdown_provider.dart';
import 'package:kiosk_point_of_sale/providers/quantity_selection_provider.dart';
import 'package:kiosk_point_of_sale/core/services/order_services/free_item_service.dart';
import 'package:kiosk_point_of_sale/core/services/order_services/order_calculator.dart';
import 'package:kiosk_point_of_sale/core/services/order_services/product_tap_cart_support.dart';
import 'package:kiosk_point_of_sale/core/services/order_services/product_tap_menu_loader.dart';
import 'package:kiosk_point_of_sale/core/services/order_services/product_tap_variant_support.dart';
import 'package:kiosk_point_of_sale/features/shared-features/customization/combo_meal_dialog.dart';
import 'package:kiosk_point_of_sale/features/shared-features/customization/product_customization_host.dart';

class ProductTapHandler {
  // ---------------------------------------------------------------------------
  // Tap guard — prevents double-taps
  // ---------------------------------------------------------------------------

  static bool _isProcessingTap = false;
  static Timer? _promotionDebounceTimer;

  // ---------------------------------------------------------------------------
  // Public entry point
  // ---------------------------------------------------------------------------

  static Future<void> handleProductTap(
    BuildContext context,
    WidgetRef ref,
    SyncProduct product,
    bool isEnglish,
    bool fromSearch,
  ) async {
    if (_isProcessingTap) return;
    _isProcessingTap = true;

    try {
      // --- 1. Consume pre-set quantity (defaults to 1 if unset) ---
      final quantity = ref.read(quantitySelectionProvider.notifier).useQuantity();

      final menuItemId = product.id;

      // --- 2. Combo meal check ---
      final isComboMeal = await ComboMealDefinitionsTable.isMenuItemComboMeal(menuItemId);

      if (isComboMeal) {
        if (!context.mounted) return;
        await _handleComboMeal(context, ref, product, quantity);
        return;
      }

      // --- 3. Fetch variants + UOM details (shared loader) ---
      final menuContext = await ProductTapMenuLoader.load(ref, product);
      if (menuContext == null) {
        dPrint('MenuProductTapHandler: no UOM found for item $menuItemId — skipping add');
        return;
      }

      // --- 4. Decision tree ---
      if (menuContext.needsCustomizationDialog) {
        if (!context.mounted) return;
        await _handleUnifiedCustomization(
          context,
          ref,
          product,
          quantity,
          menuContext,
        );
      } else {
        // Direct add — single UOM, no variants
        final unit = menuContext.menuItemDetails.first;
        final cartItem = ProductTapCartSupport.buildCartItem(
          product: product,
          unit: unit,
          selectedVariants: [],
          quantity: quantity,
          totalPrice: unit.price,
        );
        await _addItemToCart(context, ref, cartItem, quantity);
        if (context.mounted) {
          final isEnglishLocale = Localizations.localeOf(context).languageCode == 'en';
          customSnackbar(
            context,
            '${FFLocalizations.of(context).getText('w3e4rsd1')} '
            '${isEnglishLocale ? product.nameEn : product.nameAr}',
            true,
          );
        }
      }
    } finally {
      // Reset guard after 50ms — allows rapid sequential taps on simple items
      Future.delayed(const Duration(milliseconds: 50), () {
        _isProcessingTap = false;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Combo meal branch
  // ---------------------------------------------------------------------------

  static Future<void> _handleComboMeal(
    BuildContext context,
    WidgetRef ref,
    SyncProduct product,
    int quantity,
  ) async {
    final unit = product.unitOfMeasures.isNotEmpty ? product.unitOfMeasures.first : null;
    ref.read(comboMealProvider.notifier).reset();
    await ref.read(comboMealProvider.notifier).loadComboMeal(product.id);

    if (!context.mounted) return;
    await showComboMealDialog(
      context: context,
      product: product,
      basePrice: unit?.price ?? 0.0,
      initialQuantity: quantity,
    );

    _schedulePromotionReEvaluation(ref);
  }

  // ---------------------------------------------------------------------------
  // Unified customization dialog branch
  // ---------------------------------------------------------------------------

  static Future<void> _handleUnifiedCustomization(
    BuildContext context,
    WidgetRef ref,
    SyncProduct product,
    int quantity,
    ProductTapMenuContext menuContext,
  ) async {
    final parsed = ProductTapVariantSupport.parseForCustomization(menuContext.variants);

    if (!context.mounted) return;
    final themeColor = ref.read(reportGroupThemeProvider).accentColor;

    final result = await ProductCustomizationHost.show(
      context,
      product: product,
      unitOptions: menuContext.menuItemDetails,
      variants: parsed.variantList,
      isVatExclusive: parsed.isVatExclusive,
      taxRate: parsed.taxRate,
      themeColor: themeColor,
      initialQuantity: quantity,
    );

    if (result == null || result.wasCancelled) return;
    if (result.selectedUnit == null) return;

    final finalQuantity = result.quantity;
    final cartItem = ProductTapCartSupport.buildCartItem(
      product: product,
      unit: result.selectedUnit!,
      selectedVariants: result.selectedVariants,
      quantity: finalQuantity,
      totalPrice: result.totalPrice,
    );

    await _addItemToCart(context, ref, cartItem, finalQuantity);
  }

  // ---------------------------------------------------------------------------
  // Cart addition — with free-item promotion merge check
  // ---------------------------------------------------------------------------

  static Future<void> _addItemToCart(
    BuildContext context,
    WidgetRef ref,
    CartItem cartItem,
    int quantity,
  ) async {
    final existingItem = ProductTapCartSupport.findExistingItemWithFreeItemPromotion(
      ref.read(cartProvider),
      cartItem,
    );

    if (existingItem != null) {
      await _showFreeItemDialogForMergeAdd(context, ref, existingItem, quantity);
    }

    ref.read(cartProvider.notifier).addItem(cartItem);
    _schedulePromotionReEvaluation(ref);
  }

  static Future<void> _showFreeItemDialogForMergeAdd(
    BuildContext context,
    WidgetRef ref,
    CartItem existingItem,
    int additionalQuantity,
  ) async {
    dPrint(
      'MenuProductTapHandler: free-item merge for ${existingItem.nameEn}, additionalQty=$additionalQuantity',
    );
    final cart = ref.read(cartProvider);
    final cartIndex = cart.indexWhere((e) => identical(e, existingItem));
    if (cartIndex < 0) {
      dPrint('MenuProductTapHandler: free-item merge — could not resolve cart index for ${existingItem.nameEn}');
      return;
    }

    OrderSummary summary;
    try {
      summary = await ref.read(orderSummaryProvider.future);
    } catch (e, st) {
      dPrint('MenuProductTapHandler: order summary failed before free-item dialog: $e\n$st');
      return;
    }

    final salesItems = summary.salesInvoice.salesOrderItems;
    if (cartIndex >= salesItems.length) {
      dPrint(
        'MenuProductTapHandler: cart/sales length mismatch (cartIndex=$cartIndex, sales=${salesItems.length})',
      );
      return;
    }

    final salesItem = salesItems[cartIndex];
    if (salesItem.productId != existingItem.productId ||
        salesItem.unitOfMeasureId != existingItem.unitId.toString()) {
      dPrint('MenuProductTapHandler: sales line at $cartIndex does not match cart line — skip free dialog');
      return;
    }

    if (!salesItem.shouldShowFreeItemDialog()) {
      dPrint('MenuProductTapHandler: free-item dialog not required for ${existingItem.nameEn}');
      return;
    }

    if (!context.mounted) return;
    await FreeItemService.checkAndShowFreeItemDialog(context, salesItem, ref as Ref, cartIndex);
  }

  // ---------------------------------------------------------------------------
  // Promotion re-evaluation (debounced 100ms)
  // ---------------------------------------------------------------------------

  static void _schedulePromotionReEvaluation(WidgetRef ref) {
    _promotionDebounceTimer?.cancel();
    _promotionDebounceTimer = Timer(const Duration(milliseconds: 100), () {
      // Trigger re-evaluation via the payment breakdown provider
      // which already recalculates promotions on cart change.
      dPrint('MenuProductTapHandler: promotion re-evaluation triggered');
    });
  }

  // ---------------------------------------------------------------------------
  // Direct-call alias (kept for backwards compatibility)
  // ---------------------------------------------------------------------------

  static Future<void> handleProductTapDirect(
    BuildContext context,
    WidgetRef ref,
    SyncProduct product,
    bool isEnglish,
    bool fromSearch,
  ) async {
    await handleProductTap(context, ref, product, isEnglish, fromSearch);
  }
}
