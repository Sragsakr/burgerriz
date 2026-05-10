import 'package:kiosk_point_of_sale/data/models/Synchronization/report_group_translation_entity.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db_column.dart';
import 'package:sqflite/sqflite.dart';

class ReportGroupTranslationTable {
  ReportGroupTranslationTable._();

  static String name = 'report_group_translation';

  static List<DbColumn> columns = [
    DbColumn(columnName: 'tableId', columnType: 'INTEGER', isPrimary: 1),
    DbColumn(columnName: 'reportGroupId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'name', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'isDeleted', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'deleterUserId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'deletionTime', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'lastModificationTime', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'lastModifierUserId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'creationTime', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'creatorUserId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'id', columnType: 'INTEGER', isPrimary: 0),
  ];

  static Future<void> create() async {
    await AppDB.createTable(tableName: name, columns: columns);
  }

  static Future<List<ReportGroupTranslationEntity>> getAll() async {
    final list = await AppDB.read(table: name);
    return list.map((e) => ReportGroupTranslationEntity.fromJson(e)).toList();
  }

  static Future<ReportGroupTranslationEntity?> getById(int id) async {
    var list = await AppDB.read(
      table: name,
      where: 'tableId = ?',
      whereArgs: [id],
    );
    if (list.isEmpty) return null;
    return ReportGroupTranslationEntity.fromJson(list.first);
  }

  static Future<ReportGroupTranslationEntity?> getByEntityId(int id) async {
    var list = await AppDB.read(
      table: name,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (list.isEmpty) return null;
    return ReportGroupTranslationEntity.fromJson(list.first);
  }

  static Future<List<ReportGroupTranslationEntity>> getByReportGroupId(
      int reportGroupId) async {
    var list = await AppDB.read(
      table: name,
      where: 'reportGroupId = ?',
      whereArgs: [reportGroupId],
    );
    return list.map((e) => ReportGroupTranslationEntity.fromJson(e)).toList();
  }

  static Future<int> insert(ReportGroupTranslationEntity entity) async {
    final values = entity.toJson();
    return await AppDB.insert(
      table: name,
      values: values,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<int> update({
    required ReportGroupTranslationEntity entity,
    required int id,
  }) async {
    return await AppDB.update(
      table: name,
      values: entity.toJson(),
      where: 'tableId = ?',
      whereArgs: [id],
    );
  }

  static Future<void> insertOrUpdate(
      ReportGroupTranslationEntity entity) async {
    var existing = await getByEntityId(entity.id);
    if (existing == null) {
      await insert(entity);
    } else {
      await update(entity: entity, id: existing.tableId!);
    }
  }

  static Future<bool> delete(int id) async {
    final res = await AppDB.delete(
      table: name,
      where: 'id = ?',
      whereArgs: [id],
    );
    return res > 0;
  }

  static Future<bool> deleteTable() async {
    var res = await AppDB.delete(table: name);
    return res != 0;
  }
}
