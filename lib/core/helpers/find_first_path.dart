import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';
import 'package:kiosk_point_of_sale/core/config/auth_flow_config.dart';
import 'package:kiosk_point_of_sale/features/shared-features/Install/install_widget_kiosk.dart';
import 'package:kiosk_point_of_sale/features/shared-features/Login/login_widget.dart';
import 'package:kiosk_point_of_sale/features/shared-features/Install/new_install_widget.dart';
import 'package:kiosk_point_of_sale/features/shared-features/Login/new_login_widget.dart';

Future<String> checkValues() async {
  if (AuthFlowConfig.isNewFlowEnabled) {
    final isInstallCompleted = await AppPreferences().getInstallCompleted();
    if (isInstallCompleted) {
      return NewLoginWidget.routePath;
    }
    return NewInstallWidget.routePath;
  }

  final String tenant = await AppPreferences().getTenant();
  final String store = await AppPreferences().getStore();
  final String tenderType = await AppPreferences().getTenderType();
  final String natural = await AppPreferences().getEnvironmentType(); // Added
  final String timeZone = await AppPreferences().geTimeZone(); // Added
  final String loginMethod = await AppPreferences().getLoginMethod(); // Added
  final String syncInterval = await AppPreferences().getSyncInterval();

  if (tenant.isNotEmpty &&
      store.isNotEmpty &&
      tenderType.isNotEmpty &&
      natural.isNotEmpty &&
      timeZone.isNotEmpty &&
      loginMethod.isNotEmpty &&
      syncInterval.isNotEmpty) {
    return LoginWidget.routePath;
  } else {
    return InstallWidgetKiosk.routePath;
  }
}
