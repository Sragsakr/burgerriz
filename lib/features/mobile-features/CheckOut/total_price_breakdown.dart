import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/currency_display_widget.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_theme.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/internationalization.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/core/services/order_services/order_calculator.dart';
import 'package:kiosk_point_of_sale/providers/order_summary_provider.dart';
import 'package:kiosk_point_of_sale/providers/payment_breakdown_provider.dart';

class TotalPriceBreakdown extends ConsumerWidget {
  const TotalPriceBreakdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderSummaryAsync = ref.watch(orderSummaryProvider);

    return orderSummaryAsync.when(
      data: (summary) => content(context, ref, summary),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) {
        dPrint("Error: $e");
        dPrint("Stack Trace: $st");
        return Center(child: Text('Error: $e'));
      },
    );
  }

  Material content(BuildContext context, WidgetRef ref, OrderSummary summary) {
    final totalPaid = ref.watch(paymentBreakdownProvider).fold<num>(
          0.0,
          (sum, payment) => sum + payment.amount,
        );
    final remaining = (summary.totalAmount - totalPaid).toStringAsFixed(2);
    final String change = (totalPaid > summary.totalAmount)
        ? (totalPaid - summary.totalAmount).toStringAsFixed(2)
        : '0.00';
    dPrint("Change: $change");
    dPrint("Remaining: $remaining");
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
          padding: const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                FFLocalizations.of(context).getText('fnxsob92'),
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
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    translator(
                        arText: 'الاجمالي بدون ضريبة',
                        enText: 'Total without VAT'),
                    style: FlutterFlowTheme.of(context).bodyLarge.override(
                          fontFamily: 'Inter',
                          letterSpacing: 0.0,
                        ),
                  ),
                  Row(
                    children: [
                      Text(
                        '${summary.subtotal.toStringAsFixed(2)}',
                        style: FlutterFlowTheme.of(context).bodyLarge.override(
                              fontFamily: 'Inter',
                              letterSpacing: 0.0,
                            ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        child: CurrencyDisplayWidget(
                          width: 15.0,
                          height: 15.0,
                          textStyle: FlutterFlowTheme.of(context).bodyLarge.override(
                            fontFamily: 'Inter',
                            letterSpacing: 0.0,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
              if ((summary.discountAmount + summary.promotionValue) > 0)
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      translator(arText: 'الخصم', enText: 'Discount'),
                      style: FlutterFlowTheme.of(context).bodyLarge.override(
                            fontFamily: 'Inter',
                            letterSpacing: 0.0,
                          ),
                    ),
                    Row(
                      children: [
                        Text(
                          '${(summary.discountAmount + summary.promotionValue).toStringAsFixed(2)}',
                          style: FlutterFlowTheme.of(context).bodyLarge.override(
                                fontFamily: 'Inter',
                                letterSpacing: 0.0,
                              ),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          child: CurrencyDisplayWidget(
                            width: 15.0,
                            height: 15.0,
                            textStyle: FlutterFlowTheme.of(context).bodyLarge.override(
                              fontFamily: 'Inter',
                              letterSpacing: 0.0,
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              // if (summary.promotionAmount > 0 && kDebugMode)
              //   Row(
              //     mainAxisSize: MainAxisSize.max,
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     children: [
              //       Text(
              //         translator(arText: 'خصم العرض', enText: 'Promotion Discount'),
              //         style: FlutterFlowTheme.of(context).bodyLarge.override(
              //               fontFamily: 'Inter',
              //               letterSpacing: 0.0,
              //             ),
              //       ),
              //       Text(
              //         '${summary.promotionAmount.toStringAsFixed(2)} ${FFLocalizations.of(context).getText('dprmfxrn')}',
              //         style: FlutterFlowTheme.of(context).bodyLarge.override(
              //               fontFamily: 'Inter',
              //               letterSpacing: 0.0,
              //             ),
              //       ),
              //     ],
              //   ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    translator(arText: 'الضريبة', enText: 'VAT'),
                    style: FlutterFlowTheme.of(context).bodyLarge.override(
                          fontFamily: 'Inter',
                          letterSpacing: 0.0,
                        ),
                  ),
                  Row(
                    children: [
                      Text(
                        '${summary.taxAmount.toStringAsFixed(2)}',
                        style: FlutterFlowTheme.of(context).bodyLarge.override(
                              fontFamily: 'Inter',
                              letterSpacing: 0.0,
                            ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        child: CurrencyDisplayWidget(
                          width: 15.0,
                          height: 15.0,
                          textStyle: FlutterFlowTheme.of(context).bodyLarge.override(
                            fontFamily: 'Inter',
                            letterSpacing: 0.0,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    translator(
                        arText: 'الاجمالي مع الضريبة',
                        enText: 'Total with VAT'),
                    style: FlutterFlowTheme.of(context).bodyLarge.override(
                          fontFamily: 'Inter',
                          letterSpacing: 0.0,
                        ),
                  ),
                  Row(
                    children: [
                      Text(
                        '${summary.totalAmount.toStringAsFixed(2)}',
                        style: FlutterFlowTheme.of(context).bodyLarge.override(
                              fontFamily: 'Inter',
                              letterSpacing: 0.0,
                            ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        child: CurrencyDisplayWidget(
                          width: 15.0,
                          height: 15.0,
                          textStyle: FlutterFlowTheme.of(context).bodyLarge.override(
                            fontFamily: 'Inter',
                            letterSpacing: 0.0,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    FFLocalizations.of(context).getText('j6wble6y'),
                    style: FlutterFlowTheme.of(context).bodyLarge.override(
                          fontFamily: 'Inter',
                          letterSpacing: 0.0,
                        ),
                  ),
                  Row(
                    children: [
                      Text(
                        '${summary.totalPaid.toStringAsFixed(2)}',
                        style: FlutterFlowTheme.of(context).bodyLarge.override(
                              fontFamily: 'Inter',
                              letterSpacing: 0.0,
                            ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        child: CurrencyDisplayWidget(
                          width: 15.0,
                          height: 15.0,
                          textStyle: FlutterFlowTheme.of(context).bodyLarge.override(
                            fontFamily: 'Inter',
                            letterSpacing: 0.0,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
              if (double.parse(change) > 0)
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      FFLocalizations.of(context).getText('274fd8i0'),
                      style: FlutterFlowTheme.of(context).bodyLarge.override(
                            fontFamily: 'Inter',
                            letterSpacing: 0.0,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Row(
                      children: [
                        Text(
                          '$change',
                          style: FlutterFlowTheme.of(context).bodyLarge.override(
                                fontFamily: 'Inter',
                                letterSpacing: 0.0,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                          ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          child: CurrencyDisplayWidget(
                            width: 15.0,
                            height: 15.0,
                            textStyle: FlutterFlowTheme.of(context).bodyLarge.override(
                              fontFamily: 'Inter',
                              letterSpacing: 0.0,
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                )
              else
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      FFLocalizations.of(context).getText('t9yri5sl'),
                      style: FlutterFlowTheme.of(context).bodyLarge.override(
                            fontFamily: 'Inter',
                            letterSpacing: 0.0,
                            color: const Color(0xFFAF2A26),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Row(
                      children: [
                        Text(
                          '$remaining',
                          style: FlutterFlowTheme.of(context).bodyLarge.override(
                                fontFamily: 'Inter',
                                letterSpacing: 0.0,
                                color: const Color(0xFFAF2A26),
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          child: CurrencyDisplayWidget(
                            width: 15.0,
                            height: 15.0,
                          ),
                        )
                      ],
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
