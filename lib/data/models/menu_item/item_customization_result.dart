import 'package:kiosk_point_of_sale/data/models/menu_item/menu_item_details.dart';
import 'package:kiosk_point_of_sale/data/models/menu_item/selected_variant.dart';

/// The value returned by [ItemCustomizationDialog] via [Navigator.pop].
class ItemCustomizationResult {
  final MenuItemDetails? selectedUnit;
  final List<SelectedVariant> selectedVariants;
  final double totalPrice;
  final bool wasCancelled;
  final int quantity;

  const ItemCustomizationResult({
    required this.selectedUnit,
    required this.selectedVariants,
    required this.totalPrice,
    this.wasCancelled = false,
    this.quantity = 1,
  });

  /// Returned when the user closes / cancels the dialog.
  factory ItemCustomizationResult.cancelled() => const ItemCustomizationResult(
        selectedUnit: null,
        selectedVariants: [],
        totalPrice: 0,
        wasCancelled: true,
      );
}
