import 'package:kiosk_point_of_sale/data/models/promotions/models/promotions_details_fB_model.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db_column.dart';

class PromotionDetailsFBTable {
  PromotionDetailsFBTable._();

  static String name = 'promotion_details_fb';

  static List<DbColumn> columns = [
    DbColumn(columnName: 'tableId', columnType: 'INTEGER', isPrimary: 1),
    DbColumn(columnName: 'id', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'tenantId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'itemId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'itemType', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'Where', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'quantity', columnType: 'REAL', isPrimary: 0),
    DbColumn(columnName: 'promotionId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'isDeleted', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'deleterUserId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'deletionTime', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'lastModificationTime', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'lastModifierUserId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'creatorUserId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'creationTime', columnType: 'TEXT', isPrimary: 0),
  ];

  static Future<void> create() async {
    await AppDB.createTable(tableName: name, columns: columns);
  }

  static Future<List<PromotionDetailsFBModel>> getAll() async {
    var list = await AppDB.read(table: name);
    return list.map((e) => PromotionDetailsFBModel.fromJson(e)).toList();
  }

  static Future<PromotionDetailsFBModel?> getById(int? id) async {
    var list = await AppDB.read(table: name, where: 'tableId = ?', whereArgs: [id]);
    return list.isNotEmpty ? PromotionDetailsFBModel.fromJson(list.first) : null;
  }

  static Future<PromotionDetailsFBModel?> getByPromotionId(int? id) async {
    var list = await AppDB.read(table: name, where: 'promotionId = ?', whereArgs: [id]);
    return list.isNotEmpty ? PromotionDetailsFBModel.fromJson(list.first) : null;
  }

  static Future<int> insert(PromotionDetailsFBModel model) async {
    return await AppDB.insert(table: name, values: model.toJson());
  }

  static Future<int> update({required PromotionDetailsFBModel model, required int id}) async {
    return await AppDB.update(
      table: name,
      values: model.toJson(),
      where: 'tableId = ?',
      whereArgs: [id],
    );
  }

  static Future<void> insertAndUpdateIfExist(PromotionDetailsFBModel model) async {
    var existing = await getById(model.id);
    if (existing == null) {
      await insert(model);
    } else {
      await update(model: model, id: model.id);
    }
  }

  static Future<bool> delete(int id) async {
    var res = await AppDB.delete(table: name, where: 'tableId = ?', whereArgs: [id]);
    return res != 0;
  }

  static Future<bool> deleteTable() async {
    var res = await AppDB.delete(table: name);
    return res != 0;
  }
}
