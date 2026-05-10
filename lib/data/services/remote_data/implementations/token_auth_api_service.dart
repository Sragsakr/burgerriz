import 'package:dio/dio.dart';
import 'package:kiosk_point_of_sale/core/constants/app_urls.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';
import 'package:kiosk_point_of_sale/data/models/auth/device_auth_models.dart';
import 'package:kiosk_point_of_sale/data/models/auth/device_install_models.dart';
import 'package:kiosk_point_of_sale/data/services/remote_data/interfaces/token_auth_api_interface.dart';

import 'base_api_service.dart';

class TokenAuthApiService extends BaseApiService implements TokenAuthApiInterface {
  late String _baseUrl;

  TokenAuthApiService()
      : super(
          baseUrl: '',
          defaultHeaders: {'Content-Type': 'application/json'},
        );

  @override
  Future<void> initialize() async {
    _baseUrl = await AppUrls.getBaseUrl();
    await super.initialize();
  }

  @override
  Future<ValidateInstallationInfoResponse> validateInstallationInfo({
    required ValidateInstallationInfoRequest request,
  }) async {
    final tenantId = await AppPreferences().getTenant();
    if (tenantId.isNotEmpty) {
      dio.options.headers['abp.tenantId'] = tenantId;
    }
    try {
      final response = await get<Map<String, dynamic>>(
        _baseUrl + AppUrls.validateInstallationInfoUrl,
        queryParameters: {
          'ipAddress': request.ipAddress,
          'clusterId': request.clusterId,
          'tenderTypeId': request.tenderTypeId,
        },
        
      );

      final body = response.data ?? {};
      final result = (body['result'] as Map<String, dynamic>?) ?? body;
      return ValidateInstallationInfoResponse.fromJson(result);
    } on DioException catch (e) {
      throw Exception('ValidateInstallationInfo failed: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<AuthenticateDeviceByPinResponse> authenticateDeviceByPinCode({
    required AuthenticateDeviceByPinRequest request,
  }) async {
    try {
      final tenantId = await AppPreferences().getTenant();
      if (tenantId.isNotEmpty) {
        dio.options.headers['abp.tenantId'] = tenantId;
      }
      final response = await post<Map<String, dynamic>>(
        _baseUrl + AppUrls.authenticateDeviceByPinCodeUrl,
        data: request.toJson(),
      );

      final body = response.data ?? {};
      final result = (body['result'] as Map<String, dynamic>?) ?? body;
      return AuthenticateDeviceByPinResponse.fromJson(result);
    } on DioException catch (e) {
      throw Exception('AuthenticateDeviceByPinCode failed: ${e.response?.data ?? e.message}');
    }
  }
}
