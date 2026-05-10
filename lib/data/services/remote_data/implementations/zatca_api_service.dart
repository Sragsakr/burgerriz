import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:kiosk_point_of_sale/core/constants/app_urls.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/core/helpers/zatca_qr_helper.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_invoice.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/zatca_requests.dart';
import 'package:kiosk_point_of_sale/data/models/zatca_invoice_model.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/device/device_info_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/sales_tables/sales_orders_table.dart';
import 'package:kiosk_point_of_sale/providers/payment_breakdown_provider.dart';
import 'package:kiosk_point_of_sale/repository/sales_orders_repository.dart';

import '../interfaces/zatca_api_interface.dart';
import 'base_api_service.dart';

class ZatcaApiService extends BaseApiService implements ZatcaApiInterface {
  late String _baseUrl;

  ZatcaApiService()
      : super(
          baseUrl: '', // Will be set in initialize()
          defaultHeaders: {
            'Content-Type': 'application/json',
            'X-VS-Key': "bEJRPHo\$HSDeimd5ss4nm@!!tkNMQFg85!4oE9MdSYGdTsYT44MK7c@4smoMBXy",
          },
        );

  @override
  Future<void> initialize() async {
    _baseUrl = await AppUrls.getBaseUrl();
    await super.initialize();
  }

