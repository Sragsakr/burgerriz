import 'package:kiosk_point_of_sale/data/models/Synchronization/price_list_translation_entity.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db_column.dart';
import 'package:sqflite/sqflite.dart';

class PriceListTranslationTable {
  PriceListTranslationTable._();

  static String name = 'price_list_translation';

  static List<DbColumn> columns = [
    DbColumn(columnName: 'tableId', columnType: 'INTEGER', isPrimary: 1),
    DbColumn(columnName: 'priceListId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'name', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'languageId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'isDeleted', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'deleterUserId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'deletionTime', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'lastModificationTime', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'lastModifierUserId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'creationTime', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'creatorUserId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'id', columnType: 'INTEGER', isPrimary: 0),
  ];

  static Future<void> create() async {
    await AppDB.createTable(tableName: name, columns: columns);
  }

  static Future<List<PriceListTranslationEntity>> getAll() async {
    final list = await AppDB.read(table: name);
    return list.map((e) => PriceListTranslationEntity.fromJson(e)).toList();
  }

  static Future<PriceListTranslationEntity?> getById(int? id) async {
    var list = await AppDB.read(
      table: name,
      where: 'tableId = ?',
      whereArgs: [id],
    );
    if (list.isEmpty) return null;
    return PriceListTranslationEntity.fromJson(list.first);
  }

  static Future<PriceListTranslationEntity?> getByEntityId(int? id) async {
    var list = await AppDB.read(
      table: name,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (list.isEmpty) return null;
    return PriceListTranslationEntity.fromJson(list.first);
  }

  static Future<List<PriceListTranslationEntity>> getByPriceListId(
      int priceListId) async {
    var list = await AppDB.read(
      table: name,
      where: 'priceListId = ?',
      whereArgs: [priceListId],
    );
    return list.map((e) => PriceListTranslationEntity.fromJson(e)).toList();
  }

  static Future<List<PriceListTranslationEntity>> getByLanguageId(
      int languageId) async {
    var list = await AppDB.read(
      table: name,
      where: 'languageId = ?',
      whereArgs: [languageId],
    );
    return list.map((e) => PriceListTranslationEntity.fromJson(e)).toList();
  }

  static Future<int> insert(PriceListTranslationEntity entity) async {
    return await AppDB.insert(
      table: name,
      values: entity.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<int> update({
    required PriceListTranslationEntity entity,
    required int id,
  }) async {
    return await AppDB.update(
      table: name,
      values: entity.toJson(),
      where: 'tableId = ?',
      whereArgs: [id],
    );
  }

  static Future<void> insertOrUpdate(PriceListTranslationEntity entity) async {
    var existing = await getByEntityId(entity.id);
    if (existing == null) {
      await insert(entity);
    } else {
      await update(entity: entity, id: existing.tableId!);
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
