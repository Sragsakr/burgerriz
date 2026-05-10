import 'package:kiosk_point_of_sale/data/models/promotions/models/promotion_fb_store_model.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db_column.dart';
import 'package:sqflite/sqflite.dart';

class PromotionFBStoreTable {
  PromotionFBStoreTable._();

  static String name = 'promotion_fb_store';

  static List<DbColumn> columns = [
    DbColumn(columnName: 'tableId', columnType: 'INTEGER', isPrimary: 1),
    DbColumn(columnName: 'id', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'promotionFBId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'storeId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'isDeleted', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'deleterUserId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'deletionTime', columnType: 'TEXT', isPrimary: 0),
    DbColumn(
        columnName: 'lastModificationTime', columnType: 'TEXT', isPrimary: 0),
    DbColumn(
        columnName: 'lastModifierUserId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'creatorUserId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'creationTime', columnType: 'TEXT', isPrimary: 0),
  ];

  static Future<void> create() async {
    await AppDB.createTable(tableName: name, columns: columns);
  }

  static Future<List<PromotionFBStoreModel>> getAll() async {
    var list = await AppDB.read(table: name);
    return list.map((e) => PromotionFBStoreModel.fromJson(e)).toList();
  }

  static Future<List<PromotionFBStoreModel>> getByPromotionId(
      int promotionId) async {
    var list = await AppDB.read(
        table: name, where: 'promotionFBId = ?', whereArgs: [promotionId]);
    return list.map((e) => PromotionFBStoreModel.fromJson(e)).toList();
  }

  static Future<PromotionFBStoreModel?> getById(int? id) async {
    var list =
        await AppDB.read(table: name, where: 'tableId = ?', whereArgs: [id]);
    return list.isNotEmpty ? PromotionFBStoreModel.fromJson(list.first) : null;
  }

  static Future<int> insert(PromotionFBStoreModel model) async {
    return await AppDB.insert(
      table: name,
      values: model.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> insertAll(List<PromotionFBStoreModel> models) async {
    if (models.isEmpty) return;

    final batch = AppDB.getBatch();

    for (final model in models) {
      batch.insert(
        name,
        model.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  static Future<int> update(PromotionFBStoreModel model) async {
    return await AppDB.update(
      table: name,
      values: model.toJson(),
      where: 'tableId = ?',
      whereArgs: [model.tableId],
    );
  }

  static Future<int> delete(int? id) async {
    return await AppDB.delete(
      table: name,
      where: 'tableId = ?',
      whereArgs: [id],
    );
  }

  static Future<int> deleteByPromotionId(int promotionId) async {
    return await AppDB.delete(
      table: name,
      where: 'promotionFBId = ?',
      whereArgs: [promotionId],
    );
  }

  static Future<PromotionFBStoreModel?> getByTableId(int? tableId) async {
    if (tableId == null) return null;

    final list = await AppDB.read(
      table: name,
      where: 'tableId = ?',
      whereArgs: [tableId],
    );

    return list.isNotEmpty ? PromotionFBStoreModel.fromJson(list.first) : null;
  }

  static Future<List<PromotionFBStoreModel>> getByStoreId(int storeId) async {
    final list = await AppDB.read(
      table: name,
      where: 'storeId = ?',
      whereArgs: [storeId],
    );

    return list.map((e) => PromotionFBStoreModel.fromJson(e)).toList();
  }

  static Future<void> clear() async {
    await AppDB.delete(table: name);
  }
}
