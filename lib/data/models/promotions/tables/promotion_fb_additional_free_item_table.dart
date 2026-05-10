import 'package:kiosk_point_of_sale/data/models/promotions/models/promotion_fb_additional_free_item_model.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db_column.dart';

class PromotionFBAdditionalFreeItemTable {
  PromotionFBAdditionalFreeItemTable._();

  static String name = 'promotion_fb_additional_free_item';

  static List<DbColumn> columns = [
    DbColumn(columnName: 'tableId', columnType: 'INTEGER', isPrimary: 1),
    DbColumn(columnName: 'id', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'itemId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'itemType', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'quantity', columnType: 'REAL', isPrimary: 0),
    DbColumn(columnName: 'price', columnType: 'REAL', isPrimary: 0),
    DbColumn(columnName: 'promotionId', columnType: 'INTEGER', isPrimary: 0),
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

  static Future<List<PromotionFBAdditionalFreeItemModel>> getAll() async {
    var list = await AppDB.read(table: name);
    return list
        .map((e) => PromotionFBAdditionalFreeItemModel.fromJson(e))
        .toList();
  }

  static Future<PromotionFBAdditionalFreeItemModel?> getById(int? id) async {
    var list =
        await AppDB.read(table: name, where: 'tableId = ?', whereArgs: [id]);
    return list.isNotEmpty
        ? PromotionFBAdditionalFreeItemModel.fromJson(list.first)
        : null;
  }

  static Future<List<PromotionFBAdditionalFreeItemModel>> getByPromotionId(
      int promotionId) async {
    var list = await AppDB.read(
        table: name,
        where: 'promotionId = ? AND isDeleted = 0',
        whereArgs: [promotionId]);
    return list
        .map((e) => PromotionFBAdditionalFreeItemModel.fromJson(e))
        .toList();
  }

  static Future<int> insert(PromotionFBAdditionalFreeItemModel model) async {
    return await AppDB.insert(table: name, values: model.toJson());
  }

  static Future<int> update(
      {required PromotionFBAdditionalFreeItemModel model,
      required int id}) async {
    return await AppDB.update(
      table: name,
      values: model.toJson(),
      where: 'tableId = ?',
      whereArgs: [id],
    );
  }

  static Future<void> insertAndUpdateIfExist(
      PromotionFBAdditionalFreeItemModel model) async {
    var existing = await getById(model.id);
    if (existing == null) {
      await insert(model);
    } else {
      await update(model: model, id: model.id);
    }
  }

  static Future<bool> delete(int id) async {
    var res =
        await AppDB.delete(table: name, where: 'tableId = ?', whereArgs: [id]);
    return res != 0;
  }

  static Future<bool> deleteTable() async {
    var res = await AppDB.delete(table: name);
    return res != 0;
  }
}
