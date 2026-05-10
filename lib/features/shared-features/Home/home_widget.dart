// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unused_local_variable, unnecessary_new, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/confirm_back_dialog.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/custom_page_with_action_buttons.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/login_dialog.dart';
import 'package:kiosk_point_of_sale/core/config/auth_flow_config.dart';
import 'package:kiosk_point_of_sale/core/constants/zatca_constants.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_util.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_dialogs.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/core/helpers/login_helpers.dart';
import 'package:kiosk_point_of_sale/core/helpers/permission_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/responsive_helper.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/device/device_info_table.dart';
import 'package:kiosk_point_of_sale/features/shared-features/Cashier/cashier_widget.dart';
import 'package:kiosk_point_of_sale/features/shared-features/Login/login_widget.dart';
import 'package:kiosk_point_of_sale/features/shared-features/Login/new_login_widget.dart';
import 'package:kiosk_point_of_sale/features/shared-features/admin/admin_widget.dart';
import 'package:kiosk_point_of_sale/features/shared-features/settings/settings_screen.dart';
import 'package:zatca_2_invoice_generator/zatca_2_invoice_generator.dart';

class HomeWidget extends ConsumerStatefulWidget {
  static String routeName = 'Home';
  static String routePath = '/home';
  const HomeWidget({super.key});

  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends ConsumerState<HomeWidget> {
  @override
  void initState() {
    initZacta();
    initPermissions();
    super.initState();
  }

  void initPermissions() async {
    try {
      await requestAllAppPermissions();
    } catch (e) {
      dPrint(e.toString());
    }
  }

  void initZacta() async {
    final deviceInfo = await DeviceConfigTable.getDeviceInfo();
    if (deviceInfo == null) return;
    if (deviceInfo.privateKey == null ||
        deviceInfo.publicKey == null ||
        deviceInfo.vat.isEmpty) {
      return;
    }

    try {
      ZatcaManager.instance.initializeZacta(
        sellerName: deviceInfo.companyName ?? '',
        sellerTRN: deviceInfo.vat ?? '',
        privateKeyBase64: deviceInfo.privateKey ?? '',
        certificateBase64: deviceInfo.publicKey ?? '',
        supplier: Supplier(
          companyID: deviceInfo.crNumber ?? '',
          registrationName: deviceInfo.vat ?? '',
          address: Address(
            streetName: "",
            buildingNumber: "",
            citySubdivisionName: ZatcaConstants.area,
            cityName: ZatcaConstants.cityName,
            postalZone: ZatcaConstants.postalZone,
          ),
        ),
      );
    } catch (e) {
      dPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPageWithActionButtons(
      buttons: [
        ButtonSettings(
          onTap: () async {
            showAppDialog(
                context: context,
                builder: (context1) => LoginDialog(
                      path: AdminWidget.routePath,
                    ));
            // context.go('/admin-page');
          },
          title: FFLocalizations.of(context).getText('8aj1dytd'),
          icon: Icons.admin_panel_settings,
        ),
        ButtonSettings(
          onTap: () {
            context.go(CashierWidget.routePath);
          },
          title: FFLocalizations.of(context).getText('mktbrqb1'),
          icon: Icons.admin_panel_settings,
        ),
      ],
      actions: [
        // Your action widgets here
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
        IconButton(
          icon: Icon(
            Icons.settings,
            size: ResponsiveHelper.getResponsiveSize(
              context,
              24,
            ),
          ),
          onPressed: () {
            context.go(SettingsScreen.routePath);
          },
          tooltip: translator(
            arText: 'الإعدادات',
            enText: 'Settings',
          ),
        ),
      ],
      onPressedLeading: () async {
        showAppDialog(
          context: context,
          builder: (context1) => ConfirmBackDialog(
            arMsg: 'هل أنت متأكد أنك تريد تسجيل الخروج',
            enMsg: 'Are you sure you want to be logged out?',
            onAccept: () async {
              await syncOrders(ref);
              if (context1.mounted) {
                hideLoading(context1);
              }
              final useNewFlow = AuthFlowConfig.isNewFlowEnabled;
              // context.go(useNewFlow ? NewLoginWidget.routePath:LoginWidget.routePath);
              showAppDialog(
                  context: context,
                  builder: (context1) => LoginDialog(
                        path: useNewFlow ? NewLoginWidget.routePath:LoginWidget.routePath,
                      ));
            },
          ),
        );
        // context.go('/login');
        // try {
        //   showLoading(context);
        //   final bool? isSupervisor = await AuthApiService().checkIsSupervisor();
        //   if (isSupervisor != null && isSupervisor) {
        //     if (context.mounted) {
        //       hideLoading(context);
        //       context.go('/login');
        //     }
        //   } else {
        //     if (context.mounted) {
        //       hideLoading(context);
        //     }
        //     showToastError(
        //         translator(arText: 'ليس لديك صلاحية', enText: 'You don\'t have permission'));
        //   }
        // } catch (e, t) {
        //   if (context.mounted) {
        //     hideLoading(context);
        //   }
        //   dPrint(e.toString());
        //   dPrint(t.toString());
        //   showToastError('${e.toString()} : ${t.toString()}');
        // }
        // Custom back button logic
      },
      pageTitle: 'fpabqk27',
    );
  }
}
