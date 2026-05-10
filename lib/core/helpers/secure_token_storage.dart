import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';

class SecureTokenStorage {
  Future<void> saveAccessToken(String token) async {
    // TODO: Migrate to flutter_secure_storage when dependency is added.
    await AppPreferences().setAccessToken(token);
  }

  Future<String> getAccessToken() async {
    return AppPreferences().getAccessToken();
  }

  Future<void> clearAccessToken() async {
    await AppPreferences().setAccessToken('');
  }
}
