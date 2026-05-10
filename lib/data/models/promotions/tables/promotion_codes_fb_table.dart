import 'package:kiosk_point_of_sale/data/models/promotions/models/promotion_codes_fb_model.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db_column.dart';

class PromotionCodesFBTable {
  PromotionCodesFBTable._();

  static String name = 'promotion_codes_fb';

  static List<DbColumn> columns = [
    DbColumn(columnName: 'tableId', columnType: 'INTEGER', isPrimary: 1),
    DbColumn(columnName: 'id', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'code', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'tenantId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'fromDate', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'toDate', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'isTiming', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(
        columnName: 'iDuplicateQunatity', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'fromTime', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'toTime', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'multi', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'isActive', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'promotionFBId', columnType: 'INTEGER', isPrimary: 0),
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

  static Future<List<PromotionCodesFBModel>> getAll() async {
    var list = await AppDB.read(table: name);
    return list.map((e) => PromotionCodesFBModel.fromJson(e)).toList();
  }

  static Future<PromotionCodesFBModel?> getById(int? id) async {
    var list =
        await AppDB.read(table: name, where: 'tableId = ?', whereArgs: [id]);
    return list.isNotEmpty ? PromotionCodesFBModel.fromJson(list.first) : null;
  }

  static Future<int> insert(PromotionCodesFBModel model) async {
    return await AppDB.insert(table: name, values: model.toJson());
  }

  static Future<int> update(
      {required PromotionCodesFBModel model, required int id}) async {
    return await AppDB.update(
      table: name,
      values: model.toJson(),
      where: 'tableId = ?',
      whereArgs: [id],
    );
  }

  static Future<void> insertAndUpdateIfExist(
      PromotionCodesFBModel model) async {
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
