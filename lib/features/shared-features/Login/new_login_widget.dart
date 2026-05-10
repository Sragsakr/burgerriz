import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kiosk_point_of_sale/core/assets/app_assets.dart';
import 'package:kiosk_point_of_sale/core/components/bt_cash_dialog.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/custom_snackbar_widget.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/loading_animation.dart';
import 'package:kiosk_point_of_sale/core/config/auth_flow_config.dart';
import 'package:kiosk_point_of_sale/core/constants/font_size.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_theme.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/form_field_controller.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/internationalization.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_dialogs.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/core/helpers/login_helpers.dart';
import 'package:kiosk_point_of_sale/core/helpers/responsive_helper.dart';
import 'package:kiosk_point_of_sale/core/services/sync_services/global_sync_service.dart';
import 'package:kiosk_point_of_sale/data/services/remote_data/service_locator.dart';
import 'package:kiosk_point_of_sale/features/shared-features/Cashier/cashier_widget.dart';
import 'package:kiosk_point_of_sale/features/shared-features/Home/home_widget.dart';
import 'package:kiosk_point_of_sale/features/shared-features/Login/login_button_row.dart';
import 'package:kiosk_point_of_sale/features/shared-features/Login/login_footer_widget.dart';
import 'package:kiosk_point_of_sale/features/shared-features/Login/login_widget.dart';
import 'package:kiosk_point_of_sale/features/shared-features/Login/new_login_controller.dart';

class NewLoginWidget extends ConsumerStatefulWidget {
  static const routeName = 'NewLogin';
  static const routePath = '/login-v2';

  final NewLoginController? controller;

  const NewLoginWidget({super.key, this.controller});

  @override
  ConsumerState<NewLoginWidget> createState() => _NewLoginWidgetState();
}

class _NewLoginWidgetState extends ConsumerState<NewLoginWidget> {
  late final NewLoginController _controller;
  late final bool _ownsController;
  final _pinFocusNode = FocusNode();
  final _pinController = TextEditingController();

