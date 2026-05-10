import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/tables/combo_meal_definitions_table.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/tables/combo_meal_package_item_price_lists_table.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/tables/combo_meal_package_items_table.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/tables/combo_meal_package_translations_table.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/tables/combo_meal_packages_table.dart';
import 'package:kiosk_point_of_sale/data/models/combo_meal/combo_meal_model.dart';
import 'package:kiosk_point_of_sale/data/models/combo_meal/combo_meal_package_item_model.dart';
import 'package:kiosk_point_of_sale/data/models/combo_meal/combo_meal_package_model.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/tables/menu_item_fb_table.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/tables/menu_item_tax_table.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/tables/menu_item_translation_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db.dart';

class ComboMealRepository {
  /// Check if a menu item is a combo meal
  Future<bool> isComboMeal(int menuItemId) async {
    return await ComboMealDefinitionsTable.isMenuItemComboMeal(menuItemId);
  }

  /// Get complete combo meal details for a menu item
  Future<ComboMeal?> getComboMealDetails(
    int menuItemId,
    int priceListId, {
    int languageId = 1, // 1 = English, 2 = Arabic
  }) async {
    try {
      // Check if this menu item has combo meal definitions
      final definitions =
          await ComboMealDefinitionsTable.getByMenuItemId(menuItemId);

      if (definitions.isEmpty) {
        dPrint('No combo meal definitions found for menuItemId: $menuItemId');
        return null;
      }

      // Get parent menu item details
      final parentMenuItemData = await _getMenuItemDetails(menuItemId);
      if (parentMenuItemData == null) {
        dPrint('Parent menu item not found for menuItemId: $menuItemId');
        return null;
      }

      // Get parent price from price list
      final parentPrice =
          await _getParentMenuItemPrice(menuItemId, priceListId);

      // Build packages list
      List<ComboMealPackage> packages = [];

      for (var definition in definitions) {
        final package = await _getComboMealPackage(
          definition.comboMealPackageId,
          definition.order,
          languageId,
          priceListId,
        );

        if (package != null) {
          packages.add(package);
        }
      }

      // Sort packages by order
      packages.sort((a, b) => a.order.compareTo(b.order));

      return ComboMeal(
        menuItemId: menuItemId,
        name: parentMenuItemData['productNameEn'] ?? '',
        nameAr: parentMenuItemData['productNameAr'] ?? '',
        imageId: parentMenuItemData['imageUrl'] ?? 'noImageId',
        parentPrice: parentPrice,
        packages: packages,
      );
    } catch (e) {
      dPrint('Error getting combo meal details: $e');
      return null;
    }
  }

  /// Get a specific combo meal package with its items
  Future<ComboMealPackage?> _getComboMealPackage(
    int packageId,
    int order,
    int languageId,
    int priceListId,
  ) async {
    try {
      // Get package details
      final packageEntity =
          await ComboMealPackagesTable.getByEntityId(packageId);
      if (packageEntity == null) {
        dPrint('Package not found for packageId: $packageId');
        return null;
      }

      // Get translations for current language
      final translation =
          await ComboMealPackageTranslationsTable.getByPackageIdAndLanguage(
        packageId,
        languageId,
      );

      // Get translation for other language as fallback
      final otherLanguageId = languageId == 1 ? 2 : 1;
      final otherTranslation =
          await ComboMealPackageTranslationsTable.getByPackageIdAndLanguage(
        packageId,
        otherLanguageId,
      );

      final name =
          translation?.name ?? otherTranslation?.name ?? packageEntity.code;
      final nameAr =
          otherTranslation?.name ?? translation?.name ?? packageEntity.code;

      // Get package items
      final items = await _getPackageItems(packageId, languageId, priceListId);

      return ComboMealPackage(
        id: packageId,
        name: languageId == 1 ? name : nameAr,
        nameAr: languageId == 1 ? nameAr : name,
        code: packageEntity.code,
        quantity: packageEntity.quantity.toInt(),
        items: items,
        order: order,
      );
    } catch (e) {
      dPrint('Error getting combo meal package: $e');
      return null;
    }
  }

