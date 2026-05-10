import 'package:kiosk_point_of_sale/data/models/Synchronization/menu_item_fb_entity.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db_column.dart';
import 'package:sqflite/sqflite.dart';

class MenuItemFBTable {
  MenuItemFBTable._();

  static String name = 'menu_item_fb';

  static List<DbColumn> columns = [
    DbColumn(columnName: 'tableId', columnType: 'INTEGER', isPrimary: 1),
    DbColumn(columnName: 'tenantId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'mainGroupId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'reportGroupId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'materialGroupId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'productCategoryId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'isHidden', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'imageId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'openPrice', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'levelId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'hasTobaccoTax', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'itemCode', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'startUsageDate', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'endUsageDate', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'isComboMealDefinitionItem', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'isShowInPlugIn', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'menuItemConfigId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'isHoteSaleing', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'barcode1', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'barcode2', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'numberOfCalories', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'numberOfSteps', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'allowDecimal', columnType: 'INTEGER', isPrimary: 0),
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

  static Future<List<MenuItemFBEntity>> getAll() async {
    final list = await AppDB.read(table: name);
    return list.map((e) => MenuItemFBEntity.fromJson(e)).toList();
  }

  static Future<MenuItemFBEntity?> getById(int? id) async {
    var list = await AppDB.read(
      table: name,
      where: 'tableId = ?',
      whereArgs: [id],
    );
    if (list.isEmpty) return null;
    return MenuItemFBEntity.fromJson(list.first);
  }

  static Future<MenuItemFBEntity?> getByEntityId(int? id) async {
    var list = await AppDB.read(
      table: name,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (list.isEmpty) return null;
    return MenuItemFBEntity.fromJson(list.first);
  }

  static Future<List<MenuItemFBEntity>> getByProductCategoryId(
      int productCategoryId) async {
    var list = await AppDB.read(
      table: name,
      where: 'productCategoryId = ?',
      whereArgs: [productCategoryId],
    );
    return list.map((e) => MenuItemFBEntity.fromJson(e)).toList();
  }

  static Future<List<MenuItemFBEntity>> getByReportGroupId(
      int reportGroupId) async {
    var list = await AppDB.read(
      table: name,
      where: 'reportGroupId = ?',
      whereArgs: [reportGroupId],
    );
    return list.map((e) => MenuItemFBEntity.fromJson(e)).toList();
  }

  static Future<int> insert(MenuItemFBEntity entity) async {
    final values = entity.toJson();
    return await AppDB.insert(
      table: name,
      values: values,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<int> update({
    required MenuItemFBEntity entity,
    required int id,
  }) async {
    return await AppDB.update(
      table: name,
      values: entity.toJson(),
      where: 'tableId = ?',
      whereArgs: [id],
    );
  }

  static Future<void> insertOrUpdate(MenuItemFBEntity entity) async {
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
