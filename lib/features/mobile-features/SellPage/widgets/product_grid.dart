import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiosk_point_of_sale/core/helpers/menu_product_tap_handler.dart';
import 'package:kiosk_point_of_sale/features/mobile-features/SellPage/widgets/product_grid_helper.dart';
import 'package:kiosk_point_of_sale/data/models/sync_product/sync_product_model.dart';

class ProductGrid extends ConsumerWidget {
  final List<SyncProduct> products;
  final bool isEnglish;
  bool fromSearch;

  ProductGrid({
    super.key,
    required this.products,
    required this.isEnglish,
    this.fromSearch = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return InkWell(
          onTap: () {
            ProductTapHandler.handleProductTap(
              context,
              ref,
              product,
              isEnglish,
              false,
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 2,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    // child: getImageUrl(product.imageUrl),
                    child:
                        buildSyncProductImage(product), // Use the new method here
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Text(
                      isEnglish ? product.nameEn : product.nameAr,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
