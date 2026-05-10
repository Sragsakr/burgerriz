import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_icon_button.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_model.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_theme.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_widgets.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/responsive_helper.dart';
import 'package:kiosk_point_of_sale/providers/payment_breakdown_provider.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/success_payment/kiosk_phone_input.dart';

import 'phone_number_model.dart';

export 'phone_number_model.dart';

class PhoneNumberWidget extends ConsumerStatefulWidget {
  final Function(String) onSend;
  const PhoneNumberWidget({super.key, required this.onSend});

  @override
  ConsumerState<PhoneNumberWidget> createState() => _PhoneNumberWidgetState();
}

class _PhoneNumberWidgetState extends ConsumerState<PhoneNumberWidget> {
  late PhoneNumberModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PhoneNumberModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    return Container(
      // width: double.infinity,
      height:
          MediaQuery.of(context).size.height * (isKeyboardVisible ? 0.7 : 0.4),
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      alignment: AlignmentDirectional(0.0, 1.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              boxShadow: [
                BoxShadow(
                  blurRadius: 7.0,
                  color: Color(0x33000000),
                  offset: Offset(
                    0.0,
                    -2.0,
                  ),
                )
              ],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(0.0),
                bottomRight: Radius.circular(0.0),
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
            ),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                  0.0,
                  8.0,
                  0.0,
                  MediaQuery.of(context).size.height *
                      (isKeyboardVisible ? 0.3 : 0)),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 21.0),
                        child: Container(
                          width:
                              ResponsiveHelper.getResponsiveSize(context, 60.0),
                          height:
                              ResponsiveHelper.getResponsiveSize(context, 3.0),
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).alternate,
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // backIcon
                  BackIconComponent(),
                  Align(
                    alignment: AlignmentDirectional(0.0, -1.0),
                    child: Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(32.0, 30.0, 32.0, 0.0),
                      child: Text(
                        translator(
                          arText:
                              'أرسل الفاتورة إلى رقم هاتفك 📱 \nفقط أدخل رقم هاتفك',
                          enText:
                              'Want your invoice on your phone? 📱 \nJust drop your number',
                        ),
                        textAlign: TextAlign.center,
                        style: FlutterFlowTheme.of(context)
                            .headlineSmall
                            .override(
                              font: GoogleFonts.interTight(
                                fontWeight: FlutterFlowTheme.of(context)
                                    .headlineSmall
                                    .fontWeight,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .headlineSmall
                                    .fontStyle,
                              ),
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                  context, 26.0),
                              letterSpacing: 0.0,
                              fontWeight: FlutterFlowTheme.of(context)
                                  .headlineSmall
                                  .fontWeight,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .headlineSmall
                                  .fontStyle,
                            ),
                      ),
                    ),
                  ),
                  // Phone Input Component
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(32.0, 20.0, 32.0, 20.0),
                    child: PhoneInput(),
                  ),
                  // Send Button
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(32.0, 0.0, 32.0, 30.0),
                    child: FFButtonWidget(
                      onPressed: () {
                        // Get the phone number from the provider
                        final phoneNumber = ref.read(invoicePhoneProvider);
                        if (phoneNumber.isNotEmpty) {
                          widget.onSend(phoneNumber);
                        }
                      },
                      text: translator(
                        arText: 'أرسل',
                        enText: 'Send',
                      ),
                      options: FFButtonOptions(
                        width: double.infinity,
                        height:
                            ResponsiveHelper.getResponsiveButtonSize(context),
                        padding: EdgeInsetsDirectional.fromSTEB(
                            16.0, 0.0, 16.0, 0.0),
                        iconPadding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                        color: Color(0xFF877350),
                        textStyle: FlutterFlowTheme.of(context)
                            .titleSmall
                            .override(
                              font: GoogleFonts.interTight(
                                fontWeight: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .fontWeight,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .fontStyle,
                              ),
                              color: Colors.white,
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                  context, 24.0),
                              letterSpacing: 0.0,
                              fontWeight: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .fontWeight,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .fontStyle,
                            ),
                        elevation: 0.0,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BackIconComponent extends StatelessWidget {
  const BackIconComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return FlutterFlowIconButton(
      borderRadius: 8.0,
      buttonSize: 40.0,
      icon: Icon(
        Icons.chevron_left,
        color: Colors.black,
        size: 40.0,
      ),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
  }
}
