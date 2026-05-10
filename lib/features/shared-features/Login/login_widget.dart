// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, unused_field
import 'dart:io';
import 'package:kiosk_point_of_sale/core/assets/app_assets.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kiosk_mode/kiosk_mode.dart';
import 'package:kiosk_point_of_sale/core/components/bt_cash_dialog.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/custom_snackbar_widget.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/loading_animation.dart';
import 'package:kiosk_point_of_sale/core/config/auth_flow_config.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_dialogs.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/core/helpers/responsive_helper.dart';
import 'package:kiosk_point_of_sale/core/services/sync_services/global_sync_service.dart';
import 'package:kiosk_point_of_sale/core/services/kiosk_mode_services/kiosk_management_service.dart';
import 'package:kiosk_point_of_sale/data/services/remote_data/service_locator.dart';
import 'package:kiosk_point_of_sale/providers/loading_provider.dart';
import 'package:kiosk_point_of_sale/providers/login_provider.dart';
import 'package:kiosk_point_of_sale/features/shared-features/Login/login_model.dart';
import 'package:kiosk_point_of_sale/features/shared-features/Login/new_login_widget.dart';
import 'package:kiosk_point_of_sale/features/shared-features/Cashier/cashier_widget.dart';
import 'package:kiosk_point_of_sale/features/shared-features/Home/home_widget.dart';

import '../../../core/flutter_flow/flutter_flow_theme.dart';
import '../../../core/flutter_flow/flutter_flow_util.dart';
import '../../../core/flutter_flow/form_field_controller.dart';
import '../../../core/helpers/login_helpers.dart';
import 'login_button_row.dart';
import 'login_footer_widget.dart';
import 'login_form_widget.dart';

export 'login_model.dart';

class LoginWidget extends ConsumerStatefulWidget {
  static String routeName = 'Login';
  static String routePath = '/login';
  const LoginWidget({super.key});

  @override
  ConsumerState<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends ConsumerState<LoginWidget> {
  late LoginModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _hasInitialized = false; // Add flag to track initialization

  @override
  void initState() {
    super.initState();
    if (AuthFlowConfig.isNewFlowEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.go(NewLoginWidget.routePath);
      });
    }

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
        final localeDropdownValue = currentLocale?.languageCode == 'ar' ? 'عربي' : 'English';

        setState(() {
          _model.emailAddressController?.text =
              FFLocalizations.of(context).getText('sqabz9sq' /* Placeholder for actual key */);
          _model.dropDownValue = localeDropdownValue;
          _model.dropDownValueController = FormFieldController<String>(_model.dropDownValue);
          dPrint("Current locale: ${currentLocale?.languageCode}");
          dPrint("Stored locale: ${_model.dropDownValue}");
          dPrint("Initial dropdown value: ${_model.dropDownValueController?.value}");
        });

