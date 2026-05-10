import 'package:kiosk_point_of_sale/data/models/product_category/product_category_level_model.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db_column.dart';

class ProductCategoryLevelTable {
  ProductCategoryLevelTable._();

  static String name = 'product_category_levels';

  static List<DbColumn> columns = [
    DbColumn(columnName: 'tableId', columnType: 'INTEGER', isPrimary: 1),
    DbColumn(columnName: 'id', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'levelId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'productCategoryId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'isDeleted', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'deleterUserId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'deletionTime', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'lastModificationTime', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'lastModifierUserId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'creatorUserId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'creationTime', columnType: 'TEXT', isPrimary: 0),
  ];

  static Future<void> create() async {
    await AppDB.createTable(tableName: name, columns: columns);
  }

  static Future<List<ProductCategoryLevelModel>> getAll() async {
    var list = await AppDB.read(table: name);
    return list.map((e) => ProductCategoryLevelModel.fromMap(e)).toList();
  }

  static Future<ProductCategoryLevelModel?> getById(int? id) async {
    var list =
        await AppDB.read(table: name, where: 'tableId = ?', whereArgs: [id]);
    return list.isNotEmpty
        ? ProductCategoryLevelModel.fromMap(list.first)
        : null;
  }

  static Future<List<ProductCategoryLevelModel>> getByProductCategoryId(
      int productCategoryId) async {
    var list = await AppDB.read(
        table: name,
        where: 'productCategoryId = ?',
        whereArgs: [productCategoryId]);
    return list.map((e) => ProductCategoryLevelModel.fromMap(e)).toList();
  }

  static Future<List<ProductCategoryLevelModel>> getByLevelId(
      int levelId) async {
    var list = await AppDB.read(
        table: name, where: 'levelId = ?', whereArgs: [levelId]);
    return list.map((e) => ProductCategoryLevelModel.fromMap(e)).toList();
  }

  static Future<int> insert(ProductCategoryLevelModel item) async {
    return await AppDB.insert(table: name, values: item.toMap());
  }

  static Future<int> update(
      {required ProductCategoryLevelModel item, required int id}) async {
    return await AppDB.update(
        table: name,
        values: item.toMap(),
        where: 'tableId = ?',
        whereArgs: [id]);
  }

  static Future<void> insertAndUpdateIfExist(
      ProductCategoryLevelModel item) async {
    var existing = await getById(item.id);
    if (existing == null) {
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
