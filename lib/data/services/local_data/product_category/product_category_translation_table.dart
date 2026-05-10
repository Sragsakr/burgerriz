import 'package:kiosk_point_of_sale/data/models/product_category/product_category_translation_model.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db_column.dart';

class ProductCategoryTranslationTable {
  ProductCategoryTranslationTable._();

  static String name = 'product_category_translations';

  static List<DbColumn> columns = [
    DbColumn(columnName: 'tableId', columnType: 'INTEGER', isPrimary: 1),
    DbColumn(columnName: 'id', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'productCategoryId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'name', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'languageId', columnType: 'INTEGER', isPrimary: 0),
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

  static Future<List<ProductCategoryTranslationModel>> getAll() async {
    var list = await AppDB.read(table: name);
    return list
        .map((e) => ProductCategoryTranslationModel.fromMap(e))
        .toList();
  }

  static Future<ProductCategoryTranslationModel?> getById(int? id) async {
    var list =
        await AppDB.read(table: name, where: 'tableId = ?', whereArgs: [id]);
    return list.isNotEmpty
        ? ProductCategoryTranslationModel.fromMap(list.first)
        : null;
  }

  static Future<List<ProductCategoryTranslationModel>> getByProductCategoryId(
      int productCategoryId) async {
    var list = await AppDB.read(
        table: name,
        where: 'productCategoryId = ?',
        whereArgs: [productCategoryId]);
    return list
        .map((e) => ProductCategoryTranslationModel.fromMap(e))
        .toList();
  }

  static Future<List<ProductCategoryTranslationModel>> getByLanguageId(
      int languageId) async {
    var list = await AppDB.read(
        table: name, where: 'languageId = ?', whereArgs: [languageId]);
    return list
        .map((e) => ProductCategoryTranslationModel.fromMap(e))
        .toList();
  }

  static Future<int> insert(ProductCategoryTranslationModel item) async {
    return await AppDB.insert(table: name, values: item.toMap());
  }

  static Future<int> update(
      {required ProductCategoryTranslationModel item, required int id}) async {
    return await AppDB.update(
        table: name,
        values: item.toMap(),
        where: 'tableId = ?',
        whereArgs: [id]);
  }

  static Future<void> insertAndUpdateIfExist(
      ProductCategoryTranslationModel item) async {
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
