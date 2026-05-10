import 'package:kiosk_point_of_sale/core/config/app_config.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';

class AuthFlowConfig {
  static bool get isNewFlowEnabled => AppConfig.useNewInstallLoginFlow;

  static Future<bool> isInstallationCompleted() async {
    return AppPreferences().getInstallCompleted();
  }
}