        // Disable kiosk mode during login
        await _disableKioskMode();
      } catch (e) {
        print('LoginWidget: Error getting stored locale: $e');
        // Keep default Arabic locale
        setState(() {
          _model.emailAddressController?.text =
              FFLocalizations.of(context).getText('sqabz9sq' /* Placeholder for actual key */);
          _model.dropDownValueController = FormFieldController<String>(_model.dropDownValue);
        });
      }
    });
  }

  // Disable kiosk mode during login
  Future<void> _disableKioskMode() async {
    try {
      final currentMode = await getKioskMode();
      if (currentMode == KioskMode.enabled) {
        dPrint('Disabling kiosk mode during login...');
        await KioskManagementService().stopKiosk();
        dPrint('Kiosk mode disabled during login');
      }
    } catch (e) {
      dPrint('Error disabling kiosk mode during login: $e');
    }
  }

  // Enable kiosk mode after successful login
  Future<void> _enableKioskModeAfterLogin() async {
    try {
      dPrint('Enabling kiosk mode after successful login...');
      final didStart = await KioskManagementService().startKiosk();
      if (didStart) {
        dPrint('Kiosk mode enabled after successful login');
      } else {
        dPrint('Failed to enable kiosk mode after login');
      }
    } catch (e) {
      dPrint('Error enabling kiosk mode after login: $e');
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final servicesState = ref.watch(servicesNotifierProvider);

        // Trigger initialization if not already done
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_hasInitialized && servicesState is AsyncData && servicesState.value == null) {
            _hasInitialized = true; // Set flag to prevent re-initialization
            ref.read(servicesNotifierProvider.notifier).initializeServices();
          }
        });

        return servicesState.when(
          data: (_) => screenContent(context),
          loading: () => const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
          error: (error, stack) => MaterialApp(
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error initializing services: $error'),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(servicesNotifierProvider.notifier).reinitializeServices();
                      },
                      child: Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  GestureDetector screenContent(BuildContext context) {
    return GestureDetector(
      onTap: () => _model.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_model.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                width: double.infinity,
                height: 140.0,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16.0),
                    bottomRight: Radius.circular(16.0),
                    topLeft: Radius.circular(0.0),
                    topRight: Radius.circular(0.0),
                  ),
                ),
                alignment: AlignmentDirectional(-1.0, 0.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Align(
                      alignment: AlignmentDirectional(0.0, 0.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset(
                          AppAssets.newLogo,
                          width: ResponsiveHelper.getResponsiveSize(context, 193.0),
                          height: ResponsiveHelper.getResponsiveSize(context, 136.0),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  LoginFormWidget(model: _model),
                  SizedBox(height: ResponsiveHelper.getResponsiveSize(context, 16.0)),
                  LoginButtonRow(
                    isLoginButtonEnabled: true,
                    onLoginPressed: () async {
                      ValueNotifier<double> progressNotifier = ValueNotifier(0.0);
                      setState(() {
                        isShiftClosed = false;
                      });
                      await syncOrders(ref);
                      await AppPreferences().setAccessToken("");
                      final auth = ref.read(authProvider);
                      final authService = ref.watch(authApiServiceProvider);
                      final cashierShiftService = ref.watch(cashierShiftApiServiceProvider);

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
                      try {
                        final authResponse = await authService.authenticateWithPinCode(
                          // username: auth.username,
                          // password: auth.password,
                          pinCode: auth.pinCode,
                          ref: ref,
                        );

                        final loginSuccess = ref.read(isSyncSuccessProvider);
                        dPrint(loginSuccess.toString());
                        if (loginSuccess) {
                          if (auth.pinCode.isEmpty) {
                            await AppPreferences().setUsername(auth.username);
                            await AppPreferences().setPassword(auth.password);
                          } else {
                            await AppPreferences().setPinCode(auth.pinCode);
                          }
                          await AppPreferences().setAccessToken(authResponse.$1);
                          await AppPreferences().setCashierId(authResponse.$2);
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
                            // context.go(useNewFlow ? NewLoginWidget.routePath:LoginWidget.routePath);
                            // showAppDialog(
                            //     context: context,
                            //     builder: (context1) => LoginDialog(
                            //       path: useNewFlow ? NewLoginWidget.routePath:LoginWidget.routePath,
                            //     ));
                            context.pushReplacementNamed(useNewFlow ? NewLoginWidget.routePath:LoginWidget.routePath);
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

                          // Initialize kiosk mode after successful login
                          try {
                            // await _enableKioskModeAfterLogin();
                          } catch (e, t) {
                            dPrint("Error initializing kiosk mode after login: $e");
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
                        } else {
                          hideLoading(context);
                          customSnackbar(context, 'Failed to login', false);
                        }
                      } catch (e, t) {
                        dPrint(e.toString());
                        dPrint(t.toString());
                        hideLoading(context);
                        customSnackbar(context, 'Failed to login $e', false);
                      }
                    },
                    onExitPressed: () => exit(0),
                  ),
                ],
              ),
              LoginFooterWidget(
                dropDownValueController: _model.dropDownValueController!,
                dropDownValue: _model.dropDownValue!,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
