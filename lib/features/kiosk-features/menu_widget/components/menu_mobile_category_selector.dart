import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiosk_point_of_sale/core/assets/app_assets.dart';
import 'package:kiosk_point_of_sale/providers/menu_providers.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/menu_widget/components/menu_category_card_widget.dart';

class MenuMobileCategorySelector extends ConsumerWidget {
  final Function(String)? onCategorySelected;
  final String? selectedCategoryId;

  const MenuMobileCategorySelector({
    super.key,
    this.onCategorySelected,
    this.selectedCategoryId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final isSearchActive = ref.watch(isSearchActiveProvider);

    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length + 1, // +1 for "All" option
        itemBuilder: (context, index) {
          if (index == 0) {
            // "All" option
            return MenuCategoryCardWidget(
              imagePath: AppAssets.productImagePlaceholder,
              title: isEnglish ? 'All' : 'الكل',
              backgroundColor: const Color(0xFFF8F2E8),
              textColor: const Color(0xFF121212),
              isFeatured: false,
              onTap: () => onCategorySelected?.call(''),
              isSelected: selectedCategoryId == null && !isSearchActive,
            );
          } else {
            final category = categories[index - 1];
            return MenuCategoryCardWidget(
              imagePath: category.imageId != null && category.imageId!.isNotEmpty
                  ? category.imageId!
                  : AppAssets.productImagePlaceholder,
              title:
                  isEnglish ? category.nameEn : category.nameAr,
              backgroundColor: const Color(0xFFF8F2E8),
              textColor: const Color(0xFF121212),
              isFeatured: false,
              onTap: () => onCategorySelected?.call(category.id.toString()),
              isSelected:
                  selectedCategoryId == category.id.toString() && !isSearchActive,
            );
          }
        },
      ),
    );
  }
}
