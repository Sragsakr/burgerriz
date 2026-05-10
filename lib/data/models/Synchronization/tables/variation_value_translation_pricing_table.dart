import 'package:kiosk_point_of_sale/data/models/Synchronization/variation_value_translation_pricing_entity.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db_column.dart';
import 'package:sqflite/sqflite.dart';

class VariationValueTranslationPricingTable {
  VariationValueTranslationPricingTable._();

  static String name = 'variation_value_translation_pricing';

  static List<DbColumn> columns = [
    DbColumn(columnName: 'tableId', columnType: 'INTEGER', isPrimary: 1),
    DbColumn(columnName: 'variantValueId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'priceListId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'price', columnType: 'REAL', isPrimary: 0),
    DbColumn(columnName: 'factor', columnType: 'REAL', isPrimary: 0),
    DbColumn(columnName: 'isDeleted', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'deleterUserId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'deletionTime', columnType: 'TEXT', isPrimary: 0),
    DbColumn(
        columnName: 'lastModificationTime', columnType: 'TEXT', isPrimary: 0),
    DbColumn(
        columnName: 'lastModifierUserId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'creationTime', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'creatorUserId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'id', columnType: 'INTEGER', isPrimary: 0),
  ];

  static Future<void> create() async {
    await AppDB.createTable(tableName: name, columns: columns);
  }

  static Future<List<VariationValueTranslationPricingEntity>> getAll() async {
    final list = await AppDB.read(table: name);
    return list
        .map((e) => VariationValueTranslationPricingEntity.fromJson(e))
        .toList();
  }

  static Future<VariationValueTranslationPricingEntity?> getById(
      int? id) async {
    var list = await AppDB.read(
      table: name,
      where: 'tableId = ?',
      whereArgs: [id],
    );

    if (list.isEmpty) return null;
    return VariationValueTranslationPricingEntity.fromJson(list.first);
  }

  static Future<VariationValueTranslationPricingEntity?> getByEntityId(
      int? id) async {
    var list = await AppDB.read(
      table: name,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (list.isEmpty) return null;
    return VariationValueTranslationPricingEntity.fromJson(list.first);
  }

  static Future<List<VariationValueTranslationPricingEntity>>
      getByVariantValueId(int variantValueId, int priceListId) async {
    var list = await AppDB.read(
      table: name,
      where: 'variantValueId = ? AND priceListId = ?',
      whereArgs: [variantValueId, priceListId],
    );

    return list
        .map((e) => VariationValueTranslationPricingEntity.fromJson(e))
        .toList();
  }

  static Future<List<VariationValueTranslationPricingEntity>> getByPriceListId(
      int priceListId) async {
    var list = await AppDB.read(
      table: name,
      where: 'priceListId = ?',
      whereArgs: [priceListId],
    );

    return list
        .map((e) => VariationValueTranslationPricingEntity.fromJson(e))
        .toList();
  }

  static Future<int> insert(
      VariationValueTranslationPricingEntity entity) async {
    final values = entity.toJson();
    final tableId = await AppDB.insert(
      table: name,
      values: values,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return tableId;
  }

  static Future<int> update({
    required VariationValueTranslationPricingEntity entity,
    required int id,
  }) async {
    final values = entity.toJson();
    return await AppDB.update(
      table: name,
      values: values,
      where: 'tableId = ?',
      whereArgs: [id],
    );
  }

  static Future<void> insertOrUpdate(
      VariationValueTranslationPricingEntity entity) async {
    var existingItem = await getByEntityId(entity.id);
    if (existingItem == null) {
      await insert(entity);
    } else {
      await update(entity: entity, id: existingItem.tableId!);
    }
  }

  static Future<bool> delete(int id) async {
    final res = await AppDB.delete(
      table: name,
      where: 'id = ?',
      whereArgs: [id],
    );
    return res > 0;
  }

  static Future<bool> deleteTable() async {
    var res = await AppDB.delete(table: name);
    return res != 0;
  }
}
