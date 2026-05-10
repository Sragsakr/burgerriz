import 'package:kiosk_point_of_sale/data/models/coding_pattern_settings_model.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db_column.dart';

class CodingPatternSettingsRefundTable {
  CodingPatternSettingsRefundTable._();

  static String name = 'coding_pattern_settings_refund';

  static List<DbColumn> columns = [
    DbColumn(columnName: 'tableId', columnType: 'INTEGER', isPrimary: 1),
    DbColumn(columnName: 'startValue', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'incrementvalue', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'prefix', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'suffix', columnType: 'TEXT', isPrimary: 0),
    DbColumn(
        columnName: 'lastGeneratedValue', columnType: 'INTEGER', isPrimary: 0),
  ];

  static Future<void> create() async {
    await AppDB.createTable(tableName: name, columns: columns);
  }

  static Future<List<CodingPatternSettingsModel>> getAll() async {
    var list = await AppDB.read(table: name);
    return list.map((e) => CodingPatternSettingsModel.fromMap(e)).toList();
  }

  static Future<CodingPatternSettingsModel?> getById(int? id) async {
    var list =
        await AppDB.read(table: name, where: 'tableId = ?', whereArgs: [id]);
    return list.isNotEmpty
        ? CodingPatternSettingsModel.fromMap(list.first)
        : null;
  }

  static Future<int> insert(CodingPatternSettingsModel item) async {
    return await AppDB.insert(table: name, values: item.toMap());
  }

  static Future<int> update(
      {required CodingPatternSettingsModel item, required int id}) async {
    return await AppDB.update(
      table: name,
      values: item.toMap(),
      where: 'tableId = ?',
      whereArgs: [id],
    );
  }

  static Future<void> insertAndUpdateIfExist(
      CodingPatternSettingsModel item) async {
    // This table is expected to hold a single row; upsert by tableId 1
    var existing = await getById(1);
    if (existing == null) {
      await insert(item);
    } else {
      await update(item: item, id: 1);
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
