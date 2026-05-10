import 'package:flutter/material.dart';

/// Top bar of [ItemCustomizationDialog].
/// Shows item name, current step label, step counter, mode badge,
/// grid-layout dropdowns, and a close button.
class CustomizationHeader extends StatelessWidget {
  final String menuItemName;
  final String currentStepLabel;
  final int currentStep;
  final int totalSteps;
  final bool isEditMode;
  final Color accentColor;
  final int groupsPerRow;
  final int itemsPerRow;
  final ValueChanged<int> onGroupsPerRowChanged;
  final ValueChanged<int> onItemsPerRowChanged;
  final VoidCallback onClose;

  const CustomizationHeader({
    super.key,
    required this.menuItemName,
    required this.currentStepLabel,
    required this.currentStep,
    required this.totalSteps,
    required this.isEditMode,
    this.accentColor = const Color(0xFFAF2A26),
    required this.groupsPerRow,
    required this.itemsPerRow,
    required this.onGroupsPerRowChanged,
    required this.onItemsPerRowChanged,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        children: [
          // Close button
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onClose,
            splashRadius: 20,
          ),
          // Groups & Items column dropdowns
          _buildDropdown(
            label: 'Items',
            value: itemsPerRow,
            min: 1,
            max: 6,
            onChanged: onItemsPerRowChanged,
          ),
          const SizedBox(width: 6),
          _buildDropdown(
            label: 'Groups',
            value: groupsPerRow,
            min: 1,
            max: 5,
            onChanged: onGroupsPerRowChanged,
          ),
          const Spacer(),
          // Right side: item name + step info
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                menuItemName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isEditMode
                          ? Colors.orange.shade50
                          : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isEditMode ? 'Edit' : 'Customize',
                      style: TextStyle(
                        fontSize: 11,
                        color: isEditMode
                            ? Colors.orange.shade800
                            : Colors.green.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Step $currentStep / $totalSteps',
                      style: TextStyle(
                        fontSize: 11,
                        color: accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 10, color: Colors.grey)),
        DropdownButton<int>(
          value: value,
          underline: const SizedBox(),
          isDense: true,
          items: List.generate(
            max - min + 1,
            (i) => DropdownMenuItem(
              value: min + i,
              child: Text('${min + i}',
                  style: const TextStyle(fontSize: 13)),
            ),
          ),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ],
    );
  }
}
