import 'package:kiosk_point_of_sale/data/models/sale_types/sale_type_price_list_model.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db_column.dart';

class SaleTypePriceListTable {
  SaleTypePriceListTable._();

  static String name = 'sale_type_price_list';

  static List<DbColumn> columns = [
    DbColumn(columnName: 'tableId', columnType: 'INTEGER', isPrimary: 1),
    DbColumn(columnName: 'id', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'saleTypeId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'priceListId', columnType: 'INTEGER', isPrimary: 0),
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

  static Future<List<SaleTypePriceListModel>> getAll() async {
    var list = await AppDB.read(table: name);
    return list.map((e) => SaleTypePriceListModel.fromMap(e)).toList();
  }

  static Future<SaleTypePriceListModel?> getById(int? id) async {
    var list =
        await AppDB.read(table: name, where: 'tableId = ?', whereArgs: [id]);
    return list.isNotEmpty ? SaleTypePriceListModel.fromMap(list.first) : null;
  }

  static Future<SaleTypePriceListModel?> getBySaleTypeId(int? id) async {
    var list =
        await AppDB.read(table: name, where: 'saleTypeId = ?', whereArgs: [id]);
    return list.isNotEmpty ? SaleTypePriceListModel.fromMap(list.first) : null;
  }

  static Future<int> insert(SaleTypePriceListModel priceList) async {
    return await AppDB.insert(table: name, values: priceList.toMap());
  }

  static Future<int> update(
      {required SaleTypePriceListModel priceList, required int id}) async {
    return await AppDB.update(
        table: name,
        values: priceList.toMap(),
        where: 'tableId = ?',
        whereArgs: [id]);
  }

  static Future<void> insertAndUpdateIfExist(
      SaleTypePriceListModel priceList) async {
    var existingItem = await getById(priceList.id);
    if (existingItem == null) {
      await insert(priceList);
    } else {
      await update(priceList: priceList, id: priceList.id);
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
