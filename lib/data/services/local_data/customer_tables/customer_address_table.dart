import 'package:kiosk_point_of_sale/data/models/customer/customer_address_model.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db_column.dart';

class CustomerAddressTable {
  CustomerAddressTable._();

  static String name = 'customer_address';

  static List<DbColumn> columns = [
    DbColumn(columnName: 'tableId', columnType: 'INTEGER', isPrimary: 1),
    DbColumn(columnName: 'id', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'city', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'customerId', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'address', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'link', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'deliveryZoneId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'zoneName', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'zoneNameId', columnType: 'TEXT', isPrimary: 0),
    DbColumn(
        columnName: 'deliveryStreetId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'streetName', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'streetNameId', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'isSelected', columnType: 'INTEGER', isPrimary: 0),
  ];

  static Future<void> create() async {
    await AppDB.createTable(tableName: name, columns: columns);
  }

  static Future<List<CustomerAddressModel>> getAll() async {
    var list = await AppDB.read(table: name);
    return list.map((e) => CustomerAddressModel.fromDbMap(e)).toList();
  }

  static Future<CustomerAddressModel?> getById(int? id) async {
    var list = await AppDB.read(table: name, where: 'id = ?', whereArgs: [id]);
    return list.isNotEmpty ? CustomerAddressModel.fromDbMap(list.first) : null;
  }

  static Future<CustomerAddressModel?> getByTableId(int? tableId) async {
    var list = await AppDB.read(
        table: name, where: 'tableId = ?', whereArgs: [tableId]);
    return list.isNotEmpty ? CustomerAddressModel.fromDbMap(list.first) : null;
  }

  static Future<List<CustomerAddressModel>> getByCustomerId(
      String? customerId) async {
    var list = await AppDB.read(
        table: name, where: 'customerId = ?', whereArgs: [customerId]);
    return list.map((e) => CustomerAddressModel.fromDbMap(e)).toList();
  }

  static Future<CustomerAddressModel?> getSelectedAddressByCustomerId(
      String? customerId) async {
    var list = await AppDB.read(
        table: name,
        where: 'customerId = ? AND isSelected = 1',
        whereArgs: [customerId]);
    return list.isNotEmpty ? CustomerAddressModel.fromDbMap(list.first) : null;
  }

  static Future<int> insert(CustomerAddressModel address) async {
    return await AppDB.insert(table: name, values: address.toDbMap());
  }

  static Future<int> update(
      {required CustomerAddressModel address, required int tableId}) async {
    return await AppDB.update(
        table: name,
        values: address.toDbMap(),
        where: 'tableId = ?',
        whereArgs: [tableId]);
  }

  static Future<void> insertAndUpdateIfExist(
      CustomerAddressModel address) async {
    var existingItem = await getById(address.id);
    if (existingItem == null) {
      await insert(address);
    } else {
      await update(address: address, tableId: existingItem.tableId!);
    }
  }

  static Future<void> insertMultiple(
      List<CustomerAddressModel> addresses) async {
    for (var address in addresses) {
      await insertAndUpdateIfExist(address);
    }
  }

  static Future<bool> delete(int tableId) async {
    var res = await AppDB.delete(
        table: name, where: 'tableId = ?', whereArgs: [tableId]);
    return res != 0;
  }

  static Future<bool> deleteByAddressId(int addressId) async {
    var res = await AppDB.delete(
        table: name, where: 'id = ?', whereArgs: [addressId]);
    return res != 0;
  }

  static Future<bool> deleteByCustomerId(String customerId) async {
    var res = await AppDB.delete(
        table: name, where: 'customerId = ?', whereArgs: [customerId]);
    return res != 0;
  }

  static Future<bool> deleteTable() async {
    var res = await AppDB.delete(table: name);
    return res != 0;
  }
}
