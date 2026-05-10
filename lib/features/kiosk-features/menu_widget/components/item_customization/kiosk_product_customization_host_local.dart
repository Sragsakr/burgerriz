import 'package:flutter/material.dart';
import 'package:kiosk_point_of_sale/data/models/menu_item/menu_item_details.dart';
import 'package:kiosk_point_of_sale/data/models/menu_item/selected_variant.dart';
import 'package:kiosk_point_of_sale/data/models/sync_product/sync_product_model.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/menu_widget/components/item_customization/kiosk_product_customization_sheet.dart';
export 'package:kiosk_point_of_sale/features/shared-features/customization/customization_mappers.dart'
    show syncProductStubFromCartItem;

class ProductCustomizationHost extends StatelessWidget {
  const ProductCustomizationHost({
    super.key,
    required this.product,
    required this.unitOptions,
    required this.variants,
    required this.isVatExclusive,
    required this.taxRate,
    required this.themeColor,
    this.initialQuantity = 1,
    this.isEditMode = false,
    this.initialSelectedUnit,
    this.initialSelectedVariants,
  });

  final SyncProduct product;
  final List<MenuItemDetails> unitOptions;
  final List<Map<String, dynamic>> variants;
  final bool isVatExclusive;
  final double taxRate;
  final Color themeColor;
  final int initialQuantity;
  final bool isEditMode;
  final MenuItemDetails? initialSelectedUnit;
  final List<SelectedVariant>? initialSelectedVariants;

  @override
  Widget build(BuildContext context) {
    return KioskProductCustomizationSheet(
      product: product,
      unitOptions: unitOptions,
      variants: variants,
      isVatExclusive: isVatExclusive,
      taxRate: taxRate,
      themeColor: themeColor,
      initialQuantity: initialQuantity,
      isEditMode: isEditMode,
      initialSelectedUnit: initialSelectedUnit,
      initialSelectedVariants: initialSelectedVariants,
    );
  }
}
