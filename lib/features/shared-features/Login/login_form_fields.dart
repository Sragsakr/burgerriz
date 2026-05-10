import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiosk_point_of_sale/providers/login_provider.dart';

import '../../../core/constants/font_size.dart';
import '../../../core/flutter_flow/flutter_flow_theme.dart';
import '../../../core/flutter_flow/flutter_flow_util.dart';
import 'login_model.dart';

Widget buildEmailField(BuildContext context, LoginModel model, WidgetRef ref) {
  final colorScheme = Theme.of(context).colorScheme;
  return Padding(
    padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
    child: SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      height:
          MediaQuery.of(context).size.height * 0.06, // Increase the height here
      child: TextFormField(
        onChanged: (value) {
          ref.read(authProvider.notifier).update(
                (state) => state.copyWith(username: value),
              );
        },
        controller: model.emailAddressController,
        focusNode: model.emailAddressFocusNode,
        autofocus: true,
        autofillHints: const [AutofillHints.email],
        obscureText: false,
        decoration: InputDecoration(
          labelText:
              FFLocalizations.of(context).getText('ovm5vn6o' /* Email */),
          labelStyle: FlutterFlowTheme.of(context).labelMedium.copyWith(
                fontSize: getCaptionSize(
                    context), // Increase the label (hint) text size
              ),
          hintStyle: TextStyle(
            fontSize: getCaptionSize(context), // Increase the hint text size
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: colorScheme.outline.withValues(alpha: 0.35),
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: colorScheme.primary,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: colorScheme.error,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: colorScheme.error,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          filled: true,
          fillColor: colorScheme.surface,
          contentPadding: const EdgeInsets.symmetric(
              vertical: 20,
              horizontal: 16), // Adjust padding to increase height
        ),
        style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
              fontSize: getCaptionSize(context), // Increase the input text size
            ),
        keyboardType: TextInputType.emailAddress,
        validator: model.emailAddressControllerValidator.asValidator(context),
      ),
    ),
  );
}

Widget buildPasswordField(BuildContext context, LoginModel model,
    VoidCallback togglePasswordVisibility, WidgetRef ref) {
  final colorScheme = Theme.of(context).colorScheme;
  return Padding(
    padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
    child: SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      height:
          MediaQuery.of(context).size.height * 0.06, // Increase the height here
      child: TextFormField(
        onChanged: (value) {
          ref.read(authProvider.notifier).update(
                (state) => state.copyWith(password: value),
              );
        },
        controller: model.passwordController,
        focusNode: model.passwordFocusNode,
        autofocus: true,
        autofillHints: const [AutofillHints.password],
        obscureText: !model.passwordVisibility,
        decoration: InputDecoration(
          labelText:
              FFLocalizations.of(context).getText('5xyu281n' /* Password */),
          labelStyle: FlutterFlowTheme.of(context).labelMedium.copyWith(
                fontSize: getCaptionSize(
                    context), // Increase the label (hint) text size
              ),
          hintStyle: TextStyle(
            fontSize: getCaptionSize(context), // Increase the hint text size
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: colorScheme.outline.withValues(alpha: 0.35),
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: colorScheme.primary,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: colorScheme.error,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: colorScheme.error,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          filled: true,
          fillColor: colorScheme.surface,
          suffixIcon: InkWell(
            onTap: togglePasswordVisibility,
            focusNode: FocusNode(skipTraversal: true),
            child: Icon(
              model.passwordVisibility
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: FlutterFlowTheme.of(context).secondaryText,
              size: 24.0,
            ),
          ),
        ),
        style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
              fontSize: getCaptionSize(context), // Increase the input text size
            ),
        validator: model.passwordControllerValidator.asValidator(context),
      ),
    ),
  );
}

Widget buildPinCodeField(
    BuildContext context, LoginModel model, WidgetRef ref) {
  bool isLandscape =
      MediaQuery.of(context).orientation == Orientation.landscape;
  final colorScheme = Theme.of(context).colorScheme;

  return Padding(
    padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
    child: SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height *
          (isLandscape ? 0.08 : 0.06), // Increase the height here
      child: TextFormField(
        onChanged: (value) {
          ref.read(authProvider.notifier).update(
                (state) => state.copyWith(pinCode: value),
              );
        },
        controller: model.pinCodeController,
        focusNode: model.textFieldFocusNode,
        autofocus: true,
        autofillHints: const [AutofillHints.oneTimeCode],
        obscureText: false,
        decoration: InputDecoration(
          labelText: FFLocalizations.of(context)
              .getText('4mj4b3yb' /* Agent PIN Code... */),
          labelStyle: FlutterFlowTheme.of(context).labelMedium.copyWith(
                fontSize: getCaptionSize(
                    context), // Increase the label (hint) text size
              ),
          hintStyle: TextStyle(
            fontSize: getCaptionSize(context), // Increase the hint text size
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: colorScheme.outline.withValues(alpha: 0.35),
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: colorScheme.primary,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          errorBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: colorScheme.error,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          focusedErrorBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: colorScheme.error,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          filled: true,
          fillColor: colorScheme.surface,
          suffixIcon: const Icon(
            Icons.calculate,
            size: 24.0,
          ),
        ),
        style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
              fontSize: getCaptionSize(context), // Increase the input text size
            ),
        keyboardType: TextInputType.number,
        validator: model.textController3Validator.asValidator(context),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9]'))],
      ),
    ),
  );
}

Widget buildTenantField(BuildContext context, LoginModel model, WidgetRef ref) {
  final colorScheme = Theme.of(context).colorScheme;
  return Padding(
    padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
    child: SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      height:
          MediaQuery.of(context).size.height * 0.06, // Increase the height here
      child: TextFormField(
        onChanged: (value) {
          ref.read(authProvider.notifier).update(
                (state) => state.copyWith(tenantId: value),
              );
        },
        controller: model.tenantController3,
        focusNode: model.tenantFieldFocusNode,
        autofocus: true,
        autofillHints: const [AutofillHints.oneTimeCode],
        obscureText: false,
        decoration: InputDecoration(
          labelText: FFLocalizations.of(context)
              .getText('tenant' /* Agent PIN Code... */),
          labelStyle: FlutterFlowTheme.of(context).labelMedium.copyWith(
                fontSize: getCaptionSize(
                    context), // Increase the label (hint) text size
              ),
          hintStyle: TextStyle(
            fontSize: getCaptionSize(context), // Increase the hint text size
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: colorScheme.outline.withValues(alpha: 0.35),
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: colorScheme.primary,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          errorBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: colorScheme.error,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          focusedErrorBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: colorScheme.error,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          filled: true,
          fillColor: colorScheme.surface,
          suffixIcon: const Icon(
            Icons.calculate,
            size: 24.0,
          ),
        ),
        style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
              fontSize: getCaptionSize(context), // Increase the input text size
            ),
        keyboardType: TextInputType.number,
        validator: model.tenantController3Validator.asValidator(context),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9]'))],
      ),
    ),
  );
}
