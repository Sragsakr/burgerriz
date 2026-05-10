import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/core/services/order_services/free_item_service.dart';
import 'package:kiosk_point_of_sale/core/services/variations_services/variation_comparison_service.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_items_model.dart';
import 'package:kiosk_point_of_sale/data/models/menu_item/selected_variant.dart';

import '../data/models/cart_item.dart';

typedef CartScrollCallback = void Function(int index);

CartScrollCallback? _onCartScroll;

void registerCartScrollCallback(CartScrollCallback? callback) {
  _onCartScroll = callback;
}

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addItem(CartItem item) {
    final existingIndex = state.indexWhere((existingItem) {
      return VariationComparisonService.areCartItemsEqual(existingItem, item);
    });

    if (existingIndex >= 0) {
      // Update existing item quantity
      state = [
        ...state.sublist(0, existingIndex),
        state[existingIndex]
            .copyWith(quantity: state[existingIndex].quantity + 1),
        ...state.sublist(existingIndex + 1),
      ];
    } else {
      // Add new item
      state = [...state, item];
    }
    _onCartScroll?.call(state.length - 1);
  }

  void initScrolling() {
    _onCartScroll?.call(state.length - 1);
  }

  void initScrolling1() {
    _onCartScroll?.call(state.length);
  }

  void removeItem(
      String productId, int unitId, List<SingleVariationWithPrice> variations,
      {List<SelectedVariant>? selectedVariants, List<ComboMealItem>? comboItems, bool? isComboMeal}) {
    state = state
        .where((item) => !(item.productId == productId &&
            item.unitId == unitId &&
            item.isComboMeal == (isComboMeal ?? false) &&
            VariationComparisonService.areVariationsEqual(item.variations, variations) &&
            item.hasSameVariants(selectedVariants ?? []) &&
            VariationComparisonService.areComboItemsEqual(item.comboItems, comboItems)))
        .toList();

    /// need here to remove the promotion that apply on this item
  }

  void updateQuantity(String productId, int unitId, double quantity,
      List<SingleVariationWithPrice> variations,
      {List<SelectedVariant>? selectedVariants, List<ComboMealItem>? comboItems, bool? isComboMeal}) {
    final index = state.indexWhere((item) =>
        item.productId == productId &&
        item.unitId == unitId &&
        item.isComboMeal == (isComboMeal ?? false) &&
        VariationComparisonService.areVariationsEqual(item.variations, variations) &&
        item.hasSameVariants(selectedVariants ?? []) &&
        VariationComparisonService.areComboItemsEqual(item.comboItems, comboItems));

    if (index >= 0) {
      if (quantity <= 0) {
        removeItem(productId, unitId, variations, selectedVariants: selectedVariants, comboItems: comboItems, isComboMeal: isComboMeal);
      } else {
        state = [
          ...state.sublist(0, index),
          state[index].copyWith(quantity: quantity),
          ...state.sublist(index + 1),
        ];
      }
    }
  }

  void clearCart() {
    // Clear all stored free item states when cart is cleared
    FreeItemService.clearAllFreeItemStates();
    state = [];
  }

  /// Update the free item selection state for a specific cart item by index
  void updateFreeItemState(
      int cartIndex, FreeItemSelectionState freeItemState) {
    if (cartIndex >= 0 && cartIndex < state.length) {
      state = [
        ...state.sublist(0, cartIndex),
        state[cartIndex].copyWith(freeItemSelectionState: freeItemState),
        ...state.sublist(cartIndex + 1),
      ];
      dPrint(
          '🎁 Updated free item state for cart item at index $cartIndex: $freeItemState');
    } else {
      dPrint(
          '🎁 ⚠️ Invalid cart index $cartIndex for updating free item state');
    }
  }

  /// Update the free item selection details for a specific cart item by index
  void updateFreeItemDetails(
    int cartIndex,
    FreeItemSelectionState? freeItemState, {
    String? selectedFreeProductId,
    String? selectedFreeProductName,
    String? selectedFreeProductNameAr,
    double? selectedFreeProductQuantity,
    double? selectedFreeProductPrice,
    int? selectedFreeItemId,
    bool? isPromotionDuplicated,
  }) {
    if (cartIndex >= 0 && cartIndex < state.length) {
      // If all values are null, use the reset method
      if (freeItemState == null &&
          selectedFreeProductId == null &&
          selectedFreeProductName == null &&
          selectedFreeProductNameAr == null &&
          selectedFreeProductQuantity == null &&
          selectedFreeProductPrice == null &&
          selectedFreeItemId == null) {
        state = [
          ...state.sublist(0, cartIndex),
          state[cartIndex].resetFreeItemSelection(),
          ...state.sublist(cartIndex + 1),
        ];
        dPrint(
            '🎁 Reset all free item details for cart item at index $cartIndex');
      } else {
        state = [
          ...state.sublist(0, cartIndex),
          state[cartIndex].copyWith(
            freeItemSelectionState: freeItemState,
            selectedFreeProductId: selectedFreeProductId,
            selectedFreeProductName: selectedFreeProductName,
            selectedFreeProductNameAr: selectedFreeProductNameAr,
            selectedFreeProductQuantity: selectedFreeProductQuantity,
            selectedFreeProductPrice: selectedFreeProductPrice,
            selectedFreeItemId: selectedFreeItemId,
          ),
          ...state.sublist(cartIndex + 1),
        ];
        dPrint(
            '🎁 Updated free item details for cart item at index $cartIndex: $freeItemState');
        dPrint(
            '🎁 Free product: $selectedFreeProductName (ID: $selectedFreeProductId, Qty: $selectedFreeProductQuantity)');
      }
    } else {
      dPrint(
          '🎁 ⚠️ Invalid cart index $cartIndex for updating free item details');
    }
  }

  /// Replace a cart item at a specific index with a new item
  void updateItemAtIndex(int index, CartItem newItem) {
    if (index >= 0 && index < state.length) {
      state = [
        ...state.sublist(0, index),
        newItem,
        ...state.sublist(index + 1),
      ];
      dPrint('🛒 Updated cart item at index $index');
    } else {
      dPrint('🛒 ⚠️ Invalid cart index $index for updating item');
    }
  }

  double get total =>
      state.fold(0, (sum, item) => sum + (item.price * item.quantity));

// // Update cart items from a PromotionInvoice
// void updateFromPromotionInvoice(PromotionInvoice invoice) {
//   // Only update the cart items (state) from the invoice's salesOrderItems
//   // (You may want to update more fields in a real app)
//   state = invoice.salesTransaction.salesOrderItems
//       .map((item) => CartItem(

//             productId: item.productId,
//             nameEn: item.productNameEn,
//             nameAr: item.productNameAr,
//             quantity: double.tryParse(item.quantity) ?? 1,
//             price: double.tryParse(item.price) ?? 0.0,
//             unitId: int.tryParse(item.unitOfMeasureId) ?? 0,
//             inclusive: item.isExclusive,
//           ))
//       .toList();
// }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});
