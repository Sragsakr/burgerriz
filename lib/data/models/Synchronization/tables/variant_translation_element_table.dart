import 'package:kiosk_point_of_sale/data/models/Synchronization/variant_translation_element_entity.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db_column.dart';
import 'package:sqflite/sqflite.dart';

class VariantTranslationElementTable {
  VariantTranslationElementTable._();

  static String name = 'variant_translation_element';

  static List<DbColumn> columns = [
    DbColumn(columnName: 'tableId', columnType: 'INTEGER', isPrimary: 1),
    DbColumn(columnName: 'variantId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'name', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'languageId', columnType: 'INTEGER', isPrimary: 0),
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

  static Future<List<VariantTranslationElementEntity>> getAll() async {
    final list = await AppDB.read(table: name);
    return list
        .map((e) => VariantTranslationElementEntity.fromJson(e))
        .toList();
  }

  static Future<VariantTranslationElementEntity?> getById(int? id) async {
    var list = await AppDB.read(
      table: name,
      where: 'tableId = ?',
      whereArgs: [id],
    );

    if (list.isEmpty) return null;
    return VariantTranslationElementEntity.fromJson(list.first);
  }

  static Future<VariantTranslationElementEntity?> getByEntityId(int? id) async {
    var list = await AppDB.read(
      table: name,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (list.isEmpty) return null;
    return VariantTranslationElementEntity.fromJson(list.first);
  }

  static Future<List<VariantTranslationElementEntity>> getByVariantId(
      int variantId) async {
    var list = await AppDB.read(
      table: name,
      where: 'variantId = ?',
      whereArgs: [variantId],
    );

    return list
        .map((e) => VariantTranslationElementEntity.fromJson(e))
        .toList();
  }

  static Future<List<VariantTranslationElementEntity>> getByLanguageId(
      int languageId) async {
    var list = await AppDB.read(
      table: name,
      where: 'languageId = ?',
      whereArgs: [languageId],
    );

    return list
        .map((e) => VariantTranslationElementEntity.fromJson(e))
        .toList();
  }

  static Future<int> insert(VariantTranslationElementEntity entity) async {
    final values = entity.toJson();
    final tableId = await AppDB.insert(
      table: name,
      values: values,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return tableId;
  }

  static Future<int> update({
    required VariantTranslationElementEntity entity,
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
      VariantTranslationElementEntity entity) async {
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
