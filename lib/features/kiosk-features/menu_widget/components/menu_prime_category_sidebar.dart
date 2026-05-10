import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/menu_widget/components/kiosk_product_image_helpers.dart';
import 'package:kiosk_point_of_sale/core/extentions/app_extentions.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_theme.dart';
import 'package:kiosk_point_of_sale/core/helpers/responsive_helper.dart';
import 'package:kiosk_point_of_sale/data/models/sync_product/sync_product_model.dart';
import 'package:kiosk_point_of_sale/providers/category_navigation_provider.dart';
import 'package:kiosk_point_of_sale/providers/payment_breakdown_provider.dart';

class MenuPrimeCategorySidebar extends ConsumerWidget {
  const MenuPrimeCategorySidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parentCategories = ref.watch(parentCategoriesProvider);
    final selectedParent = ref.watch(selectedParentCategoryProvider);
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';

    if (parentCategories.isEmpty) {
      return const SizedBox(
        width: 100,
        child: Center(
          child: AutoSizeText(
            'No categories',
            maxLines: 2,
            minFontSize: 10,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
      );
    }
    final theme = ref.watch(reportGroupThemeProvider);
    return Container(
      width: ResponsiveHelper.getResponsiveSize(context, 18.w),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        border: Border(
          right: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
          left: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 10),
          Image.asset(
            theme.logoAsset,
            width: theme.isSteakHouseBrand ? 15.w : null,
            height: theme.isSteakHouseBrand ? 15.w : 5.h,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: parentCategories.length,
              itemBuilder: (context, index) {
                final category = parentCategories[index];
                final isSelected = selectedParent?.id == category.id;

                return _PrimeCategoryTile(
                  category: category,
                  isSelected: isSelected,
                  isEnglish: isEnglish,
                  backgroundColor: theme.accentColor,
                  onTap: () {
                    ref.read(categoryNavigationProvider.notifier).selectParentCategory(category);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimeCategoryTile extends StatelessWidget {
  final SyncCategory category;
  final bool isSelected;
  final bool isEnglish;
  final VoidCallback onTap;
  final Color backgroundColor;

  const _PrimeCategoryTile({
    required this.category,
    required this.isSelected,
    required this.isEnglish,
    required this.onTap,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final tileSize = ResponsiveHelper.getResponsiveSize(context, 60);
    final imageSize = ResponsiveHelper.getResponsiveSize(context, 15.w);
    final fontSize = ResponsiveHelper.getResponsiveFontSize(context, 9);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: tileSize,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              color: isSelected ? backgroundColor : const Color(0xFFF8F2E8),
              borderRadius: BorderRadius.circular(12),
              border: isSelected ? Border.all(color: backgroundColor, width: 2) : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFFAF2A26).withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      )
                    ]
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCategoryImage(context, imageSize),
                const SizedBox(height: 4),
                AutoSizeText(
                  isEnglish ? category.nameEn : category.nameAr,
                  maxLines: 2,
                  minFontSize: 12,
                  stepGranularity: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: fontSize,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF121212),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryImage(BuildContext context, double size) {
    final hasImage = category.imageId != null && category.imageId!.isNotEmpty;

    if (hasImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: size,
          height: size,
          child: buildImage(category.imageId!),
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withValues(alpha: 0.2) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.restaurant_menu,
        size: size * 0.5,
        color: isSelected ? Colors.white : Colors.grey.shade500,
      ),
    );
  }
}
