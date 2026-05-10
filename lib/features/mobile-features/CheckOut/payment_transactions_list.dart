import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/currency_display_widget.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_theme.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/internationalization.dart';
import 'package:kiosk_point_of_sale/providers/order_summary_provider.dart';
import 'package:kiosk_point_of_sale/providers/payment_breakdown_provider.dart';

class PaymentTransactionsList extends ConsumerWidget {
  const PaymentTransactionsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payments = ref.watch(paymentBreakdownProvider);
    final orderSummaryAsync = ref.watch(orderSummaryProvider);

    // Dynamically calculate totals for each payment method
    final paymentTotals =
        ref.watch(paymentBreakdownProvider.notifier).paymentTotals;
    final isLandScape =
        MediaQuery.of(context).orientation == Orientation.landscape;
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
                FFLocalizations.of(context).getText('kztj03z2'),
                style: FlutterFlowTheme.of(context).headlineSmall.override(
                      fontFamily: 'Inter Tight',
                      color: FlutterFlowTheme.of(context).primaryText,
                      letterSpacing: 0.0,
                      fontSize: isLandScape
                          ? 30
                          : MediaQuery.sizeOf(context).width * 0.06,
                    ),
              ),
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.01),

              // Loop through each payment method dynamically
              for (var entry in paymentTotals.entries)
                if (entry.value['total'] > 0)
                  Dismissible(
                    key: Key("${entry.key}"),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: Colors.red,
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    onDismissed: (direction) {
                      // Remove all payments of this method
                      ref
                          .read(paymentBreakdownProvider.notifier)
                          .removeAllPaymentsOfType(entry.key);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            FFLocalizations.of(context).languageCode == 'ar'
                                ? entry.value['arName'] // Arabic Name
                                : entry.value['enName'], // English Name
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Inter',
                                  letterSpacing: 0.0,
                                ),
                          ),
                          Row(
                            children: [
                              Text(
                                '${entry.value['total'].toStringAsFixed(2)}',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Inter',
                                      letterSpacing: 0.0,
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
                    ),
                  ),

              // Show message if there are no payments
              if (payments.isEmpty)
                Text(
                  FFLocalizations.of(context).getText('o7yfcj25'),
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Inter',
                        color: FlutterFlowTheme.of(context).secondaryText,
                        letterSpacing: 0.0,
                      ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
