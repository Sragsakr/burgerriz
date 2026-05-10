import 'dart:math';

import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';
import 'package:kiosk_point_of_sale/core/helpers/data_logs.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/core/helpers/sync_request_helper.dart';
import 'package:kiosk_point_of_sale/data/NearPay/nearpay_api_services.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_invoice.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_items_model.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_order_model.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_paymethod_model.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/coding_pattern/coding_pattern_settings_refund_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/coding_pattern/coding_pattern_settings_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/device/shift_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/sale_type_tables/sale__tender_type_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/sales_tables/sales_items_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/sales_tables/sales_orders_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/sales_tables/sales_paymethods_table.dart';

abstract class SalesOrdersRepository {
  Future<List<SalesInvoice>> getAllOrdersFromDataBaseByShiftAndDate(
      {bool forScreen = false});
  Future<List<SalesInvoice>> getAllOrdersFromDataBaseByDate(
      {bool forScreen = false});

  Future<List<SalesInvoice>> getAllOrdersFromDataBase({bool forScreen = false});
  Future<List<SalesInvoice>> getPtCashDataBase({bool forScreen = false});

  Future<List<SalesInvoice>> getAllRefundOrdersFromDataBase();

  Future<void> saveSalesOrder(SalesInvoice invoice, {required String? orderNo});

  Future<void> updateSalesOrder(SalesInvoice invoice);

  Future<void> saveOrderPayMethods(SalesInvoice invoice);

  Future<void> updateOrderPayMethods(SalesInvoice invoice);

  Future<void> saveSalesOrderItems(SalesInvoice invoice);

  Future<void> updateSalesOrderItems(SalesInvoice invoice);

  Future<SalesPayMethodModel> generateCashPayMethod(
      int? salesPayMethodId, SalesOrderModel salesOrder, double cashTotal);

  Future<SalesPayMethodModel> generateNearByPayMethod(
      int? salesPayMethodId, SalesOrderModel salesOrder, double nearpayTotal);

  Future<List<SalesInvoice>> searchOrdersByReceiptNumber(String receiptNumber);
  Future<List<SalesInvoice>> searchOrdersByReceiptNumberAndDate(
      String receiptNumber);
  Future<List<SalesInvoice>> searchOrdersByReceiptNumberAndShiftAndDate(
      String receiptNumber);
}

