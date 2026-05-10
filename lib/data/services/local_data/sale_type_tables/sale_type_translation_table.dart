import 'package:kiosk_point_of_sale/data/models/sale_types/sale_type_translation_model.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db_column.dart';

class SaleTypeTranslationTable {
  SaleTypeTranslationTable._();

  static String name = 'sale_type_translation';

  static List<DbColumn> columns = [
    DbColumn(columnName: 'tableId', columnType: 'INTEGER', isPrimary: 1),
    DbColumn(columnName: 'id', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'saleTypeId', columnType: 'INTEGER', isPrimary: 0),
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

  // Get all SaleTypeTranslations
  static Future<List<SaleTypeTranslationModel>> getAll() async {
    List<SaleTypeTranslationModel> translations = [];
    var list = await AppDB.read(table: name);
    for (var e in list) {
      // dPrint('Translation: $e');
      translations.add(SaleTypeTranslationModel.fromMap(e));
    }
    return translations;
  }

  // Get SaleTypeTranslation by ID
  static Future<SaleTypeTranslationModel?> getById(int? id) async {
    List<SaleTypeTranslationModel> translations = [];
    var list = await AppDB.read(
      table: name,
      where: 'tableId = ?',
      whereArgs: [id],
    );
    for (var e in list) {
      translations.add(SaleTypeTranslationModel.fromMap(e));
    }
    return translations.isEmpty ? null : translations.first;
  }

  // Insert a SaleTypeTranslation
  static Future<int> insert(SaleTypeTranslationModel translation) async {
    return await AppDB.insert(
      table: name,
      values: translation.toMap(),
    );
  }

  // Update a SaleTypeTranslation
  static Future<int> update({
    required SaleTypeTranslationModel translation,
    required int id,
  }) async {
    return await AppDB.update(
      table: name,
      values: translation.toMap(),
      where: 'tableId = ?',
      whereArgs: [id],
    );
  }

  // Insert or Update if exists
  static Future<void> insertAndUpdateIfExist(
      SaleTypeTranslationModel translation) async {
    var existingItem = await getById(translation.id);
    if (existingItem == null) {
      await insert(translation);
    } else {
      await update(translation: translation, id: translation.id);
    }
  }

  // Delete SaleTypeTranslation by ID
  static Future<bool> delete(int id) async {
    var res = await AppDB.delete(
      table: name,
      where: 'tableId = ?',
      whereArgs: [id],
    );
    return res != 0;
  }

  // Delete all SaleTypeTranslations
  static Future<bool> deleteTable() async {
    var res = await AppDB.delete(table: name);
    return res != 0;
  }
}
