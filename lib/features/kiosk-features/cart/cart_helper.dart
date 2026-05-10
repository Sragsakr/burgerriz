import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/custom_choice_chips.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/custom_snackbar_widget.dart';
import 'package:kiosk_point_of_sale/core/extentions/app_extentions.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';
import 'package:kiosk_point_of_sale/core/helpers/clear_cart_with_prices.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/core/services/printing_services/kiosk_printing/thermal_printer_service.dart';
import 'package:kiosk_point_of_sale/core/services/loading_services/enhanced_loading_service.dart';
import 'package:kiosk_point_of_sale/data/NearPay/nearpay_api_services.dart';
import 'package:kiosk_point_of_sale/data/models/sale_types/sale_tender_type_model.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_invoice.dart';
import 'package:kiosk_point_of_sale/data/models/store/device_info_model.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/device/device_info_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/sale_type_tables/sale__tender_type_table.dart';
import 'package:kiosk_point_of_sale/data/services/remote_data/service_locator.dart';
import 'package:kiosk_point_of_sale/main.dart';
import 'package:kiosk_point_of_sale/providers/nearpay_provider.dart';
import 'package:kiosk_point_of_sale/providers/payment_breakdown_provider.dart';
import 'package:kiosk_point_of_sale/repository/sales_orders_repository.dart';
import 'package:kiosk_point_of_sale/features/shared-features/payment/final_invoice_builder.dart'
    show generateFinalInvoice;
import 'package:kiosk_point_of_sale/features/shared-features/payment/checkout_payment_method.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/entry_widget/entry_widget.dart';

class CartHelper {
  Future<SalesInvoice> saveFinalOrder(SalesInvoice invoice) async {
    final receiptNumber = await receiptID();
    invoice.salesOrderModel.receiptNumber = receiptNumber;
    final finalInvoice = await SalesOrdersRepositoryImpl().saveSalesOrder(invoice, orderNo: '');
    return finalInvoice;

    //  resetPaymentAndCartValues(ref);
  }

  Future<SalesInvoice> generateTempOrder(WidgetRef ref, BuildContext context) async {
    String userMobile = ref.watch(invoicePhoneProvider);
    String selectedMode = await AppPreferences().getPrinterMode();
    SalesInvoice finalInvoice = await generateFinalInvoice(selectedMode, ref, context, userMobile, temp: true);
    return finalInvoice;

    //  resetPaymentAndCartValues(ref);
  }

  Future<void> completePayment(
    WidgetRef ref,
    BuildContext context,
    SalesInvoice? finalInvoice,
  ) async {
    try {
      final zatcaApiService = ref.watch(zatcaApiServiceProvider);
      final feedbackService = ref.watch(feedbackApiServiceProvider);
      String userMobile = ref.watch(invoicePhoneProvider);

      // Show enhanced loading with progress tracking
      enhancedLoadingService.showEnhancedLoading(
        context,
        message: translator(arText: "جاري معالجة الطلب", enText: "Processing Order"),
        isLottie: userMobile.isEmpty,
      );

      // Generate invoice once and reuse

      List<Uint8List> frames = [];

      // Use the enhanced loading service to process invoice printing
      await enhancedLoadingService.processPrinting(
        operationType: translator(arText: "فاتورة", enText: "Invoice"),
        generatePdf: userMobile.isEmpty
            ? () async {
                // final pdfBytes1 =
                //     await OptimizedPdfService.generateOptimizedPdf(
                //         finalInvoice!);
                // log("1 generatePdf frames length: ${pdfBytes1.length}");
                final logoAsset = ref.read(reportGroupThemeProvider).logoAsset;
                frames = await ThermalPrinterService.buildInvoicePdf(
                  finalInvoice!,
                  logoAsset,
                );

                return frames;
              }
            : null,
        sendInvoice: userMobile.isNotEmpty
            ? () async {
                await zatcaApiService.sendInvoiceToPhone(finalInvoice!);
                feedbackService.sendFeedbackRequest(phoneNumber: userMobile);
              }
            : null,
        printInvoice: userMobile.isEmpty
            ? () async {
                log("2 printInvoice frames length: ${frames.length}");
                await ThermalPrinterService.printInvoiceFinal(
                  frames: frames,
                );
                // if (selectedMode == 'network' || kDebugMode) {
                //   await NetworkPrinterController.printInvoice(
                //       data: printingData!, withSnac: false);
                // } else {
                //   await DragoPrinterController.printInvoiceData(
                //       data: printingData!, withSnac: false);
                // }
              }
            : null,
      );

      resetPaymentAndCartValues(ref);

      navKey.currentState!.context.pushReplacementNamed(EntryWidget.routeName);
    } catch (e, t) {
      dPrint("Exception: $e");
      dPrint("StackTrace: $t");

      enhancedLoadingService.hideLoading();
      customSnackbar(navKey.currentState!.context, e.toString() + t.toString(), false);
      dPrint(e.toString());
      dPrint(t.toString());
    }
  }

