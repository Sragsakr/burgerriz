import 'package:dio/dio.dart';
import 'package:kiosk_point_of_sale/core/constants/app_urls.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';
import 'package:kiosk_point_of_sale/data/models/coding_pattern_settings_model.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/coding_pattern/coding_pattern_settings_refund_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/coding_pattern/coding_pattern_settings_table.dart';
import 'package:kiosk_point_of_sale/data/services/remote_data/interfaces/coding_pattern_settings_api_interface.dart';

import 'base_api_service.dart';

class CodingPatternSettingsApiService extends BaseApiService
    implements CodingPatternSettingsApiInterface {
  late String _baseUrl;

  CodingPatternSettingsApiService()
      : super(
          baseUrl: '', // Will be set in initialize()
          defaultHeaders: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );

  @override
  Future<void> initialize() async {
    _baseUrl = await AppUrls.getBaseUrl();
    await super.initialize();
  }

  @override
  Future<CodingPatternSettingsModel> getSalesCodePattern() async {
    try {
      final token = await AppPreferences().getAccessToken();
      final tenantId = await AppPreferences().getTenant();
      final storeId = await AppPreferences().getStore();
      dio.options.headers.addAll({
        'abp.tenantid': tenantId,
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });
      final queryParams = {
        'storeId': storeId,
        'isRefund': 0,
      };

      final Response<Map<String, dynamic>> response = await get(
        _baseUrl + AppUrls.codingPatternGetSalesCodePattern,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data!;
        if (data['success'] == true && data['result'] is Map<String, dynamic>) {
          final codingPatternSettings = CodingPatternSettingsModel.fromMap(
              data['result'] as Map<String, dynamic>);
          await CodingPatternSettingsTable.insertAndUpdateIfExist(
              codingPatternSettings);
          return codingPatternSettings;
        }
        throw Exception('Unexpected response structure');
      }
      throw Exception('Failed to fetch coding pattern settings');
    } on DioException catch (e) {
      throw Exception('Error fetching coding pattern settings: '
          '${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<CodingPatternSettingsModel> getSalesCodePatternForRefund() async {
    try {
      final token = await AppPreferences().getAccessToken();
      final tenantId = await AppPreferences().getTenant();
      final storeId = await AppPreferences().getStore();
      dio.options.headers.addAll({
        'abp.tenantid': tenantId,
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });
      final queryParams = {
        'storeId': storeId,
        'isRefund': 1,
      };

      final Response<Map<String, dynamic>> response = await get(
        _baseUrl + AppUrls.codingPatternGetSalesCodePattern,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data!;
        if (data['success'] == true && data['result'] is Map<String, dynamic>) {
          final codingPatternSettings = CodingPatternSettingsModel.fromMap(
              data['result'] as Map<String, dynamic>);
          await CodingPatternSettingsRefundTable.insertAndUpdateIfExist(
              codingPatternSettings);
          return codingPatternSettings;
        }
        throw Exception('Unexpected response structure');
      }
      throw Exception('Failed to fetch coding pattern settings');
    } on DioException catch (e) {
      throw Exception('Error fetching coding pattern settings: '
          '${e.response?.data ?? e.message}');
    }
  }
}
