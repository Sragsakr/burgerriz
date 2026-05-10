import 'package:kiosk_point_of_sale/data/models/cart_item.dart';
import 'package:kiosk_point_of_sale/data/models/menu_item/menu_item_details.dart';
import 'package:kiosk_point_of_sale/data/models/menu_item/selected_variant.dart';
import 'package:kiosk_point_of_sale/data/models/sync_product/sync_product_model.dart';
import 'package:kiosk_point_of_sale/repository/promotions/enums/promotion_value_type.dart';

/// Shared cart-building and promotion-merge helpers for product tap flows
/// (menu grid, quantity shortcuts, etc.). Keeps [ProductTapHandler] thin.
abstract final class ProductTapCartSupport {
  ProductTapCartSupport._();

  static List<MenuItemDetails> buildFallbackMenuItemDetails(SyncProduct product, int menuItemId) {
    if (product.unitOfMeasures.isEmpty) return [];
    return product.unitOfMeasures.map((u) {
      return MenuItemDetails(
        menuItemId: menuItemId,
        unitOfMeasureId: u.unitOfMeasureId,
        unitNameEn: u.nameEn,
        unitNameAr: u.nameAr,
        price: 0.0,
        taxValue: 0.0,
        isVAT: false,
      );
    }).toList();
  }

  static CartItem buildCartItem({
    required SyncProduct product,
    required MenuItemDetails unit,
    required List<SelectedVariant> selectedVariants,
    required int quantity,
    required double totalPrice,
  }) {
    return CartItem(
      imageUrl: product.imageUrl,
      itemCode: product.itemCode ?? '',
      inclusive: product.isExclusive,
      categoryId: product.category?.id.toString() ?? '',
      productId: product.productId,
      nameEn: product.nameEn,
      nameAr: product.nameAr,
      quantity: quantity,
      price: totalPrice,
      unitId: unit.unitOfMeasureId,
      unitNameEn: unit.unitNameEn,
      unitNameAr: unit.unitNameAr,
      variations: [],
      selectedVariants: selectedVariants,
    );
  }

  /// When adding the same line as an existing free-product promotion, UI may need to merge.
  static CartItem? findExistingItemWithFreeItemPromotion(List<CartItem> cart, CartItem itemToAdd) {
    for (final item in cart) {
      if (item.productId != itemToAdd.productId) continue;
      if (item.unitId != itemToAdd.unitId) continue;
      if (item.promotionType != PromotionIValueType.specificValueWithFreeProduct.value) continue;
      if (item.promotionId == null && item.actualPromotionId == null) continue;
      return item;
    }
    return null;
  }
}
