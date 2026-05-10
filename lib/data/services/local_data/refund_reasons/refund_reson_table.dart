import 'package:kiosk_point_of_sale/data/models/refund_reson_model.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db_column.dart';

class RefundResonTable {
  RefundResonTable._();

  static String name = 'refund_resons';

  static List<DbColumn> columns = [
    DbColumn(columnName: 'tableId', columnType: 'INTEGER', isPrimary: 1),
    DbColumn(columnName: 'id', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'code', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'description', columnType: 'TEXT', isPrimary: 0),
  ];

  static Future<void> create() async {
    await AppDB.createTable(tableName: name, columns: columns);
  }

  static Future<List<RefundResonModel>> getAll() async {
    var list = await AppDB.read(table: name);
    return list.map((e) => RefundResonModel.fromMap(e)).toList();
  }

  static Future<RefundResonModel?> getById(int? id) async {
    var list =
        await AppDB.read(table: name, where: 'tableId = ?', whereArgs: [id]);
    return list.isNotEmpty ? RefundResonModel.fromMap(list.first) : null;
  }

  static Future<int> insert(RefundResonModel item) async {
    return await AppDB.insert(table: name, values: item.toMap());
  }

  static Future<int> update(
      {required RefundResonModel item, required int id}) async {
    return await AppDB.update(
        table: name,
        values: item.toMap(),
        where: 'tableId = ?',
        whereArgs: [id]);
  }

  static Future<void> insertAndUpdateIfExist(RefundResonModel item) async {
    var existingItem = await getById(item.id);
    if (existingItem == null) {
      await insert(item);
    } else {
      await update(item: item, id: item.id);
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
