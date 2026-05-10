import 'package:dio/dio.dart';
import 'package:kiosk_point_of_sale/core/constants/app_urls.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';
import 'package:kiosk_point_of_sale/data/models/theme/device_theme_setting_model.dart';
import 'package:kiosk_point_of_sale/data/services/remote_data/interfaces/theme_setting_api_interface.dart';

import 'base_api_service.dart';

class ThemeSettingApiService extends BaseApiService
    implements ThemeSettingApiInterface {
  late String _baseUrl;

  ThemeSettingApiService()
      : super(
          baseUrl: '',
          defaultHeaders: {'Content-Type': 'application/json'},
        );

  @override
  Future<void> initialize() async {
    _baseUrl = await AppUrls.getBaseUrl();
    await super.initialize();
  }

  Future<void> _applyAuthHeaders() async {
    final token = await AppPreferences().getAccessToken();
    final tenantId = await AppPreferences().getTenant();
    if (token.isNotEmpty) {
      await addAuthToken(token);
    }
    dio.options.headers['abp.tenantId'] = tenantId;
  }

  @override
  Future<List<DeviceThemeSettingModel>> getDeviceThemesByDeviceName({
    required String deviceName,
  }) async {
    try {
      await _applyAuthHeaders();
      final response = await get<Map<String, dynamic>>(
        '$_baseUrl/api/services/app/themeSetting/GetDeviceThemesByDeviceName',
        queryParameters: {'DeviceName': deviceName},
      );
      final dynamic result = response.data?['result'];
      if (result is List) {
        return result
            .whereType<Map<String, dynamic>>()
            .map(DeviceThemeSettingModel.fromMap)
            .toList();
      }
      return <DeviceThemeSettingModel>[];
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<List<DeviceThemeSettingModel>> getDeviceThemesByClusterAndIpAddress({
    required String ipAddress,
    required int clusterId,
  }) async {
    return [];
    try {
      await _applyAuthHeaders();
      final response = await get<Map<String, dynamic>>(
        '$_baseUrl/api/services/app/themeSetting/GetDeviceThemesByClusterAndIpAddress',
        queryParameters: {
          'ipAddress': ipAddress,
          'clusterId': clusterId,
        },
      );
      final dynamic result = response.data?['result'];
      if (result is List) {
        return result
            .whereType<Map<String, dynamic>>()
            .map(DeviceThemeSettingModel.fromMap)
            .toList();
      }
      return <DeviceThemeSettingModel>[];
    } on DioException {
      rethrow;
    }
  }
}
