// ignore_for_file: deprecated_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/confirm_back_dialog.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/login_dialog.dart';
import 'package:kiosk_point_of_sale/core/config/auth_flow_config.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_dialogs.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/core/helpers/login_helpers.dart';
import 'package:kiosk_point_of_sale/core/helpers/responsive_helper.dart';
import 'package:kiosk_point_of_sale/features/shared-features/Install/install_widget_kiosk.dart';
import 'package:kiosk_point_of_sale/features/shared-features/Install/new_install_widget.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/flutter_flow/flutter_flow_drop_down.dart';
import '../../../core/flutter_flow/flutter_flow_theme.dart';
import '../../../core/flutter_flow/flutter_flow_util.dart';
import '../../../core/flutter_flow/form_field_controller.dart';

class LoginFooterWidget extends ConsumerWidget {
  final FormFieldController<String> dropDownValueController;
  final String dropDownValue;

  const LoginFooterWidget({
    super.key,
    required this.dropDownValueController,
    required this.dropDownValue,
  });

  Future<(String, String)> getVersionData() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;
    // dPrint("version $version buildNumber $buildNumber");
    return (version, buildNumber);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 12.0),
          child: TextButton(
            onPressed: () {
              if (kDebugMode) {
                context.go(InstallWidgetKiosk.routePath);
                return;
              }
              showAppDialog(
                context: context,
                builder: (context1) => ConfirmBackDialog(
                  arMsg: 'هل أنت متأكد أنك تريد العودة للتثبيت؟',
                  enMsg: 'Are you sure you want to go to install mode?',
                  onAccept: () {
                    hideLoading(context1);
                    showAppDialog(
                        context: context,
                        builder: (context1) =>   LoginDialog(
                              path:  AuthFlowConfig.isNewFlowEnabled ? NewInstallWidget.routePath:InstallWidgetKiosk.routePath
                          ,
                            ));
                  },
                ),
              );
            },
            child: FutureBuilder<(String, String)>(
                future: getVersionData(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final versionData = snapshot.data;
                    return RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '11.05.2026',
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getResponsiveSize(context, 16.0),
                            ),
                          ),
                          TextSpan(
                            text: "  V-${versionData?.$1} - (${versionData?.$2}) ",
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  fontFamily: 'Readex Pro',
                                  color: FlutterFlowTheme.of(context).primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: ResponsiveHelper.getResponsiveSize(context, 16.0),
                                ),
                          ),
                        ],
                        style: FlutterFlowTheme.of(context).bodyMedium,
                      ),
                      textScaler: TextScaler.linear(MediaQuery.of(context).textScaleFactor),
                    );
                  } else if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  } else {
                    return const SizedBox();
                  }
                }),
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(10.0, 0.0, 0.0, 0.0),
          child: FlutterFlowDropDown<String>(
            controller: dropDownValueController,
            options: const ['English', 'عربي'],
            onChanged: (val) async {
              dPrint('val is $val');
              String languageCode = val == 'عربي' ? 'ar' : 'en';
              await switchAppLanguage(ref, context, newLang: languageCode);
            },
            width: ResponsiveHelper.isTablet(context) ? 160.0 : 130.0,
            height: ResponsiveHelper.isTablet(context) ? 60 : 35.0,
            textStyle: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                  fontSize: ResponsiveHelper.getResponsiveSize(context, 16.0),
                ),
            hintText: FFLocalizations.of(context).getText('g1fsz32d' /* Please select... */),
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: FlutterFlowTheme.of(context).secondaryText,
              size: 24.0,
            ),
            fillColor: FlutterFlowTheme.of(context).secondaryBackground,
            elevation: 2.0,
            borderColor: FlutterFlowTheme.of(context).alternate,
            borderWidth: 2.0,
            borderRadius: 8.0,
            margin: const EdgeInsetsDirectional.fromSTEB(16.0, 4.0, 16.0, 4.0),
            hidesUnderline: true,
            isSearchable: false,
            isMultiSelect: false,
          ),
        ),
      ],
    );
  }
}