  @override
  Future<void> sendInvoiceToPhone(SalesInvoice invoice) async {
    final deviceInfo = await DeviceConfigTable.getDeviceInfo();
    if (deviceInfo == null) return;
    final headers = {
      'X-Account-ID': deviceInfo.zigsAccountId ?? '',
      'X-Auth-Key': deviceInfo.zigsAuthKey ?? '',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final payload = await _generatePayload(invoice);

    try {
      final response = await dio.request(
        'https://zigs.menaplatform.com/invoicing/generate-invoice/',
        options: Options(method: 'POST', headers: headers),
        data: json.encode(payload),
      );

      if (response.statusCode == 200) {
        log("✅ Invoice sent successfully: ${json.encode(response.data)}");
      } else {
        log("❌ Failed to send invoice: ${response.statusMessage}");
      }
    } catch (e) {
      log("❌ Error sending invoice: $e");
    }
  }

  @override
  Future<ZatcaInvoiceModel?> sendInvoice(SalesInvoice invoice) async {
    final deviceInfo = await DeviceConfigTable.getDeviceInfo();
    if (deviceInfo == null) return null;
    if (deviceInfo.tenantIdZatca == null || deviceInfo.passwordZatca == null || deviceInfo.usernameZatca == null) {
      return null;
    }

    final token = await getToken();
    final url = await AppUrls.getZactaSendInvoiceUrl();
    dio.options.headers['abp.tenantid'] = deviceInfo.tenantIdZatca;
    dio.options.headers['Authorization'] = 'Bearer $token';

    final requestBody = _generateZatcaRequest(invoice);
    log("sssssssss$requestBody");

    try {
      final response = await post<Map<String, dynamic>>(
        url,
        data: requestBody,
      );

      if (response.statusCode == 200 && response.data!['success'] == true) {
        final ZatcaInvoiceModel zatcaModel = ZatcaInvoiceModel.fromJson(response.data!['result']);
        await _updateInvoiceStatus(invoice, zatcaModel);
        return zatcaModel;
      } else {
        throw Exception("Failed to send invoice: ${response.data!["error"]}");
      }
    } on DioException catch (e) {
      throw Exception("Failed to send invoice: ${e.response?.data ?? e.message}");
    }
  }

  @override
  Future<String?> sendReturnInvoice(SalesInvoice invoice) async {
    final deviceInfo = await DeviceConfigTable.getDeviceInfo();
    if (deviceInfo == null) return null;
    if (deviceInfo.tenantIdZatca == null || deviceInfo.passwordZatca == null || deviceInfo.usernameZatca == null) {
      return null;
    }

    final token = await getToken();
    dio.options.headers['abp.tenantid'] = deviceInfo.tenantIdZatca;
    dio.options.headers['Authorization'] = 'Bearer $token';

    final requestBody = _generateZatcaRequest(invoice, refund: true);

    try {
      final response = await post<Map<String, dynamic>>(
        AppUrls.zatcaSendInvoiceUrl,
        data: requestBody,
      );

      if (response.statusCode == 200 && response.data!['success'] == true) {
        final String? returnedFromTransactionId = response.data!['result']['id'];
        if (returnedFromTransactionId != null) {
          await _updateReturnInvoiceStatus(invoice, returnedFromTransactionId);
          return returnedFromTransactionId;
        }
      }
      throw Exception("Failed to send return invoice: ${response.data!["error"]}");
    } on DioException catch (e) {
      throw Exception("Failed to send return invoice: ${e.response?.data ?? e.message}");
    }
  }

  @override
  Future<String> getToken() async {
    final deviceInfo = await DeviceConfigTable.getDeviceInfo();
    if (deviceInfo == null) return "";
    if (deviceInfo.tenantIdZatca == null || deviceInfo.passwordZatca == null || deviceInfo.usernameZatca == null) {
      return "";
    }

    dio.options.headers['abp.tenantid'] = deviceInfo.tenantIdZatca;

    // Check if token exists and is valid
    final cachedToken = await AppPreferences().getZatcaToken();
    final expiryTimestamp = await AppPreferences().getZatcaTokenExpiry();
    final url = await AppUrls.getZatcaTokenUrl();
    if (cachedToken.isNotEmpty &&
        expiryTimestamp != 0 &&
        DateTime.now().isBefore(DateTime.fromMillisecondsSinceEpoch(expiryTimestamp))) {
      return cachedToken;
    }

    // Get new token
    final authRequest = AuthenticationRequest(
      usernameOrEmailAddress: deviceInfo.usernameZatca!,
      password: deviceInfo.passwordZatca!,
    );

    try {
      final response = await post<Map<String, dynamic>>(
        url,
        data: authRequest.toMap(),
      );

      if (response.statusCode == 200 && response.data!['success'] == true) {
        final token = response.data!['result']['accessToken'];
        final expiry = DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch;

        await AppPreferences().setZatcaToken(token);
        await AppPreferences().setZatcaTokenExpiry(expiry);

        return token;
      } else {
        throw Exception("Failed to get Zatca token: ${response.data!["error"]}");
      }
    } on DioException catch (e) {
      throw Exception("Failed to get Zatca token: ${e.response?.data ?? e.message}");
    }
  }

  Future<Map<String, dynamic>> _generatePayload(SalesInvoice invoice) async {
    final deviceInfo = await DeviceConfigTable.getDeviceInfo();
    String ext = invoice.salesOrderModel.isRefund == 1 ? "2" : "1";

    final preRecipe = "${deviceInfo?.storeCode ?? ''}-${deviceInfo?.deviceNumber ?? ''}$ext-";
    final recieptNumber = preRecipe + (invoice.salesOrderModel.receiptNumber ?? '');
    final refRecieptNumber =
        (invoice.salesOrderModel.refReceiptNumber != null && invoice.salesOrderModel.refReceiptNumber?.length != 0)
            ? (preRecipe + (invoice.salesOrderModel.refReceiptNumber ?? ''))
            : "";
    final createdAt = DateTime.parse(invoice.salesOrderModel.createdAt);
    final formattedDateTime = DateFormat("yyyy-MM-ddTHH:mm").format(createdAt);
    final totalWithVat = double.parse(invoice.salesOrderModel.totalAmount);
    final totalWithoutVat = double.parse(invoice.salesOrderModel.subTotal);
    final totalVat = double.parse(invoice.salesOrderModel.tax);

    final qrCode = buildZatcaQrCodeContent(invoice);
    // final qrCode = "";

    final map = {
      "address": deviceInfo?.address,
      "vat_number": deviceInfo?.vat,
      "invoice_type": invoice.salesOrderModel.isRefund == 1
          ? 'simplified_credit_note'
          : "simplified_tax_invoice", // or "simplified_tax_invoice" based on your needs
      "datetime": formattedDateTime,
      "invoice_number": recieptNumber,
      "qr_code": qrCode,
      "total_discount_value":
          ((invoice.salesOrderModel.discountValue ?? 0.0) + (invoice.salesOrderModel.promotionValue ?? 0.0))
                  .roundToTwoDecimals() ??
              0.0,
      "payment_method": invoice.salesOrderPayMethods
          .map((e) => {
                "title": e.nameEn,
                "amount": e.amount.toStringAsFixed(2),
              })
          .toList(),
      "phone_number": invoice.salesOrderModel.customerPhone,
      "total_price": totalWithoutVat.toStringAsFixed(2),
      "total_vat_value": totalVat.toStringAsFixed(2),
      "total_price_with_vat": totalWithVat.toStringAsFixed(2),
      "items": invoice.salesOrderItems.map((item) {
        final unitPrice = double.parse(item.price);

        final qty = double.parse(item.quantity);
        final discount = item.promotionValue ?? 0.0;
        final totalPrice = unitPrice * qty;
        dPrint("Discount: $discount");
        dPrint("Total Price: $totalPrice");
        dPrint("Total Price After Discount: ${(double.parse(item.total) * qty) - discount}");

        final variationMaps = <Map<String, dynamic>>[];
        if (item.variations != null) {
          for (final variation in item.variations!) {
            variationMaps.add({
              "variation_name_ar": variation['variationNameAr'],
              "variation_name": variation['variationNameEn'],
              "variation_price": variation['variationPrice'],
            });
          }
        }
        if (item.comboMealItems != null) {
          for (final combo in item.comboMealItems!) {
            variationMaps.add({
              "variation_name_ar": combo['comboNameAr']?.toString(),
              "variation_name": combo['comboNameEn']?.toString(),
              "variation_price": combo['price'],
            });
          }
        }

        return {
          "product_name": item.productNameEn,
          "product_name_ar": item.productNameAr,
          "product_price": item.price,
          "product_quantity": qty,
          "total_price": item.total,
          "discount_value": discount,
          "total_price_after_discount": double.parse(item.total),
          "total_with_vat": item.total,
          "vat_percentage": "15.00",
          "vat_value": item.vatBeforeDiscount,
          "free_products": item.selectedFreeProductName != null
              ? [
                  {
                    "product_name": item.selectedFreeProductName,
                    "product_name_ar": item.selectedFreeProductNameAr,
                    "product_price": item.selectedFreeProductPrice,
                    "product_quantity": item.selectedFreeProductQuantity,
                  }
                ]
              : [],
          "variations": variationMaps,
        };
      }).toList(),
    };
    print("map: $map");
    return map;
  }

  /// Generate ZATCA request body from a `SalesInvoice` instance.
  Map<String, dynamic> _generateZatcaRequest(SalesInvoice invoice, {bool refund = false}) {
    final totalAmountWithVat = double.parse(invoice.salesOrderModel.totalAmount);
    final totalAmountWithoutVat = totalAmountWithVat / 1.15;
// Total with VAT
    final totalVat = totalAmountWithVat - totalAmountWithoutVat;
    final isCash = invoice.salesOrderPayMethods.any((payMethod) => payMethod.nameEn.toLowerCase() == 'cash');
    bool havePayMethods = invoice.salesOrderPayMethods.isNotEmpty;
    int cashMethod = havePayMethods ? int.parse(invoice.salesOrderPayMethods.first.tenantId) : 1;
    // تنسيق الوقت
    final createdAt = DateTime.parse(invoice.salesOrderModel.createdAt);
    final formattedTime = DateFormat('HH:mm').format(createdAt);
    return {
      "TotalPrice": totalAmountWithoutVat,
      "TotalVatValue": totalVat,
      "TotalPriceWithVat": totalAmountWithVat,
      "IssueDate": invoice.salesOrderModel.createdAt.split('T').first,
      "IssueTime": formattedTime,
      "InvoiceType": refund ? "SimplifiedCreditNote" : "SimplifiedInvoice",
      "TemplateType": 1,
      // "paymentMethod": invoice.salesOrderPayMethods
      //     .map((e) => {
      //           "title": e.nameEn,
      //           "amount": e.amount.toStringAsFixed(2),
      //         })
      //     .toList(),
      // "PaymentMethod": cashMethod.toString(),
      "PaymentMethod": 10,
      if (refund) "ReturnedFromTransactionId": invoice.salesOrderModel.invoiceId,
      // Only for return invoices
      "Notes": refund ? " PosMena Mobile Refund for B2B Invoice" : 'PosMena Mobile Invoice',
      "ZatcaInvoiceItems": invoice.salesOrderItems.map((item) {
        //سعر المنتج بدون الضريبه

        final qty = double.parse(item.quantity);
        final discount = item.promotionValue ?? 0.0;

        return {
          "ProductName": item.productNameEn,
          "ProductPrice": item.total,
          "ProductQuantity": qty,
          "TotalPrice": item.price,
          "DiscountValue": discount, // Placeholder for discounts
          "TotalPriceAfterDiscount": double.parse(item.total) - discount,
          "VatPercentage": 15.0,
          "VatValue": item.vatBeforeDiscount,
          "TotalWithVat": item.total,
        };
      }).toList(),
    };
  }

  Future<void> _updateInvoiceStatus(SalesInvoice invoice, ZatcaInvoiceModel zatcaModel) async {
    invoice.salesOrderModel.isZactaSync = 1;
    invoice.salesOrderModel.invoiceId = zatcaModel.id;
    await SalesOrderTable.update(
      salesOrder: invoice.salesOrderModel,
      id: invoice.salesOrderModel.id!,
    );

    final invoices = await SalesOrdersRepositoryImpl().getAllOrdersFromDataBase();
    for (var childInvoice in invoices) {
      if (childInvoice.salesOrderModel.refReceiptNumber == invoice.salesOrderModel.orderNumber) {
        childInvoice.salesOrderModel.invoiceId = zatcaModel.id;
        await SalesOrderTable.update(
          salesOrder: childInvoice.salesOrderModel,
          id: childInvoice.salesOrderModel.id!,
        );
      }
    }
  }

  Future<void> _updateReturnInvoiceStatus(SalesInvoice invoice, String returnedFromTransactionId) async {
    invoice.salesOrderModel.zatcaReturnedFromTransactionId = returnedFromTransactionId;
    invoice.salesOrderModel.isRefund = 1;
    invoice.salesOrderModel.isZactaSync = 1;

    for (var item in invoice.salesOrderItems) {
      item.isRefund = 1;
    }

    await SalesOrdersRepositoryImpl().updateSalesOrder(invoice);
  }
}
