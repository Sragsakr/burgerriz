import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiosk_point_of_sale/core/colors/app_colors.dart';
import 'package:kiosk_point_of_sale/core/extentions/app_extentions.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_animations.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_theme.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_widgets.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_dialogs.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_invoice.dart';
import 'package:kiosk_point_of_sale/main.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/cart/cart_helper.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/entry_widget/entry_widget.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/success_payment/components/qr_invoice_dialog.dart';

class InvoiceOptionsComponent extends ConsumerStatefulWidget {
  final SalesInvoice salesInvoice;

  const InvoiceOptionsComponent({
    super.key,
    required this.salesInvoice,
  });

  @override
  ConsumerState<InvoiceOptionsComponent> createState() =>
      _InvoiceOptionsComponentState();
}

class _InvoiceOptionsComponentState
    extends ConsumerState<InvoiceOptionsComponent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Green Future Text
          Align(
            alignment: const AlignmentDirectional(0.0, -1.0),
            child: Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(24.0, 24.0, 24.0, 0.0),
              child: Text(
                translator(
                  arText:
                      'لمستقبل أكثر اخضراراً 🌱 🌍\nكيف تريد استلام فاتورتك؟',
                  enText:
                      'For a greener future 🌱 🌍\nhow would you like to receive your invoice?',
                ),
                textAlign: TextAlign.center,
                style: FlutterFlowTheme.of(context).labelMedium.override(
                      font: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontStyle:
                            FlutterFlowTheme.of(context).labelMedium.fontStyle,
                      ),
                      color: AppColors.black,
                      fontSize: 35.0,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.bold,
                      fontStyle:
                          FlutterFlowTheme.of(context).labelMedium.fontStyle,
                    ),
              ),
            ).animateOnPageLoad(
              AnimationInfo(
                trigger: AnimationTrigger.onPageLoad,
                effects: [
                  VisibilityEffect(duration: 150.ms),
                  FadeEffect(
                    curve: Curves.easeInOut,
                    delay: 150.0.ms,
                    duration: 300.0.ms,
                    begin: 0.0,
                    end: 1.0,
                  ),
                  ScaleEffect(
                    curve: Curves.easeInOut,
                    delay: 150.0.ms,
                    duration: 300.0.ms,
                    begin: Offset(0.8, 0.8),
                    end: Offset(1.0, 1.0),
                  ),
                  TiltEffect(
                    curve: Curves.easeInOut,
                    delay: 150.0.ms,
                    duration: 300.0.ms,
                    begin: Offset(0, 1.396),
                    end: Offset(0, 0),
                  ),
                  MoveEffect(
                    curve: Curves.easeInOut,
                    delay: 150.0.ms,
                    duration: 300.0.ms,
                    begin: Offset(0.0, 40.0),
                    end: Offset(0.0, 0.0),
                  ),
                ],
              ),
            ),
          ),

          // Buttons Row
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              // Print Invoice Button
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                      16.0, 34.0, 16.0, 4.0),
                  child: FFButtonWidget(
                    onPressed: () async {
                      if (kDebugMode) {
                        navKey.currentState!.context
                            .pushReplacementNamed(EntryWidget.routeName);
                        return;
                      }
                      await CartHelper()
                          .completePayment(ref, context, widget.salesInvoice);
                    },
                    text: translator(
                      arText: 'طباعة الفاتورة',
                      enText: 'Print invoice',
                    ),
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 90.0,
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          10, 0.0, 10.0, 0.0),
                      iconPadding: const EdgeInsetsDirectional.fromSTEB(
                          0.0, 0.0, 0.0, 0.0),
                      color: const Color(0xFFEF946C),
                      textStyle:
                          FlutterFlowTheme.of(context).titleSmall.override(
                                font: GoogleFonts.interTight(
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .fontStyle,
                                ),
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                fontSize: 28.0,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w500,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .fontStyle,
                              ),
                      elevation: 2.0,
                      borderSide: const BorderSide(
                        color: Colors.transparent,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                  ),
                ),
              ),

              // Digital Invoice Button
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                      16.0, 34.0, 16.0, 4.0),
                  child: FFButtonWidget(
                    onPressed: () async {
                      await showAppDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => QrInvoiceDialog(
                          salesInvoice: widget.salesInvoice,
                        ),
                      );
                    },
                    text: translator(
                      arText: 'فاتورة رقمية',
                      enText: 'Digital invoice',
                    ),
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 90.0,
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          10.0, 0.0, 10.0, 0.0),
                      iconPadding: const EdgeInsetsDirectional.fromSTEB(
                          0.0, 0.0, 0.0, 0.0),
                      color: FlutterFlowTheme.of(context).success,
                      textStyle:
                          FlutterFlowTheme.of(context).titleSmall.override(
                                font: GoogleFonts.interTight(
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .fontStyle,
                                ),
                                color: Colors.white,
                                fontSize: 28.0,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w500,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .fontStyle,
                              ),
                      elevation: 2.0,
                      borderSide: const BorderSide(
                        color: Colors.transparent,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
