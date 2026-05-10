import 'package:kiosk_point_of_sale/data/models/sale_types/sale_type_store_model.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db_column.dart';

class SaleTypeStoresTable {
  SaleTypeStoresTable._();

  static String name = 'sale_type_stores';

  static List<DbColumn> columns = [
    DbColumn(columnName: 'tableId', columnType: 'INTEGER', isPrimary: 1),
    DbColumn(columnName: 'id', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'tenantId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'storeId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'saleTypeId', columnType: 'INTEGER', isPrimary: 0),
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

  static Future<List<SaleTypeStoresModel>> getAll() async {
    var list = await AppDB.read(table: name);
    return list.map((e) => SaleTypeStoresModel.fromMap(e)).toList();
  }

  static Future<SaleTypeStoresModel?> getById(int? id) async {
    var list =
        await AppDB.read(table: name, where: 'tableId = ?', whereArgs: [id]);
    return list.isNotEmpty ? SaleTypeStoresModel.fromMap(list.first) : null;
  }

  static Future<int> insert(SaleTypeStoresModel store) async {
    return await AppDB.insert(table: name, values: store.toMap());
  }

  static Future<int> update(
      {required SaleTypeStoresModel store, required int id}) async {
    return await AppDB.update(
        table: name,
        values: store.toMap(),
        where: 'tableId = ?',
        whereArgs: [id]);
  }

  static Future<void> insertAndUpdateIfExist(SaleTypeStoresModel store) async {
    var existingItem = await getById(store.id);
    if (existingItem == null) {
      await insert(store);
    } else {
      await update(store: store, id: store.id);
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
