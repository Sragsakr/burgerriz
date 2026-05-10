import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiosk_point_of_sale/core/assets/app_assets.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/currency_display_widget.dart';
import 'package:kiosk_point_of_sale/core/extentions/app_extentions.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_model.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_theme.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_dialogs.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/core/helpers/responsive_helper.dart';
import 'package:kiosk_point_of_sale/data/NearPay/nearpay_api_services.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_invoice.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_paymethod_model.dart';
import 'package:kiosk_point_of_sale/providers/nearpay_provider.dart';
import 'package:kiosk_point_of_sale/providers/order_summary_provider.dart';
import 'package:kiosk_point_of_sale/providers/payment_breakdown_provider.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/cart/cart_helper.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/menu_widget/menu_widget.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/pay_widget/components/background_image_component.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/pay_widget/components/pay_header_component.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/success_payment/success_payment_widget.dart';

import '../../../core/helpers/app_language_helper.dart';
import 'pay_now_model.dart';

export 'pay_now_model.dart';

class PayNowWidget extends ConsumerStatefulWidget {
  final SalesInvoice invoice;

  const PayNowWidget(this.invoice, {super.key});

  static String routeName = 'PayNow';
  static String routePath = '/payNow';

  @override
  ConsumerState<PayNowWidget> createState() => _PayNowWidgetState();
}

