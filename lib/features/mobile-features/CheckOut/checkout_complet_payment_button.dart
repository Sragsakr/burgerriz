// ignore_for_file: unused_element, use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/custom_snackbar_widget.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_theme.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_widgets.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/internationalization.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';
import 'package:kiosk_point_of_sale/core/helpers/clear_cart_with_prices.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/core/services/printing_services/drago/drago_printer_controller.dart';
import 'package:kiosk_point_of_sale/core/services/printing_services/network_printing/network_printer_controller.dart';
import 'package:kiosk_point_of_sale/core/services/printing_services/optimized_printer_controller.dart';
import 'package:kiosk_point_of_sale/core/services/loading_services/enhanced_loading_service.dart';
import 'package:kiosk_point_of_sale/data/NearPay/nearpay_api_services.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_invoice.dart';
import 'package:kiosk_point_of_sale/data/models/store/device_info_model.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/device/device_info_table.dart';
import 'package:kiosk_point_of_sale/data/services/remote_data/service_locator.dart';
import 'package:kiosk_point_of_sale/features/shared-features/payment/final_invoice_builder.dart';
import 'package:kiosk_point_of_sale/providers/cart_provider.dart';
import 'package:kiosk_point_of_sale/providers/nearpay_provider.dart';
import 'package:kiosk_point_of_sale/providers/order_summary_provider.dart';
import 'package:kiosk_point_of_sale/providers/payment_breakdown_provider.dart';
import 'package:kiosk_point_of_sale/repository/promotions/promotions_services.dart';
import 'package:kiosk_point_of_sale/repository/sales_orders_repository.dart';

final promotionsServices = PromotionsServices.instance;

class CheckoutCompletePaymentButton extends ConsumerStatefulWidget {
  const CheckoutCompletePaymentButton({super.key});

  @override
  CheckoutCompletePaymentButtonState createState() => CheckoutCompletePaymentButtonState();
}

