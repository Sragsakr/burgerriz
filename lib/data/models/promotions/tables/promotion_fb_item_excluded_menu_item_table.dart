import 'package:kiosk_point_of_sale/data/models/promotions/models/promotion_fb_item_excluded_menu_item_model.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db_column.dart';

class PromotionFBItemExcludedMenuItemTable {
  PromotionFBItemExcludedMenuItemTable._();

  static String name = 'promotion_fb_item_excluded_menu_item';

  static List<DbColumn> columns = [
    DbColumn(columnName: 'tableId', columnType: 'INTEGER', isPrimary: 1),
    DbColumn(columnName: 'id', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'tenantId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'menuItemId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(
        columnName: 'promotionFBItemId', columnType: 'INTEGER', isPrimary: 0),
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

  static Future<List<PromotionFBItemExcludedMenuItemModel>> getAll() async {
    var list = await AppDB.read(table: name);
    return list
        .map((e) => PromotionFBItemExcludedMenuItemModel.fromMap(e))
        .toList();
  }

  static Future<PromotionFBItemExcludedMenuItemModel?> getById(int? id) async {
    var list =
        await AppDB.read(table: name, where: 'tableId = ?', whereArgs: [id]);
    return list.isNotEmpty
        ? PromotionFBItemExcludedMenuItemModel.fromMap(list.first)
        : null;
  }

  static Future<int> insert(PromotionFBItemExcludedMenuItemModel model) async {
    return await AppDB.insert(table: name, values: model.toMap());
  }

  static Future<int> update(
      {required PromotionFBItemExcludedMenuItemModel model,
      required int id}) async {
    return await AppDB.update(
      table: name,
      values: model.toMap(),
      where: 'tableId = ?',
      whereArgs: [id],
    );
  }

  static Future<void> insertAndUpdateIfExist(
      PromotionFBItemExcludedMenuItemModel model) async {
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
