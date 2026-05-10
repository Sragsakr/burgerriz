import 'package:kiosk_point_of_sale/data/models/sale_types/sale_type_model.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db_column.dart';

class SaleTypeTable {
  SaleTypeTable._();

  static String name = 'sale_type';

  static List<DbColumn> columns = [
    DbColumn(columnName: 'tableId', columnType: 'INTEGER', isPrimary: 1),
    DbColumn(columnName: 'id', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'saleNatural', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'hasRoles', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'tenantId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'isB2B', columnType: 'INTEGER', isPrimary: 0),
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

  // Method to get all sales items
  static Future<List<SaleTypeModel>> getAll() async {
    List<SaleTypeModel> salesItems = [];
    var list = await AppDB.read(table: name);
    for (var e in list) {
      salesItems.add(SaleTypeModel.fromMap(e));
    }
    return salesItems;
  } // Method to get all sales items

  static Future<SaleTypeModel?> getSalesModelById(int? id) async {
    List<SaleTypeModel> salesItems = [];
    var list = await AppDB.read(
      table: name,
      where: 'tableId = ?',
      whereArgs: [id],
    );
    for (var e in list) {
      salesItems.add(SaleTypeModel.fromMap(e));
    }
    return salesItems.isEmpty ? null : salesItems.first;
  }

  // Method to insert a new sales item
  static Future<int> insert(SaleTypeModel salesItem) async {
    // dPrint('salesItem: ${salesItem.toMap()}');
    return await AppDB.insert(
      table: name,
      values: salesItem.toMap(),
    );
  }

  // Method to update an existing sales item
  static Future<int> update({
    required SaleTypeModel salesItem,
    required int id,
  }) async {
    return await AppDB.update(
      table: name,
      values: salesItem.toMap(),
      where: 'tableId = ?',
      whereArgs: [id],
    );
  }

  // Method to insert or update a sales item if it exists
  static Future<void> insertAndUpdateIfExist(SaleTypeModel salesItem) async {
    var existingItem = await getSalesModelById(salesItem.id);
    if (existingItem == null) {
      await insert(salesItem);
    } else {
      await update(salesItem: salesItem, id: salesItem.id);
    }
  }

  // Method to delete a sales item by ID
  static Future<bool> delete(int id) async {
    var res = await AppDB.delete(
      table: name,
      where: 'tableId = ?',
      whereArgs: [id],
    );
    return res != 0;
  }

  // Method to delete all sales items from the table
  static Future<bool> deleteTable() async {
    var res = await AppDB.delete(
      table: name,
    );
    return res != 0;
  }
}
