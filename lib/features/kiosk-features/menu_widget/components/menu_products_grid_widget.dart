import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiosk_point_of_sale/core/helpers/responsive_helper.dart';
import 'package:kiosk_point_of_sale/data/models/sync_product/sync_product_model.dart';
import 'package:kiosk_point_of_sale/providers/category_navigation_provider.dart';
import 'package:kiosk_point_of_sale/providers/menu_providers.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/menu_widget/components/menu_product_card_widget.dart';

class MenuProductsGridWidget extends ConsumerWidget {
  final String? selectedCategoryId;
  final Function(String)? onProductSelected;

  const MenuProductsGridWidget({
    super.key,
    this.selectedCategoryId,
    this.onProductSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final searchQuery = ref.watch(searchQueryProvider);
    final isSearchActive = ref.watch(isSearchActiveProvider);

    List<SyncProduct> products = [];

    if (isSearchActive) {
      products = ref.watch(searchProductsProvider);
    } else {
      final activeCategory = ref.watch(activeCategoryProvider);
      if (activeCategory != null) {
        products = ref.watch(productsProvider(activeCategory.id.toString()));
      }
    }

    if (products.isEmpty) {
      return _EmptyView(
        isSearchActive: isSearchActive,
        searchQuery: searchQuery,
        isEnglish: isEnglish,
      );
    }

    final activeCategory = ref.watch(activeCategoryProvider);
    final animationKey = isSearchActive ? 'search_$searchQuery' : 'cat_${activeCategory?.id}';

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: Padding(
        key: ValueKey(animationKey),
        padding: EdgeInsets.zero,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(5.0, 0.0, 0.0, 0.0),
                child: GridView.builder(
                  padding: const EdgeInsetsDirectional.only(end: 16, bottom: 20, top: 8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                    childAspectRatio: 0.78,
                  ),
                  scrollDirection: Axis.vertical,
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return MenuProductCardWidget(
                      product: product,
                      isEnglish: isEnglish,
                      fromSearch: isSearchActive,
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final bool isSearchActive;
  final String searchQuery;
  final bool isEnglish;

  const _EmptyView({
    required this.isSearchActive,
    required this.searchQuery,
    required this.isEnglish,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSearchActive ? Icons.search_off : Icons.restaurant_menu_outlined,
            size: ResponsiveHelper.getResponsiveSize(context, 48),
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          AutoSizeText(
            isSearchActive
                ? (isEnglish ? 'No products found for "$searchQuery"' : 'لم يتم العثور على منتجات لـ "$searchQuery"')
                : (isEnglish ? 'No products available' : 'لا توجد منتجات متاحة'),
            maxLines: 3,
            minFontSize: 14,
            stepGranularity: 1,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 8),
          AutoSizeText(
            isSearchActive
                ? (isEnglish ? 'Try a different search term' : 'جرب مصطلح بحث مختلف')
                : (isEnglish ? 'Select a category to view products' : 'اختر فئة لعرض المنتجات'),
            maxLines: 2,
            minFontSize: 10,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}
