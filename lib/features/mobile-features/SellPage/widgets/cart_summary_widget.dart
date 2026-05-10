import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/currency_display_widget.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_theme.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/internationalization.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/core/helpers/responsive_helper.dart';
import 'package:kiosk_point_of_sale/core/services/order_services/order_calculator.dart';
import 'package:kiosk_point_of_sale/providers/cart_provider.dart';
import 'package:kiosk_point_of_sale/providers/order_summary_provider.dart';

class CartSummaryWidget extends ConsumerWidget {
  const CartSummaryWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use OrderSummary for consistent and accurate data
    final orderSummaryAsync = ref.watch(orderSummaryProvider);
    return orderSummaryAsync.when(
      data: (orderSummary) {
        return _buildSummaryContent(context, ref, orderSummary);
      },
      loading: () => _buildLoadingContent(context),
      error: (error, stack) {
        dPrint("Stack Trace: $stack");
        return _buildErrorContent(context, error);
      },
    );
  }

  Widget _buildSummaryContent(
      BuildContext context, WidgetRef ref, OrderSummary orderSummary) {
    // Get actual cart item count
    final cartItems = ref.watch(cartProvider);
    final itemCount = cartItems.length;
    // Check if promotions were removed and show message
    // final customer = ref.watch(selectedCustomerProvider);
    bool isLandscape = ResponsiveHelper.isTablet(context);

    return Container(
      width: isLandscape
          ? MediaQuery.sizeOf(context).width * 0.4
          : MediaQuery.sizeOf(context).width,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFE0E0E0),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 6, 16, 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  FFLocalizations.of(context).getText('kh98lj6m'),
                  style: FlutterFlowTheme.of(context).titleMedium.override(
                        fontFamily: 'Inter Tight',
                        color: FlutterFlowTheme.of(context).primaryText,
                        letterSpacing: 0.0,
                        fontSize: ResponsiveHelper.isMobile(context) ? 16 : 20,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Spacer(),
                Row(
                  children: [
                    Text(
                      '${orderSummary.totalAmount.toStringAsFixed(2)}',
                      style: FlutterFlowTheme.of(context).titleMedium.override(
                            fontFamily: 'Inter Tight',
                            color: const Color(0xFFAF2A26),
                            letterSpacing: 0.0,
                            fontSize: ResponsiveHelper.isMobile(context) ? 16 : 20,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
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
            if ((orderSummary.discountAmount + orderSummary.promotionValue) > 0)
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    translator(arText: 'الخصم', enText: 'Discount'),
                    style: FlutterFlowTheme.of(context).titleMedium.override(
                          fontFamily: 'Inter Tight',
                          color: FlutterFlowTheme.of(context).primaryText,
                          letterSpacing: 0.0,
                          fontSize:
                              ResponsiveHelper.isMobile(context) ? 16 : 20,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Row(
                    children: [
                      Text(
                        '${(orderSummary.discountAmount + orderSummary.promotionValue).toStringAsFixed(2)}',
                        style: FlutterFlowTheme.of(context).titleMedium.override(
                              fontFamily: 'Inter Tight',
                              color: const Color(0xFFAF2A26),
                              letterSpacing: 0.0,
                              fontSize:
                                  ResponsiveHelper.isMobile(context) ? 16 : 20,
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
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  translator(arText: "عدد المنتجات", enText: "Item Count"),
                  style: FlutterFlowTheme.of(context).titleMedium.override(
                        fontFamily: 'Inter Tight',
                        color: FlutterFlowTheme.of(context).primaryText,
                        letterSpacing: 0.0,
                        fontSize: ResponsiveHelper.isMobile(context) ? 16 : 20,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '$itemCount',
                  style: FlutterFlowTheme.of(context).titleMedium.override(
                        fontFamily: 'Inter Tight',
                        color: const Color(0xFFAF2A26),
                        letterSpacing: 0.0,
                        fontSize: ResponsiveHelper.isMobile(context) ? 16 : 20,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingContent(BuildContext context) {
    bool isLandscape = ResponsiveHelper.isTablet(context);

    return Container(
      width: isLandscape
          ? MediaQuery.sizeOf(context).width * 0.4
          : MediaQuery.sizeOf(context).width,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFE0E0E0),
          width: 1,
        ),
      ),
      child: const Padding(
        padding: EdgeInsetsDirectional.fromSTEB(16, 6, 16, 6),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildErrorContent(BuildContext context, Object error) {
    return Container(
      width: MediaQuery.sizeOf(context).width,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFE0E0E0),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 6, 16, 6),
        child: Center(
          child: Text(
            'Error: ${error.toString()}',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'Inter Tight',
                  color: Colors.red,
                ),
          ),
        ),
      ),
    );
  }
}
