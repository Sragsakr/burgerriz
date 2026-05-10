import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/custom_snackbar_widget.dart';
import 'package:kiosk_point_of_sale/core/constants/font_size.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_theme.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_util.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_widgets.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/form_field_controller.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/core/helpers/login_helpers.dart';
import 'package:kiosk_point_of_sale/core/helpers/toast_utils.dart';
import 'package:kiosk_point_of_sale/data/services/remote_data/service_locator.dart';
import 'package:kiosk_point_of_sale/providers/loading_provider.dart';
import 'package:kiosk_point_of_sale/providers/login_provider.dart';
import 'package:kiosk_point_of_sale/features/shared-features/Login/login_model.dart';
import 'package:kiosk_point_of_sale/features/shared-features/Login/login_form_fields.dart';

class LoginDialog extends ConsumerStatefulWidget {
  final String? path;

  const LoginDialog({
    super.key,
    this.path,
  });

  @override
  ConsumerState<LoginDialog> createState() => LoginFormWidgetState();
}

class LoginFormWidgetState extends ConsumerState<LoginDialog> {
  late LoginModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _keyboardVisible = false;

  @override
  void initState() {
    super.initState();
    // AppPreferences().clear();
    _model = createModel(context, () => LoginModel());

    _model.emailAddressController ??= TextEditingController();
    _model.emailAddressFocusNode ??= FocusNode();
    _model.passwordController ??= TextEditingController();
    _model.passwordFocusNode ??= FocusNode();
    _model.pinCodeController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

    // Initialize with default locale, will be updated in post frame callback
    String initialDropdownValue = 'عربي'; // Default to Arabic
    _model.dropDownValue = initialDropdownValue;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        // Get stored locale asynchronously
        final currentLocale = await FFLocalizations.getStoredLocale();
        final localeDropdownValue =
            currentLocale?.languageCode == 'ar' ? 'عربي' : 'English';

        setState(() {
          _model.emailAddressController?.text = FFLocalizations.of(context)
              .getText('sqabz9sq' /* Placeholder for actual key */);
          _model.dropDownValue = localeDropdownValue;
          _model.dropDownValueController =
              FormFieldController<String>(_model.dropDownValue);
        });
      } catch (e) {
        print('LoginDialog: Error getting stored locale: $e');
        // Keep default Arabic locale
        setState(() {
          _model.emailAddressController?.text = FFLocalizations.of(context)
              .getText('sqabz9sq' /* Placeholder for actual key */);
          _model.dropDownValueController =
              FormFieldController<String>(_model.dropDownValue);
        });
      }
    });
  }

  void togglePasswordVisibility() {
    setState(() {
      _model.passwordVisibility = !_model.passwordVisibility;
    });
  }

  void togglePasswordAndPinCode() {
    setState(() {
      _model.showPinCode = !_model.showPinCode;
      if (_model.showPinCode) {
        FocusManager.instance.primaryFocus?.unfocus();
        _model.textFieldFocusNode?.requestFocus();
        _model.emailAddressController?.clear();
        _model.passwordController?.clear();
        ref.read(authProvider.notifier).update(
              (state) => state.copyWith(username: null, password: null),
            );
      } else {
        _model.pinCodeController?.clear();

        ref.read(authProvider.notifier).update(
              (state) => state.copyWith(pinCode: null),
            );
      }
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    _keyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;

    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height *
              (_model.showPinCode
                  ? (0.25 - (_keyboardVisible ? .05 : 0))
                  : 0.22 - (_keyboardVisible ? .03 : 0)),
          horizontal: 20.0),
      child: Material(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Rounded corners
        ),
        elevation: 8,
        clipBehavior: Clip.none,
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            // height: MediaQuery.of(context).size.height * 0.7,
            // constraints: const BoxConstraints(maxWidth: 400, maxHeight: 400),
            padding: const EdgeInsets.all(20),
            child: Column(
              // mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Padding(
                //   padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 5.0),
                //   child: Text(
                //     FFLocalizations.of(context)
                //         .getText('enter_tenant' /* Enter the agent pincode or Use... */),
                //     textAlign: TextAlign.center,
                //     style: FlutterFlowTheme.of(context).labelMedium.override(
                //           fontFamily: 'Readex Pro',
                //           fontSize: getBodyTextSize(context),
                //         ),
                //   ),
                // ),
                // buildTenantField(context, _model, ref),
                if (_model.showPinCode) ...[
                  SizedBox(
                    height: 50,
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        0.0, 2.0, 0.0, 24.0),
                    child: Text(
                      FFLocalizations.of(context).getText(
                          '78gfsss7' /* Enter the agent pincode or Use... */),
                      textAlign: TextAlign.center,
                      style: FlutterFlowTheme.of(context).labelMedium.override(
                            fontFamily: 'Readex Pro',
                            fontSize: getBodyTextSize(context),
                          ),
                    ),
                  ),
                  buildPinCodeField(context, _model, ref),
                ] else ...[
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        0.0, 12.0, 0.0, 5.0),
                    child: Text(
                      FFLocalizations.of(context).getText(
                          '3ggxepf3' /* Enter the agent name and passw... */),
                      textAlign: TextAlign.center,
                      style: FlutterFlowTheme.of(context).labelMedium.override(
                            fontFamily: 'Readex Pro',
                            fontSize: getBodyTextSize(context),
                          ),
                    ),
                  ),
                  buildEmailField(context, _model, ref),
                  buildPasswordField(
                      context, _model, togglePasswordVisibility, ref),
                ],
                // IconButton(
                //     onPressed: () {
                //       togglePasswordAndPinCode();
                //     },
                //     icon: const Icon(Icons.keyboard_alt_outlined,
                //         color: Color(0xFFAF2A26), size: 24)),
                _buildButton(
                  context: context,
                  textKey: FFLocalizations.of(context).getText('1tuoojz4'),
                  // LOGIN
                  onPressed: () async {
                    final authService = ref.watch(authApiServiceProvider);

                    // final tenant = await AppPreferences().getTenant();
                    final auth = ref.read(authProvider);
                    FocusScope.of(context).unfocus();
                    showLoading(context);
                    try {
                      final authResponse =
                          await authService.authenticateWithPinCode(
                        isSupervisor: true,
                        pinCode: _model.showPinCode ? auth.pinCode : '',
                        ref: ref,
                      );
                      dPrint(authResponse.toString());

                      final loginSuccess = ref.read(isSyncSuccessProvider);
                      dPrint(loginSuccess.toString());
                      if (loginSuccess) {
                        try {
                          // showLoading(context);
                          final bool isSupervisor =
                              await authService.checkIsSupervisor(
                            // tenantId: auth.tenantId,
                            token: authResponse.$1,
                          );
                          if (isSupervisor) {
                            if (widget.path != null) {
                              if (context.mounted) {
                                hideLoading(context);
                                context.go(widget.path ?? '/login');
                                return;
                              }
                            } else {
                              hideLoading(context);
                              context.canPop() ? context.pop(true) : null;
                            }
                          } else {
                            if (context.mounted) {
                              hideLoading(context);
                            }
                            showToastError(translator(
                                arText: 'ليس لديك صلاحية',
                                enText: 'You don\'t have permission'));
                          }
                        } catch (e, t) {
                          if (context.mounted) {
                            hideLoading(context);
                          }
                          dPrint(e.toString());
                          dPrint(t.toString());
                          showToastError('${e.toString()} : ${t.toString()}');
                        }
                      } else {
                        customSnackbar(context, 'Failed to login', false);
                      }
                    } catch (e, t) {
                      if (context.mounted) {
                        hideLoading(context);
                      }
                      dPrint(e.toString());
                      dPrint(t.toString());
                      showToastError('${e.toString()} : ${t.toString()}');
                      return;
                    }
                  },
                  color: colorScheme.primary,
                  textStyle: FlutterFlowTheme.of(context).titleMedium,
                  borderSide: const BorderSide(
                    color: Colors.transparent,
                    width: 1.0,
                  ),
                  hoverColor: colorScheme.primary.withValues(alpha: 0.85),
                ),
                _buildButton(
                  context: context,
                  textKey: translator(arText: 'رجوع', enText: 'Back'),
                  // EXIT
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  color: colorScheme.surface,
                  textStyle: FlutterFlowTheme.of(context).titleMedium.override(
                        fontFamily: 'Readex Pro',
                        color: colorScheme.primary,
                      ),
                  borderSide: BorderSide(
                    color: colorScheme.primary,
                    width: 1.0,
                  ),
                  hoverColor: colorScheme.primary.withValues(alpha: 0.85),
                  hoverBorderSide: BorderSide(
                    color: colorScheme.primary.withValues(alpha: 0.85),
                    width: 1.0,
                  ),
                  hoverTextColor: colorScheme.onPrimary,
                ),
                Visibility(
                    visible: _keyboardVisible,
                    child: SizedBox(
                      height: _model.showPinCode ? 100 : 150,
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required String textKey,
    required VoidCallback? onPressed,
    required Color color,
    required TextStyle textStyle,
    required BorderSide borderSide,
    Color? hoverColor,
    BorderSide? hoverBorderSide,
    Color? hoverTextColor,
  }) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
      child: FFButtonWidget(
        onPressed: onPressed,
        text: textKey,
        options: FFButtonOptions(
          width: MediaQuery.of(context).size.width * 0.8,
          height: 40.0,
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
          iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
          color: color,
          textStyle: textStyle,
          elevation: 3.0,
          borderSide: borderSide,
          borderRadius: BorderRadius.circular(12.0),
          hoverColor: hoverColor ?? color,
          hoverBorderSide: hoverBorderSide,
          hoverTextColor: hoverTextColor,
        ),
      ),
    );
  }
}
