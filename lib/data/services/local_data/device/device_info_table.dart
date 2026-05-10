import 'package:kiosk_point_of_sale/data/models/store/device_info_model.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db_column.dart';

class DeviceConfigTable {
  DeviceConfigTable._();

  static String name = 'device_config';

  static List<DbColumn> columns = [
    DbColumn(columnName: 'id', columnType: 'INTEGER', isPrimary: 1),
    DbColumn(columnName: 'tenant_id', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'tenant_id_zatca', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'username_zatca', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'password_zatca', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'store_number', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'device_number', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'public_key', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'private_key', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'company_name', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'address', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'vat', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'cr_number', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'terminal_id', columnType: 'TEXT', isPrimary: 0),
    DbColumn(
        columnName: 'predefined_sequence', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'logo', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'store_code', columnType: 'TEXT', isPrimary: 0),
    DbColumn(
        columnName: 'feedmena_account_id', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'feedmena_auth_key', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'zigs_account_id', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'zigs_auth_key', columnType: 'TEXT', isPrimary: 0),
  ];

  static Future<void> create() async {
    await AppDB.createTable(tableName: name, columns: columns);
  }

  static Future<List<DeviceConfigModel>> getAll() async {
    List<DeviceConfigModel> devices = [];
    var list = await AppDB.read(table: name);
    for (var e in list) {
      devices.add(DeviceConfigModel.fromJson(e));
    }
    return devices;
  }

  static Future<DeviceConfigModel?> getDeviceInfo() async {
    var list = await AppDB.read(
      table: name,
    );
    return list.isNotEmpty ? DeviceConfigModel.fromJson(list.first) : null;
  }

  static Future<int> insert(DeviceConfigModel device) async {
    return await AppDB.insert(
      table: name,
      values: device.toJson(),
    );
  }

  static Future<int> update({
    required DeviceConfigModel device,
    required int id,
  }) async {
    return await AppDB.update(
      table: name,
      values: device.toJson(),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<bool> delete(int id) async {
    var res = await AppDB.delete(
      table: name,
      where: 'id = ?',
      whereArgs: [id],
    );
    return res != 0;
  }

  static Future<bool> deleteTable() async {
    var res = await AppDB.delete(table: name);
    return res != 0;
  }
}
