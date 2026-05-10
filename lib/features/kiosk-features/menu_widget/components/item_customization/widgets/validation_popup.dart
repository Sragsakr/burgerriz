import 'package:flutter/material.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_dialogs.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/menu_widget/components/item_customization/models/variant_group_data.dart';

Future<void> showMaxSelectionsExceededPopup({
  required BuildContext context,
  required VariantGroupData group,
  required double currentTotal,
}) async {
  await showAppDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _ValidationDialog(
      title: 'Max Selections Reached',
      icon: Icons.block,
      message:
          '"${group.nameEn}" allows a maximum of ${group.maxSelections} selection(s).',
      detail: 'Currently selected: ${currentTotal.toInt()}',
    ),
  );
}

Future<void> showMaxQtyPerModifierExceededPopup({
  required BuildContext context,
  required VariantGroupData group,
  required int maxQty,
}) async {
  await showAppDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _ValidationDialog(
      title: 'Max Quantity Reached',
      icon: Icons.exposure_minus_1,
      message:
          'You can only select up to $maxQty of each option in "${group.nameEn}".',
      detail: '',
    ),
  );
}

Future<void> showSelectAllExceededPopup({
  required BuildContext context,
  required VariantGroupData group,
  required int wouldSelect,
  required int maxAllowed,
}) async {
  await showAppDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (_) => _ValidationDialog(
      title: 'Cannot Select All',
      icon: Icons.select_all,
      message:
          '"${group.nameEn}" allows at most $maxAllowed selection(s), but selecting all would add $wouldSelect.',
      detail: 'Please deselect some options first.',
    ),
  );
}

class _ValidationDialog extends StatelessWidget {
  final String title;
  final IconData icon;
  final String message;
  final String detail;

  const _ValidationDialog({
    required this.title,
    required this.icon,
    required this.message,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 12,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFAF2A26).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon,
                        color: const Color(0xFFAF2A26), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => Navigator.of(context).pop(),
                    splashRadius: 16,
                  ),
                ],
              ),
              const Divider(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFAF2A26).withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: const Color(0xFFAF2A26).withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(message,
                        style: const TextStyle(fontSize: 13)),
                    if (detail.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        detail,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFAF2A26),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFAF2A26),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
