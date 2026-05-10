import 'package:flutter/foundation.dart';
import 'package:kiosk_point_of_sale/data/models/cart_item.dart';

class VariationComparisonService {
  /// Compares two lists of variations to determine if they are equivalent
  static bool areVariationsEqual(List<SingleVariationWithPrice> variations1,
      List<SingleVariationWithPrice> variations2) {
    if (variations1.length != variations2.length) return false;

    // Sort both lists by variantId for consistent comparison
    final sorted1 = List<SingleVariationWithPrice>.from(variations1)
      ..sort((a, b) =>
          a.variationValue.variantId.compareTo(b.variationValue.variantId));
    final sorted2 = List<SingleVariationWithPrice>.from(variations2)
      ..sort((a, b) =>
          a.variationValue.variantId.compareTo(b.variationValue.variantId));

    return listEquals(
      sorted1.map((e) => e.variationValue.variantId).toList(),
      sorted2.map((e) => e.variationValue.variantId).toList(),
    );
  }

  /// Compares two lists of combo items to determine if they are equivalent
  static bool areComboItemsEqual(List<ComboMealItem>? combo1, List<ComboMealItem>? combo2) {
    if (combo1 == null && combo2 == null) return true;
    if (combo1 == null || combo2 == null) return false;
    if (combo1.length != combo2.length) return false;

    // Sort both lists by comboMealPackageItemId for consistent comparison
    final sorted1 = List<ComboMealItem>.from(combo1)
      ..sort((a, b) => a.comboMealPackageItemId.compareTo(b.comboMealPackageItemId));
    final sorted2 = List<ComboMealItem>.from(combo2)
      ..sort((a, b) => a.comboMealPackageItemId.compareTo(b.comboMealPackageItemId));

    for (var i = 0; i < sorted1.length; i++) {
      if (sorted1[i].comboMealPackageItemId != sorted2[i].comboMealPackageItemId ||
          sorted1[i].quantity != sorted2[i].quantity) {
        return false;
      }
    }
    return true;
  }

  /// Generates a unique key for a cart item based on its properties
  static String generateCartItemKey(CartItem item) {
    final variationIds =
        item.variations.map((e) => e.variationValue.variantId).toList()..sort();

    return '${item.productId}_${item.unitId}_${variationIds.join('_')}';
  }

  /// Checks if two cart items are the same (same product, unit, and variations)
  static bool areCartItemsEqual(CartItem item1, CartItem item2) {
    return item1.productId == item2.productId &&
        item1.unitId == item2.unitId &&
        item1.isComboMeal == item2.isComboMeal &&
        areVariationsEqual(item1.variations, item2.variations) &&
        item1.hasSameVariants(item2.selectedVariants) &&
        areComboItemsEqual(item1.comboItems, item2.comboItems);
  }
}
