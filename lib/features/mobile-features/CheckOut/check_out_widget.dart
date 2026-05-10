import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_theme.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_util.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/responsive_helper.dart';
import 'package:kiosk_point_of_sale/core/services/printing_services/drago/drago_printer_controller.dart';
import 'package:kiosk_point_of_sale/features/mobile-features/CheckOut/check_out_model.dart';
import 'package:kiosk_point_of_sale/features/mobile-features/CheckOut/checkout_complet_payment_button.dart';
import 'package:kiosk_point_of_sale/features/mobile-features/CheckOut/checkout_enter_amount.dart';
import 'package:kiosk_point_of_sale/features/shared-features/payment/checkout_payment_method.dart';
import 'package:kiosk_point_of_sale/features/mobile-features/CheckOut/payment_transactions_list.dart';
import 'package:kiosk_point_of_sale/features/mobile-features/CheckOut/phone_widget.dart';
import 'package:kiosk_point_of_sale/features/mobile-features/CheckOut/total_price_breakdown.dart';

class CheckOutWidget extends ConsumerStatefulWidget {
  const CheckOutWidget({super.key});

  @override
  ConsumerState<CheckOutWidget> createState() => _CheckOutWidgetState();
}

class _CheckOutWidgetState extends ConsumerState<CheckOutWidget> {
  late CheckOutModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    DragoPrinterController.scan();

    _model = createModel(context, () => CheckOutModel());
    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          key: scaffoldKey,
          backgroundColor: Colors.white,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: Icon(
                  Icons.language,
                  size: ResponsiveHelper.getResponsiveSize(
                    context,
                    24,
                  ),
                ),
                onPressed: () async {
                  await switchAppLanguage(ref, context);
                },
              ),
            ],
            centerTitle: true,
            elevation: 0.8,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Color(0xFFAF2A26),
                size: 30.0,
              ),
              onPressed: () {
                context.go('/sell-page');
              },
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(2.0, 0.0, 0.0, 0.0),
                child: Text(
                  FFLocalizations.of(context).getText('ag46q06s'),
                  // 'POS',
                  style: FlutterFlowTheme.of(context).headlineSmall.override(
                        fontFamily: 'Outfit',
                        color: FlutterFlowTheme.of(context).gray600,
                      ),
                ),
              ),
              centerTitle: true,
              expandedTitleScale: 1.0,
            ),
          ),
          body: buildScreen()),
    );
  }

  SafeArea buildScreen() {
    return SafeArea(
      top: true,
      child: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            color: Color.fromARGB(174, 238, 238, 238),
          ),
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(12, 12, 12, 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PaymentMethodSelector(),
                SizedBox(height: 10),
                PaymentAmountInput(),
                SizedBox(height: 10),
                PhoneInput(),
                SizedBox(height: 10),
                TotalPriceBreakdown(),
                SizedBox(height: 10),
                PaymentTransactionsList(),
                SizedBox(height: 10),
                CheckoutCompletePaymentButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
