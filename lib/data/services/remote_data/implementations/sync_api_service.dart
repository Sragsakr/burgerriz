import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/custom_snackbar_widget.dart';
import 'package:kiosk_point_of_sale/core/constants/app_urls.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/core/helpers/sync_request_helper.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_invoice.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_order_model.dart';
import 'package:kiosk_point_of_sale/data/models/zatca_invoice_model.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/sales_tables/sales_orders_table.dart';
import 'package:kiosk_point_of_sale/data/services/remote_data/implementations/zatca_api_service.dart';
import 'package:kiosk_point_of_sale/data/services/remote_data/service_locator.dart';
import 'package:kiosk_point_of_sale/main.dart';
import 'package:kiosk_point_of_sale/repository/sales_orders_repository.dart';

import '../interfaces/sync_api_interface.dart';
import 'base_api_service.dart';

bool sync = kDebugMode ? true : true;

class SyncApiService extends BaseApiService implements SyncApiInterface {
  late String _baseUrl;

  SyncApiService()
      : super(
          baseUrl: '', // Will be set in initialize()
          defaultHeaders: {'Content-Type': 'application/json'},
        );

  @override
  Future<void> initialize() async {
    _baseUrl = await AppUrls.getBaseUrl();
    await super.initialize();
  }

  @override
  Future<Response?> sendTransactions(WidgetRef ref) async {
    if (!sync) return null;
    try {
      final token = await AppPreferences().getAccessToken();
      final tenantId = await AppPreferences().getTenant();

      if (token.isEmpty) {
        return null;
      }

      dio.options.headers.addAll({
        'abp.tenantid': tenantId,
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      final record = await SyncRequestHelper.generateTransactionBodyData();
      List<Map<String, dynamic>> data = record.$1;

      if (data.isEmpty) return null;
      dPrint(data.toString());

      List<SalesOrderModel> salesOrders = record.$2;
      List<String> transactionsIds =
          salesOrders.map((e) => e.id.toString()).toList();
      dPrint(transactionsIds);

      final response = await post<Map<String, dynamic>>(
        _baseUrl + AppUrls.syncOrdersUrl,
        data: json.encode(data),
      );

      if (response.statusCode == 200) {
        log('Response Data: ${response.data}');
        log(response.data.toString());

        for (var order in salesOrders) {
          order.isBackOfficeSync = 1;
          await SalesOrderTable.update(salesOrder: order, id: order.id!);
        }
        return response;
      } else {
        final msg = response.data!['Data']['error']['message'];
        customSnackbar(navKey.currentState!.context, msg, false);
        throw Exception(
            'Failed to send transactions. Status Code: ${response.statusCode}');
      }
    } on DioException catch (e, t) {
      log('Error: $e');
      log('Stack Trace: $t');
      throw Exception('Unexpected error occurred: $e ,$t');
    }
  }

  @override
  Future<Response?> sendRefundsTransactions(WidgetRef ref) async {
    if (!sync) return null;
    try {
      final token = await AppPreferences().getAccessToken();
      final tenantId = await AppPreferences().getTenant();

      if (token.isEmpty) {
        return null;
      }

      dio.options.headers.addAll({
        'abp.tenantid': tenantId,
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      final record =
          await SyncRequestHelper.generateRefundTransactionBodyData();
      List<Map<String, dynamic>> data = record.$1;
      // dPrint(data.toString());
      if (data.isEmpty) return null;
      dPrint(data.toString());

      List<SalesOrderModel> salesOrders = record.$2;
      List<String> transactionsIds =
          salesOrders.map((e) => e.id.toString()).toList();
      dPrint(transactionsIds);

      final response = await post<Map<String, dynamic>>(
        _baseUrl + AppUrls.syncOrdersUrl,
        data: json.encode(data),
      );

      if (response.statusCode == 200) {
        log('Response Data: ${response.data}');
        log(response.data.toString());

        for (var order in salesOrders) {
          order.isBackOfficeSync = 1;
          await SalesOrderTable.update(salesOrder: order, id: order.id!);
        }
        return response;
      } else {
        final msg = response.data!['Data']['error']['message'];
        customSnackbar(navKey.currentState!.context, msg, false);
        throw Exception(
            'Failed to send transactions. Status Code: ${response.statusCode}');
      }
    } on DioException catch (e, t) {
      log('Error: $e');
      log('Stack Trace: $t');
      throw Exception('Unexpected error occurred: $e ,$t');
    }
  }

  @override
  Future<Response?> sendRefundNotifications(WidgetRef ref) async {
    if (!sync) return null;

    try {
      final token = await AppPreferences().getAccessToken();
      final tenantId = await AppPreferences().getTenant();

      if (token.isEmpty) {
        return null;
      }

      dio.options.headers.addAll({
        'abp.tenantid': tenantId,
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      final record = await SyncRequestHelper.generateNotificationBodyData();
      List<Map<String, dynamic>> data = record.$1;

      if (data.isEmpty) return null;

      List<SalesOrderModel> salesOrders = record.$2;
      List<String> transactionsIds =
          salesOrders.map((e) => e.id.toString()).toList();
      dPrint(transactionsIds);

      final response = await post<Map<String, dynamic>>(
        _baseUrl + AppUrls.syncRefundOrdersUrl,
        data: json.encode(data),
      );

      if (response.statusCode == 200) {
        log('Response Data: ${response.data}');
        log(response.data.toString());

        for (var order in salesOrders) {
          order.isBackOfficeSync = 1;
          await SalesOrderTable.update(salesOrder: order, id: order.id!);
        }
        return response;
      } else {
        final msg = response.data!['Data']['error']['message'];
        customSnackbar(navKey.currentState!.context, msg, false);
        throw Exception(
            'Failed to send transactions. Status Code: ${response.statusCode}');
      }
    } on DioException catch (e, t) {
      log('Error: $e');
      log('Stack Trace: $t');
      throw Exception('Unexpected error occurred: $e ,$t');
    }
  }

  @override
  Future<void> sendOrdersToZacta(WidgetRef ref) async {
    if (!sync) return;

    List<SalesInvoice> invoices =
        await SalesOrdersRepositoryImpl().getAllOrdersFromDataBase();
    final zatcaApiService = ref.watch(zatcaApiServiceProvider);

    for (var invoice in invoices) {
      if (invoice.salesOrderModel.isZactaSync == 0 &&
          invoice.salesOrderModel.isRefund == 0) {
        try {
          ZatcaInvoiceModel? zatcaInvoiceModel =
              await zatcaApiService.sendInvoice(invoice);
          // save invoice
        } catch (e, t) {
          dPrint(e.toString());
          dPrint(t.toString());
          return;
        }
      }
    }
  }

  @override
  Future<void> sendRefundOrdersToZacta(WidgetRef ref) async {
    if (!sync) return;

    List<SalesInvoice> invoices =
        await SalesOrdersRepositoryImpl().getAllOrdersFromDataBase();
    final zatcaApiService = ref.watch(zatcaApiServiceProvider);
    for (var invoice in invoices) {
      if (invoice.salesOrderModel.isRefund == 0) continue;
      if (invoice.salesOrderModel.isZactaSync == 1) continue;
      if (invoice.salesOrderModel.isRefund == 1 &&
          invoice.salesOrderModel.invoiceId == null) {
        continue;
      }
      try {
        await zatcaApiService.sendReturnInvoice(invoice);
      } catch (e, t) {
        dPrint(e.toString());
        dPrint(t.toString());
        return;
      }
    }
  }

  // Standalone methods that don't require WidgetRef
  Future<Response?> sendTransactionsStandalone() async {
    if (!sync) return null;
    try {
      final token = await AppPreferences().getAccessToken();
      final tenantId = await AppPreferences().getTenant();

      if (token.isEmpty) {
        return null;
      }

      dio.options.headers.addAll({
        'abp.tenantid': tenantId,
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      final record = await SyncRequestHelper.generateTransactionBodyData();
      List<Map<String, dynamic>> data = record.$1;

      if (data.isEmpty) return null;
      dPrint(data.toString());

      List<SalesOrderModel> salesOrders = record.$2;
      List<String> transactionsIds =
          salesOrders.map((e) => e.id.toString()).toList();
      // dPrint(transactionsIds);

      final response = await post<Map<String, dynamic>>(
        _baseUrl + AppUrls.syncOrdersUrl,
        data: json.encode(data),
      );

      if (response.statusCode == 200) {
        log('Response Data: ${response.data}');
        log(response.data.toString());

        for (var order in salesOrders) {
          order.isBackOfficeSync = 1;
          await SalesOrderTable.update(salesOrder: order, id: order.id!);
        }
        return response;
      } else {
        final msg = response.data!['Data']['error']['message'];
        log('Error: $msg');
        throw Exception(
            'Failed to send transactions. Status Code: ${response.statusCode}');
      }
    } on DioException catch (e, t) {
      log('Error: $e');
      log('Stack Trace: $t');
      throw Exception('Unexpected error occurred: $e ,$t');
    }
  }

  Future<Response?> sendRefundsTransactionsStandalone() async {
    if (!sync) return null;
    try {
      final token = await AppPreferences().getAccessToken();
      final tenantId = await AppPreferences().getTenant();

      if (token.isEmpty) {
        return null;
      }

      dio.options.headers.addAll({
        'abp.tenantid': tenantId,
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      final record =
          await SyncRequestHelper.generateRefundTransactionBodyData();
      List<Map<String, dynamic>> data = record.$1;
      // dPrint(data.toString());
      if (data.isEmpty) return null;
      dPrint(data.toString());

      List<SalesOrderModel> salesOrders = record.$2;
      List<String> transactionsIds =
          salesOrders.map((e) => e.id.toString()).toList();
      dPrint(transactionsIds);

      final response = await post<Map<String, dynamic>>(
        _baseUrl + AppUrls.syncOrdersUrl,
        data: json.encode(data),
      );

      if (response.statusCode == 200) {
        log('Response Data: ${response.data}');
        log(response.data.toString());

        for (var order in salesOrders) {
          order.isBackOfficeSync = 1;
          await SalesOrderTable.update(salesOrder: order, id: order.id!);
        }
        return response;
      } else {
        final msg = response.data!['Data']['error']['message'];
        log('Error: $msg');
        throw Exception(
            'Failed to send transactions. Status Code: ${response.statusCode}');
      }
    } on DioException catch (e, t) {
      log('Error: $e');
      log('Stack Trace: $t');
      throw Exception('Unexpected error occurred: $e ,$t');
    }
  }

  Future<Response?> sendRefundNotificationsStandalone() async {
    if (!sync) return null;

    try {
      final token = await AppPreferences().getAccessToken();
      final tenantId = await AppPreferences().getTenant();

      if (token.isEmpty) {
        return null;
      }

      dio.options.headers.addAll({
        'abp.tenantid': tenantId,
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      final record = await SyncRequestHelper.generateNotificationBodyData();
      List<Map<String, dynamic>> data = record.$1;

      if (data.isEmpty) return null;

      List<SalesOrderModel> salesOrders = record.$2;
      List<String> transactionsIds =
          salesOrders.map((e) => e.id.toString()).toList();
      dPrint(transactionsIds);

      final response = await post<Map<String, dynamic>>(
        _baseUrl + AppUrls.syncRefundOrdersUrl,
        data: json.encode(data),
      );

      if (response.statusCode == 200) {
        log('Response Data: ${response.data}');
        log(response.data.toString());

        for (var order in salesOrders) {
          order.isBackOfficeSync = 1;
          await SalesOrderTable.update(salesOrder: order, id: order.id!);
        }
        return response;
      } else {
        final msg = response.data!['Data']['error']['message'];
        log('Error: $msg');
        throw Exception(
            'Failed to send transactions. Status Code: ${response.statusCode}');
      }
    } on DioException catch (e, t) {
      log('Error: $e');
      log('Stack Trace: $t');
      throw Exception('Unexpected error occurred: $e ,$t');
    }
  }

  Future<void> sendOrdersToZactaStandalone() async {
    if (!sync) return;

    List<SalesInvoice> invoices =
        await SalesOrdersRepositoryImpl().getAllOrdersFromDataBase();

    // Create a new ZatcaApiService instance for standalone use
    final zatcaApiService = ZatcaApiService();
    await zatcaApiService.initialize();

    for (var invoice in invoices) {
      if (invoice.salesOrderModel.isZactaSync == 0 &&
          invoice.salesOrderModel.isRefund == 0) {
        try {
          ZatcaInvoiceModel? zatcaInvoiceModel =
              await zatcaApiService.sendInvoice(invoice);
          // save invoice
        } catch (e, t) {
          dPrint(e.toString());
          dPrint(t.toString());
          return;
        }
      }
    }
  }

  Future<void> sendRefundOrdersToZactaStandalone() async {
    if (!sync) return;

    List<SalesInvoice> invoices =
        await SalesOrdersRepositoryImpl().getAllOrdersFromDataBase();

    // Create a new ZatcaApiService instance for standalone use
    final zatcaApiService = ZatcaApiService();
    await zatcaApiService.initialize();

    for (var invoice in invoices) {
      if (invoice.salesOrderModel.isRefund == 0) continue;
      if (invoice.salesOrderModel.isZactaSync == 1) continue;
      try {
        ZatcaInvoiceModel? zatcaInvoiceModel =
            await zatcaApiService.sendInvoice(invoice);
        // save invoice
      } catch (e, t) {
        dPrint(e.toString());
        dPrint(t.toString());
        return;
      }
    }
  }
}
