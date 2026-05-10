import 'package:dio/dio.dart';
import 'package:kiosk_point_of_sale/core/helpers/logger.dart';

const _tag = 'NetworkService';

class NetworkService {
  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
  ));

  static Future<bool> hasInternetConnection() async {
    try {
      final response = await _dio.head('https://www.google.com');
      return response.statusCode != null && response.statusCode! < 500;
    } catch (e) {
      AppLogger.warning(_tag, 'No internet connection detected');
      return false;
    }
  }

  static Future<bool> canReachUrl(String url) async {
    try {
      final response = await _dio.head(url);
      return response.statusCode != null && response.statusCode! < 500;
    } catch (e) {
      AppLogger.warning(_tag, 'Cannot reach $url');
      return false;
    }
  }
}

class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}
