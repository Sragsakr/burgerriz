// ignore_for_file: constant_identifier_names
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/tables/combo_meal_definitions_table.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/tables/combo_meal_package_items_table.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/tables/combo_meal_package_item_price_lists_table.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/tables/combo_meal_packages_table.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/tables/combo_meal_package_translations_table.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/tables/menu_item_fb_table.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/tables/report_group_translation_table.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/tables/menu_item_translation_table.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/tables/menu_item_price_list_table.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/tables/menu_item_tax_table.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/tables/price_list_translation_table.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/tables/menu_item_variation_table.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/tables/variant_table_element_table.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/tables/variant_translation_element_table.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/tables/variation_value_table.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/tables/variation_value_translation_pricing_table.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/tables/variation_value_translation_table.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/tables/promotion_codes_fb_table.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/tables/promotion_details_fb_excluded_menu_item_table.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/tables/promotion_fb_additional_free_item_excluded_menu_item_table.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/tables/promotion_fb_additional_free_item_table.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/tables/promotion_fb_item_excluded_menu_item_table.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/tables/promotion_fb_item_table.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/tables/promotion_fb_store_table.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/tables/promotions_details_fB_table.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/tables/promotions_fB_table_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/coding_pattern/coding_pattern_settings_refund_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/coding_pattern/coding_pattern_settings_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/currency/currency_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/unit_of_measure/unit_of_measure_translation_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/product_category/product_category_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/product_category/product_category_translation_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/product_category/product_category_level_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/primary_category/primary_category_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/primary_category/primary_category_translation_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/secondary_category/secondary_category_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/secondary_category/secondary_category_translation_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/customer_tables/customer_service.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db_column.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/meta_data_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/device/device_info_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/device/shift_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/refund_reasons/refund_reson_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/sale_type_tables/sale__tender_type_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/sale_type_tables/sale_type_price_list_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/sale_type_tables/sale_type_store_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/sale_type_tables/sale_type_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/sale_type_tables/sale_type_translation_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/sales_tables/sales_items_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/sales_tables/sales_orders_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/sales_tables/sales_paymethods_table.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDB {
  AppDB._();

  static late Database db;
  static late String dbPath;
  static const appDBName = 'posmena_db.db';

  static Future<void> init() async {
    String databasePath = Platform.isWindows ? Directory.current.path : await getDatabasesPath();
    String path = join(databasePath, appDBName);

    db = await openDatabase(
      path,
      version: 1, // we don't depend on version
    );

    dbPath = db.path;
    try {
      await _createAllTables();
    } catch (e) {
      dPrint('Create All DB Tables Error is $e');
    }
  }

  static _createAllTables() async {
    dPrint('Create All DB Tables');
    await CurrencyTable.create();
    await DeviceConfigTable.create();
    await CashierShiftTable.create();
    await MetadataTable.create();
    await SalesOrderTable.create();
    await SalesItemsTable.create();
    await SalesPayMethodTable.create();
    await CustomerService.createTables();
    await SaleTenderTypeTable.create();
    await SaleTypeTable.create();
    await SaleTypePriceListTable.create();
    await SaleTypeTranslationTable.create();
    await SaleTypeStoresTable.create();
    await PromotionCodesFBTable.create();
    await PromotionFBItemTable.create();
    await PromotionDetailsFBTable.create();
    await PromotionsFBTable.create();
    await PromotionFBStoreTable.create();
    await PromotionDetailsFBExcludedMenuItemTable.create();
    await PromotionFBItemExcludedMenuItemTable.create();
    await PromotionFBAdditionalFreeItemTable.create();
    await PromotionFBAdditionalFreeItemExcludedMenuItemTable.create();
    await RefundResonTable.create();
    await MenuItemVariationTable.create();
    await VariantTableElementTable.create();
    await VariantTranslationElementTable.create();
    await VariationValueTable.create();
    await VariationValueTranslationTable.create();
    await VariationValueTranslationPricingTable.create();
    await CodingPatternSettingsTable.create();
    await CodingPatternSettingsRefundTable.create();
    await UnitOfMeasureTranslationTable.create();
    await ProductCategoryTable.create();
    await ProductCategoryTranslationTable.create();
    await ProductCategoryLevelTable.create();
    await PrimaryCategoryTable.create();
    await PrimaryCategoryTranslationTable.create();
    await SecondaryCategoryTable.create();
    await SecondaryCategoryTranslationTable.create();
    // Combo Meal Tables
    await ComboMealPackagesTable.create();
    await ComboMealPackageTranslationsTable.create();
    await ComboMealPackageItemsTable.create();
    await ComboMealPackageItemPriceListsTable.create();
    await ComboMealDefinitionsTable.create();
    // Menu Item Sync Tables
    await MenuItemFBTable.create();
    await ReportGroupTranslationTable.create();
    await MenuItemTranslationTable.create();
    await MenuItemPriceListTable.create();
    await MenuItemTaxTable.create();
    await PriceListTranslationTable.create();
    await _cleanupLegacyReportGroupState();
  }

  static Future<void> _cleanupLegacyReportGroupState() async {
    try {
      await db.rawUpdate('UPDATE ${MenuItemFBTable.name} SET reportGroupId = NULL');
      await db.rawDelete('DELETE FROM ${ReportGroupTranslationTable.name}');
    } catch (e) {
      dPrint('ReportGroup cleanup skipped: $e');
    }
  }

  static Future<void> executeRawQuery(String sql) async {
    await db.execute(sql);
  }

  static Future<List<Map<String, Object?>>> read({
    required String table,
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    return await db.query(table, where: where, whereArgs: whereArgs, orderBy: orderBy, limit: limit, offset: offset);
  }

  /// Insert data into a table
  static Future<int> insert({
    required String table,
    required Map<String, Object?> values,
    ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.abort,
  }) async {
    try {
      return await db.insert(
        table,
        values,
        conflictAlgorithm: conflictAlgorithm,
      );
    } catch (e) {
      print('Error inserting into $table: $e');
      return -1;
    }
  }

  static Batch getBatch() => db.batch();

  static Future<int> delete({
    required String table,
    String? where,
    List<Object?>? whereArgs,
  }) async {
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  static Future<int> update({
    required String table,
    required Map<String, Object?> values,
    String? where,
    List<Object?>? whereArgs,
  }) async {
    return await db.update(table, values, where: where, whereArgs: whereArgs);
  }

  //static Future<void> deleteAllDB() async {
  // await _db.close();
  // String databasePath = await getDatabasesPath();
  // String path = join(databasePath, AppStrings.appDBName);
  // await deleteDatabase(path);
  // await init();
  //}
  static Future<void> deleteAllDB() async {
    dPrint('Delete All DB');
    await CurrencyTable.deleteTable();
    await DeviceConfigTable.deleteTable();
    await CashierShiftTable.deleteTable();
    await MetadataTable.deleteTable();
    await SalesOrderTable.deleteTable();
    await SalesItemsTable.deleteTable();
    await SalesPayMethodTable.deleteTable();
    await CustomerService.clearAllData();
    await SaleTenderTypeTable.deleteTable();
    await SaleTypeTable.deleteTable();
    await SaleTypePriceListTable.deleteTable();
    await SaleTypeStoresTable.deleteTable();
    await SaleTypeTranslationTable.deleteTable();
    await PromotionCodesFBTable.deleteTable();
    await PromotionFBItemTable.deleteTable();
    await PromotionDetailsFBTable.deleteTable();
    await PromotionsFBTable.deleteTable();
    await PromotionDetailsFBExcludedMenuItemTable.deleteTable();
    await PromotionFBItemExcludedMenuItemTable.deleteTable();
    await PromotionFBAdditionalFreeItemTable.deleteTable();
    await PromotionFBAdditionalFreeItemExcludedMenuItemTable.deleteTable();
    await RefundResonTable.deleteTable();
    await MenuItemVariationTable.deleteTable();
    await VariantTableElementTable.deleteTable();
    await VariantTranslationElementTable.deleteTable();
    await VariationValueTable.deleteTable();
    await VariationValueTranslationTable.deleteTable();
    await VariationValueTranslationPricingTable.deleteTable();
    await CodingPatternSettingsTable.deleteTable();
    await CodingPatternSettingsRefundTable.deleteTable();
    await UnitOfMeasureTranslationTable.deleteTable();
    await ProductCategoryTable.deleteTable();
    await ProductCategoryTranslationTable.deleteTable();
    await ProductCategoryLevelTable.deleteTable();
    await PrimaryCategoryTable.deleteTable();
    await PrimaryCategoryTranslationTable.deleteTable();
    await SecondaryCategoryTable.deleteTable();
    await SecondaryCategoryTranslationTable.deleteTable();
    // Combo Meal Tables
    await ComboMealDefinitionsTable.deleteTable();
    await ComboMealPackageItemPriceListsTable.deleteTable();
    await ComboMealPackageItemsTable.deleteTable();
    await ComboMealPackageTranslationsTable.deleteTable();
    await ComboMealPackagesTable.deleteTable();
    // Menu Item Sync Tables
    await MenuItemFBTable.deleteTable();
    await MenuItemTranslationTable.deleteTable();
    await MenuItemPriceListTable.deleteTable();
    await MenuItemTaxTable.deleteTable();
    await PriceListTranslationTable.deleteTable();
  }

  static Future<void> deleteAllSaleDb() async {
    dPrint('Delete AllSale DB');
    await SalesOrderTable.deleteTable();
    await SalesItemsTable.deleteTable();
    await SalesPayMethodTable.deleteTable();
  }

  /// Run logic inside a transaction
  static Future<T> runTransaction<T>(Future<T> Function(Transaction txn) action) async {
    return await db.transaction((txn) async {
      try {
        return await action(txn);
      } catch (e) {
        print('Transaction error: $e');
        rethrow;
      }
    });
  }

  static Future<bool> isTableCreatedBefore(String tableName) async {
    var tables = await db.rawQuery('SELECT * FROM sqlite_master WHERE name="$tableName";');
    return tables.isNotEmpty;
  }

  static createTable({
    required String tableName,
    required List<DbColumn> columns,
    List<String>? compositePrimaryKeys, // للمفتاح الأساسي المركب
  }) async {
    try {
      bool isExist = await isTableCreatedBefore(tableName);
      if (!isExist) {
        // تعريف الأعمدة
        List<String> rawColumns = columns.map((e) {
          final safeColumnName = '"${e.columnName}"';
          String columnDefinition = '$safeColumnName ${e.columnType}';
          if (e.isPrimary == 1) columnDefinition += ' PRIMARY KEY';
          if (e.isUnique == 1) columnDefinition += ' UNIQUE';
          if (e.foreignKey != null) {
            columnDefinition += ' REFERENCES ${e.foreignKey}';
          }
          return columnDefinition;
        }).toList();

        // إضافة المفتاح الأساسي المركب إذا وُجد
        if (compositePrimaryKeys != null && compositePrimaryKeys.isNotEmpty) {
          rawColumns.add('PRIMARY KEY (${compositePrimaryKeys.join(', ')})');
        }

        await executeRawQuery("""
      CREATE TABLE $tableName
      (
      ${rawColumns.join(',\n')}
      )
      """);
      } else {
        // تحديث الجدول بإضافة الأعمدة الجديدة
        List<DbColumn> existedColumns =
            (await db.rawQuery('PRAGMA table_info($tableName);')).map((e) => DbColumn.fromMap(e)).toList();
        //
        List<DbColumn> newColumns = columns
            .where((e) => existedColumns.firstWhereOrNull((e2) => e2.columnName == e.columnName) == null)
            .toList();
        for (var c in newColumns) {
          await executeRawQuery("ALTER TABLE $tableName ADD COLUMN \"${c.columnName}\" ${c.columnType};");
        }
      }
    } catch (e, t) {
      dPrint(e.toString());
      dPrint(t.toString());
    }
  }

  static Future<int> getTableRowCount(String tableName) async {
    int? count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $tableName'));
    return count ?? 0;
  }

  static Future<int> getTableCountWithFilter({
    required String table,
    required String where,
    required List<Object?> whereArgs,
  }) async {
    int? count = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM $table WHERE $where',
        whereArgs,
      ),
    );
    return count ?? 0;
  }
}
