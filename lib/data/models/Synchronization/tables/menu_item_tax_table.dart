import 'package:kiosk_point_of_sale/data/models/Synchronization/menu_item_tax_entity.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db_column.dart';
import 'package:sqflite/sqflite.dart';

class MenuItemTaxTable {
  MenuItemTaxTable._();

  static String name = 'menu_item_tax';

  static List<DbColumn> columns = [
    DbColumn(columnName: 'tableId', columnType: 'INTEGER', isPrimary: 1),
    DbColumn(columnName: 'menuItemId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'taxId', columnType: 'INTEGER', isPrimary: 0),
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

  static Future<List<MenuItemTaxEntity>> getAll() async {
    final list = await AppDB.read(table: name);
    return list.map((e) => MenuItemTaxEntity.fromJson(e)).toList();
  }

  static Future<MenuItemTaxEntity?> getById(int? id) async {
    var list = await AppDB.read(
      table: name,
      where: 'tableId = ?',
      whereArgs: [id],
    );
    if (list.isEmpty) return null;
    return MenuItemTaxEntity.fromJson(list.first);
  }

  static Future<MenuItemTaxEntity?> getByEntityId(int? id) async {
    var list = await AppDB.read(
      table: name,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (list.isEmpty) return null;
    return MenuItemTaxEntity.fromJson(list.first);
  }

  static Future<List<MenuItemTaxEntity>> getByMenuItemId(
      int menuItemId) async {
    var list = await AppDB.read(
      table: name,
      where: 'menuItemId = ?',
      whereArgs: [menuItemId],
    );
    return list.map((e) => MenuItemTaxEntity.fromJson(e)).toList();
  }

  static Future<int> insert(MenuItemTaxEntity entity) async {
    return await AppDB.insert(
      table: name,
      values: entity.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<int> update({
    required MenuItemTaxEntity entity,
    required int id,
  }) async {
    return await AppDB.update(
      table: name,
      values: entity.toJson(),
      where: 'tableId = ?',
      whereArgs: [id],
    );
  }

  static Future<void> insertOrUpdate(MenuItemTaxEntity entity) async {
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
