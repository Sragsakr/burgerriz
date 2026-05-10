import 'package:flutter/material.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/data/models/menu_item/selected_variant.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/menu_widget/components/item_customization/models/variant_group_data.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/menu_widget/components/item_customization/widgets/option_tile.dart';

/// Renders one variant/modifier group as a card.
class GroupSection extends StatelessWidget {
  final VariantGroupData group;
  final List<SelectedVariant> selections;
  final String? errorMessage;
  final int itemsPerRow;
  final void Function(VariantGroupData group, VariantValueOption option) onToggleVariant;
  final void Function(VariantGroupData group, int variantValueId, double qty)
      onUpdateQuantity;
  final VoidCallback onSelectAll;
  final VoidCallback onDeselectAll;

  const GroupSection({
    super.key,
    required this.group,
    required this.selections,
    this.errorMessage,
    required this.itemsPerRow,
    required this.onToggleVariant,
    required this.onUpdateQuantity,
    required this.onSelectAll,
    required this.onDeselectAll,
  });

  bool _isSelected(int variantValueId) =>
      selections.any((s) => s.variantValueId == variantValueId);

  double _getQuantity(int variantValueId) {
    final match = selections.where((s) => s.variantValueId == variantValueId);
    return match.isNotEmpty ? match.first.quantity : 1.0;
  }

  /// Total quantity selected across all variants in this group
  double get _totalSelectedQuantity =>
      selections.fold(0.0, (sum, s) => sum + s.quantity);

  int get _selectedCount => _totalSelectedQuantity.toInt();

  /// Number of free items available in this group
  int get _freeItemsCount {
    if (group.pricingRule == 3) return 999; // allFree - unlimited
    if (group.pricingRule == 2) {
      return group.pricingRuleFreeItemsCount <= 0 
          ? 1 
          : group.pricingRuleFreeItemsCount;
    }
    return 0;
  }

  /// Number of remaining free items (based on total quantity selected)
  int get _remainingFreeItems {
    if (group.pricingRule == 3) return 999; // allFree - always free
    if (group.pricingRule == 2) {
      final free = _freeItemsCount;
      final used = _totalSelectedQuantity.toInt();
      return (free - used).clamp(0, free);
    }
    return 0;
  }

  /// Remaining max selections (based on total quantity)
  int get _remainingMaxSelections {
    if (group.maxSelections <= 0) return 999; // unlimited
    return (group.maxSelections - _totalSelectedQuantity.toInt()).clamp(0, group.maxSelections);
  }

  /// "All Free" for rule 3, "X Free Left" showing remaining free items
  String? get _pricingRuleLabel {
    switch (group.pricingRule) {
      case 3:
        return 'All Free';
      case 2:
        final freeCount = _freeItemsCount;
        final remaining = _remainingFreeItems;
        if (_totalSelectedQuantity > 0) {
          return remaining > 0 ? '$remaining Free Left' : 'Free Used';
        }
        return freeCount == 1 ? '1 Free' : '$freeCount Free';
      default:
        return null;
    }
  }

  Widget _buildConstraintMessage() {
    final max = group.maxSelections;
    if (max <= 0) return const SizedBox.shrink();
    
    final remaining = _remainingMaxSelections;
    final text = _totalSelectedQuantity > 0
        ? '$remaining of $max left'
        : 'Max $max';
    
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, color: Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasError = errorMessage != null && errorMessage!.isNotEmpty;
    final groupName = translator(
      arText: group.nameAr,
      enText: group.nameEn,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasError ? const Color(0xFFAF2A26) : Colors.grey.shade200,
          width: hasError ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ──────────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: group name + required badge + constraint text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            groupName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        if (group.isRequired) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFAF2A26).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: const Color(0xFFAF2A26).withValues(alpha: 0.3),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 10,
                                  color: Color(0xFFAF2A26),
                                ),
                                SizedBox(width: 2),
                                Text(
                                  'Required',
                                  style: TextStyle(
                                    color: Color(0xFFAF2A26),
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    _buildConstraintMessage(),
                  ],
                ),
              ),
              // Right: "Modifier" badge (top) + pricing rule + count (below)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (group.isModifier)
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Modifier',
                          style: TextStyle(
                              fontSize: 9, color: Colors.blue.shade800),
                        ),
                      ),
                    ),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_pricingRuleLabel != null)
                          Container(
                            margin: const EdgeInsets.only(right: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade600,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _pricingRuleLabel!,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        // Red badge: shows selected / max (e.g. "3 / 8")
                        // or just maxSelections when nothing selected yet
                        if (group.maxSelections > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _selectedCount > 0
                                  ? const Color(0xFFAF2A26)
                                  : Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _selectedCount > 0
                                  ? '$_selectedCount / ${group.maxSelections}'
                                  : '${group.maxSelections}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                errorMessage!,
                style: const TextStyle(
                    color: Color(0xFFAF2A26), fontSize: 11),
              ),
            ),
          // ── Deselect All / Select All ────────────────────────────────────
          if (group.values.length > 1) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                _ActionButton(
                  label: 'Deselect All',
                  onTap: onDeselectAll,
                ),
                const SizedBox(width: 6),
                _ActionButton(
                  label: 'Select All',
                  onTap: onSelectAll,
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          _buildOptionsGrid(context),
        ],
      ),
    );
  }

  Widget _buildOptionsGrid(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final spacing = 6.0;
      final totalSpacing = spacing * (itemsPerRow - 1);
      final tileWidth =
          (constraints.maxWidth - totalSpacing) / itemsPerRow;
      const tileHeight = 64.0;

      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: group.values.map((option) {
          final selected = _isSelected(option.variantValueId);
          final qty = _getQuantity(option.variantValueId);
          return OptionTile(
            name: translator(arText: option.nameAr, enText: option.nameEn),
            price: option.price,
            isSelected: selected,
            isDefault: option.isDefault,
            quantity: qty,
            showQtyControls: group.allowMultipleQuantitiesPerModifier,
            maxQtyPerModifier: group.maxQtyPerModifier,
            tileWidth: tileWidth,
            tileHeight: tileHeight,
            onTap: () => onToggleVariant(group, option),
            onIncrement: () => onUpdateQuantity(
                group, option.variantValueId, qty + 1),
            onDecrement: () => onUpdateQuantity(
                group, option.variantValueId, qty - 1),
          );
        }).toList(),
      );
    });
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ActionButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Text(label, style: const TextStyle(fontSize: 11)),
        ),
      ),
    );
  }
}