class _PayNowWidgetState extends ConsumerState<PayNowWidget> {
  late PayNowModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PayNowModel());
    // NOTE: Auto-payment removed — user must tap a payment button
  }

  /// Credit Card flow (existing NearPay terminal flow)
  Future<void> payOrderSummary() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final totalAmount =
          double.parse(widget.invoice.salesOrderModel.totalAmount.toString());
      await CartHelper().handleNearpayPayment(
        context,
        ref,
        totalAmount,
        widget.invoice.salesOrderModel.uuid,
      );
      if (ref.read(nearpayPaymentDoneProvider.notifier).state == true) {
        await _completePayment(totalAmount, isCreditCard: true);
      }
    } catch (e, stackTrace) {
      dPrint("Payment error: $e stackTrace: $stackTrace");
      if (mounted && context.mounted) {
        _showPaymentErrorDialog(e.toString());
      }
    }
    if (mounted) setState(() => _isProcessing = false);
  }

  /// Click & Get flow (no terminal — record payment and go to success)
  Future<void> payWithClickAndGet() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final totalAmount =
          double.parse(widget.invoice.salesOrderModel.totalAmount.toString());
      await CartHelper().setClickAndGetPaymentMethod(ref, totalAmount);
      await _completePayment(totalAmount, isCreditCard: false);
    } catch (e, stackTrace) {
      dPrint("Click & Get payment error: $e stackTrace: $stackTrace");
      if (mounted && context.mounted) {
        _showPaymentErrorDialog(e.toString());
      }
    }
    if (mounted) setState(() => _isProcessing = false);
  }

  /// Shared completion: set payment method, save order, navigate to success
  Future<void> _completePayment(double totalAmount,
      {required bool isCreditCard}) async {
    if (isCreditCard) {
      await CartHelper().setNearPayPaymentMethod(ref, totalAmount);
    }
    List<SalesPayMethodModel> salesPayMethodsList = await setPaymentMethod();
    widget.invoice.salesOrderPayMethods = salesPayMethodsList;
    final finalInvoice = await CartHelper().saveFinalOrder(widget.invoice);
    dPrint("finalInvoice is ${finalInvoice.toJson()}");

    context.pushNamed(SuccessPaymentWidget.routeName, extra: finalInvoice);
  }

  void _showPaymentErrorDialog(String errorMessage) {
    showAppDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 30,
              ),
              SizedBox(width: 10),
              Text(
                translator(arText: 'خطأ في الدفع', enText: 'Payment Error'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                translator(
                  arText: 'حدث خطأ أثناء معالجة الدفع:',
                  enText: 'An error occurred while processing payment:',
                ),
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Text(
                translator(
                  arText: 'هل تريد المحاولة مرة أخرى؟',
                  enText: 'Would you like to try again?',
                ),
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go(MenuWidget.routePath);
              },
              child: Text(
                translator(arText: 'إلغاء', enText: 'Cancel'),
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: FlutterFlowTheme.of(context).primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text(
                translator(arText: 'حسناً', enText: 'OK'),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<List<SalesPayMethodModel>> setPaymentMethod() async {
    final paymentTotals =
        ref.watch(paymentBreakdownProvider.notifier).paymentTotals;
    final salesPayMethodsList = <SalesPayMethodModel>[];
    final String tenant = await AppPreferences().getTenant();

    for (var entry in paymentTotals.entries) {
      int tenderId = entry.key;
      double totalAmount = (entry.value["total"] as num).toDouble();

      if (totalAmount > 0) {
        final payMethodModel = SalesPayMethodModel(
          id: null,
          orderId: '',
          nameEn: entry.value["enName"],
          nameAr: entry.value["arName"],
          amount: totalAmount,
          tenantId: tenant,
          tenderTypeId: tenderId,
          uniqueId: uuid.v4(),
        );
        salesPayMethodsList.add(payMethodModel);
      }
    }
    return salesPayMethodsList;
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderSummaryAsync = ref.watch(orderSummaryProvider);
    final totalAmount =
        double.parse(widget.invoice.salesOrderModel.totalAmount.toString());

    return orderSummaryAsync.when(
      skipLoadingOnReload: true,
      data: (orderSummary) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).primaryText,
            body: _buildScreenContent(context, orderSummary, totalAmount),
          ),
        );
      },
      loading: () => GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: FlutterFlowTheme.of(context).primaryText,
          body: _buildScreenContent(context, null, totalAmount),
        ),
      ),
      error: (error, stack) {
        dPrint("Stack Trace: $stack");
        return Center(child: Text('Error: $error'));
      },
    );
  }

  Widget _buildScreenContent(
      BuildContext context, dynamic orderSummary, double totalAmount) {
    return SafeArea(
      top: true,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Color(0xFFf4ebdc),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: BackgroundImageComponent(
                child: Column(
                  children: [
                    // Header Section — back button + store logo
                    Container(
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.only(top: 20, bottom: 5.h),
                        child: PayHeaderComponent(),
                      ),
                    ),

                    // Content section — title, total, buttons
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(height: 5.h),
                          // Title
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 32.0),
                            child: Text(
                              translator(
                                arText: 'كيف تريد أن تدفع طلبك؟',
                                enText: 'HOW WOULD YOU LIKE TO PAY YOUR ORDER?',
                              ),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize:
                                    ResponsiveHelper.getResponsiveFontSize(
                                        context, 24.0),
                                fontWeight: FontWeight.bold,
                                color: FlutterFlowTheme.of(context).primaryText,
                              ),
                            ),
                          ),

                          SizedBox(
                              height: ResponsiveHelper.getResponsiveSize(
                                  context, 12.0)),

                          // "Your order total" subtitle
                          Text(
                            translator(
                              arText: 'إجمالي طلبك',
                              enText: 'Your order total',
                            ),
                            style: GoogleFonts.inter(
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                  context, 18.0),
                              fontWeight: FontWeight.w400,
                              color: Colors.grey.shade600,
                            ),
                          ),

                          SizedBox(
                              height: ResponsiveHelper.getResponsiveSize(
                                  context, 4.0)),

                          // Total amount in green with currency
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CurrencyDisplayWidget(
                                variant: CurrencyVisualVariant.green,
                                width: ResponsiveHelper.getResponsiveSize(
                                    context, 22.0),
                                height: ResponsiveHelper.getResponsiveSize(
                                    context, 22.0),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                totalAmount.toStringAsFixed(0),
                                style: GoogleFonts.inter(
                                  fontSize:
                                      ResponsiveHelper.getResponsiveFontSize(
                                          context, 24.0),
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2E7D32),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(
                              height: ResponsiveHelper.getResponsiveSize(
                                  context, 36.0)),

                          // Two payment buttons side by side (square)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 40.0),
                            child: Row(
                              children: [
                                // Credit Card button
                                Expanded(
                                  child: _PaymentButton(
                                    label: translator(
                                      arText: 'بطاقة ائتمان',
                                      enText: 'Credit Card',
                                    ),
                                    iconAsset: AppAssets.cardPaymentIcon,
                                    backgroundColor:
                                        const Color(0xFFFFC107), // yellow
                                    textColor:
                                        const Color(0xFF2E7D32), // dark green
                                    isProcessing: _isProcessing,
                                    onTap: payOrderSummary,
                                  ),
                                ),

                                SizedBox(
                                    width: ResponsiveHelper.getResponsiveSize(
                                        context, 16.0)),

                                // Click & Get button
                                Expanded(
                                  child: _PaymentButton(
                                    label: translator(
                                      arText: 'اضغط واستلم',
                                      enText: 'Click & Get',
                                    ),
                                    iconAsset: AppAssets.clickGetIcon,
                                    backgroundColor:
                                        const Color(0xFF2E7D32), // dark green
                                    textColor: Colors.white,
                                    isProcessing: _isProcessing,
                                    onTap: payWithClickAndGet,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Language switcher at the bottom
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: InkWell(
                        onTap: () async {
                          await switchAppLanguage(ref, context);
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.language,
                                size: ResponsiveHelper.getResponsiveSize(
                                    context, 18.0),
                                color: Colors.grey.shade700,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                translator(
                                    arText: 'English', enText: 'العربية'),
                                style: GoogleFonts.inter(
                                  fontSize:
                                      ResponsiveHelper.getResponsiveFontSize(
                                          context, 14.0),
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable square-ish payment button matching the design
class _PaymentButton extends StatelessWidget {
  final String label;
  final String iconAsset;
  final Color backgroundColor;
  final Color textColor;
  final bool isProcessing;
  final VoidCallback onTap;

  const _PaymentButton({
    required this.label,
    required this.iconAsset,
    required this.backgroundColor,
    required this.textColor,
    required this.isProcessing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.1, // slightly wider than tall, close to square
      child: Material(
        color: Colors.transparent,
        elevation: 2,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: isProcessing ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: isProcessing
                  ? backgroundColor.withValues(alpha: 0.6)
                  : backgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isProcessing)
                  SizedBox(
                    width: ResponsiveHelper.getResponsiveSize(context, 50.0),
                    height: ResponsiveHelper.getResponsiveSize(context, 50.0),
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(textColor),
                    ),
                  )
                else
                  Image.asset(
                    iconAsset,
                    width: ResponsiveHelper.getResponsiveSize(context, 70.0),
                    height: ResponsiveHelper.getResponsiveSize(context, 70.0),
                    fit: BoxFit.contain,
                  ),
                SizedBox(
                    height: ResponsiveHelper.getResponsiveSize(context, 10.0)),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize:
                        ResponsiveHelper.getResponsiveFontSize(context, 18.0),
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
