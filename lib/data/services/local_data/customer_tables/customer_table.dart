import 'package:kiosk_point_of_sale/data/models/customer/customer_model.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db_column.dart';

class CustomerTable {
  CustomerTable._();

  static String name = 'customer';

  static List<DbColumn> columns = [
    DbColumn(columnName: 'tableId', columnType: 'INTEGER', isPrimary: 1),
    DbColumn(columnName: 'id', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'fullName', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'cellPhone', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'code', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'discountPrcnt', columnType: 'REAL', isPrimary: 0),
    DbColumn(columnName: 'fromDate', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'toDate', columnType: 'TEXT', isPrimary: 0),
  ];

  static Future<void> create() async {
    await AppDB.createTable(tableName: name, columns: columns);
  }

  static Future<List<CustomerModel>> getAll() async {
    var list = await AppDB.read(table: name);
    return list.map((e) => CustomerModel.fromDbMap(e)).toList();
  }

  static Future<CustomerModel?> getById(String? id) async {
    var list = await AppDB.read(table: name, where: 'id = ?', whereArgs: [id]);
    return list.isNotEmpty ? CustomerModel.fromDbMap(list.first) : null;
  }

  static Future<CustomerModel?> getByTableId(int? tableId) async {
    var list = await AppDB.read(
        table: name, where: 'tableId = ?', whereArgs: [tableId]);
    return list.isNotEmpty ? CustomerModel.fromDbMap(list.first) : null;
  }

  static Future<CustomerModel?> getByCode(String? code) async {
    var list =
        await AppDB.read(table: name, where: 'code = ?', whereArgs: [code]);
    return list.isNotEmpty ? CustomerModel.fromDbMap(list.first) : null;
  }

  static Future<CustomerModel?> getByPhone(String? phone) async {
    var list = await AppDB.read(
        table: name, where: 'cellPhone = ?', whereArgs: [phone]);
    return list.isNotEmpty ? CustomerModel.fromDbMap(list.first) : null;
  }

  static Future<int> insert(CustomerModel customer) async {
    return await AppDB.insert(table: name, values: customer.toDbMap());
  }

  static Future<int> update(
      {required CustomerModel customer, required int tableId}) async {
    return await AppDB.update(
        table: name,
        values: customer.toDbMap(),
        where: 'tableId = ?',
        whereArgs: [tableId]);
  }

  static Future<void> insertAndUpdateIfExist(CustomerModel customer) async {
    var existingItem = await getById(customer.id);
    if (existingItem == null) {
      await insert(customer);
    } else {
      await update(customer: customer, tableId: existingItem.tableId!);
    }
  }

  static Future<bool> delete(int tableId) async {
    var res = await AppDB.delete(
        table: name, where: 'tableId = ?', whereArgs: [tableId]);
    return res != 0;
  }

  static Future<bool> deleteByCustomerId(String customerId) async {
    var res = await AppDB.delete(
        table: name, where: 'id = ?', whereArgs: [customerId]);
    return res != 0;
  }

  static Future<bool> deleteTable() async {
    var res = await AppDB.delete(table: name);
    return res != 0;
  }
}
