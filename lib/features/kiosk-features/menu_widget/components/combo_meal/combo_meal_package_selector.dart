import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiosk_point_of_sale/core/extentions/app_extentions.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/data/models/combo_meal/combo_meal_package_model.dart';
import 'package:kiosk_point_of_sale/providers/combo_meal_provider.dart';

class ComboMealPackageSelector extends ConsumerWidget {
  final ComboMealPackage package;
  final Color themeColor;

  const ComboMealPackageSelector({
    super.key,
    required this.package,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(comboMealProvider.notifier);
    ref.watch(comboMealProvider);

    final groupName = translator(arText: package.nameAr, enText: package.name);
    final selectedCount = package.items.fold<int>(0, (sum, item) => sum + notifier.getItemSelectionCount(item));

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: _SectionHeader(
              title: groupName,
              isRequired: true, // Assuming packages are required
              selectCount: package.quantity,
              selectedCount: selectedCount,
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(builder: (context, constraints) {
            const spacing = 10.0;
            final tileW = (constraints.maxWidth - spacing * 3) / 4;

            if (package.items.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    translator(arText: 'لا توجد عناصر متاحة', enText: 'No items available'),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              );
            }

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: List.generate(package.items.length, (i) {
                final item = package.items[i];
                final count = notifier.getItemSelectionCount(item);
                final isSelected = count > 0;
                final canSelect = item.canSelect && !package.isComplete;
                final isFree = item.price <= 0;

                return _KioskOptionTile(
                  name: translator(arText: item.nameAr, enText: item.name),
                  price: item.price,
                  isFree: isFree,
                  isSelected: isSelected,
                  quantity: count.toDouble(),
                  showQtyControls: item.maxQuantity > 1,
                  maxQtyPerModifier: item.maxQuantity,
                  tileWidth: tileW,
                  accentColor: Colors.orange,
                  onTap: () {
                    if (isSelected) {
                      notifier.removeItem(item);
                    } else if (canSelect) {
                      notifier.selectItem(item);
                    } else if (package.isComplete) {
                      if (package.quantity == 1) {
                        // Single-select package: swap selection
                        final current = package.items.firstWhere(
                          (i) => notifier.getItemSelectionCount(i) > 0,
                          orElse: () => item,
                        );
                        notifier.removeItem(current);
                        notifier.selectItem(item);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              translator(
                                arText: 'لقد وصلت إلى الحد الأقصى للاختيارات',
                                enText: 'You have reached the maximum selections',
                              ),
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  },
                  onIncrement: () {
                    if (canSelect) notifier.selectItem(item);
                  },
                  onDecrement: () {
                    if (isSelected) notifier.removeItem(item);
                  },
                );
              }),
            );
          }),
        ],
      ),
    );
  }
}

// =============================================================================
// Transferred from KioskProductCustomizationSheet
// =============================================================================

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isRequired;
  final int selectCount;
  final int selectedCount;

  const _SectionHeader({
    required this.title,
    required this.isRequired,
    required this.selectCount,
    required this.selectedCount,
  });

  @override
  Widget build(BuildContext context) {
    final selectLabel = selectCount > 0 ? ' (Select $selectCount)' : '';
    final reqLabel = isRequired ? 'Required' : 'Optional';
    final reqColor = isRequired ? const Color(0xFFAF2A26) : Colors.black;
    const selectTextColor = Color(0xFF9E9E9E);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Directionality(
          textDirection: TextDirection.ltr,
          child: RichText(
            text: TextSpan(
              text: reqLabel,
              style: TextStyle(
                fontSize: 12,
                color: reqColor,
                fontWeight: FontWeight.w600,
              ),
              children: [
                TextSpan(
                  text: selectLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    color: selectTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PriceBadge extends StatelessWidget {
  final bool isFree;
  final double price;
  final Color accentColor;

  const _PriceBadge({
    required this.isFree,
    required this.price,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final label = isFree || price <= 0 ? 'Free' : '+${price.toStringAsFixed(2)} SR';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 5),
      decoration: BoxDecoration(
        color: accentColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _KioskOptionTile extends StatelessWidget {
  final String name;
  final double price;
  final bool isFree;
  final bool isSelected;
  final double quantity;
  final bool showQtyControls;
  final int maxQtyPerModifier;
  final double tileWidth;
  final Color accentColor;
  final VoidCallback onTap;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  const _KioskOptionTile({
    required this.name,
    required this.price,
    required this.isFree,
    required this.isSelected,
    required this.tileWidth,
    required this.accentColor,
    required this.onTap,
    this.quantity = 1.0,
    this.showQtyControls = false,
    this.maxQtyPerModifier = 0,
    this.onIncrement,
    this.onDecrement,
  });

  static const double _circleSize = 20.0;

  @override
  Widget build(BuildContext context) {
    final bool canDecrement = isSelected && quantity >= 1;
    final bool canIncrement = maxQtyPerModifier <= 0 || quantity < maxQtyPerModifier;

    return Container(
      width: 22.w,
      height: 12.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          if (showQtyControls && isSelected) ...[
            _ZoneIndicator(
                side: Alignment.centerLeft,
                icon: Icons.remove,
                isActive: canDecrement,
                tileWidth: tileWidth,
                accentColor: accentColor),
            _ZoneIndicator(
                side: Alignment.centerRight,
                icon: Icons.add,
                isActive: canIncrement,
                tileWidth: tileWidth,
                accentColor: accentColor),
          ],
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 1.h),
              Center(
                child: Container(
                  width: _circleSize,
                  height: _circleSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? accentColor : Colors.white,
                    border: Border.all(
                      color: isSelected ? accentColor : Colors.grey.shade400,
                      width: isSelected ? 0 : 1.5,
                    ),
                  ),
                  child: isSelected ? const Icon(Icons.check, size: 18, color: Colors.white) : null,
                ),
              ),
              SizedBox(height: .5.h),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  showQtyControls && isSelected ? '$name (${quantity.toInt()})' : name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
              Spacer(),
              _PriceBadge(isFree: isFree, price: price, accentColor: accentColor),
            ],
          ),

          // Interaction Layer
          Positioned.fill(
            child: showQtyControls && isSelected
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: onDecrement,
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: onTap,
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: onIncrement,
                        ),
                      ),
                    ],
                  )
                : GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onTap,
                  ),
          ),
        ],
      ),
    );
  }
}

class _ZoneIndicator extends StatelessWidget {
  final AlignmentGeometry side;
  final IconData icon;
  final bool isActive;
  final double tileWidth;
  final Color accentColor;

  const _ZoneIndicator({
    required this.side,
    required this.icon,
    required this.isActive,
    required this.tileWidth,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final isLeft = side == Alignment.centerLeft;
    return Positioned.fill(
      child: Align(
        alignment: side,
        child: Container(
          width: tileWidth / 4,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: isLeft ? Alignment.centerLeft : Alignment.centerRight,
              end: isLeft ? Alignment.centerRight : Alignment.centerLeft,
              colors: [
                accentColor.withValues(alpha: isActive ? 0.15 : 0.04),
                Colors.transparent,
              ],
            ),
            borderRadius: isLeft
                ? const BorderRadius.horizontal(left: Radius.circular(9))
                : const BorderRadius.horizontal(right: Radius.circular(9)),
          ),
          child: Icon(
            icon,
            size: 13,
            color: accentColor.withValues(alpha: isActive ? 0.8 : 0.2),
          ),
        ),
      ),
    );
  }
}