  /// Get all items in a package with their prices
  Future<List<ComboMealPackageItem>> _getPackageItems(
    int packageId,
    int languageId,
    int priceListId,
  ) async {
    try {
      final packageItemEntities =
          await ComboMealPackageItemsTable.getByPackageId(packageId);

      List<ComboMealPackageItem> items = [];

      for (var itemEntity in packageItemEntities) {
        // Get menu item details for name and image
        final menuItemData = await _getMenuItemDetails(itemEntity.menuItemId);

        if (menuItemData == null) continue;

        // Get price from price list
        final priceEntity =
            await ComboMealPackageItemPriceListsTable.getByItemIdAndPriceList(
          itemEntity.id,
          priceListId,
        );
        dPrint("priceEntity: ${priceEntity?.toJson()}");
        // Get tax info from menu item
        final taxValue =
            double.tryParse((menuItemData['taxValue']) ?? "0.0") ?? 0.15;
        final isVAT =
            menuItemData['isExclusive'] == 0; // inclusive = VAT included

        items.add(ComboMealPackageItem(
          id: itemEntity.id,
          menuItemId: itemEntity.menuItemId,
          name: menuItemData['productNameEn'] ?? '',
          nameAr: menuItemData['productNameAr'] ?? '',
          imageId: menuItemData['imageUrl'] ?? 'noImageId',
          maxQuantity: itemEntity.quantity.toInt(),
          price: priceEntity?.price ?? 0.0,
          taxValue: taxValue,
          isVAT: isVAT,
        ));
      }

      return items;
    } catch (e, t) {
      dPrint('Error getting package items: $e $t');
      return [];
    }
  }

  /// Get menu item details from sync tables
  Future<Map<String, dynamic>?> _getMenuItemDetails(int menuItemId) async {
    try {
      final items = await AppDB.read(
        table: MenuItemFBTable.name,
        where: 'id = ?',
        whereArgs: [menuItemId],
        limit: 1,
      );

      if (items.isEmpty) return null;
      final item = items.first;

      final translations =
          await MenuItemTranslationTable.getByMenuItemId(menuItemId);
      final enTranslation =
          translations.where((t) => t.languageId == 1).firstOrNull;
      final arTranslation =
          translations.where((t) => t.languageId == 2).firstOrNull;

      final taxEntries =
          await MenuItemTaxTable.getByMenuItemId(menuItemId);

      return {
        'productNameEn': enTranslation?.name ?? '',
        'productNameAr': arTranslation?.name ?? '',
        'imageUrl': item['imageId']?.toString() ?? '',
        'taxValue': taxEntries.isNotEmpty ? '0.15' : '0.0',
        'isExclusive': 0,
      };
    } catch (e) {
      dPrint('Error getting menu item details: $e');
      return null;
    }
  }

  /// Get parent menu item price from MenuItemPriceLists
  Future<double> _getParentMenuItemPrice(
      int menuItemId, int priceListId) async {
    try {
      // Try to get price from unit measures table (which stores prices per price list)
      final list = await AppDB.read(
        table: 'unit_of_measures',
        where: 'productId = ? AND saleTypeId IS NOT NULL',
        whereArgs: [menuItemId.toString()],
        limit: 1,
      );

      if (list.isNotEmpty) {
        return (list.first['price'] as num?)?.toDouble() ?? 0.0;
      }

      return 0.0;
    } catch (e) {
      dPrint('Error getting parent menu item price: $e');
      return 0.0;
    }
  }

  /// Get all combo meal menu item IDs
  Future<List<int>> getAllComboMealMenuItemIds() async {
    try {
      final definitions = await ComboMealDefinitionsTable.getAll();
      final menuItemIds = definitions
          .where((d) => !d.isDeleted)
          .map((d) => d.menuItemId)
          .toSet()
          .toList();
      return menuItemIds;
    } catch (e) {
      dPrint('Error getting combo meal menu item IDs: $e');
      return [];
    }
  }
}
