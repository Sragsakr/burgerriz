import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/free_item_selection_dialog.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_dialogs.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_items_model.dart';
import 'package:kiosk_point_of_sale/providers/cart_provider.dart';

class FreeItemService {
  // Store free item selection states to preserve across order recalculations
  static final Map<String, FreeItemSelectionState> _freeItemStates = {};

  /// Check for free items for all sales items that have promotions applied
  /// and show selection dialogs if free items are available
  static Future<void> checkAndShowFreeItemDialogs(
    BuildContext context,
    List<SalesItemsModel> salesItems,
    Ref ref,
  ) async {
    dPrint(
        '🎁 FreeItemService: Checking ${salesItems.length} sales items for free item dialogs');
    debugPrintStoredStates();

    for (int i = 0; i < salesItems.length; i++) {
      final salesItem = salesItems[i];
      dPrint('🎁 Checking item $i: ${salesItem.productNameEn}');
      dPrint('   - Promotion ID: ${salesItem.promotionCodeId}');
      dPrint('   - Free item state: ${salesItem.freeItemSelectionState}');

      // Simple check: if the item already has a state (selected or ignored), skip it
      if (salesItem.freeItemSelectionState != null &&
          salesItem.freeItemSelectionState != FreeItemSelectionState.notShown) {
        dPrint(
            '   - ⏭️ Skipping item - already has state: ${salesItem.freeItemSelectionState}');
        continue;
      }

      dPrint(
          '   - Should show dialog: ${salesItem.shouldShowFreeItemDialog()}');

      // Only check items that should show the dialog
      if (salesItem.shouldShowFreeItemDialog()) {
        dPrint('🎁 Showing dialog for: ${salesItem.productNameEn}');
        await _checkAndShowFreeItemDialog(
            context, salesItem, ref, salesItems.indexOf(salesItem));
        // // Only show one dialog at a time
        // break;
      }
    }
  }

  /// Check for free items for a specific sales item and show dialog if available
  static Future<void> checkAndShowFreeItemDialog(
    BuildContext context,
    SalesItemsModel salesItem,
    Ref ref,
    int cartIndex,
  ) async {
    if (salesItem.shouldShowFreeItemDialog()) {
      await _checkAndShowFreeItemDialog(context, salesItem, ref, cartIndex);
    }
  }

