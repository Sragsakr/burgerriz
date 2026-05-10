import 'package:kiosk_point_of_sale/data/models/unit_of_measure/unit_of_measure_translation_model.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db_column.dart';

class UnitOfMeasureTranslationTable {
  UnitOfMeasureTranslationTable._();

  static String name = 'unit_of_measure_translations';

  static List<DbColumn> columns = [
    DbColumn(columnName: 'tableId', columnType: 'INTEGER', isPrimary: 1),
    DbColumn(columnName: 'id', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'unitOfMeasureId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'name', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'languageId', columnType: 'INTEGER', isPrimary: 0),
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

  static Future<List<UnitOfMeasureTranslationModel>> getAll() async {
    var list = await AppDB.read(table: name);
    return list.map((e) => UnitOfMeasureTranslationModel.fromMap(e)).toList();
  }

  static Future<UnitOfMeasureTranslationModel?> getById(int? id) async {
    var list =
        await AppDB.read(table: name, where: 'tableId = ?', whereArgs: [id]);
    return list.isNotEmpty
        ? UnitOfMeasureTranslationModel.fromMap(list.first)
        : null;
  }

  static Future<List<UnitOfMeasureTranslationModel>> getByUnitOfMeasureId(
      int unitOfMeasureId) async {
    var list = await AppDB.read(
        table: name,
        where: 'unitOfMeasureId = ?',
        whereArgs: [unitOfMeasureId]);
    return list.map((e) => UnitOfMeasureTranslationModel.fromMap(e)).toList();
  }

  static Future<List<UnitOfMeasureTranslationModel>> getByLanguageId(
      int languageId) async {
    var list = await AppDB.read(
        table: name, where: 'languageId = ?', whereArgs: [languageId]);
    return list.map((e) => UnitOfMeasureTranslationModel.fromMap(e)).toList();
  }

  static Future<int> insert(UnitOfMeasureTranslationModel item) async {
    return await AppDB.insert(table: name, values: item.toMap());
  }

  static Future<int> update(
      {required UnitOfMeasureTranslationModel item, required int id}) async {
    return await AppDB.update(
        table: name,
        values: item.toMap(),
        where: 'tableId = ?',
        whereArgs: [id]);
  }

  static Future<void> insertAndUpdateIfExist(
      UnitOfMeasureTranslationModel item) async {
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
