import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiosk_point_of_sale/core/config/app_mode_session.dart';
import 'package:kiosk_point_of_sale/core/helpers/clear_cart_with_prices.dart';
import 'package:kiosk_point_of_sale/core/helpers/login_helpers.dart';
import 'package:kiosk_point_of_sale/providers/payment_breakdown_provider.dart';
import 'package:kiosk_point_of_sale/data/models/sync_product/sync_product_model.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/sale_type_tables/sale_type_price_list_table.dart';
import 'package:kiosk_point_of_sale/providers/menu_providers.dart';
import 'package:kiosk_point_of_sale/repository/menu_item_sync_repository.dart';

/// Shared catalog load for kiosk menu bar, kiosk sale-type screen, and handheld sale flow.
class MenuCatalogPreloadHelper {
  MenuCatalogPreloadHelper._();

  /// Fills [categoriesProvider], per-category [productsProvider], and [allProductsProvider].
  ///
  /// When effective report group is null (unset or [AppConfig.isMobile]), loads full price-list menu.
  static Future<void> loadCatalogForSaleType(
    WidgetRef ref,
    SaleType saleType, {
    bool resetPaymentAndCart = false,
  }) async {
    ref.read(saleTypeNotifier.notifier).state = saleType;
    AppModeSession.effectiveCatalogReportGroupId();

    final priceList =
        await SaleTypePriceListTable.getBySaleTypeId(saleType.saleTypeId);
    final priceListId = priceList?.priceListId ?? 1;

    final syncRepo = MenuItemSyncRepository();
    final allCategories = await syncRepo.getAllCategories();

    // Load ALL products once (not per category)
    final allProducts = await syncRepo.getAllProducts(priceListId);

    ref.read(allProductsProvider.notifier).state = [];
    final allFiltered = <SyncProduct>[];
    final validCategories = <SyncCategory>[];

    // Group products by category in memory
    final productsByCategory = <int, List<SyncProduct>>{};
    for (final product in allProducts) {
      productsByCategory
          .putIfAbsent(product.productCategoryId, () => [])
          .add(product);
    }

    // Update providers
    for (final category in allCategories) {
      final products = productsByCategory[category.id] ?? [];
      if (products.isNotEmpty) {
        validCategories.add(category);
        ref
            .read(productsProvider(category.id.toString()).notifier)
            .state = products;
        allFiltered.addAll(products);
      }
    }

    ref.read(categoriesProvider.notifier).state = validCategories;
    ref.read(allProductsProvider.notifier).state = allFiltered;

    if (resetPaymentAndCart) {
      resetPaymentAndCartValues(ref);
    }
  }
}