  /// Internal method to check and show free item dialog
  static Future<void> _checkAndShowFreeItemDialog(BuildContext context,
      SalesItemsModel salesItem, Ref ref, int cartIndex) async {
    try {
      dPrint(
          '🎁 _checkAndShowFreeItemDialog: Checking free products for ${salesItem.productNameEn}');

      // Check if this item has free products available
      final freeProducts = await salesItem.getFreeProducts(ref);
      dPrint('🎁 Found ${freeProducts.length} free products');

      if (freeProducts.isNotEmpty) {
        dPrint('🎁 Getting free products with details...');
        // Get free products with details
        final freeProductsWithDetails =
            await salesItem.getFreeProductsWithDetails(ref);
        dPrint(
            '🎁 Free products with details: ${freeProductsWithDetails.length}');

        dPrint('🎁 Showing free item selection dialog...');
        // Show the free item selection dialog
        final result = await showAppDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => FreeItemSelectionDialog(
            salesItem: salesItem,
            freeProducts: freeProducts,
            freeProductsWithDetails: freeProductsWithDetails,
          ),
        );

        dPrint('🎁 Dialog result: $result');
        // Handle the result
        if (result == null || result == false) {
          // User cancelled - mark as ignored to prevent showing again
          dPrint('🎁 User cancelled - marking as ignored');
          salesItem.setFreeItemSelectionState(FreeItemSelectionState.ignored);
          // here will update the cart item state
          ref
              .read(cartProvider.notifier)
              .updateFreeItemState(cartIndex, FreeItemSelectionState.ignored);
        } else {
          dPrint('🎁 User selected free item');
          salesItem.setFreeItemSelectionState(FreeItemSelectionState.selected);
          // here will update the cart item state with all free product details
          ref.read(cartProvider.notifier).updateFreeItemDetails(
                cartIndex,
                FreeItemSelectionState.selected,
                selectedFreeProductId: salesItem.selectedFreeProductId,
                selectedFreeProductName: salesItem.selectedFreeProductName,
                selectedFreeProductNameAr: salesItem.selectedFreeProductNameAr,
                selectedFreeProductQuantity:
                    salesItem.selectedFreeProductQuantity,
                selectedFreeProductPrice: salesItem.selectedFreeProductPrice,
                selectedFreeItemId: salesItem.selectedFreeItemId,
                isPromotionDuplicated: salesItem.isPromotionDuplicated,
              );
          // State is already set to selected in selectFreeProduct method
        }

        // Force immediate state storage to prevent any race conditions

        FreeItemService.storeFreeItemState(
          salesItem,
        );
        dPrint(
            '🎁 Force stored state after dialog: ${salesItem.freeItemSelectionState}');

        // Ensure the state is preserved with additional safety
        FreeItemService.ensureStatePreserved(
            salesItem, salesItem.freeItemSelectionState!);
      } else {
        dPrint('🎁 No free products available for this item');
      }
    } catch (e) {
      // Handle error silently or log it
      dPrint('❌ Error checking for free items: $e');
    }
  }

  /// Check if any sales items have free products available
  static Future<bool> hasAnyFreeItemsAvailable(
      List<SalesItemsModel> salesItems, Ref ref) async {
    for (final salesItem in salesItems) {
      if (salesItem.shouldShowFreeItemDialog()) {
        final freeProducts = await salesItem.getFreeProducts(ref);
        dPrint('Free products: ${freeProducts.length}');
        if (freeProducts.isNotEmpty) {
          return true;
        }
      }
    }
    return false;
  }

  /// Get all sales items that have free products available
  static Future<List<SalesItemsModel>> getSalesItemsWithFreeProducts(
    List<SalesItemsModel> salesItems,
    Ref ref,
  ) async {
    final List<SalesItemsModel> itemsWithFreeProducts = [];

    for (final salesItem in salesItems) {
      if (salesItem.shouldShowFreeItemDialog()) {
        final freeProducts = await salesItem.getFreeProducts(ref);
        if (freeProducts.isNotEmpty) {
          itemsWithFreeProducts.add(salesItem);
        }
      }
    }

    return itemsWithFreeProducts;
  }

  /// Reset free product selection for a specific sales item
  /// This should be called when an item is removed from cart
  static void resetFreeProductSelection(SalesItemsModel salesItem) {
    if (salesItem.hasSelectedFreeProduct()) {
      salesItem.removeFreeProduct();
    }
  }

  /// Reset free product selections for multiple sales items
  /// This should be called when multiple items are removed or cart is cleared
  static void resetFreeProductSelections(List<SalesItemsModel> salesItems) {
    for (final salesItem in salesItems) {
      resetFreeProductSelection(salesItem);
    }
  }

  /// Generate a unique key for a sales item to store its free item state
  /// Uses the cart index for reliable identification
  static String _getItemKey(SalesItemsModel salesItem) {
    return 'cart_index_${salesItem.uniqueId}';
  }

  /// Store the free item selection state for a sales item
  static void storeFreeItemState(SalesItemsModel salesItem) {
    if (salesItem.freeItemSelectionState != null) {
      final key = _getItemKey(salesItem);
      _freeItemStates[key] = salesItem.freeItemSelectionState!;
      dPrint(
          '🎁 Stored free item state for ${salesItem.productNameEn}: ${salesItem.freeItemSelectionState}');
      dPrint('🎁 Total stored states: ${_freeItemStates.length}');
    }
  }

  /// Retrieve the free item selection state for a sales item
  static FreeItemSelectionState? getFreeItemState(SalesItemsModel salesItem) {
    final key = _getItemKey(salesItem);
    final state = _freeItemStates[key];
    dPrint(
        '🎁 Retrieved free item state for ${salesItem.productNameEn}: $state');
    dPrint('🎁 Available keys: ${_freeItemStates.keys.toList()}');
    return state;
  }

  /// Clear the stored free item state for a specific item
  static void clearFreeItemState(SalesItemsModel salesItem, int cartIndex) {
    final key = _getItemKey(salesItem);
    _freeItemStates.remove(key);
    dPrint(
        '🎁 Cleared free item state for ${salesItem.productNameEn} (cart index: $cartIndex)');
  }

  /// Clear the stored free item state for a cart item using cart index
  static void clearFreeItemStateByCartIndex(int cartIndex) {
    final key = 'cart_index_$cartIndex';
    _freeItemStates.remove(key);
    dPrint('🎁 Cleared free item state for cart index: $cartIndex');
  }

  /// Clear all stored free item states
  static void clearAllFreeItemStates() {
    _freeItemStates.clear();
    dPrint('🎁 Cleared all free item states');
  }

  /// Get all stored states for debugging
  static Map<String, FreeItemSelectionState> get storedStates =>
      _freeItemStates;

  /// Debug method to print all stored states
  static void debugPrintStoredStates() {
    dPrint('🎁 === DEBUG: All Stored States ===');
    if (_freeItemStates.isEmpty) {
      dPrint('🎁 No states stored');
    } else {
      _freeItemStates.forEach((key, state) {
        dPrint('🎁 $key: $state');
      });
    }
    dPrint('🎁 === END DEBUG ===');
  }

  /// Ensure a state is preserved for a specific cart index
  /// This is a safety method to prevent state loss
  static void ensureStatePreserved(
      SalesItemsModel salesItem, FreeItemSelectionState state) {
    final key = 'cart_index_${salesItem.uniqueId}';
    _freeItemStates[key] = state;
  }

  /// Check if a state exists for a cart index
  static bool hasStateForCartIndex(int cartIndex) {
    final key = 'cart_index_$cartIndex';
    return _freeItemStates.containsKey(key);
  }

  /// Update the free item selection state in the cart item
  /// This ensures the state is preserved in the cart item itself
  static void updateCartItemState(
      SalesItemsModel salesItem, FreeItemSelectionState state) {
    // This method will be called from the SalesItemsModel when state is set
    // The actual cart item update will be handled by the cart provider
    dPrint(
        '🎁 Updating cart item state for ${salesItem.productNameEn}: $state');
  }
}
