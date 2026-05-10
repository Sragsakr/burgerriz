import 'package:kiosk_point_of_sale/data/models/Synchronization/variant_table_element_entity.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db_column.dart';
import 'package:sqflite/sqflite.dart';

class VariantTableElementTable {
  VariantTableElementTable._();

  static String name = 'variant_table_element';

  static List<DbColumn> columns = [
    DbColumn(columnName: 'tableId', columnType: 'INTEGER', isPrimary: 1),
    DbColumn(columnName: 'categoryId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'isRequired', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'minSelections', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'maxSelections', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(
        columnName: 'allowMultipleQuantitiesPerModifier',
        columnType: 'INTEGER',
        isPrimary: 0),
    DbColumn(
        columnName: 'maxQtyPerModifier', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'isAdd', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'isModifier', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'isActive', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'pricingRule', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(
        columnName: 'pricingRuleFreeItemsCount',
        columnType: 'INTEGER',
        isPrimary: 0),
    DbColumn(columnName: 'periorty', columnType: 'INTEGER', isPrimary: 0),
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

  static Future<List<VariantTableElementEntity>> getAll() async {
    final list = await AppDB.read(table: name);
    return list.map((e) => VariantTableElementEntity.fromJson(e)).toList();
  }

  static Future<VariantTableElementEntity?> getById(int? id) async {
    var list = await AppDB.read(
      table: name,
      where: 'tableId = ?',
      whereArgs: [id],
    );

    if (list.isEmpty) return null;
    return VariantTableElementEntity.fromJson(list.first);
  }

  static Future<VariantTableElementEntity?> getByEntityId(int? id) async {
    var list = await AppDB.read(
      table: name,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (list.isEmpty) return null;
    return VariantTableElementEntity.fromJson(list.first);
  }

  static Future<List<VariantTableElementEntity>> getByCategoryId(
      int categoryId) async {
    var list = await AppDB.read(
      table: name,
      where: 'categoryId = ?',
      whereArgs: [categoryId],
    );

    return list.map((e) => VariantTableElementEntity.fromJson(e)).toList();
  }

  static Future<int> insert(VariantTableElementEntity entity) async {
    final values = entity.toJson();
    final tableId = await AppDB.insert(
      table: name,
      values: values,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return tableId;
  }

  static Future<int> update({
    required VariantTableElementEntity entity,
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

  static Future<void> insertOrUpdate(VariantTableElementEntity entity) async {
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
