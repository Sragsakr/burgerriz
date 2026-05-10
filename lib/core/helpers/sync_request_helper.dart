import 'dart:convert';
import 'dart:developer';

import 'package:kiosk_point_of_sale/core/enums/transaction_status_enum.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_items_model.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_order_model.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_paymethod_model.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/currency/currency_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/device/device_info_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/device/shift_table.dart';
import 'package:kiosk_point_of_sale/repository/sales_orders_repository.dart';

class SyncRequestHelper {
  static Future<(List<Map<String, dynamic>>, List<SalesOrderModel>)>
      generateTransactionBodyData() async {
    List<Map<String, dynamic>> body = [];
    List<SalesOrderModel> salesOrders = [];
    final records =
        await SalesOrdersRepositoryImpl().getAllOrdersFromDataBase();

    for (var record in records) {
      // dPrint(record.salesOrderModel.toMap().toString());
      if (record.salesOrderModel.isBackOfficeSync == 1) continue;
      final bool isRefund = record.salesOrderModel.isRefund == 1;
      if (isRefund) continue;
      SalesOrderModel salesOrder = record.salesOrderModel;
      List<SalesItemsModel> salesItems = record.salesOrderItems;
      List<SalesPayMethodModel> salesPayments = record.salesOrderPayMethods;

      final cashierId = await AppPreferences().getCashierId();
      final cashierShifts = await CashierShiftTable.getAll();
      final qtyType = await AppPreferences().getQuantityType();

      final currency = await CurrencyTable.getSarCurrency();
      // dPrint("currency is ${currency?.name} ${currency?.currencyId} ");
      final shift = cashierShifts.first;
      final deviceInfo = await DeviceConfigTable.getDeviceInfo();
      String ext = "1";
      final preRecipe =
          "${deviceInfo?.storeCode ?? ''}-${deviceInfo?.deviceNumber ?? ''}$ext-";
      final oldRec = salesOrder.receiptNumber;
      dPrint("oldRec is $oldRec");
      final recieptNumber = preRecipe + (salesOrder.receiptNumber ?? '');
      final refRecieptNumber = (salesOrder.refReceiptNumber != null &&
              salesOrder.refReceiptNumber?.length != 0)
          ? (preRecipe + (salesOrder.refReceiptNumber ?? ''))
          : null;
      final oneTransactionBody = {
        "Id": salesOrder.uuid,
        "SaleId": salesOrder.uuid,
        "RecieptNumber": salesOrder.saleTypeId == -1 ? null : recieptNumber,
        "RefRecieptNumber":
            salesOrder.saleTypeId == -1 ? null : refRecieptNumber,
        "CustomerId": salesOrder.customerId,
        "RefSaleTransactionId": salesOrder.refSaleTransactionModelId,
        "CashierId": cashierId,
        "CashierShiftId": shift.cashierShiftId,
        "SubTotal": salesOrder.subTotal,
        "VAT": salesOrder.tax,
        "Total": salesOrder.totalAmount,
        "status": TransactionStatus.paidOrder.value,
        "Notes": salesOrder.note,
        "SaleTypeId":
            salesOrder.saleTypeId == -1 ? null : salesOrder.saleTypeId,
        "Date": salesOrder.createdAt.toString(),
        "TerminalId": null,
        "Discount": salesOrder.discount,
        "DiscountValue": salesOrder.discountValue,
        "DiscountType": salesOrder.discountType,
        "promotionCode": salesOrder.promotionCode,
        "promotionType": salesOrder.promotionType,
        "promotionValue": salesOrder.promotionValue,
        "promotionAmount": salesOrder.promotionAmount,
        "PromotionId": salesOrder.promotionId,
        "HappyHourId": null,
        "TemplateType": 1,
        "AdditionalAllowns": 0,
        "SaleDetails": salesItems
            .map((d) => d.toMapWithUniqueId(salesOrder.uuid, qtyType))
            .toList(),
        "SalepaymentTransactions": salesPayments
            .map((p) =>
                p.toMapWithUniqueId(salesOrder.uuid, currency?.currencyId ?? 1))
            .toList(),
        "SaleTransactionsDiningTables": [],
      };
      // dPrint(jsonEncode(oneTransactionBody).toString());
      body.add(oneTransactionBody);
      salesOrders.add(salesOrder);
    }

    // Encode the list of transaction objects as a JSON string
    return (body, salesOrders);
  }

