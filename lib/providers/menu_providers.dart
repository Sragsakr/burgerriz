// providers/menu_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiosk_point_of_sale/data/models/menu_item/menu_item_details.dart';
import 'package:kiosk_point_of_sale/data/models/sync_product/sync_product_model.dart';
import 'package:kiosk_point_of_sale/providers/cart_provider.dart';
import 'package:kiosk_point_of_sale/repository/menu_item_sync_repository.dart';

final categoriesProvider = StateProvider<List<SyncCategory>>((ref) => []);
final allProductsProvider = StateProvider<List<SyncProduct>>((ref) => []);

final productsProvider =
    StateProvider.family<List<SyncProduct>, String>((ref, categoryId) => []);

// Search functionality providers
final searchQueryProvider = StateProvider<String>((ref) => '');

// Provider to check if search is active
final isSearchActiveProvider = Provider<bool>((ref) {
  final searchQuery = ref.watch(searchQueryProvider);
  return searchQuery.isNotEmpty;
});

// Search products provider that filters products based on search query
final searchProductsProvider = Provider<List<SyncProduct>>((ref) {
  final allProducts = ref.watch(allProductsProvider);
  final searchQuery = ref.watch(searchQueryProvider);

  if (searchQuery.isEmpty) {
    return allProducts;
  }

  return allProducts.where((product) {
    return product.nameEn
            .toLowerCase()
            .contains(searchQuery.toLowerCase()) ||
        product.nameAr
            .toLowerCase()
            .contains(searchQuery.toLowerCase()) ||
        (product.itemCode?.toLowerCase().contains(searchQuery.toLowerCase()) ??
            false) ||
        (product.barcode1 != null &&
            product.barcode1!
                .toLowerCase()
                .contains(searchQuery.toLowerCase())) ||
        (product.barcode2 != null &&
            product.barcode2!
                .toLowerCase()
                .contains(searchQuery.toLowerCase()));
  }).toList();
});

// Optional: Create a loading state provider
final isLoadingProvider = StateProvider<bool>((ref) => false);

// Recommended products provider that excludes items already in cart
final recommendedProductsProvider = Provider<List<SyncProduct>>((ref) {
  final allProducts = ref.watch(allProductsProvider);
  final cartItems = ref.watch(cartProvider);

  // Get product IDs that are already in cart
  final cartProductIds = cartItems.map((item) => item.productId).toSet();
  allProducts
      .where((product) => product.unitOfMeasures.isNotEmpty)
      .toList()
      .sort((a, b) => a.unitOfMeasures.first.price
          .compareTo(b.unitOfMeasures.first.price));
  // Filter out products that are already in cart and take top 10
  final recommendedProducts = allProducts
      .where((product) => !cartProductIds.contains(product.productId))
      .take(10)
      .toList();

  return recommendedProducts;
});

/// Provides [MenuItemDetails] (UOM + price entries) for a specific menu item
/// in the active price list. Used by the tap handler and [ItemCustomizationDialog].
final menuItemDetailsProvider = FutureProvider.autoDispose
    .family<List<MenuItemDetails>, MenuItemDetailsParams>(
  (ref, params) async {
    final repo = MenuItemSyncRepository();
    return repo.getMenuItemDetails(params.menuItemId, params.priceListId);
  },
);

// Helper methods for search functionality
extension SearchHelpers on WidgetRef {
  void clearSearch() {
    read(searchQueryProvider.notifier).state = '';
  }

  void updateSearchQuery(String query) {
    read(searchQueryProvider.notifier).state = query;
  }
}
