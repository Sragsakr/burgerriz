import 'package:kiosk_point_of_sale/data/models/Synchronization/combo_meal_definition_entity.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db_column.dart';
import 'package:sqflite/sqflite.dart';

class ComboMealDefinitionsTable {
  ComboMealDefinitionsTable._();

  static String name = 'combo_meal_definitions';

  static List<DbColumn> columns = [
    DbColumn(columnName: 'tableId', columnType: 'INTEGER', isPrimary: 1),
    DbColumn(columnName: 'menuItemId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(
        columnName: 'comboMealPackageId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'order_index', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'isDeleted', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'deleterUserId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'deletionTime', columnType: 'TEXT', isPrimary: 0),
    DbColumn(
        columnName: 'lastModificationTime', columnType: 'TEXT', isPrimary: 0),
    DbColumn(
        columnName: 'lastModifierUserId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'creationTime', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'creatorUserId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'id', columnType: 'INTEGER', isPrimary: 0),
  ];

  static Future<void> create() async {
    await AppDB.createTable(tableName: name, columns: columns);
  }

  static Future<List<ComboMealDefinitionEntity>> getAll() async {
    final list = await AppDB.read(table: name);
    return list.map((e) => ComboMealDefinitionEntity.fromJson(e)).toList();
  }

  static Future<ComboMealDefinitionEntity?> getById(int? id) async {
    var list = await AppDB.read(
      table: name,
      where: 'tableId = ?',
      whereArgs: [id],
    );

    if (list.isEmpty) return null;
    return ComboMealDefinitionEntity.fromJson(list.first);
  }

  static Future<ComboMealDefinitionEntity?> getByEntityId(int? id) async {
    var list = await AppDB.read(
      table: name,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (list.isEmpty) return null;
    return ComboMealDefinitionEntity.fromJson(list.first);
  }

  static Future<List<ComboMealDefinitionEntity>> getByMenuItemId(
      int menuItemId) async {
    var list = await AppDB.read(
      table: name,
      where: 'menuItemId = ? AND isDeleted = 0',
      whereArgs: [menuItemId],
      orderBy: '"order_index" ASC',
    );

    return list.map((e) => ComboMealDefinitionEntity.fromJson(e)).toList();
  }

  static Future<bool> isMenuItemComboMeal(int menuItemId) async {
    var list = await AppDB.read(
      table: name,
      where: 'menuItemId = ? AND isDeleted = 0',
      whereArgs: [menuItemId],
      limit: 1,
    );

    return list.isNotEmpty;
  }

  static Future<int> insert(ComboMealDefinitionEntity entity) async {
    final values = entity.toJson();
    final tableId = await AppDB.insert(
      table: name,
      values: values,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return tableId;
  }

  static Future<int> update({
    required ComboMealDefinitionEntity entity,
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

  static Future<void> insertOrUpdate(ComboMealDefinitionEntity entity) async {
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