  Future<void> handleNearpayPayment(
    BuildContext context,
    WidgetRef ref,
    double nearpayTotal,
    String transactionId,
  ) async {
    print('Processing Nearpay: $nearpayTotal');
    DeviceConfigModel? appConfig = await DeviceConfigTable.getDeviceInfo();
    if (appConfig == null) {
      throw Exception('No app config found in the database');
    }

    if (appConfig.terminalId == null || kDebugMode || nearpayTotal == 0
        // || isTesting
        ) {
      ref.read(nearpayPaymentDoneProvider.notifier).state = true;
    } else {
      await handleNearpayTransaction(
        transactionId: transactionId,
        terminalID: appConfig.terminalId!,
        amount: (nearpayTotal * 100).toInt(),
        context: context,
        ref: ref,
      );
    }
  }

  /// NEAR PAY PAYMENT METHOD
  Future<void> setNearPayPaymentMethod(WidgetRef ref, double amount) async {
    ref.read(availablePaymentMethodsProvider.notifier).state = [];
    final tenderTypes = await SaleTenderTypeTable.getAll();

    // Convert SaleTenderTypeModel to PaymentChoiceData dynamically
    List<PaymentChoiceData> methods = tenderTypes
        .where((tender) => tender.isDeleted == 0 && tender.languageId == 1) // Only active methods
        .where((tender) =>
            tender.name.toLowerCase() == 'nearpay' ||
            tender.name.toLowerCase() == 'mada') // Filter NearPay if no terminal
        .map((tender) {
      return PaymentChoiceData(
        tenderId: tender.tenderTypeId,
        enName: _getEnglishName(tender.tenderTypeId, tenderTypes),
        arName: _getEnglishName(tender.tenderTypeId, tenderTypes),
        icon: Icons.payment,
        // paymentMethod: tender.name, // Directly storing as a string
      );
    }).toList();

    // Update state
    ref.read(availablePaymentMethodsProvider.notifier).state = methods;

    ref.read(paymentBreakdownProvider.notifier).addPayment(methods[0], amount, methods[0].tenderId);
  }

  /// CLICK & GET PAYMENT METHOD — no terminal interaction
  Future<void> setClickAndGetPaymentMethod(WidgetRef ref, double amount) async {
    ref.read(availablePaymentMethodsProvider.notifier).state = [];
    final tenderTypes = await SaleTenderTypeTable.getAll();
    dPrint("tenderTypes: ${tenderTypes.map((tender) => tender.name ).toList()}");
   
    // Lookup the "Click & Get" tender type (normalized comparison)
    final clickGetTenders = tenderTypes.where((tender) {
      if (tender.isDeleted != 0 || tender.languageId != 1) return false;
      final normalizedName = tender.name.toLowerCase().replaceAll('&', 'and').trim();
      return normalizedName == 'cash' || normalizedName == 'nakit' || normalizedName == 'كاش';
    }).toList();

    if (clickGetTenders.isEmpty) {
      throw Exception(
        'Click & Get tender type not found. '
        'Please ensure a "Click & Get" tender type is configured and synced.',
      );
    }

    final tender = clickGetTenders.first;

    final method = PaymentChoiceData(
      tenderId: tender.tenderTypeId,
      enName: _getEnglishName(tender.tenderTypeId, tenderTypes),
      arName: _getArabicName(tender.tenderTypeId, tenderTypes),
      icon: Icons.payments_outlined,
    );

    // Update state
    ref.read(availablePaymentMethodsProvider.notifier).state = [method];

    ref.read(paymentBreakdownProvider.notifier).addPayment(method, amount, method.tenderId);
  }

  /// Fetch available payment methods dynamically
  Future<void> _fetchPaymentMethod(WidgetRef ref) async {
    final tenderTypes = await SaleTenderTypeTable.getAll();

    // Convert SaleTenderTypeModel to PaymentChoiceData dynamically
    List<PaymentChoiceData> methods = tenderTypes
        .where((tender) => tender.isDeleted == 0 && tender.languageId == 1) // Only active methods
        .where((tender) => tender.name.toLowerCase() == 'nearpay') // Filter NearPay if no terminal
        .map((tender) {
      return PaymentChoiceData(
        tenderId: tender.tenderTypeId,
        enName: _getEnglishName(tender.tenderTypeId, tenderTypes),
        arName: _getArabicName(tender.tenderTypeId, tenderTypes),
        icon: Icons.payment,
        // paymentMethod: tender.name, // Directly storing as a string
      );
    }).toList();

    // Update state
    ref.read(availablePaymentMethodsProvider.notifier).state = methods;
  }

  /// Map English payment method names to Arabic equivalents
  String _getArabicName(int tenderTypeId, List<SaleTenderTypeModel> tenderTypes) {
    final tenderType = tenderTypes
        .firstWhere((tender) => tender.tenderTypeId == tenderTypeId && tender.isDeleted == 0 && tender.languageId == 2);
    return tenderType.name;
  }

  String _getEnglishName(int tenderTypeId, List<SaleTenderTypeModel> tenderTypes) {
    final tenderType = tenderTypes
        .firstWhere((tender) => tender.tenderTypeId == tenderTypeId && tender.isDeleted == 0 && tender.languageId == 1);
    return tenderType.name;
  }
}
