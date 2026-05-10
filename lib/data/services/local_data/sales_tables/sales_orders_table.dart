import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_order_model.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/app_db_column.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/db/meta_data_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/device/shift_table.dart';

class SalesOrderTable {
  SalesOrderTable._();

  static String name = 'sales_orders';

  // Defining columns for the sales_orders table
  static List<DbColumn> columns = [
    DbColumn(columnName: 'id', columnType: 'INTEGER', isPrimary: 1),
    DbColumn(columnName: 'invoiceId', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'refReceiptNumber', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'createdAt', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'workDate', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'updatedAt', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'deletedAt', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'totalAmount', columnType: 'TEXT', isPrimary: 0),
    DbColumn(
        columnName: 'totalAmountBeforeDiscount',
        columnType: 'TEXT',
        isPrimary: 0),
    DbColumn(columnName: 'note', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'cashierName', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'saleTypeId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'isRefund', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'cashierShiftId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(
        columnName: 'isBackOfficeSync', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'isZactaSync', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'haveRefund', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'userId', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'tenantId', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'uuid', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'orderNumber', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'receiptNumber', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'userPhone', columnType: 'TEXT', isPrimary: 0),
    DbColumn(
        columnName: 'refSaleTransactionModelId',
        columnType: 'TEXT',
        isPrimary: 0),
    DbColumn(columnName: 'paymentMethod', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'subTotal', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(
        columnName: 'subTotalBeforeDiscount',
        columnType: 'INTEGER',
        isPrimary: 0),
    DbColumn(columnName: 'tax', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(
        columnName: 'taxBeforeDiscount', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'discount', columnType: 'REAL', isPrimary: 0),
    DbColumn(columnName: 'discountValue', columnType: 'REAL', isPrimary: 0),
    DbColumn(columnName: 'discountAmount', columnType: 'REAL', isPrimary: 0),
    DbColumn(columnName: 'discountType', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(
        columnName: 'returnedFromTransactionId',
        columnType: 'TEXT',
        isPrimary: 0),
    DbColumn(columnName: 'promotionCode', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'promotionType', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'promotionValue', columnType: 'REAL', isPrimary: 0),
    DbColumn(columnName: 'promotionId', columnType: 'INTEGER', isPrimary: 0),
    DbColumn(columnName: 'promotionAmount', columnType: 'REAL', isPrimary: 0),
    // New fields for order-level calculations
    DbColumn(columnName: 'orderDiscount', columnType: 'REAL', isPrimary: 0),
    DbColumn(
        columnName: 'orderLoyaltyDiscount', columnType: 'REAL', isPrimary: 0),
    DbColumn(
        columnName: 'orderPromotionValue', columnType: 'REAL', isPrimary: 0),
    DbColumn(
        columnName: 'orderVatBeforeDiscount', columnType: 'REAL', isPrimary: 0),
    DbColumn(
        columnName: 'orderAdditionalAllowns', columnType: 'REAL', isPrimary: 0),
    DbColumn(
        columnName: 'orderPriceIncludeVAT', columnType: 'REAL', isPrimary: 0),
    DbColumn(columnName: 'change', columnType: 'REAL', isPrimary: 0),
    DbColumn(
        columnName: 'saleNotificationDetailId',
        columnType: 'TEXT',
        isPrimary: 0),
    DbColumn(columnName: 'refundResonId', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'customerId', columnType: 'TEXT', isPrimary: 0),
    DbColumn(columnName: 'promotionName', columnType: 'TEXT', isPrimary: 0),
  ];

  // Method to create the sales_orders table
  static Future<void> create() async {
    await AppDB.createTable(tableName: name, columns: columns);
  }

  // Method to get all sales orders
  static Future<List<SalesOrderModel>> getAll() async {
    List<SalesOrderModel> salesOrders = [];
    var list = await AppDB.read(table: name);
    for (var e in list) {
      // dPrint("###e: $e");
      salesOrders.add(SalesOrderModel.fromMap(e));
    }
    return salesOrders;
  }

  // static Future<int> getLatestInvoiceId() async {
  //   List<SalesOrderModel> salesOrders = [];
  //   var list = await AppDB.read(table: name);
  //   for (var e in list) {
  //     salesOrders.add(SalesOrderModel.fromMap(e));
  //   }
  //   int value = salesOrders.isNotEmpty ? salesOrders.last.invoiceId2 ?? 0 : 0;
  //
  //   return value + 1;
  // } // Method to get all sales orders

  static Future<List<SalesOrderModel>> getAllRefunds() async {
    List<SalesOrderModel> salesOrders = [];
    var list =
        await AppDB.read(table: name, where: 'isRefund = ?', whereArgs: [1]);
    for (var e in list) {
      salesOrders.add(SalesOrderModel.fromMap(e));
    }
    return salesOrders;
  }

  // get un sync orders from db where isrefund not 1
  static Future<List<SalesOrderModel>> getUnSyncOrders() async {
    List<SalesOrderModel> salesOrders = [];
    var list = await AppDB.read(
        table: name, where: 'isBackOfficeSync != ?', whereArgs: [0]);
    for (var e in list) {
      salesOrders.add(SalesOrderModel.fromMap(e));
    }
    return salesOrders;
  }

  // Method to get a specific sales order by ID
  static Future<SalesOrderModel?> getSalesOrderById(int? id) async {
    List<SalesOrderModel> salesOrders = [];
    var list = await AppDB.read(
      table: name,
      where: 'id = ?',
      whereArgs: [id],
    );
    for (var e in list) {
      salesOrders.add(SalesOrderModel.fromMap(e));
    }
    return salesOrders.isEmpty ? null : salesOrders.first;
  } // Method to get a specific sales order by ID

  static Future<SalesOrderModel?> getSalesOrderByInvoiceId(String? id) async {
    List<SalesOrderModel> salesOrders = [];
    var list = await AppDB.read(
      table: name,
      where: 'id = ?',
      whereArgs: [id],
    );
    for (var e in list) {
      salesOrders.add(SalesOrderModel.fromMap(e));
    }
    return salesOrders.isEmpty ? null : salesOrders.first;
  }

  // Method to insert a new sales order
  static Future<int> insert(SalesOrderModel salesOrder,
      {required String? orderNo}) async {
    final cashierShifts = await CashierShiftTable.getAll();
    if (orderNo?.isEmpty == true) {
      final shift = cashierShifts.isNotEmpty ? cashierShifts.first : null;
      final orderNumber = shift?.startOfDayDate == null
          ? await MetadataTable.getOrResetInvoiceCounter(salesOrder)
          : await MetadataTable.getOrResetInvoiceCounterByStartDate(salesOrder);
      dPrint("receiptNumber is $orderNumber");
      salesOrder.orderNumber = orderNumber.toString();
    }
    return await AppDB.insert(
      table: name,
      values: salesOrder.toMap(),
    );
  }

  // Method to update an existing sales order
  static Future<int> update({
    required SalesOrderModel salesOrder,
    required int id,
  }) async {
    try {
      dPrint("*****************");
      dPrint(salesOrder.toMap());
      return await AppDB.update(
        table: name,
        values: salesOrder.toMap(),
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e, t) {
      dPrint("Error updating sales order: $e");
      dPrint("Stack Trace: $t");
      return 0;
    }
  }

  // Method to insert or update a sales order if it exists
  static Future<void> insertAndUpdateIfExist(SalesOrderModel salesOrder) async {
    var existingOrder = await getSalesOrderById(salesOrder.id);
    if (existingOrder == null) {
      await insert(salesOrder, orderNo: salesOrder.orderNumber);
    } else {
      await update(salesOrder: salesOrder, id: salesOrder.id!);
    }
  }

  // Method to delete a sales order by ID
  static Future<bool> delete(int id) async {
    var res = await AppDB.delete(
      table: name,
      where: 'id = ?',
      whereArgs: [id],
    );
    return res != 0;
  }

  // Method to delete all sales orders from the table
  static Future<bool> deleteTable() async {
    var res = await AppDB.delete(
      table: name,
    );
    return res != 0;
  }

  // Method to search sales orders by receipt number
  static Future<List<SalesOrderModel>> searchByReceiptNumber(
      String receiptNumber) async {
    List<SalesOrderModel> salesOrders = [];
    var list = await AppDB.read(
      table: name,
      where: 'receiptNumber LIKE ?',
      whereArgs: ['%$receiptNumber%'],
    );
    for (var e in list) {
      salesOrders.add(SalesOrderModel.fromMap(e));
    }
    return salesOrders;
  }
}
