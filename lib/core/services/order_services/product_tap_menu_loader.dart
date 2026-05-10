import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiosk_point_of_sale/data/models/menu_item/menu_item_details.dart';
import 'package:kiosk_point_of_sale/data/models/sync_product/sync_product_model.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/sale_type_tables/sale_type_price_list_table.dart';
import 'package:kiosk_point_of_sale/providers/menu_providers.dart';
import 'package:kiosk_point_of_sale/providers/payment_breakdown_provider.dart';
import 'package:kiosk_point_of_sale/repository/menu_item_sync_repository.dart';

import 'product_tap_cart_support.dart';
import 'product_tap_variant_support.dart';

/// Result of loading menu-item variants + UOM rows for a product tap flow.
class ProductTapMenuContext {
  ProductTapMenuContext({
    required this.variants,
    required this.menuItemDetails,
    required this.priceListId,
  });

  final Map<String, dynamic> variants;
  final List<MenuItemDetails> menuItemDetails;
  final int priceListId;

  bool get hasConfigurableVariants => ProductTapVariantSupport.hasConfigurableVariants(variants);

  bool get multipleUnits => menuItemDetails.length > 1;

  bool get needsCustomizationDialog => multipleUnits || hasConfigurableVariants;
}

/// Loads remote/local menu context for [ProductTapHandler] (single place to change fetch logic).
abstract final class ProductTapMenuLoader {
  ProductTapMenuLoader._();

  static final MenuItemSyncRepository _repo = MenuItemSyncRepository();

  /// Returns `null` when the product has no usable unit of measure (even after stub fallback).
  static Future<ProductTapMenuContext?> load(WidgetRef ref, SyncProduct product) async {
    final menuItemId = product.id;

    final currentSaleType = ref.read(saleTypeNotifier);
    final saleTypePriceList =
        await SaleTypePriceListTable.getBySaleTypeId(currentSaleType?.saleTypeId ?? 0);
    final priceListId = saleTypePriceList?.priceListId ?? 1;

    final results = await Future.wait([
      _repo.fetchMenuItemVariants(menuItemId, priceListId),
      ref.read(menuItemDetailsProvider(MenuItemDetailsParams(menuItemId, priceListId)).future),
    ]);

    final variants = results[0] as Map<String, dynamic>;
    var menuItemDetails = results[1] as List<MenuItemDetails>;

    if (menuItemDetails.isEmpty) {
      menuItemDetails = ProductTapCartSupport.buildFallbackMenuItemDetails(product, menuItemId);
      if (menuItemDetails.isEmpty) {
        return null;
      }
    }

    return ProductTapMenuContext(
      variants: variants,
      menuItemDetails: menuItemDetails,
      priceListId: priceListId,
    );
  }
}
