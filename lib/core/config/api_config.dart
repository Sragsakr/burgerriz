import 'package:kiosk_point_of_sale/core/constants/app_urls.dart';

class ApiConfig {
  ApiConfig._();

  static String? baseUrl;

  static Future<void> init() async {
    baseUrl = await AppUrls.getBaseUrl();
  }
}
