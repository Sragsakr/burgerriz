import 'package:flutter/material.dart';
import 'package:kiosk_point_of_sale/data/models/menu_item/selected_variant.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/menu_widget/components/item_customization/models/variant_group_data.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/menu_widget/components/item_customization/widgets/group_section.dart';

/// Lays out a list of [VariantGroupData] into a responsive Wrap.
/// Each group becomes a [GroupSection] card.
class GroupsGrid extends StatelessWidget {
  final List<VariantGroupData> groups;
  final Map<int, List<SelectedVariant>> selectedByGroup;
  final Map<int, String> validationErrors;
  final int groupsPerRow;
  final int itemsPerRow;
  final void Function(VariantGroupData, VariantValueOption) onToggleVariant;
  final void Function(VariantGroupData, int variantValueId, double qty)
      onUpdateQuantity;
  final void Function(VariantGroupData) onSelectAll;
  final void Function(VariantGroupData) onDeselectAll;

  const GroupsGrid({
    super.key,
    required this.groups,
    required this.selectedByGroup,
    required this.validationErrors,
    required this.groupsPerRow,
    required this.itemsPerRow,
    required this.onToggleVariant,
    required this.onUpdateQuantity,
    required this.onSelectAll,
    required this.onDeselectAll,
  });

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(builder: (context, constraints) {
      final spacing = 8.0;
      final totalSpacing = spacing * (groupsPerRow - 1);
      final cardWidth = (constraints.maxWidth - totalSpacing) / groupsPerRow;

      return Column(
        children: [
          Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: groups.map((group) {
              return SizedBox(
                width: cardWidth,
                child: GroupSection(
                  group: group,
                  selections: selectedByGroup[group.variantId] ?? [],
                  errorMessage: validationErrors[group.variantId],
                  itemsPerRow: itemsPerRow,
                  onToggleVariant: onToggleVariant,
                  onUpdateQuantity: onUpdateQuantity,
                  onSelectAll: () => onSelectAll(group),
                  onDeselectAll: () => onDeselectAll(group),
                ),
              );
            }).toList(),
          ),
        ],
      );
    });
  }
}
