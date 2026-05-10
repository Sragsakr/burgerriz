import 'package:kiosk_point_of_sale/data/models/promotions/models/promotions_fB_table_model.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/tables/promotion_fb_store_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db_column.dart';
import 'package:sqflite/sqflite.dart';

class PromotionsFBTable {
  PromotionsFBTable._();

  static String name = 'promotions_fb';

  static List<DbColumn> columns = [
    DbColumn(columnName: 'tableId', columnType: 'INTEGER', isPrimary: 1),
    DbColumn(columnName: 'id', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'tenantId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'promotionType', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'templateType', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'name', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'highestValue', columnType: 'REAL', isPrimary: 0),
    DbColumn(columnName: 'lowestValue', columnType: 'REAL', isPrimary: 0),
    DbColumn(columnName: 'value', columnType: 'REAL', isPrimary: 0),
    DbColumn(columnName: 'valueType', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'isTotalInvoice', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'isNextInvoice', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'invoiceAmount', columnType: 'REAL', isPrimary: 0),
    DbColumn(columnName: 'validForDays', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'isShowInPlugIn', columnType: 'INTEGER', isPrimary: 0),
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

  static Future<List<PromotionsFBTableModel>> getAll(
      {bool loadStores = false}) async {
    final list = await AppDB.read(table: name);
    final promotions =
        list.map((e) => PromotionsFBTableModel.fromJson(e)).toList();

    if (loadStores) {
      for (final promo in promotions) {
        promo.promotionFBStores =
            await PromotionFBStoreTable.getByPromotionId(promo.id);
      }
    }

    return promotions;
  }

  static Future<PromotionsFBTableModel?> getById(int? id,
      {bool loadStores = false}) async {
    var list = await AppDB.read(
      table: name,
      where: 'tableId = ?',
      whereArgs: [id],
    );

    if (list.isEmpty) return null;

    final promo = PromotionsFBTableModel.fromJson(list.first);

    if (loadStores) {
      promo.promotionFBStores =
          await PromotionFBStoreTable.getByPromotionId(promo.id);
    }

    return promo;
  }

  static Future<PromotionsFBTableModel?> getByPromotionId(int? id,
      {bool loadStores = false}) async {
    var list = await AppDB.read(
      table: name,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (list.isEmpty) return null;

    final promo = PromotionsFBTableModel.fromJson(list.first);

    if (loadStores) {
      promo.promotionFBStores =
          await PromotionFBStoreTable.getByPromotionId(promo.id);
    }

    return promo;
  }

  static Future<int> insert(PromotionsFBTableModel promo) async {
    final values = promo.toJson()..remove('promotionFBStores');
    final tableId = await AppDB.insert(
      table: name,
      values: values,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    if (tableId > 0 && promo.promotionFBStores.isNotEmpty) {
      // Save the stores
      await PromotionFBStoreTable.deleteByPromotionId(promo.id);
      await PromotionFBStoreTable.insertAll(promo.promotionFBStores);
    }

    return tableId;
  }

  static Future<int> update({
    required PromotionsFBTableModel promo,
    required int id,
  }) async {
    final values = promo.toJson()..remove('promotionFBStores');
    final result = await AppDB.update(
      table: name,
      values: values,
      where: 'tableId = ?',
      whereArgs: [id],
    );

    if (result > 0 && promo.promotionFBStores.isNotEmpty) {
      // Update the stores
      await PromotionFBStoreTable.deleteByPromotionId(promo.id);
      await PromotionFBStoreTable.insertAll(promo.promotionFBStores);
    }

    return result;
  }

  static Future<void> insertAndUpdateIfExist(
      PromotionsFBTableModel promo) async {
    var existingItem = await getById(promo.id);
    if (existingItem == null) {
      await insert(promo);
    } else {
      await update(promo: promo, id: promo.id);
    }
  }

  static Future<bool> delete(int id) async {
    // First delete related stores
    await PromotionFBStoreTable.deleteByPromotionId(id);

    // Then delete the promotion
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
