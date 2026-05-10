import 'package:dio/dio.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/data/models/store/device_info_model.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/device/device_info_table.dart';

import '../interfaces/app_config_api_interface.dart';
import 'base_api_service.dart';

class AppConfigApiService extends BaseApiService
    implements AppConfigApiInterface {
  static const String _baseUrl = "https://zatca.posmena.com.tr";
  static const String _username = "Posmena_mobile";
  static const String _password = "Osama_2001";

  AppConfigApiService()
      : super(
          baseUrl: _baseUrl,
          defaultHeaders: {'Content-Type': 'application/json'},
        );

  @override
  Future<String?> getAccessToken() async {
    try {
      final response = await post<Map<String, dynamic>>(
        '/api/token/',
        data: {
          "username": _username,
          "password": _password,
        },
      );

      if (response.statusCode == 200) {
        dPrint(response.data.toString());
        return response.data!["access"];
      } else {
        dPrint("Failed to retrieve access token: ${response.data}");
        return null;
      }
    } on DioException catch (e) {
      dPrint("Error getting access token: $e");
      return null;
    }
  }

  @override
  Future<String?> refreshAccessToken(String refreshToken) async {
    try {
      final response = await post<Map<String, dynamic>>(
        '/api/token/refresh/',
        data: {"refresh": refreshToken},
      );

      if (response.statusCode == 200) {
        return response.data!["access"];
      } else {
        dPrint("Failed to refresh access token: ${response.data}");
        return null;
      }
    } on DioException catch (e) {
      dPrint("Error refreshing access token: $e");
      return null;
    }
  }

  @override
  Future<List<dynamic>?> listAllDevices(String accessToken) async {
    try {
      dio.options.headers['Authorization'] = 'Bearer $accessToken';

      final response = await get<List<dynamic>>('/devices/');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        dPrint("Failed to retrieve devices: ${response.data}");
        return null;
      }
    } on DioException catch (e) {
      dPrint("Error retrieving devices: $e");
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>?> getDeviceById() async {
    try {
      final tenantId = await AppPreferences().getTenant();
      final deviceNumber = await AppPreferences().getDeviceNumber();
      final storeNumber = await AppPreferences().getStore();
      final accessToken = await getAccessToken();

      if (accessToken == null) return null;

      dio.options.headers['Authorization'] = 'Bearer $accessToken';

      final response = await get<Map<String, dynamic>>(
        '/devices/$tenantId/$storeNumber/$deviceNumber/',
      );

      if (response.statusCode == 200) {
        final device = DeviceConfigModel.fromJson(response.data!);
        await DeviceConfigTable.deleteTable();
        await DeviceConfigTable.insert(device);
        return response.data;
      } else {
        dPrint("Failed to retrieve device info: ${response.data}");
        return null;
      }
    } on DioException catch (e, t) {
      dPrint("Error retrieving device info: $e");
      dPrint("$t");
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>?> createDevice(
      String accessToken, Map<String, dynamic> deviceData) async {
    try {
      dio.options.headers['Authorization'] = 'Bearer $accessToken';

      final response = await post<Map<String, dynamic>>(
        '/devices/',
        data: deviceData,
      );

      if (response.statusCode == 201) {
        return response.data;
      } else {
        dPrint("Failed to create device: ${response.data}");
        return null;
      }
    } on DioException catch (e) {
      dPrint("Error creating device: $e");
      return null;
    }
  }
}
