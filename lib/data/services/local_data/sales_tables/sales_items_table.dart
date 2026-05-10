import 'package:kiosk_point_of_sale/data/models/sales_models/sales_items_model.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db_column.dart';

class SalesItemsTable {
  SalesItemsTable._();

  static String name = 'sales_items';

  static List<DbColumn> columns = [
    DbColumn(columnName: 'id', columnType: 'INTEGER', isPrimary: 1),
    DbColumn(columnName: 'createdAt', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'updatedAt', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'productId', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'categoryId', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'productNameEn', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'productNameAr', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'unitOfMeasureId', columnType: 'TEXT', isPrimary: 0),
    DbColumn(
        columnName: 'unitOfMeasureNameEn', columnType: 'TEXT', isPrimary: 0),
    DbColumn(
        columnName: 'unitOfMeasureNameAr', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'quantity', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'price', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'total', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'note', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'isRefund', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'isExclusive', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'userId', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'tenantId', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'uniqueId', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'tax', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'orderId', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'promotionCode', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'promotionType', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'promotionValue', columnType: 'REAL', isPrimary: 0),
    DbColumn(columnName: 'promotionId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(
        columnName: 'promotionCodeId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'promotionAmount', columnType: 'REAL', isPrimary: 0),
    DbColumn(columnName: 'vatBeforeDiscount', columnType: 'REAL', isPrimary: 0),
    DbColumn(columnName: 'discount', columnType: 'REAL', isPrimary: 0),
    DbColumn(columnName: 'loyaltyDiscount', columnType: 'REAL', isPrimary: 0),
    DbColumn(columnName: 'additionalAllowns', columnType: 'REAL', isPrimary: 0),
    DbColumn(columnName: 'priceIncludeVAT', columnType: 'REAL', isPrimary: 0),
    DbColumn(columnName: 'promotionName', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'variations', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'comboMealItems', columnType: 'TEXT', isPrimary: 0),
    // Free product fields
    DbColumn(
        columnName: 'selectedFreeProductId', columnType: 'TEXT', isPrimary: 0),
    DbColumn(
        columnName: 'selectedFreeProductName',
        columnType: 'TEXT',
        isPrimary: 0),
    DbColumn(
        columnName: 'selectedFreeProductNameAr',
        columnType: 'TEXT',
        isPrimary: 0),
    DbColumn(columnName: 'selectedFreeUUid', columnType: 'TEXT', isPrimary: 0),
    DbColumn(
        columnName: 'selectedFreeProductQuantity',
        columnType: 'INTEGER',
        isPrimary: 0),
    DbColumn(
        columnName: 'selectedFreeProductPrice',
        columnType: 'REAL',
        isPrimary: 0),
    DbColumn(
        columnName: 'selectedFreeItemId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'isComboMeal', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(
        columnName: 'isPromotionDuplicated',
        columnType: 'INTEGER',
        isPrimary: 0),
  ];

  // Method to create the sales_items table
  static Future<void> create() async {
    await AppDB.createTable(tableName: name, columns: columns);
  }

  // Method to get all sales items
  static Future<List<SalesItemsModel>> getAll() async {
    List<SalesItemsModel> salesItems = [];
    var list = await AppDB.read(table: name);
    for (var e in list) {
      salesItems.add(SalesItemsModel.fromMap(e));
    }
    return salesItems;
  } // Method to get all sales items

  static Future<List<SalesItemsModel>> getAllRefunds() async {
    List<SalesItemsModel> salesItems = [];
    var list =
        await AppDB.read(table: name, where: 'isRefund = ?', whereArgs: [1]);
    for (var e in list) {
      salesItems.add(SalesItemsModel.fromMap(e));
    }
    return salesItems;
  }

  // Method to get a specific sales item by ID
  static Future<List<SalesItemsModel>?> getSalesItemByOrderId(
      String orderId) async {
    List<SalesItemsModel> salesItems = [];
    var list = await AppDB.read(
      table: name,
      where: 'orderId = ?',
      whereArgs: [orderId],
    );
    for (var e in list) {
      salesItems.add(SalesItemsModel.fromMap(e));
    }
    return salesItems;
  }

  static Future<SalesItemsModel?> getSalesItemById(int? id) async {
    List<SalesItemsModel> salesItems = [];
    var list = await AppDB.read(
      table: name,
      where: 'id = ?',
      whereArgs: [id],
    );
    for (var e in list) {
      salesItems.add(SalesItemsModel.fromMap(e));
    }
    return salesItems.isEmpty ? null : salesItems.first;
  }

  static Future<SalesItemsModel?> getSalesItemByUniqueId(String? uniqueId) async {
    if (uniqueId == null || uniqueId.isEmpty) return null;
    List<SalesItemsModel> salesItems = [];
    var list = await AppDB.read(
      table: name,
      where: 'uniqueId = ?',
      whereArgs: [uniqueId],
    );
    for (var e in list) {
      salesItems.add(SalesItemsModel.fromMap(e));
    }
    return salesItems.isEmpty ? null : salesItems.first;
  }

  // Method to insert a new sales item
  static Future<int> insert(SalesItemsModel salesItem) async {
    // dPrint('salesItem: ${salesItem.toMap()}');
    return await AppDB.insert(
      table: name,
      values: salesItem.toMap(),
    );
  }

  // Method to update an existing sales item
  static Future<int> update({
    required SalesItemsModel salesItem,
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
  static Future<void> insertAndUpdateIfExist(SalesItemsModel salesItem) async {
    // First try to find by uniqueId (more reliable), then fallback to id
    var existingItem = await getSalesItemByUniqueId(salesItem.uniqueId);
    existingItem ??= await getSalesItemById(salesItem.id);
    
    if (existingItem == null) {
      await insert(salesItem);
    } else {
      await update(salesItem: salesItem, id: existingItem.id!);
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
