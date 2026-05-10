import 'package:kiosk_point_of_sale/data/models/sales_models/sales_order_model.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db_column.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/device/shift_table.dart';
import 'package:sqflite/sqflite.dart';

class MetadataTable {
  MetadataTable._();

  static const String tableName = 'metadata';

  static List<DbColumn> columns = [
    DbColumn(columnName: 'key', columnType: 'TEXT', isPrimary: 1),
    DbColumn(columnName: 'value', columnType: 'TEXT', isPrimary: 0),
  ];
  static const String keyPtCash = 'ptCash';

  static Future<double> getPtCash() async {
    final value = await getValue(keyPtCash);
    return double.tryParse(value ?? '') ?? 0.0;
  }

  static Future<void> setPtCash(double value) async {
    await setValue(keyPtCash, value.toString());
  }

  static Future<void> deletePtCash() async {
    await AppDB.delete(
      table: tableName,
      where: 'key = ?',
      whereArgs: [keyPtCash],
    );
  }

  /// Create the Metadata table if it doesn't exist
  static Future<void> create() async {
    await AppDB.createTable(tableName: tableName, columns: columns);
  }

  /// Get a value from the Metadata table by key
  static Future<String?> getValue(String key) async {
    final result = await AppDB.read(
      table: tableName,
      where: 'key = ?',
      whereArgs: [key],
    );
    return result.isNotEmpty ? result.first['value'] as String? : null;
  }

  /// Set or update a value in the Metadata table
  static Future<void> setValue(String key, String value) async {
    await AppDB.insert(
      table: tableName,
      values: {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Delete all entries in the Metadata table
  static Future<bool> deleteTable() async {
    final res = await AppDB.delete(table: tableName);
    return res != 0;
  }

  /// Fetch an integer value safely from the metadata table
  static Future<int> getIntValue(String key, {int defaultValue = 0}) async {
    final value = await getValue(key);
    return int.tryParse(value ?? '') ?? defaultValue;
  }

  /// Set an integer value in the metadata table
  static Future<void> setIntValue(String key, int value) async {
    await setValue(key, value.toString());
  }

  /// Handle the resetting or incrementing of the invoice counter
  static Future<int> getOrResetInvoiceCounter(
      SalesOrderModel salesOrder) async {
    final today = DateTime.now().toIso8601String().split('T').first;

    return await AppDB.db.transaction((txn) async {
      // Use txn here
      final lastResetDateQuery = await txn.rawQuery(
        // Use txn instead of AppDB.db
        'SELECT value FROM $tableName WHERE key = ?',
        ['lastResetDate'],
      );
      final lastResetDate = lastResetDateQuery.isNotEmpty
          ? lastResetDateQuery.first['value']
          : null;

      int invoiceCounter;

      if (lastResetDate == null || lastResetDate != today) {
        invoiceCounter = 1;

        await txn.rawInsert(
          // Use txn instead of AppDB.db
          'INSERT OR REPLACE INTO $tableName (key, value) VALUES (?, ?)',
          ['lastResetDate', today],
        );
        await txn.rawInsert(
          'INSERT OR REPLACE INTO $tableName (key, value) VALUES (?, ?)',
          ['invoiceCounter', invoiceCounter.toString()],
        );
      } else {
        final counterQuery = await txn.rawQuery(
          'SELECT value FROM $tableName WHERE key = ?',
          ['invoiceCounter'],
        );
        final currentCounter = counterQuery.isNotEmpty
            ? int.parse(counterQuery.first['value'] as String? ?? '0')
            : 0;
        invoiceCounter = currentCounter + 1;

        await txn.rawUpdate(
          'UPDATE $tableName SET value = ? WHERE key = ?',
          [invoiceCounter.toString(), 'invoiceCounter'],
        );
      }

      return invoiceCounter;
    });
  }

  /// Handle invoice counter based on business start date
  static Future<int> getOrResetInvoiceCounterByStartDate(
      SalesOrderModel salesOrder) async {
    final cashierShifts = await CashierShiftTable.getAll();
    if (cashierShifts.isEmpty) return 1;

    final shift = cashierShifts.first;
    if (!shift.isActiveEndOfDay ||
        shift.startOfDayDate == null ||
        shift.endOfDayDate == null) {
      return 1;
    }
    // DateTime startOfBusinessDay =
    // DateTime.parse("2025-03-06T17:01:00Z").toLocal();
    // DateTime endOfBusinessDay =
    // DateTime.parse("2025-03-07T16:59:00Z").toLocal();
    DateTime startOfBusinessDay =
        DateTime.parse(shift.startOfDayDate!).toLocal();
    DateTime orderDateTime =
        DateTime.tryParse(salesOrder.createdAt)?.toLocal() ?? DateTime.now();

    return await AppDB.db.transaction((txn) async {
      // استعلام عن آخر تاريخ تم فيه إعادة ضبط الفاتورة
      final lastResetDateQuery = await txn.rawQuery(
          'SELECT value FROM metadata WHERE key = ?', ['lastResetDate']);
      final lastResetDate = lastResetDateQuery.isNotEmpty
          ? lastResetDateQuery.first['value'] as String? ?? ''
          : '';

      // استعلام عن رقم الفاتورة الحالي
      final lastInvoiceCounterQuery = await txn.rawQuery(
          'SELECT value FROM metadata WHERE key = ?', ['invoiceCounter']);
      final lastInvoiceCounter = lastInvoiceCounterQuery.isNotEmpty
          ? int.tryParse(
                  lastInvoiceCounterQuery.first['value'] as String? ?? '0') ??
              0
          : 0;

      String businessDateString =
          startOfBusinessDay.toIso8601String().split('T').first;
      int invoiceCounter;

      if (lastResetDate != businessDateString) {
        // إعادة ضبط العداد لأول طلب في اليوم الجديد
        invoiceCounter = 1;
        await txn.rawInsert(
            'INSERT OR REPLACE INTO metadata (key, value) VALUES (?, ?)',
            ['lastResetDate', businessDateString]);
      } else {
        // زيادة العداد بشكل طبيعي
        invoiceCounter = lastInvoiceCounter + 1;
      }

      await txn.rawInsert(
          'INSERT OR REPLACE INTO metadata (key, value) VALUES (?, ?)',
          ['invoiceCounter', invoiceCounter.toString()]);

      return invoiceCounter;
    });
  }
}