  static Future<(List<Map<String, dynamic>>, List<SalesOrderModel>)>
      generateRefundTransactionBodyData() async {
    List<Map<String, dynamic>> body = [];
    List<SalesOrderModel> salesOrders = [];
    final allInvoices = await SalesOrdersRepositoryImpl()
        .getAllOrdersFromDataBase(forScreen: true);
    final records =
        allInvoices.where((e) => e.salesOrderItems.isEmpty).toList();
    for (var record in records) {
      // dPrint(record.salesOrderModel.toMap().toString());
      if (record.salesOrderModel.isBackOfficeSync == 1) continue;
      SalesOrderModel salesOrder = record.salesOrderModel;
      List<SalesItemsModel> salesItems = record.salesOrderItems;
      List<SalesPayMethodModel> salesPayments = record.salesOrderPayMethods;
      final qtyType = await AppPreferences().getQuantityType();

      final currency = await CurrencyTable.getSarCurrency();
      dPrint("currency is ${currency?.name} ${currency?.currencyId} ");
      final deviceInfo = await DeviceConfigTable.getDeviceInfo();
      String ext = "1";

      final preRecipe =
          "${deviceInfo?.storeCode ?? ''}-${deviceInfo?.deviceNumber ?? ''}$ext-";
      final recieptNumber = preRecipe + (salesOrder.receiptNumber ?? '');
      final refRecieptNumber = (salesOrder.refReceiptNumber != null &&
              salesOrder.refReceiptNumber?.length != 0)
          ? (preRecipe + (salesOrder.refReceiptNumber ?? ''))
          : null;
      final oneTransactionBody = {
        "Id": salesOrder.uuid,
        "SaleId": salesOrder.uuid,
        "RecieptNumber": salesOrder.saleTypeId == -1 ? null : recieptNumber,
        "RefRecieptNumber":
            salesOrder.saleTypeId == -1 ? null : refRecieptNumber,
        "CustomerId": salesOrder.customerId,
        "RefSaleTransactionId": salesOrder.refSaleTransactionModelId,
        "CashierId": salesOrder.userId,
        "CashierShiftId": salesOrder.cashierShiftId,
        "SubTotal": salesOrder.subTotal,
        "VAT": salesOrder.tax,
        "Total": salesOrder.totalAmount,
        "status": TransactionStatus.paidOrder.value,
        "Notes": salesOrder.note,
        "SaleTypeId":
            salesOrder.saleTypeId == -1 ? null : salesOrder.saleTypeId,
        "Date": salesOrder.createdAt.toString(),
        "TerminalId": null,
        "Discount": salesOrder.discount,
        "DiscountValue": salesOrder.discountValue,
        "DiscountType": salesOrder.discountType,
        "promotionCode": salesOrder.promotionCode,
        "promotionType": salesOrder.promotionType,
        "promotionValue": salesOrder.promotionValue,
        "promotionAmount": salesOrder.promotionAmount,
        "PromotionId": salesOrder.promotionId,
        "HappyHourId": null,
        "TemplateType": 1,
        "AdditionalAllowns": 0,
        "SaleDetails": salesItems
            .map((d) => d.toMapWithUniqueId(salesOrder.uuid, qtyType))
            .toList(),
        "SalepaymentTransactions": salesPayments
            .map((p) =>
                p.toMapWithUniqueId(salesOrder.uuid, currency?.currencyId ?? 1))
            .toList(),
        "SaleTransactionsDiningTables": [],
      };
      dPrint(jsonEncode(oneTransactionBody).toString());
      body.add(oneTransactionBody);
      salesOrders.add(salesOrder);
    }

    // Encode the list of transaction objects as a JSON string
    return (body, salesOrders);
  }

