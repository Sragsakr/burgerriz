import 'package:flutter/material.dart';
import 'package:kiosk_point_of_sale/core/extentions/app_extentions.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/responsive_helper.dart';
import 'package:kiosk_point_of_sale/data/models/menu_item/selected_variant.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/menu_widget/components/item_customization/models/variant_group_data.dart';

/// Shared kiosk-style blocks used by [KioskProductCustomizationSheet] and
/// [ItemCustomizationDialog] for visual parity.

// -----------------------------------------------------------------------------
// Nutrition tag (Cal / Min)
// -----------------------------------------------------------------------------

class KioskStyleNutritionTag extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;

  const KioskStyleNutritionTag({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade500, width: 1),
        borderRadius: BorderRadius.circular(999),
        color: Colors.white,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Price badge on option tiles
// -----------------------------------------------------------------------------

class KioskStylePriceBadge extends StatelessWidget {
  final bool isFree;
  final double price;

  const KioskStylePriceBadge({super.key, required this.isFree, required this.price});

  static const Color _orange = Color(0xFFEE8B60);

  @override
  Widget build(BuildContext context) {
    final label = isFree || price <= 0 ? 'Free' : '+${price.toStringAsFixed(2)}';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 5),
      decoration: BoxDecoration(
        color: _orange,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style:   TextStyle(
          fontSize: ResponsiveHelper.getResponsiveFontSize(context,11),
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Section header (grey bar)
// -----------------------------------------------------------------------------

class KioskStyleSectionHeader extends StatelessWidget {
  final String title;
  final bool isRequired;
  final int selectCount;
  final int selectedCount;

  const KioskStyleSectionHeader({
    super.key,
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

// -----------------------------------------------------------------------------
// Zone indicator (+/- hints on tiles)
// -----------------------------------------------------------------------------

class _KioskStyleCustomizationZoneIndicator extends StatelessWidget {
  final AlignmentGeometry side;
  final IconData icon;
  final bool isActive;
  final double tileWidth;
  final Color accentColor;

  const _KioskStyleCustomizationZoneIndicator({
    required this.side,
    required this.icon,
    required this.isActive,
    required this.tileWidth,
    this.accentColor = const Color(0xFFEE8B60),
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

// -----------------------------------------------------------------------------
// Option tile
// -----------------------------------------------------------------------------

class KioskStyleCustomizationOptionTile extends StatelessWidget {
  final String name;
  final double price;
  final bool isFree;
  final bool isSelected;
  final double quantity;
  final bool showQtyControls;
  final int maxQtyPerModifier;
  final double tileWidth;
  final VoidCallback onTap;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  const KioskStyleCustomizationOptionTile({
    super.key,
    required this.name,
    required this.price,
    required this.isFree,
    required this.isSelected,
    required this.tileWidth,
    required this.onTap,
    this.quantity = 1.0,
    this.showQtyControls = false,
    this.maxQtyPerModifier = 0,
    this.onIncrement,
    this.onDecrement,
  });

  static const double _circleSize = 20.0;
  static const Color _accentOrange = Color(0xFFEE8B60);

  @override
  Widget build(BuildContext context) {
    final bool canDecrement = isSelected && quantity >= 1;
    final bool canIncrement = maxQtyPerModifier <= 0 || quantity < maxQtyPerModifier;

    return Container(
      width: 18.w,
      height: 15.h,
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
            _KioskStyleCustomizationZoneIndicator(
              side: Alignment.centerLeft,
              icon: Icons.remove,
              isActive: canDecrement,
              tileWidth: tileWidth,
              accentColor: _accentOrange,
            ),
            _KioskStyleCustomizationZoneIndicator(
              side: Alignment.centerRight,
              icon: Icons.add,
              isActive: canIncrement,
              tileWidth: tileWidth,
              accentColor: _accentOrange,
            ),
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
                    color: isSelected ? _accentOrange : Colors.white,
                    border: Border.all(
                      color: isSelected ? _accentOrange : Colors.grey.shade400,
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
              const Spacer(),
              KioskStylePriceBadge(isFree: isFree, price: price),
            ],
          ),
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

// -----------------------------------------------------------------------------
// Group section (modifiers / variants)
// -----------------------------------------------------------------------------

class KioskStyleCustomizationGroupSection extends StatelessWidget {
  final VariantGroupData group;
  final List<SelectedVariant> selections;
  final String? errorMessage;
  final void Function(VariantValueOption option) onToggleVariant;
  final void Function(int variantValueId, double qty) onUpdateQuantity;

  const KioskStyleCustomizationGroupSection({
    super.key,
    required this.group,
    required this.selections,
    this.errorMessage,
    required this.onToggleVariant,
    required this.onUpdateQuantity,
  });

  bool _isSelected(int id) => selections.any((s) => s.variantValueId == id);

  double _getQty(int id) {
    final match = selections.where((s) => s.variantValueId == id);
    return match.isNotEmpty ? match.first.quantity : 1.0;
  }

  int get _selectedCount => selections.fold<double>(0, (s, v) => s + v.quantity).toInt();

  bool _isFree(VariantValueOption option) {
    switch (group.pricingRule) {
      case 3:
        return true;
      case 2:
        final freeCount = group.pricingRuleFreeItemsCount;
        if (freeCount <= 0) return false;

        final selectedIndex = selections.indexWhere(
          (s) => s.variantValueId == option.variantValueId,
        );
        if (selectedIndex < 0) return false;
        return selectedIndex < freeCount;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasError = errorMessage != null && errorMessage!.isNotEmpty;
    final groupName = translator(arText: group.nameAr, enText: group.nameEn);

    return Container(
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
            child: KioskStyleSectionHeader(
              title: groupName,
              isRequired: group.isRequired,
              selectCount: group.maxSelections > 0 ? group.maxSelections : group.minSelections,
              selectedCount: _selectedCount,
            ),
          ),
          if (hasError) ...[
            const SizedBox(height: 4),
            Text(
              errorMessage!,
              style: const TextStyle(color: Color(0xFFAF2A26), fontSize: 11),
            ),
          ],
          const SizedBox(height: 12),
          LayoutBuilder(builder: (context, constraints) {
            const spacing = 15.0;
            final tileW = (constraints.maxWidth - spacing * 3) / 4;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: List.generate(group.values.length, (i) {
                final opt = group.values[i];
                final selected = _isSelected(opt.variantValueId);
                final qty = _getQty(opt.variantValueId);
                final free = _isFree(opt);
                return KioskStyleCustomizationOptionTile(
                  name: translator(arText: opt.nameAr, enText: opt.nameEn),
                  price: opt.price,
                  isFree: free,
                  isSelected: selected,
                  quantity: qty,
                  showQtyControls: group.allowMultipleQuantitiesPerModifier,
                  maxQtyPerModifier: group.maxQtyPerModifier,
                  tileWidth: tileW,
                  onTap: () => onToggleVariant(opt),
                  onIncrement: () => onUpdateQuantity(opt.variantValueId, qty + 1),
                  onDecrement: () => onUpdateQuantity(opt.variantValueId, qty - 1),
                );
              }),
            );
          }),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Bottom bar +/- quantity
// -----------------------------------------------------------------------------

class KioskStyleQtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color themeColor;

  const KioskStyleQtyButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Icon(
          icon,
          size: 18,
          color: onTap != null ? themeColor : Colors.grey.shade400,
        ),
      ),
    );
  }
}