class CheckoutCompletePaymentButtonState extends ConsumerState<CheckoutCompletePaymentButton> {
  @override
  Widget build(BuildContext context) {
    ref.watch(cartProvider);
    ref.watch(paymentBreakdownProvider);
    final orderSummaryAsync = ref.watch(orderSummaryProvider);

    bool isPaymentSufficient(double totalPaid, double totalAmount, double discountAmount) {
      return totalPaid >= (totalAmount - discountAmount).roundToTwoDecimals();
    }

    void completePayment(WidgetRef ref, BuildContext context) async {
      try {
        final zatcaApiService = ref.watch(zatcaApiServiceProvider);
        final feedbackService = ref.watch(feedbackApiServiceProvider);
        String userMobile = ref.watch(invoicePhoneProvider);
        String selectedMode = await AppPreferences().getPrinterMode();

        // Show enhanced loading with progress tracking
        enhancedLoadingService.showEnhancedLoading(
          context,
          message: translator(arText: "جاري معالجة الطلب", enText: "Processing Order"),
          isLottie: userMobile.isEmpty,
        );

        // Generate invoice once and reuse
        SalesInvoice? finalInvoice;
        List<int>? printingData;

        // Use the enhanced loading service to process invoice printing
        await enhancedLoadingService.processPrinting(
          operationType: translator(arText: "فاتورة", enText: "Invoice"),
          generateInvoice: () async {
            finalInvoice = await generateFinalInvoice(
                selectedMode, ref, context, userMobile);
            return finalInvoice!;
          },
          generatePdf: userMobile.isEmpty
              ? () async {
                  // Use optimized PDF generation
                  printingData = await OptimizedPrinterController.getOptimizedInvoicePdfByMode(
                    invoice: finalInvoice!,
                  );
                  return printingData!;
                }
              : null,
          saveOrder: () async {
            return await SalesOrdersRepositoryImpl()
                .saveSalesOrder(finalInvoice!, orderNo: '');
          },
          sendInvoice: userMobile.isNotEmpty
              ? () async {
                  await zatcaApiService.sendInvoiceToPhone(finalInvoice!);
                  feedbackService.sendFeedbackRequest(phoneNumber: userMobile);
                }
              : null,
          printInvoice: userMobile.isEmpty
              ? () async {
                  if (selectedMode == 'network') {
                    await NetworkPrinterController.printInvoice(
                        data: printingData!, withSnac: false);
                  } else {
                    await DragoPrinterController.printInvoiceData(
                        data: printingData!, withSnac: false);
                  }
                }
              : null,
        );

        // Navigate to sale type page
        context.go('/sale_type-page');
        resetPaymentAndCartValues(ref);
      } catch (e, t) {
        dPrint("Exception: $e");
        dPrint("StackTrace: $t");
        enhancedLoadingService.hideLoading();
        customSnackbar(context, e.toString(), false);
        dPrint(e.toString());
        dPrint(t.toString());
      }
    }

    Future<void> handleNearpayPayment(
        BuildContext context, WidgetRef ref, double nearpayTotal) async {

      DeviceConfigModel? appConfig = await DeviceConfigTable.getDeviceInfo();
      if (appConfig == null) {
        throw Exception('No app config found in the database');
      }

      if (appConfig.terminalId == null) {
        ref.read(nearpayPaymentDoneProvider.notifier).state = true;
      } else {
        await handleNearpayTransaction(
          transactionId: uuid.v4(),
          terminalID: appConfig.terminalId!,
          amount: (nearpayTotal * 100).toInt(),
          context: context,
          ref: ref,
        );
      }
    }

    return FFButtonWidget(
      showLoadingIndicator: true,
      onPressed: () async {
        dPrint("=== BUTTON PRESSED START ===");
        FocusScope.of(context).unfocus();
        dPrint("Focus unfocused");

        dPrint("Checking payment sufficiency...");
        double totalPaid = orderSummaryAsync.when(
          data: (data) => data.totalPaid,
          error: (e, t) => 0.0,
          loading: () => 0.0,
        );
        double totalAmount = orderSummaryAsync.when(
          data: (data) => data.totalAmount,
          error: (e, t) => 0.0,
          loading: () => 0.0,
        );
        double discountAmount = orderSummaryAsync.when(
          data: (data) => data.discountAmount,
          error: (e, t) => 0.0,
          loading: () => 0.0,
        );

        dPrint(
            "Payment values - totalPaid: $totalPaid, totalAmount: $totalAmount, discountAmount: $discountAmount");
        bool isSufficient = isPaymentSufficient(totalPaid, totalAmount, discountAmount);
        dPrint("Payment sufficient: $isSufficient");

        if (!isSufficient) {
          dPrint("Payment insufficient - showing error");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      FFLocalizations.of(context).getText('7tizifaj'),
                    ),
                  ),
                ],
              ),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.red,
            ),
          );
          print('More money needed!');
          return;
        }
        dPrint("Payment sufficiency check passed");

        dPrint("Processing payment methods...");
        final paymentTotals = ref.watch(paymentBreakdownProvider.notifier).paymentTotals;
        dPrint("Payment totals: $paymentTotals");
        dPrint("Payment totals entries count: ${paymentTotals.entries.length}");

        for (var entry in paymentTotals.entries) {
          double totalAmount = (entry.value["total"] as num).toDouble();
          String enName = entry.value["enName"] as String;
          String arName = entry.value["arName"] as String;

          dPrint(
              "Processing payment - tenderId: ${entry.key}, totalAmount: $totalAmount, enName: $enName, arName: $arName");

          bool isnNeaPay =
              (enName.toLowerCase() == "nearpay") || (arName.toLowerCase() == "نيرباي");
          dPrint("Is NearPay: $isnNeaPay");

          if (isnNeaPay && totalAmount > 0) {
            dPrint("Processing NearPay payment: $totalAmount");
            await handleNearpayPayment(context, ref, totalAmount);
          } else if (isnNeaPay && totalAmount == 0) {
            dPrint("NearPay amount is 0, setting done to true");
            ref.read(nearpayPaymentDoneProvider.notifier).state = true;
          } else {
            dPrint("Not NearPay payment, setting done to true");
            ref.read(nearpayPaymentDoneProvider.notifier).state = true;
          }
        }

        dPrint("Checking if NearPay payment is done...");
        if (ref.read(nearpayPaymentDoneProvider.notifier).state == true) {
          dPrint("NearPay payment done, calling completePayment");
          completePayment(ref, context);
        } else {
          dPrint("NearPay payment not done yet");
        }
        dPrint("=== BUTTON PRESSED END ===");
      },
      text: FFLocalizations.of(context).getText('n5r1ls2y'),
      options: FFButtonOptions(
        width: MediaQuery.sizeOf(context).width,
        height: 56,
        padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
        color: const Color(0xFFAF2A26),
        textStyle: FlutterFlowTheme.of(context).titleMedium.override(
              fontFamily: 'Inter Tight',
              color: FlutterFlowTheme.of(context).info,
              letterSpacing: 0.0,
              fontSize: MediaQuery.sizeOf(context).width * 0.06,
            ),
        elevation: 3,
        borderRadius: BorderRadius.circular(28),
      ),
    );
  }
}