  static Future<(List<Map<String, dynamic>>, List<SalesOrderModel>)>
      generateNotificationBodyData() async {
    List<Map<String, dynamic>> body = [];
    List<SalesOrderModel> salesOrders = [];
    final records =
        await SalesOrdersRepositoryImpl().getAllRefundOrdersFromDataBase();

    for (var record in records) {
      if (record.salesOrderModel.isBackOfficeSync == 1) continue;

      SalesOrderModel salesOrder = record.salesOrderModel;
      List<SalesItemsModel> salesItems = record.salesOrderItems;
      List<SalesPayMethodModel> salesPayments = record.salesOrderPayMethods;
      final deviceInfo = await DeviceConfigTable.getDeviceInfo();
      final qtyType = await AppPreferences().getQuantityType();

      final currency = await CurrencyTable.getSarCurrency();

      final preRecipe =
          "${deviceInfo?.storeCode ?? ''}-${deviceInfo?.deviceNumber ?? ''}2-";
      final recieptNumber = preRecipe + (salesOrder.receiptNumber ?? '');
      final refRecieptNumber = (salesOrder.refReceiptNumber != null &&
              salesOrder.refReceiptNumber?.length != 0)
          ? (preRecipe + (salesOrder.refReceiptNumber ?? ''))
          : "";
      final oneTransactionBody = {
        "Id": salesOrder.uuid,
        "RecieptNumber": salesOrder.saleTypeId == -1 ? null : recieptNumber,
        "RefRecieptNumber":
            salesOrder.saleTypeId == -1 ? null : refRecieptNumber,
        "CustomerId": salesOrder.customerId,
        "RefSaleTransactionId": salesOrder.refSaleTransactionModelId,
        "CashierId": salesOrder.userId,
        "CashierShiftId": salesOrder.cashierShiftId,
        "SubTotal": salesOrder.subTotal,
        "VAT": salesOrder.tax,
        "Total": salesOrder.totalAmount,
        "status": TransactionStatus.returned.value,
        "TenantId": salesOrder.tenantId,
        "Notes": salesOrder.note,
        "SaleTypeId":
            salesOrder.saleTypeId == -1 ? null : salesOrder.saleTypeId,
        "Date": salesOrder.createdAt.toString(),
        "TerminalId": null,
        "Discount": salesOrder.discount,
        "DiscountValue": salesOrder.discountValue,
        "DiscountType": salesOrder.discountType,
        "promotionCode": salesOrder.promotionCode,
        "promotionType": salesOrder.promotionType,
        "promotionValue": salesOrder.promotionValue,
        "promotionAmount": salesOrder.promotionAmount,
        "PromotionId": salesOrder.promotionId,
        "HappyHourId": null,
        "TemplateType": 1,
        "IsPrinted": true,
        "AdditionalAllowns": 0,
        "SaleNotificationDetails": salesItems
            .map((d) => d.toMapNotificationWithUniqueId(
                salesOrder.uuid, salesOrder.refundResonId ?? "", qtyType))
            .toList(),
        "SalePaymentNotifications": salesPayments
            .map((p) => p.toMapWithUniqueIdForRefund(
                salesOrder.uuid, currency?.currencyId ?? 1))
            .toList(),
      };
      log(jsonEncode(oneTransactionBody));
      body.add(oneTransactionBody);
      salesOrders.add(salesOrder);
    }
    // dPrint("generateRefundTransactionNotificationBodyData2"+ body.toString());
    // Encode the list of transaction objects as a JSON string
    return (body, salesOrders);
  }

  Future<DateTime?> getBusinessDay(String? orderCreateAt) async {
    final cashierShifts = await CashierShiftTable.getAll();
    if (cashierShifts.isEmpty) return null;

    final shift = cashierShifts.first;
    if (!shift.isActiveEndOfDay ||
        shift.startOfDayDate == null ||
        shift.endOfDayDate == null) {
      return null;
    }

    // تحويل التواريخ إلى DateTime مع التأكد من عدم وجود أخطاء
    DateTime? orderDateTime;
    try {
      orderDateTime = orderCreateAt != null
          ? DateTime.parse(orderCreateAt).toLocal()
          : null;
    } catch (e) {
      return null; // في حالة حدوث خطأ عند تحويل التاريخ، نعيد null
    }
    // DateTime startOfBusinessDay =
    //     DateTime.parse("2025-03-06T17:01:00Z").toLocal();
    // DateTime endOfBusinessDay =
    //     DateTime.parse("2025-03-07T16:59:00Z").toLocal();
    DateTime startOfBusinessDay =
        DateTime.parse(shift.startOfDayDate!).toLocal();
    DateTime endOfBusinessDay = DateTime.parse(shift.endOfDayDate!).toLocal();

    if (orderDateTime == null) return null;

    if (orderDateTime.isBefore(startOfBusinessDay)) {
      // الطلب قبل بداية اليوم → تابع لليوم السابق
      return startOfBusinessDay.subtract(const Duration(days: 1));
    }
    // else if (orderDateTime.isAfter(endOfBusinessDay)) {
    //   // الطلب بعد نهاية اليوم → تابع لليوم الجديد
    //   return endOfBusinessDay.add(const Duration(days: 1));
    // }
    else {
      // الطلب ضمن اليوم الحالي
      return startOfBusinessDay;
    }
  }
}
