import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/data/models/sale_types/sale_tender_type_model.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db_column.dart';

class SaleTenderTypeTable {
  SaleTenderTypeTable._();

  static String name = 'sale_tender_type';

  static List<DbColumn> columns = [
    DbColumn(columnName: 'tableId', columnType: 'INTEGER', isPrimary: 1),
    DbColumn(columnName: 'id', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'tenderTypeId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'name', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'languageId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'isDeleted', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'deleterUserId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'deletionTime', columnType: 'TEXT', isPrimary: 0),
    DbColumn(
        columnName: 'lastModificationTime', columnType: 'TEXT', isPrimary: 0),
    DbColumn(
        columnName: 'lastModifierUserId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'creationTime', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'creatorUserId', columnType: 'INTEGER', isPrimary: 0),
  ];

  static Future<void> create() async {
    await AppDB.createTable(tableName: name, columns: columns);
  }

  // Method to get all sales items
  static Future<List<SaleTenderTypeModel>> getAll() async {
    List<SaleTenderTypeModel> salesItems = [];
    var list = await AppDB.read(table: name);
    for (var e in list) {
      dPrint('salesItem: $e');
      salesItems.add(SaleTenderTypeModel.fromMap(e));
    }
    return salesItems;
  } // Method to get all sales items

  // Method to get a specific sales item by ID
  static Future<SaleTenderTypeModel?> getSalesItemByName(
      String tableName) async {
    List<SaleTenderTypeModel> salesItems = [];
    getAll();
    var list = await AppDB.read(
      table: name,
      where: 'name = ?',
      whereArgs: [tableName.toLowerCase()],
    );
    for (var e in list) {
      // dPrint('salesItem: $e');
      salesItems.add(SaleTenderTypeModel.fromMap(e));
    }
    return salesItems.first;
  }

  static Future<SaleTenderTypeModel?> getSalesItemById(int? id) async {
    List<SaleTenderTypeModel> salesItems = [];
    var list = await AppDB.read(
      table: name,
      where: 'tableId = ?',
      whereArgs: [id],
    );
    for (var e in list) {
      salesItems.add(SaleTenderTypeModel.fromMap(e));
    }
    return salesItems.isEmpty ? null : salesItems.first;
  }

  // Method to insert a new sales item
  static Future<int> insert(SaleTenderTypeModel salesItem) async {
    dPrint('TenderType: ${salesItem.toMap()}');
    final id = await AppDB.insert(
      table: name,
      values: salesItem.toMap(),
    );
    dPrint('TenderTypeId:: $id');
    dPrint(SaleTenderTypeTable.name);
    return id;
  }

  // Method to update an existing sales item
  static Future<int> update({
    required SaleTenderTypeModel salesItem,
    required int id,
  }) async {
    return await AppDB.update(
      table: name,
      values: salesItem.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Method to insert or update a sales item if it exists
  static Future<void> insertAndUpdateIfExist(
      SaleTenderTypeModel salesItem) async {
    var existingItem = await getSalesItemById(salesItem.id);
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
      where: 'id = ?',
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