class SalesOrdersRepositoryImpl implements SalesOrdersRepository {
  @override
  Future<SalesInvoice> saveSalesOrder(SalesInvoice invoice,
      {required String? orderNo}) async {
    try {
      int? orderId;
      orderId = await SalesOrderTable.insert(invoice.salesOrderModel,
          orderNo: orderNo);
      invoice.salesOrderModel.id = orderId;
      dPrint("invoice.salesOrderModel.id is ${invoice.salesOrderModel.id}");
      await saveSalesOrderItems(invoice);
      await saveOrderPayMethods(invoice);
      return invoice;
    } catch (e, t) {
      dPrint("Error inSave SalesItems $e $t");
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> updateSalesOrder(SalesInvoice invoice) async {
    await SalesOrderTable.insertAndUpdateIfExist(invoice.salesOrderModel);
    await updateSalesOrderItems(invoice);
    await saveOrderPayMethods(invoice);
  }

  @override
  Future<void> saveSalesOrderItems(SalesInvoice invoice) async {
    for (var item in invoice.salesOrderItems) {
      item.invoiceId = invoice.salesOrderModel.id.toString();
      dPrint("saveSalesOrderItems ${item.invoiceId}");
      try {
        final insertedId = await SalesItemsTable.insert(item);
        item.id = insertedId;
      } catch (e, t) {
        throw Exception("saveSalesOrderItems Error $e $t");
        dPrint('Sales Items Error: $e');
        dPrint('Sales Items Trace: $t');
      }
    }
    await printAllSalesOrders();
  }

  @override
  Future<void> updateSalesOrderItems(SalesInvoice invoice) async {
    for (var item in invoice.salesOrderItems) {
      item.isRefund = 1;
      try {
        await SalesItemsTable.insertAndUpdateIfExist(item);
      } catch (e, t) {
        dPrint('Sales Items Error: $e');
        dPrint('Sales Items Trace: $t');
      }
    }
    await printAllSalesOrders();
  }

  @override
  Future<void> saveOrderPayMethods(SalesInvoice invoice) async {
    // Group payments by method and sum their amounts
    for (var item in invoice.salesOrderPayMethods) {
      item.orderId = invoice.salesOrderModel.id.toString();
      try {
        await SalesPayMethodTable.insert(item);
      } catch (e, t) {
        dPrint('Sales PayMethods Error: $e');
        dPrint('Sales PayMethods Trace: $t');
      }
    }
    // await pintAllSalesOrderPayMethods();
  }

  @override
  Future<void> updateOrderPayMethods(SalesInvoice invoice) async {
    // Group payments by method and sum their amounts
    for (var item in invoice.salesOrderPayMethods) {
      try {
        await SalesPayMethodTable.insertAndUpdateIfExist(item);
      } catch (e, t) {
        dPrint('Sales PayMethods Error: $e');
        dPrint('Sales PayMethods Trace: $t');
      }
    }
  }

  @override
  Future<SalesPayMethodModel> generateCashPayMethod(int? salesPayMethodId,
      SalesOrderModel salesOrder, double cashTotal) async {
    final saleType = await SaleTenderTypeTable.getSalesItemByName('cash');
    final String tenant = await AppPreferences().getTenant();

    SalesPayMethodModel payMethodModel = SalesPayMethodModel(
      id: salesPayMethodId,
      orderId: salesOrder.id.toString(),
      nameEn: 'Cash',
      nameAr: 'نقد',
      amount: cashTotal,
      tenantId: tenant,
      tenderTypeId: saleType!.tenderTypeId,
      uniqueId: uuid.v4(),
    );
    return payMethodModel;
  }

  @override
  Future<SalesPayMethodModel> generateNearByPayMethod(int? salesPayMethodId,
      SalesOrderModel salesOrder, double nearpayTotal) async {
    final saleType = await SaleTenderTypeTable.getSalesItemByName('NearPay');
    final String tenant = await AppPreferences().getTenant();

    SalesPayMethodModel payMethodModel = SalesPayMethodModel(
      id: salesPayMethodId,
      orderId: salesOrder.id.toString(),
      nameEn: 'NearPay',
      nameAr: 'نيرباي',
      amount: nearpayTotal,
      tenantId: tenant,
      tenderTypeId: saleType!.tenderTypeId,
      uniqueId: uuid.v4(),
    );
    return payMethodModel;
  }

  @override
  Future<List<SalesInvoice>> getAllOrdersFromDataBase(
      {bool forScreen = false}) async {
    try {
      List<SalesOrderModel> salesOrdersDB = await SalesOrderTable.getAll();
      List<SalesItemsModel> salesItemsDB = await SalesItemsTable.getAll();
      List<SalesPayMethodModel> payMethodsDB =
          await SalesPayMethodTable.getAll();

      List<SalesInvoice> salesInvoices = [];
      for (var order in salesOrdersDB) {
        List<SalesItemsModel> orderItems = [];
        List<SalesPayMethodModel> orderPayMethods = [];
        for (var item in salesItemsDB) {
          if (item.invoiceId == order.id.toString()) {
            orderItems.add(item);
          }
        }
        for (var method in payMethodsDB) {
          if (method.orderId == order.id.toString()) {
            orderPayMethods.add(method);
          }
        }
        SalesInvoice salesInvoice = SalesInvoice(
          salesOrderModel: order,
          salesOrderItems: orderItems,
          salesOrderPayMethods: orderPayMethods,
        );
        salesInvoices.add(salesInvoice);
      }
      salesInvoices.sort(
          (a, b) => b.salesOrderModel.id!.compareTo(a.salesOrderModel.id!));
      if (!forScreen) {
        final allInvoices =
            salesInvoices.where((e) => e.salesOrderItems.isNotEmpty).toList();
        return allInvoices;
      } else {
        return salesInvoices;
      }

      @override
      Future<List<SalesInvoice>> searchOrdersByReceiptNumber(
          String receiptNumber) async {
        try {
          List<SalesOrderModel> salesOrdersDB =
              await SalesOrderTable.searchByReceiptNumber(receiptNumber);
          List<SalesItemsModel> salesItemsDB = await SalesItemsTable.getAll();
          List<SalesPayMethodModel> payMethodsDB =
              await SalesPayMethodTable.getAll();

          List<SalesInvoice> salesInvoices = [];
          for (var order in salesOrdersDB) {
            List<SalesItemsModel> orderItems = [];
            List<SalesPayMethodModel> orderPayMethods = [];
            for (var item in salesItemsDB) {
              if (item.invoiceId == order.id.toString()) {
                orderItems.add(item);
              }
            }
            for (var method in payMethodsDB) {
              if (method.orderId == order.id.toString()) {
                orderPayMethods.add(method);
              }
            }
            SalesInvoice salesInvoice = SalesInvoice(
              salesOrderModel: order,
              salesOrderItems: orderItems,
              salesOrderPayMethods: orderPayMethods,
            );
            salesInvoices.add(salesInvoice);
          }
          salesInvoices.sort(
              (a, b) => b.salesOrderModel.id!.compareTo(a.salesOrderModel.id!));
          return salesInvoices;
        } catch (e, t) {
          dPrint(e.toString());
          dPrint(t.toString());
        }
        return [];
      }
    } catch (e, t) {
      dPrint(e.toString());
      dPrint(t.toString());
    }
    return [];
  }

  @override
  Future<List<SalesInvoice>> getPtCashDataBase({bool forScreen = false}) async {
    try {
      List<SalesOrderModel> salesOrdersDB = await SalesOrderTable.getAll();
      List<SalesItemsModel> salesItemsDB = await SalesItemsTable.getAll();
      List<SalesPayMethodModel> payMethodsDB =
          await SalesPayMethodTable.getAll();

      List<SalesInvoice> salesInvoices = [];
      for (var order in salesOrdersDB) {
        List<SalesItemsModel> orderItems = [];
        List<SalesPayMethodModel> orderPayMethods = [];
        for (var item in salesItemsDB) {
          if (item.invoiceId == order.id.toString()) {
            orderItems.add(item);
          }
        }
        for (var method in payMethodsDB) {
          if (method.orderId == order.id.toString()) {
            orderPayMethods.add(method);
          }
        }
        SalesInvoice salesInvoice = SalesInvoice(
          salesOrderModel: order,
          salesOrderItems: orderItems,
          salesOrderPayMethods: orderPayMethods,
        );
        salesInvoices.add(salesInvoice);
      }
      salesInvoices.sort(
          (a, b) => b.salesOrderModel.id!.compareTo(a.salesOrderModel.id!));

      return salesInvoices;
    } catch (e, t) {
      dPrint(e.toString());
      dPrint(t.toString());
    }
    return [];
  }

  @override
  Future<List<SalesInvoice>> getAllOrdersFromDataBaseByShiftAndDate(
      {bool forScreen = false}) async {
    try {
      List<SalesOrderModel> salesOrdersDB = await SalesOrderTable.getAll();
      List<SalesItemsModel> salesItemsDB = await SalesItemsTable.getAll();
      List<SalesPayMethodModel> payMethodsDB =
          await SalesPayMethodTable.getAll();

      List<SalesInvoice> salesInvoices = [];
      for (var order in salesOrdersDB) {
        List<SalesItemsModel> orderItems = [];
        List<SalesPayMethodModel> orderPayMethods = [];
        for (var item in salesItemsDB) {
          if (item.invoiceId == order.id.toString()) {
            orderItems.add(item);
          }
        }
        for (var method in payMethodsDB) {
          if (method.orderId == order.id.toString()) {
            orderPayMethods.add(method);
          }
        }
        SalesInvoice salesInvoice = SalesInvoice(
          salesOrderModel: order,
          salesOrderItems: orderItems,
          salesOrderPayMethods: orderPayMethods,
        );
        salesInvoices.add(salesInvoice);
      }
      salesInvoices.sort(
          (a, b) => b.salesOrderModel.id!.compareTo(a.salesOrderModel.id!));
      final allInvoices =
          salesInvoices.where((e) => e.salesOrderItems.isNotEmpty).toList();
      String createdAt = DateTime.now().toIso8601String();
      final workDate = await SyncRequestHelper().getBusinessDay(createdAt);
      String date = workDate?.toIso8601String().split('T').first ??
          DateTime.now().toIso8601String().split('T').first;

      final cashierShifts = await CashierShiftTable.getAll();
      final shift = cashierShifts.first;
      final invoices = allInvoices.where((e) {
        dPrint(
            " date is ($date) workDate is  (${e.salesOrderModel.workDate})  ${e.salesOrderModel.workDate == date}");
        return e.salesOrderModel.workDate == date &&
            shift.cashierShiftId == e.salesOrderModel.cashierShiftId;
      }).toList();
      dPrint("invoices: ${allInvoices.map((e) => e.salesOrderModel.toMap())}");
      return invoices;
    } catch (e, t) {
      dPrint(e.toString());
      dPrint(t.toString());
    }
    return [];
  }

  @override
  Future<List<SalesInvoice>> getAllOrdersFromDataBaseByDate(
      {bool forScreen = false}) async {
    try {
      List<SalesOrderModel> salesOrdersDB = await SalesOrderTable.getAll();
      List<SalesItemsModel> salesItemsDB = await SalesItemsTable.getAll();
      List<SalesPayMethodModel> payMethodsDB =
          await SalesPayMethodTable.getAll();

      List<SalesInvoice> salesInvoices = [];
      for (var order in salesOrdersDB) {
        List<SalesItemsModel> orderItems = [];
        List<SalesPayMethodModel> orderPayMethods = [];
        for (var item in salesItemsDB) {
          if (item.invoiceId == order.id.toString()) {
            orderItems.add(item);
          }
        }
        for (var method in payMethodsDB) {
          if (method.orderId == order.id.toString()) {
            orderPayMethods.add(method);
          }
        }
        SalesInvoice salesInvoice = SalesInvoice(
          salesOrderModel: order,
          salesOrderItems: orderItems,
          salesOrderPayMethods: orderPayMethods,
        );
        salesInvoices.add(salesInvoice);
      }
      salesInvoices.sort(
          (a, b) => b.salesOrderModel.id!.compareTo(a.salesOrderModel.id!));
      final allInvoices =
          salesInvoices.where((e) => e.salesOrderItems.isNotEmpty).toList();
      String createdAt = DateTime.now().toIso8601String();
      final workDate = await SyncRequestHelper().getBusinessDay(createdAt);
      String date = workDate?.toIso8601String().split('T').first ??
          DateTime.now().toIso8601String().split('T').first;
      dPrint("date: $date");
      final invoices = allInvoices.where((e) {
        return e.salesOrderModel.workDate == date;
      }).toList();
      return invoices;
    } catch (e, t) {
      dPrint(e.toString());
      dPrint(t.toString());
    }
    return [];
  }

  @override
  Future<List<SalesInvoice>> getAllRefundOrdersFromDataBase() async {
    List<SalesOrderModel> salesOrdersDB = await SalesOrderTable.getAllRefunds();
    List<SalesItemsModel> salesItemsDB = await SalesItemsTable.getAllRefunds();
    List<SalesPayMethodModel> payMethodsDB = await SalesPayMethodTable.getAll();

    List<SalesInvoice> salesInvoices = [];
    for (var order in salesOrdersDB) {
      List<SalesItemsModel> orderItems = [];
      List<SalesPayMethodModel> orderPayMethods = [];
      for (var item in salesItemsDB) {
        if (item.invoiceId == order.id.toString()) {
          orderItems.add(item);
        }
      }
      for (var method in payMethodsDB) {
        if (method.orderId == order.id.toString()) {
          orderPayMethods.add(method);
        }
      }
      SalesInvoice salesInvoice = SalesInvoice(
        salesOrderModel: order,
        salesOrderItems: orderItems,
        salesOrderPayMethods: orderPayMethods,
      );
      salesInvoices.add(salesInvoice);
    }
    salesInvoices
        .sort((a, b) => b.salesOrderModel.id!.compareTo(a.salesOrderModel.id!));

    return salesInvoices;
  }

  @override
  Future<List<SalesInvoice>> searchOrdersByReceiptNumber(
      String receiptNumber) async {
    try {
      List<SalesOrderModel> salesOrdersDB =
          await SalesOrderTable.searchByReceiptNumber(receiptNumber);
      List<SalesItemsModel> salesItemsDB = await SalesItemsTable.getAll();
      List<SalesPayMethodModel> payMethodsDB =
          await SalesPayMethodTable.getAll();

      List<SalesInvoice> salesInvoices = [];
      for (var order in salesOrdersDB) {
        List<SalesItemsModel> orderItems = [];
        List<SalesPayMethodModel> orderPayMethods = [];
        for (var item in salesItemsDB) {
          if (item.invoiceId == order.id.toString()) {
            orderItems.add(item);
          }
        }
        for (var method in payMethodsDB) {
          if (method.orderId == order.id.toString()) {
            orderPayMethods.add(method);
          }
        }
        SalesInvoice salesInvoice = SalesInvoice(
          salesOrderModel: order,
          salesOrderItems: orderItems,
          salesOrderPayMethods: orderPayMethods,
        );
        salesInvoices.add(salesInvoice);
      }
      salesInvoices.sort(
          (a, b) => b.salesOrderModel.id!.compareTo(a.salesOrderModel.id!));
      return salesInvoices;
    } catch (e, t) {
      dPrint(e.toString());
      dPrint(t.toString());
    }
    return [];
  }

  @override
  Future<List<SalesInvoice>> searchOrdersByReceiptNumberAndDate(
      String receiptNumber) async {
    try {
      List<SalesOrderModel> salesOrdersDB =
          await SalesOrderTable.searchByReceiptNumber(receiptNumber);
      List<SalesItemsModel> salesItemsDB = await SalesItemsTable.getAll();
      List<SalesPayMethodModel> payMethodsDB =
          await SalesPayMethodTable.getAll();

      List<SalesInvoice> salesInvoices = [];
      for (var order in salesOrdersDB) {
        List<SalesItemsModel> orderItems = [];
        List<SalesPayMethodModel> orderPayMethods = [];
        for (var item in salesItemsDB) {
          if (item.invoiceId == order.id.toString()) {
            orderItems.add(item);
          }
        }
        for (var method in payMethodsDB) {
          if (method.orderId == order.id.toString()) {
            orderPayMethods.add(method);
          }
        }
        SalesInvoice salesInvoice = SalesInvoice(
          salesOrderModel: order,
          salesOrderItems: orderItems,
          salesOrderPayMethods: orderPayMethods,
        );
        salesInvoices.add(salesInvoice);
      }
      salesInvoices.sort(
          (a, b) => b.salesOrderModel.id!.compareTo(a.salesOrderModel.id!));
      // Filter by today's date
      String createdAt = DateTime.now().toIso8601String();
      final workDate = await SyncRequestHelper().getBusinessDay(createdAt);
      String date = workDate?.toIso8601String().split('T').first ??
          DateTime.now().toIso8601String().split('T').first;
      final invoices = salesInvoices
          .where((e) => e.salesOrderModel.workDate == date)
          .toList();
      return invoices;
    } catch (e, t) {
      dPrint(e.toString());
      dPrint(t.toString());
    }
    return [];
  }

  @override
  Future<List<SalesInvoice>> searchOrdersByReceiptNumberAndShiftAndDate(
      String receiptNumber) async {
    try {
      List<SalesOrderModel> salesOrdersDB =
          await SalesOrderTable.searchByReceiptNumber(receiptNumber);
      List<SalesItemsModel> salesItemsDB = await SalesItemsTable.getAll();
      List<SalesPayMethodModel> payMethodsDB =
          await SalesPayMethodTable.getAll();

      List<SalesInvoice> salesInvoices = [];
      for (var order in salesOrdersDB) {
        List<SalesItemsModel> orderItems = [];
        List<SalesPayMethodModel> orderPayMethods = [];
        for (var item in salesItemsDB) {
          if (item.invoiceId == order.id.toString()) {
            orderItems.add(item);
          }
        }
        for (var method in payMethodsDB) {
          if (method.orderId == order.id.toString()) {
            orderPayMethods.add(method);
          }
        }
        SalesInvoice salesInvoice = SalesInvoice(
          salesOrderModel: order,
          salesOrderItems: orderItems,
          salesOrderPayMethods: orderPayMethods,
        );
        salesInvoices.add(salesInvoice);
      }
      salesInvoices.sort(
          (a, b) => b.salesOrderModel.id!.compareTo(a.salesOrderModel.id!));
      // Filter by today's date and shift
      String createdAt = DateTime.now().toIso8601String();
      final workDate = await SyncRequestHelper().getBusinessDay(createdAt);
      String date = workDate?.toIso8601String().split('T').first ??
          DateTime.now().toIso8601String().split('T').first;
      final cashierShifts = await CashierShiftTable.getAll();
      final shift = cashierShifts.first;
      final invoices = salesInvoices
          .where((e) =>
              e.salesOrderModel.workDate == date &&
              shift.cashierShiftId == e.salesOrderModel.cashierShiftId)
          .toList();
      return invoices;
    } catch (e, t) {
      dPrint(e.toString());
      dPrint(t.toString());
    }
    return [];
  }
}

String receiptIDNormal(int storeId) {
  int now = DateTime.now().millisecondsSinceEpoch;
  int random = Random().nextInt(10000); // Add randomness
  int hash = (now + storeId * 100000 + random) % 100000000;
  return hash.toString().padLeft(8, '0');
}

Future<String> receiptID() async {
  final storeId = await AppPreferences().getStore();
  final codingPatternSettings = await CodingPatternSettingsTable.getById(1);
  if (codingPatternSettings == null) {
    return receiptIDNormal(int.parse(storeId));
  }
  final startNum = codingPatternSettings.startValue;
  final incrementNumber = codingPatternSettings.incrementValue;
  final prefix = codingPatternSettings.prefix;
  final suffix = codingPatternSettings.suffix;
  // Extract numeric value from lastGeneratedValue without prefix/suffix
  final extractedLastNumber = codingPatternSettings.lastGeneratedValue;
  int currentNumber = await AppPreferences().getCurrentInvoice();
  if (currentNumber == 0) {
    // If we have a previously generated code, continue from it; otherwise start fresh
    currentNumber = extractedLastNumber >= startNum
        ? extractedLastNumber + incrementNumber
        : startNum;
  } else {
    currentNumber += incrementNumber;
  }
  await AppPreferences().setCurrentInvoice(currentNumber);
  return '$prefix${currentNumber.toString()}$suffix';
}

Future<String> receiptIDRefund() async {
  final storeId = await AppPreferences().getStore();

  final codingPatternSettings =
      await CodingPatternSettingsRefundTable.getById(1);
  if (codingPatternSettings == null) {
    return receiptIDNormal(int.parse(storeId));
  }
  final startNum = codingPatternSettings.startValue;
  final incrementNumber = codingPatternSettings.incrementValue;
  final prefix = codingPatternSettings.prefix;
  final suffix = codingPatternSettings.suffix;
  // Extract numeric value from lastGeneratedValue without prefix/suffix
  final extractedLastNumber = codingPatternSettings.lastGeneratedValue;
  int currentNumber = await AppPreferences().getCurrentInvoiceRefund();
  if (currentNumber == 0) {
    // If we have a previously generated code, continue from it; otherwise start fresh
    currentNumber = extractedLastNumber >= startNum
        ? extractedLastNumber + incrementNumber
        : startNum;
  } else {
    currentNumber += incrementNumber;
  }
  await AppPreferences().setCurrentInvoiceRefund(currentNumber);
  return '$prefix${currentNumber.toString()}$suffix';
}

int _extractNumberFromCode(String code, String prefix, String suffix) {
  var core = code;
  if (prefix.isNotEmpty && core.startsWith(prefix)) {
    core = core.substring(prefix.length);
  }
  if (suffix.isNotEmpty && core.endsWith(suffix)) {
    core = core.substring(0, core.length - suffix.length);
  }
  final match = RegExp(r"\d+").firstMatch(core);
  if (match != null) {
    return int.tryParse(match.group(0) ?? '') ?? 0;
  }
  return int.tryParse(core) ?? 0;
}
