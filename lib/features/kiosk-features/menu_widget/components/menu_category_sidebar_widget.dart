import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiosk_point_of_sale/core/assets/app_assets.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/providers/menu_providers.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/menu_widget/components/menu_category_card_widget.dart';

class MenuCategorySidebarWidget extends ConsumerWidget {
  final Function(String?)? onCategorySelected;
  final String? selectedCategoryId;

  const MenuCategorySidebarWidget({
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
      width: MediaQuery.sizeOf(context).width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(0.0),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 20.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MenuCategoryCardWidget(
                imagePath: AppAssets.newLogo,
                title: translator(arText: "الكل", enText: "All"),
                backgroundColor: const Color(0xFFF8F2E8),
                textColor: const Color(0xFF121212),
                isFeatured: false,
                isSelected: selectedCategoryId == null || isSearchActive,
                onTap: () => onCategorySelected?.call(null),
              ),
              ...categories.map((category) => MenuCategoryCardWidget(
                    imagePath: category.imageId != null && category.imageId!.isNotEmpty
                        ? category.imageId!
                        : AppAssets.productImagePlaceholder,
                    title: isEnglish ? category.nameEn : category.nameAr,
                    backgroundColor: const Color(0xFFF8F2E8),
                    textColor: const Color(0xFF121212),
                    isFeatured: false,
                    onTap: () => onCategorySelected?.call(category.id.toString()),
                    isSelected: selectedCategoryId == category.id.toString() && !isSearchActive,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
