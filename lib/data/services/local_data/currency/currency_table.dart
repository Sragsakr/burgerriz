import 'package:kiosk_point_of_sale/data/models/store/currency_model.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db_column.dart';

class CurrencyTable {
  CurrencyTable._();

  static String name = 'currency';

  static List<DbColumn> columns = [
    DbColumn(columnName: 'tableId', columnType: 'INTEGER', isPrimary: 1),
    DbColumn(columnName: 'id', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'languageId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'currencyId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'name', columnType: 'TEXT', isPrimary: 0),
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

  static Future<List<CurrencyModel>> getAll() async {
    var list = await AppDB.read(table: name);
    return list.map((e) => CurrencyModel.fromMap(e)).toList();
  }

  static Future<CurrencyModel?> getById(int? id) async {
    var list =
        await AppDB.read(table: name, where: 'tableId = ?', whereArgs: [id]);
    return list.isNotEmpty ? CurrencyModel.fromMap(list.first) : null;
  }

  static Future<CurrencyModel?> getSarCurrency() async {
    var list = await AppDB.read(table: name);
    return list.isNotEmpty ? CurrencyModel.fromMap(list.first) : null;
  }

  static Future<int> insert(CurrencyModel currency) async {
    return await AppDB.insert(table: name, values: currency.toMap());
  }

  static Future<int> update(
      {required CurrencyModel currency, required int id}) async {
    return await AppDB.update(
        table: name,
        values: currency.toMap(),
        where: 'tableId = ?',
        whereArgs: [id]);
  }

  static Future<void> insertAndUpdateIfExist(CurrencyModel currency) async {
    var existingItem = await getById(currency.id);
    if (existingItem == null) {
      await insert(currency);
    } else {
      await update(currency: currency, id: currency.id);
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
