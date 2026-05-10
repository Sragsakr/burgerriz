import 'package:kiosk_point_of_sale/data/models/sales_models/sales_paymethod_model.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db_column.dart';

class SalesPayMethodTable {
  SalesPayMethodTable._();

  static String name = 'sales_pay_methods';

  // Adding orderId column
  static List<DbColumn> columns = [
    DbColumn(columnName: 'id', columnType: 'INTEGER', isPrimary: 1),
    DbColumn(columnName: 'nameEn', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'nameAr', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'amount', columnType: 'REAL', isPrimary: 0),
    DbColumn(columnName: 'tenderTypeId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'orderId', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'uniqueId', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'tenantId', columnType: 'TEXT', isPrimary: 0),
    // New column
  ];

  // Method to create the sales_pay_methods table
  static Future<void> create() async {
    await AppDB.createTable(tableName: name, columns: columns);
  }

  // Method to get all sales pay methods
  static Future<List<SalesPayMethodModel>> getAll() async {
    List<SalesPayMethodModel> payMethods = [];
    var list = await AppDB.read(table: name);
    for (var e in list) {
      payMethods.add(SalesPayMethodModel.fromMap(e));
    }
    return payMethods;
  } // Method to get all sales pay methods

  static Future<List<SalesPayMethodModel>> getAllRefunds() async {
    List<SalesPayMethodModel> payMethods = [];
    var list = await AppDB.read(table: name);
    for (var e in list) {
      payMethods.add(SalesPayMethodModel.fromMap(e));
    }
    return payMethods;
  }

  // Method to get a specific sales pay method by ID
  static Future<SalesPayMethodModel?> getPayMethodById(int? id) async {
    List<SalesPayMethodModel> payMethods = [];
    var list = await AppDB.read(
      table: name,
      where: 'id = ?',
      whereArgs: [id],
    );
    for (var e in list) {
      payMethods.add(SalesPayMethodModel.fromMap(e));
    }
    return payMethods.isEmpty ? null : payMethods.first;
  }

  static Future<List<SalesPayMethodModel>?> getPayMethodByOrderId(
      String orderId) async {
    List<SalesPayMethodModel> payMethods = [];
    var list = await AppDB.read(
      table: name,
      where: 'orderId = ?',
      whereArgs: [orderId],
    );
    for (var e in list) {
      payMethods.add(SalesPayMethodModel.fromMap(e));
    }
    return payMethods;
  }

  // Method to insert a new sales pay method
  static Future<int> insert(SalesPayMethodModel payMethod) async {
    return await AppDB.insert(
      table: name,
      values: payMethod.toMap(),
    );
  }

  // Method to update an existing sales pay method
  static Future<int> update({
    required SalesPayMethodModel payMethod,
    required int id,
  }) async {
    return await AppDB.update(
      table: name,
      values: payMethod.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Method to insert or update a sales pay method if it exists
  static Future<void> insertAndUpdateIfExist(
      SalesPayMethodModel payMethod) async {
    var existingPayMethod = await getPayMethodById(payMethod.id);
    if (existingPayMethod == null) {
      await insert(payMethod);
    } else {
      await update(payMethod: payMethod, id: payMethod.id!);
    }
  }

  // Method to delete a sales pay method by ID
  static Future<bool> delete(int id) async {
    var res = await AppDB.delete(
      table: name,
      where: 'id = ?',
      whereArgs: [id],
    );
    return res != 0;
  }

  // Method to delete all sales pay methods from the table
  static Future<bool> deleteTable() async {
    var res = await AppDB.delete(
      table: name,
    );
    return res != 0;
  }
}
