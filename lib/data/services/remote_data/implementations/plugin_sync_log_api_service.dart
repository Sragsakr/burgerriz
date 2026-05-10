import 'package:dio/dio.dart';
import 'package:kiosk_point_of_sale/core/constants/app_urls.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';
import 'package:kiosk_point_of_sale/data/services/remote_data/implementations/sync_api_service.dart';

import '../interfaces/plugin_sync_log_api_interface.dart';
import 'base_api_service.dart';

/// Implementation of Plugin Sync Log API service
class PluginSyncLogApiService extends BaseApiService
    implements PluginSyncLogApiInterface {
  late String _baseUrl;
  PluginSyncLogApiService()
      : super(
          baseUrl: '', // Will be set in initialize()
          defaultHeaders: {'Content-Type': 'application/json'},
        );

  @override
  Future<void> initialize() async {
    _baseUrl = await AppUrls.getBaseUrl();
    await super.initialize();
  }

  @override
  Future<void> createPluginSyncLog({
    required String date,
  }) async {
    if (!sync) return;
    final storeId = await AppPreferences().getStore();
    final userId = await AppPreferences().getCashierId();
    try {
      final token = await AppPreferences().getAccessToken();
      final tenantId = await AppPreferences().getTenant();

      if (token.isEmpty) {
        throw Exception('Authentication token is missing.');
      }

      dio.options.headers.addAll({
        'abp.tenantid': tenantId,
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      final response = await post<dynamic>(
        _baseUrl + AppUrls.createPluginSyncLogUrl,
        data: {
          'storeId': storeId,
          'userId': userId,
          'date': date,
        },
      );

      return;
    } on DioException catch (e) {
      await handleError(e);
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions:
            RequestOptions(path: '/api/services/app/PluginSyncLog/Create'),
        error: 'Unexpected error during plugin sync log creation: $e',
      );
    }
  }
}
