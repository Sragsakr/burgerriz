import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_theme.dart';
import 'package:kiosk_point_of_sale/core/helpers/responsive_helper.dart';
import 'package:kiosk_point_of_sale/providers/category_navigation_provider.dart';

class MenuSubcategoryBar extends ConsumerWidget {
  const MenuSubcategoryBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isShowing = ref.watch(isShowingChildrenProvider);
    final children = ref.watch(currentChildCategoriesProvider);
    final selectedChild = ref.watch(selectedChildCategoryProvider);
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';

    if (!isShowing || children.isEmpty) {
      if(kDebugMode)
      return const Center(
        child: AutoSizeText(
          'No subcategories',
          maxLines: 1,
          minFontSize: 10,
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      );
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 12, 10),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: children
                .map((child) => _SubcategoryChip(
                      label: isEnglish ? child.nameEn : child.nameAr,
                      isSelected: selectedChild?.id == child.id,
                      onTap: () {
                        ref
                            .read(categoryNavigationProvider.notifier)
                            .selectChildCategory(child);
                      },
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _SubcategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SubcategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 8, 0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFAF2A26)
                  : const Color(0xFFF8F2E8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: AutoSizeText(
              label,
              maxLines: 1,
              minFontSize: 10,
              stepGranularity: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 13),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF121212),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
