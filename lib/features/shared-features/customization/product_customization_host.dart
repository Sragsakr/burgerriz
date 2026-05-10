import 'package:flutter/material.dart';
import 'package:kiosk_point_of_sale/core/config/app_config.dart';
import 'package:kiosk_point_of_sale/core/config/app_mode_session.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_dialogs.dart';
import 'package:kiosk_point_of_sale/data/models/menu_item/menu_item_details.dart';
import 'package:kiosk_point_of_sale/data/models/menu_item/selected_variant.dart';
import 'package:kiosk_point_of_sale/data/models/sync_product/sync_product_model.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/menu_widget/components/item_customization/item_customization_dialog.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/menu_widget/components/item_customization/kiosk_product_customization_sheet.dart';
import 'package:kiosk_point_of_sale/features/mobile-features/customization/mobile_item_customization_sheet.dart';
import 'package:kiosk_point_of_sale/data/models/menu_item/item_customization_result.dart';
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

  static Future<ItemCustomizationResult?> show(
    BuildContext context, {
    required SyncProduct product,
    required List<MenuItemDetails> unitOptions,
    required List<Map<String, dynamic>> variants,
    required bool isVatExclusive,
    required double taxRate,
    required Color themeColor,
    int initialQuantity = 1,
    bool isEditMode = false,
    MenuItemDetails? initialSelectedUnit,
    List<SelectedVariant>? initialSelectedVariants,
  }) async {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final menuItemName = isEnglish ? product.nameEn : product.nameAr;

    if (AppConfig.isMobile) {
      return MobileItemCustomizationSheet.show(
        context,
        menuItemName: menuItemName,
        menuItemId: product.id,
        imageId: product.imageId,
        unitOptions: unitOptions,
        variants: variants,
        isVatExclusive: isVatExclusive,
        taxRate: taxRate,
        isEditMode: isEditMode,
        initialSelectedUnit: initialSelectedUnit,
        initialSelectedVariants: initialSelectedVariants,
        initialQuantity: initialQuantity,
        accentColor: themeColor,
        numberOfCalories: product.numberOfCalories,
        numberOfSteps: product.numberOfSteps,
      );
    } else {
      return showAppDialog<ItemCustomizationResult>(
        context: context,
        barrierDismissible: false,
        builder: (_) => ItemCustomizationDialog(
          menuItemName: menuItemName,
          menuItemId: product.id,
          imageId: product.imageId,
          unitOptions: unitOptions,
          variants: variants,
          isVatExclusive: isVatExclusive,
          taxRate: taxRate,
          isEditMode: isEditMode,
          initialSelectedUnit: initialSelectedUnit,
          initialSelectedVariants: initialSelectedVariants,
          initialQuantity: initialQuantity,
          accentColor: themeColor,
          numberOfCalories: product.numberOfCalories,
          numberOfSteps: product.numberOfSteps,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final isEnglish = Localizations.localeOf(context).languageCode == 'en';
        final menuItemName = isEnglish ? product.nameEn : product.nameAr;

        if (AppModeSession.useCustomizationWizard) {
          return ItemCustomizationDialog(
            menuItemName: menuItemName,
            menuItemId: product.id,
            imageId: product.imageId,
            unitOptions: unitOptions,
            variants: variants,
            isVatExclusive: isVatExclusive,
            taxRate: taxRate,
            isEditMode: isEditMode,
            initialSelectedUnit: initialSelectedUnit,
            initialSelectedVariants: initialSelectedVariants,
            initialQuantity: initialQuantity,
            accentColor: themeColor,
            numberOfCalories: product.numberOfCalories,
            numberOfSteps: product.numberOfSteps,
          );
        }

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
      },
    );
  }
}
