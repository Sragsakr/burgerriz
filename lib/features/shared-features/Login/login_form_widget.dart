import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiosk_point_of_sale/core/enums/login_method_enums.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';

import '../../../core/constants/font_size.dart';
import '../../../core/flutter_flow/flutter_flow_theme.dart';
import '../../../core/flutter_flow/flutter_flow_util.dart';
import 'login_model.dart';
import 'login_form_fields.dart';

class LoginFormWidget extends ConsumerStatefulWidget {
  final LoginModel model;

  const LoginFormWidget({
    super.key,
    required this.model,
  });

  @override
  ConsumerState<LoginFormWidget> createState() => LoginFormWidgetState();
}

class LoginFormWidgetState extends ConsumerState<LoginFormWidget> {
  void togglePasswordVisibility() {
    setState(() {
      widget.model.passwordVisibility = !widget.model.passwordVisibility;
    });
  }

  LoginMethod method = LoginMethod.pinCode;
  @override
  void initState() {
    super.initState();
    // AppPreferences().getLoginMethod().then((name) {
    //   setState(() {
    //     method = getLoginMethod(name);
    //     if (method == LoginMethod.pinCode) {
    //       FocusScope.of(context).requestFocus(widget.model.unfocusNode);
    //       FocusScope.of(context).unfocus();
    //       widget.model.textFieldFocusNode?.requestFocus();
    //     }
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          FFLocalizations.of(context).getText('679kunro' /* Welcome  `*/),
          style: FlutterFlowTheme.of(context).displaySmall.override(
                fontFamily: 'Outfit',
                fontSize: getHeading1Size(context),
                fontWeight: FontWeight.w500,
              ),
        ),
        Text(
          FFLocalizations.of(context)
              .getText('t9abm3vl' /* To POINT Of SALE */),
          style: FlutterFlowTheme.of(context).displaySmall.override(
                fontFamily: 'Outfit',
                fontSize: getHeading1Size(context),
                fontWeight: FontWeight.w500,
              ),
        ),

        // Padding(
        //   padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 5.0),
        //   child: Text(
        //     FFLocalizations.of(context).getText(
        //         'enter_tenant' /* Enter the agent pincode or Use... */),
        //     textAlign: TextAlign.center,
        //     style: FlutterFlowTheme.of(context).labelMedium.override(
        //           fontFamily: 'Readex Pro',
        //           fontSize: getBodyTextSize(context),
        //         ),
        //   ),
        // ),
        // buildTenantField(context, widget.model, ref),
        if (method == LoginMethod.pinCode) ...[
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 2.0, 0.0, 24.0),
            child: Text(
              FFLocalizations.of(context)
                  .getText('78gfsss7' /* Enter the agent pincode or Use... */),
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).labelMedium.override(
                    fontFamily: 'Readex Pro',
                    fontSize: getBodyTextSize(context),
                  ),
            ),
          ),
          buildPinCodeField(context, widget.model, ref),
        ] else ...[
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 5.0),
            child: Text(
              FFLocalizations.of(context)
                  .getText('3ggxepf3' /* Enter the agent name and passw... */),
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).labelMedium.override(
                    fontFamily: 'Readex Pro',
                    fontSize: getBodyTextSize(context),
                  ),
            ),
          ),
          buildEmailField(context, widget.model, ref),
          buildPasswordField(
              context, widget.model, togglePasswordVisibility, ref),
        ],
        // IconButton(
        //     onPressed: () {
        //       togglePasswordAndPinCode();
        //     },
        //     icon: const Icon(Icons.keyboard_alt_outlined,
        //         color: Color(0xFFAF2A26), size: 24)),
      ],
    );
  }

  void togglePasswordAndPinCode() async {
    if (method == LoginMethod.userName) {
      setState(() {
        method = LoginMethod.pinCode;
        FocusManager.instance.primaryFocus?.unfocus();
        widget.model.textFieldFocusNode?.requestFocus();
      });
    } else {
      setState(() {
        method = LoginMethod.userName;
      });
    }
    await AppPreferences().setLoginMethod(method.name);
  }
}
