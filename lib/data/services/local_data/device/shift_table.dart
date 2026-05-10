import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/data/models/store/shift_model.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db_column.dart';

class CashierShiftTable {
  CashierShiftTable._();

  static String name = 'cashier_shift';

  static List<DbColumn> columns = [
    DbColumn(columnName: 'tableId', columnType: 'INTEGER', isPrimary: 1),
    DbColumn(columnName: 'id', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'cashierShiftId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'endOfDayID', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'startOfDayTiming', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'endOfDayTiming', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'date', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'status', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'syncStatus', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'dayStatus', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'cashierStatus', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'isValid', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'canLogin', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'startOfDayDate', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'endOfDayDate', columnType: 'TEXT', isPrimary: 0),
    DbColumn(
        columnName: 'isActiveEndOfDay', columnType: 'INTEGER', isPrimary: 0),
  ];

  static Future<void> create() async {
    await AppDB.createTable(tableName: name, columns: columns);
  }

  /// **Get all cashier shifts**
  static Future<List<CashierShift>> getAll() async {
    List<CashierShift> shifts = [];
    var list = await AppDB.read(table: name);
    for (var e in list) {
      // dPrint('Cashier Shift: $e');
      shifts.add(CashierShift.fromMap(e));
    }
    return shifts;
  }

  /// **Get a specific cashier shift by ID**
  static Future<CashierShift?> getById(int? id) async {
    var list = await AppDB.read(
      table: name,
      where: 'tableId = ?',
      whereArgs: [id],
    );
    if (list.isNotEmpty) {
      return CashierShift.fromMap(list.first);
    }
    return null;
  }

  /// **Insert a new cashier shift**
  static Future<int> insert(CashierShift shift) async {
    dPrint('Inserting Cashier Shift: ${shift.toMap()}');
    final id = await AppDB.insert(
      table: name,
      values: shift.toMap(),
    );
    dPrint('Inserted CashierShift ID: $id');
    return id;
  }

  /// **Update an existing cashier shift**
  static Future<int> update({
    required CashierShift shift,
    required int id,
  }) async {
    return await AppDB.update(
      table: name,
      values: shift.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// **Insert or update a cashier shift**
  static Future<void> insertOrUpdate(CashierShift shift) async {
    var existingShift = await getById(shift.id);
    if (existingShift == null) {
      await insert(shift);
    } else {
      await update(shift: shift, id: shift.id!);
    }
  }

  /// **Delete a cashier shift by ID**
  static Future<bool> delete(int id) async {
    var res = await AppDB.delete(
      table: name,
      where: 'id = ?',
      whereArgs: [id],
    );
    return res != 0;
  }

  /// **Delete all records from the cashier shift table**
  static Future<bool> deleteTable() async {
    var res = await AppDB.delete(table: name);
    return res != 0;
  }
}
