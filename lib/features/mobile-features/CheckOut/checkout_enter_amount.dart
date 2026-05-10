import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_theme.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/internationalization.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/providers/payment_breakdown_provider.dart';

import '../../../providers/order_summary_provider.dart';

class PaymentAmountInput extends ConsumerStatefulWidget {
  const PaymentAmountInput({
    super.key,
  });

  @override
  ConsumerState<PaymentAmountInput> createState() => _PaymentAmountInputState();
}

class _PaymentAmountInputState extends ConsumerState<PaymentAmountInput> {
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _amountController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  _addPayment() async {
    final selectedMethod = ref.read(selectedPaymentMethodProvider);
    if (selectedMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            FFLocalizations.of(context).getText('qsp4ng6w'),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text);
    final orderSummaryAsync = ref.watch(orderSummaryProvider);
    final remainingAmount = orderSummaryAsync.when(
      data: (data) =>
          data.totalAmount -
          ref.watch(paymentBreakdownProvider).fold<double>(
                0.0,
                (sum, payment) => sum + payment.amount,
              ),
      loading: () => 0.0,
      error: (e, t) => 0.0,
    );
    if ((amount == null || amount <= 0) &&
        orderSummaryAsync.when(
              data: (data) => data.totalAmount,
              loading: () => 0.0,
              error: (e, t) => 0.0,
            ) >
            0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            FFLocalizations.of(context).getText('930d3x2p'),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    bool isCash = selectedMethod.enName.toLowerCase() == "cash";
    dPrint("isCash is $isCash and selectedMethod is ${selectedMethod.enName}");
    // Add the payment
    if (amount != null && amount > remainingAmount && !isCash) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            translator(
                arText:
                    "لا يمكن اضافة دفعة غير كاش بقيمة اكبر من المبلغ المتبقي",
                enText:
                    "Can't Add Non cash payment With value Bigger than Total"),
          ),
          backgroundColor: Colors.red,
        ),
      );
      _amountController.text = remainingAmount.toStringAsFixed(2);
      return;
    }
    ref
        .read(paymentBreakdownProvider.notifier)
        .addPayment(selectedMethod, amount ?? 0.0, selectedMethod.tenderId);

    // Clear the input
    _amountController.clear();
    _focusNode.unfocus();
  }

  _checkRemainingAmountText() async {
    final selectedMethod = ref.read(selectedPaymentMethodProvider);
    final orderSummaryAsync = ref.watch(orderSummaryProvider);
    if (selectedMethod != null) {
      try {
        final remainingAmount = orderSummaryAsync.when(
          data: (data) =>
              data.totalAmount -
              ref.watch(paymentBreakdownProvider).fold<double>(
                    0.0,
                    (sum, payment) => sum + payment.amount,
                  ),
          loading: () => 0.0,
          error: (e, t) => 0.0,
        );
        _amountController.text = remainingAmount.toStringAsFixed(2);
      } catch (e) {
        if (kDebugMode) {
          print('-------------------------');
          print(e.toString());
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canAddPayment = ref.watch(canAddPaymentProvider);
    _checkRemainingAmountText();
    return Material(
      color: Colors.transparent,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.sizeOf(context).width,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                FFLocalizations.of(context).getText('lu8ezi20'),
                style: FlutterFlowTheme.of(context).headlineSmall.override(
                      fontFamily: 'Inter Tight',
                      color: FlutterFlowTheme.of(context).primaryText,
                      letterSpacing: 0.0,
                      fontSize: MediaQuery.of(context).orientation ==
                              Orientation.landscape
                          ? 30
                          : MediaQuery.sizeOf(context).width * 0.06,
                    ),
              ),
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.01),
              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: TextField(
                      controller: _amountController,
                      focusNode: _focusNode,
                      enabled: canAddPayment,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        hintText: canAddPayment
                            ? FFLocalizations.of(context).getText('64xgeh4y')
                            : FFLocalizations.of(context).getText('qsp4ng6m'),
                        fillColor: const Color(0xFFF5F5F5),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Color(0xFFE0E0E0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Color(0xFFE0E0E0)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: MediaQuery.sizeOf(context).width * 0.02),
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                      onPressed: canAddPayment
                          ? () async {
                              await _addPayment();
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFAF2A26),
                        padding: EdgeInsets.zero,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: Icon(
                        Icons.add,
                        color: FlutterFlowTheme.of(context).info,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