  String _dropDownValue = 'عربي';
  late final FormFieldController<String> _dropDownValueController;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
      _ownsController = false;
    } else {
      _controller = NewLoginController();
      _ownsController = true;
    }

    _dropDownValueController = FormFieldController<String>(_dropDownValue);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final currentLocale = await FFLocalizations.getStoredLocale();
        final localeDropdownValue = currentLocale?.languageCode == 'ar' ? 'عربي' : 'English';
        if (!mounted) return;
        setState(() {
          _dropDownValue = localeDropdownValue;
          _dropDownValueController.value = localeDropdownValue;
        });
      } catch (_) {
        // Keep default Arabic dropdown label
      }
    });
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    _pinFocusNode.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Widget _buildPinField(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * (isLandscape ? 0.08 : 0.06),
        child: TextFormField(
          controller: _pinController,
          focusNode: _pinFocusNode,
          autofocus: true,
          autofillHints: const [AutofillHints.oneTimeCode],
          obscureText: false,
          decoration: InputDecoration(
            labelText: FFLocalizations.of(context).getText('4mj4b3yb' /* Agent PIN Code... */),
            labelStyle: FlutterFlowTheme.of(context).labelMedium.copyWith(
                  fontSize: getCaptionSize(context),
                ),
            hintStyle: TextStyle(
              fontSize: getCaptionSize(context),
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
                fontSize: getCaptionSize(context),
              ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp('[0-9]')),
          ],
          onFieldSubmitted: (_) => _submitLogin(context),
        ),
      ),
    );
  }

  Future<void> _submitLogin(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final l10n = FFLocalizations.of(context);
    final ok = await _controller.login(
      _pinController.text,
      l10n.getText,
    );
    if (!context.mounted) return;
    if (!ok) {
      final msg = _controller.state.errorMessage;
      if (msg != null && msg.isNotEmpty) {
        customSnackbar(context, msg, false);
      }
      return;
    }
await _syncData(context);
    final token = await AppPreferences().getAccessToken();
    if (token.isNotEmpty && context.mounted) {
      context.go(HomeWidget.routePath);
    }
  }

  _syncData(BuildContext context) async {
    try {
      final progressNotifier = ValueNotifier<double>(0.0);
      await ref.read(servicesNotifierProvider.notifier).initializeServices();
      final cashierShiftService = ref.read(cashierShiftApiServiceProvider);
      setState(() {
        isShiftClosed = false;
      });

      await syncOrders(ref);
      FocusScope.of(context).unfocus();
      showAppDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return LoadingPopup(
            progressNotifier: progressNotifier,
            message: translator(arText: "جاري تحميل البيانات", enText: "Sync Data"),
          );
        },
      );
      final isShiftOpened = await cashierShiftService.isHaveOpenedShift();
      try {
        await cashierShiftService.startShift();
      } catch (e, t) {
        dPrint("errrrr is $e isLogin");
        dPrint(e.toString());
        dPrint(t.toString());
        hideLoading(context);
        customSnackbar(context, '$e', false);
        final useNewFlow = AuthFlowConfig.isNewFlowEnabled;
        // // context.go(useNewFlow ? NewLoginWidget.routePath:LoginWidget.routePath);
        // showAppDialog(
        //     context: context,
        //     builder: (context1) => LoginDialog(
        //       path:useNewFlow ? NewLoginWidget.routePath:LoginWidget.routePath,
        //     ));
        context.pushReplacementNamed(LoginWidget.routeName);
        return;
      }

      await syncMenuData(context, ref, progressNotifier);

      // Start global sync service after successful login
      try {
        final globalSyncService = ref.read(globalSyncServiceProvider);
        globalSyncService.initialize(ref);
        dPrint("Global sync service started after login");
      } catch (e, t) {
        dPrint("Error starting global sync after login: $e");
        dPrint("Stack trace: $t");
      }

      await AppPreferences().setCurrentInvoice(0);
      hideLoading(context);
      if (!context.mounted) return;
      context.pushReplacementNamed(HomeWidget.routeName);
      dPrint("Login successful");

      if (!isShiftOpened) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
          await showBTCashDialog(context);
        });
      }
    } catch (e, t) {
      dPrint("Error in _syncData: $e");
      dPrint("Stack trace: $t");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Scaffold(
            backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
            body: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    width: double.infinity,
                    height: 200.0,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16.0),
                        bottomRight: Radius.circular(16.0),
                        topLeft: Radius.circular(0.0),
                        topRight: Radius.circular(0.0),
                      ),
                    ),
                    alignment: const AlignmentDirectional(-1.0, 0.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Align(
                          alignment: const AlignmentDirectional(0.0, 0.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.asset(
                              AppAssets.newLogo,
                              width: ResponsiveHelper.getResponsiveSize(context, 200.0),
                              height: ResponsiveHelper.getResponsiveSize(context, 200.0),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Column(
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
                            FFLocalizations.of(context).getText('t9abm3vl' /* To POINT Of SALE */),
                            style: FlutterFlowTheme.of(context).displaySmall.override(
                                  fontFamily: 'Outfit',
                                  fontSize: getHeading1Size(context),
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 2.0, 0.0, 24.0),
                            child: Text(
                              FFLocalizations.of(context).getText('78gfsss7' /* Enter the agent pincode or Use... */),
                              textAlign: TextAlign.center,
                              style: FlutterFlowTheme.of(context).labelMedium.override(
                                    fontFamily: 'Readex Pro',
                                    fontSize: getBodyTextSize(context),
                                  ),
                            ),
                          ),
                          _buildPinField(context),
                        ],
                      ),
                      SizedBox(height: ResponsiveHelper.getResponsiveSize(context, 16.0)),
                      LoginButtonRow(
                        isLoginButtonEnabled: !_controller.state.isLoading,
                        onLoginPressed: () => _submitLogin(context),
                        onExitPressed: () => exit(0),
                      ),
                    ],
                  ),
                  LoginFooterWidget(
                    dropDownValueController: _dropDownValueController,
                    dropDownValue: _dropDownValue,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
