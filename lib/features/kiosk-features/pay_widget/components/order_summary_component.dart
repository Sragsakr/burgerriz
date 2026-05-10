import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/currency_display_widget.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_theme.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/responsive_helper.dart';
import 'package:kiosk_point_of_sale/core/services/order_services/order_calculator.dart';

class OrderSummaryComponent extends StatelessWidget {
  final OrderSummary orderSummary;

  const OrderSummaryComponent({
    super.key,
    required this.orderSummary,
  });

  @override
  Widget build(BuildContext context) {
    final cartItems = orderSummary.salesInvoice.salesOrderItems;
    final itemCount = cartItems.length;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
      child: Material(
        color: Colors.transparent,
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xE8BBDCE5),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          ),
          child: Padding(
            padding:
                const EdgeInsetsDirectional.fromSTEB(25.0, 20.0, 25.0, 0.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Summary Title
                Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                  child: Text(
                    translator(
                      arText: 'ملخص الطلب',
                      enText: 'Order Summary',
                    ),
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.interTight(
                            fontWeight: FontWeight.bold,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                          color: const Color(0xFF877350),
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context, 26.0),
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.bold,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                  ),
                ),

                // Total Amount Row
                _buildSummaryRow(
                  context,
                  label: translator(
                    arText: 'المبلغ الإجمالي',
                    enText: 'Total Amount',
                  ),
                  value: orderSummary.totalAmount.toStringAsFixed(2),
                  isTotal: true,
                ),
                _buildSummaryRow(
                  context,
                  label: translator(
                    arText: 'الاجمالي بدون ضريبة',
                    enText: 'Total without VAT',
                  ),
                  value: orderSummary.subtotal.toStringAsFixed(2),
                ),
                _buildSummaryRow(
                  context,
                  label: translator(
                    arText: 'الضريبة',
                    enText: 'VAT',
                  ),
                  value: orderSummary.taxAmount.toStringAsFixed(2),
                ),
                // Discount Row (if applicable)
                if ((orderSummary.discountAmount +
                        orderSummary.promotionValue) >
                    0)
                  _buildSummaryRow(
                    context,
                    label: translator(
                      arText: 'الخصم',
                      enText: 'Discount',
                    ),
                    value: (orderSummary.discountAmount +
                            orderSummary.promotionValue)
                        .toStringAsFixed(2),
                  ),

                // Item Count Row
                _buildSummaryRow(
                  context,
                  label: translator(
                    arText: 'عدد المنتجات',
                    enText: 'Item Count',
                  ),
                  value: itemCount.toString(),
                  isItemCount: true,
                ),

                // const SizedBox(height: 20),

                // Price Breakdown Section
                // _buildPriceBreakdownSection(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context, {
    required String label,
    required String value,
    bool isTotal = false,
    bool isItemCount = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              label,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(
                      fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
                    color: FlutterFlowTheme.of(context).primaryText,
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                        context, isTotal ? 24.0 : 22.0),
                    letterSpacing: 0.0,
                    fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
                    fontStyle:
                        FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                  ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isItemCount) ...[
                Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 4.0, 0.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: const CurrencyDisplayWidget(
                      width: 20.0,
                      height: 20.0,
                    ),
                  ),
                ),
              ],
              Text(
                value,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      ),
                      color: const Color(0xFF877350),
                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context, isTotal ? 24.0 : 22.0),
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.bold,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdownSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Divider
        Container(
          height: 1,
          color: Colors.grey.shade300,
          margin: const EdgeInsets.symmetric(vertical: 10),
        ),

        // Price Breakdown Title
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 15.0),
          child: Text(
            translator(
              arText: 'تفاصيل الأسعار',
              enText: 'Price Breakdown',
            ),
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.interTight(
                    fontWeight: FontWeight.bold,
                    fontStyle:
                        FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                  ),
                  color: const Color(0xFF877350),
                  fontSize:
                      ResponsiveHelper.getResponsiveFontSize(context, 22.0),
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.bold,
                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                ),
          ),
        ),

        // Total without VAT
        _buildPriceRow(
          context,
          translator(
            arText: 'الاجمالي بدون ضريبة',
            enText: 'Total without VAT',
          ),
          orderSummary.subtotal.toStringAsFixed(2),
        ),

        // Discount (if applicable)
        if ((orderSummary.discountAmount + orderSummary.promotionValue) > 0)
          _buildPriceRow(
            context,
            translator(
              arText: 'الخصم',
              enText: 'Discount',
            ),
            (orderSummary.discountAmount + orderSummary.promotionValue)
                .toStringAsFixed(2),
          ),

        // VAT
        _buildPriceRow(
          context,
          translator(
            arText: 'الضريبة',
            enText: 'VAT',
          ),
          orderSummary.taxAmount.toStringAsFixed(2),
        ),

        // Total with VAT
        _buildPriceRow(
          context,
          translator(
            arText: 'الاجمالي مع الضريبة',
            enText: 'Total with VAT',
          ),
          orderSummary.totalAmount.toStringAsFixed(2),
          isTotal: true,
        ),

        // VAT Registration Number
        // Padding(
        //   padding: const EdgeInsetsDirectional.fromSTEB(0.0, 15.0, 0.0, 0.0),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [
        //       Text(
        //         translator(
        //           arText: 'رقم التسجيل في ضريبة القيمة المضافة:',
        //           enText: 'VAT Registration Number:',
        //         ),
        //         style: FlutterFlowTheme.of(context).bodyMedium.override(
        //           font: GoogleFonts.inter(
        //             fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
        //             fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
        //           ),
        //           color: FlutterFlowTheme.of(context).primaryText,
        //           fontSize: 18.0,
        //           letterSpacing: 0.0,
        //           fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
        //           fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
        //         ),
        //       ),
        //       Text(
        //         '310409608400003',
        //         style: FlutterFlowTheme.of(context).bodyMedium.override(
        //           font: GoogleFonts.inter(
        //             fontWeight: FontWeight.bold,
        //             fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
        //           ),
        //           color: const Color(0xFF877350),
        //           fontSize: 18.0,
        //           letterSpacing: 0.0,
        //           fontWeight: FontWeight.bold,
        //           fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
        //           decoration: TextDecoration.underline,
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
      ],
    );
  }

  Widget _buildPriceRow(
    BuildContext context,
    String label,
    String value, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.interTight(
                    fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                    fontStyle:
                        FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                  ),
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context, isTotal ? 20.0 : 18.0),
                  letterSpacing: 0.0,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                ),
          ),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: const CurrencyDisplayWidget(
                  width: 18.0,
                  height: 18.0,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                value,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.interTight(
                        fontWeight:
                            isTotal ? FontWeight.bold : FontWeight.normal,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      ),
                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context, isTotal ? 20.0 : 18.0),
                      letterSpacing: 0.0,
                      fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
