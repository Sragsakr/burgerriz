import 'package:kiosk_point_of_sale/data/models/Synchronization/combo_meal_package_entity.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db_column.dart';
import 'package:sqflite/sqflite.dart';

class ComboMealPackagesTable {
  ComboMealPackagesTable._();

  static String name = 'combo_meal_packages';

  static List<DbColumn> columns = [
    DbColumn(columnName: 'tableId', columnType: 'INTEGER', isPrimary: 1),
    DbColumn(columnName: 'code', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'quantity', columnType: 'REAL', isPrimary: 0),
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

  static Future<List<ComboMealPackageEntity>> getAll() async {
    final list = await AppDB.read(table: name);
    return list.map((e) => ComboMealPackageEntity.fromJson(e)).toList();
  }

  static Future<ComboMealPackageEntity?> getById(int? id) async {
    var list = await AppDB.read(
      table: name,
      where: 'tableId = ?',
      whereArgs: [id],
    );

    if (list.isEmpty) return null;
    return ComboMealPackageEntity.fromJson(list.first);
  }

  static Future<ComboMealPackageEntity?> getByEntityId(int? id) async {
    var list = await AppDB.read(
      table: name,
      where: 'id = ? AND isDeleted = 0',
      whereArgs: [id],
    );

    if (list.isEmpty) return null;
    return ComboMealPackageEntity.fromJson(list.first);
  }

  static Future<int> insert(ComboMealPackageEntity entity) async {
    final values = entity.toJson();
    final tableId = await AppDB.insert(
      table: name,
      values: values,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return tableId;
  }

  static Future<int> update({
    required ComboMealPackageEntity entity,
    required int id,
  }) async {
    final values = entity.toJson();
    return await AppDB.update(
      table: name,
      values: values,
      where: 'tableId = ?',
      whereArgs: [id],
    );
  }

  static Future<void> insertOrUpdate(ComboMealPackageEntity entity) async {
    var existingItem = await getByEntityId(entity.id);
    if (existingItem == null) {
      await insert(entity);
    } else {
      await update(entity: entity, id: existingItem.tableId!);
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

