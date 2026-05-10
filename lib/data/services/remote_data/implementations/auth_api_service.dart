import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiosk_point_of_sale/core/config/app_config.dart';
import 'package:kiosk_point_of_sale/core/constants/app_urls.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/providers/loading_provider.dart';

import '../interfaces/auth_api_interface.dart';
import 'base_api_service.dart';

class AuthApiService extends BaseApiService implements AuthApiInterface {
  late String _baseUrl;
  bool _isInitialized = false;

  AuthApiService()
      : super(
          baseUrl: '', // Will be set in initialize()
          defaultHeaders: {'Content-Type': 'application/json'},
        );

  @override
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }
    _baseUrl = await AppUrls.getBaseUrl();
    dPrint('Auth API Base URL: $_baseUrl');
    await super.initialize();
    _isInitialized = true;
  }

  @override
  Future<(String token, int userId)> authenticateWithCredentials({
    required String username,
    required String password,
    required WidgetRef ref,
  }) async {
    await initialize();
    try {
      ref.read(loadingProvider.notifier).reset();
      final tenantId = await AppPreferences().getTenant();
      dio.options.headers['abp.tenantid'] = tenantId;

      final response = await post<Map<String, dynamic>>(
        _baseUrl + AppUrls.authUrl,
        data: {
          "userNameOrEmailAddress": username,
          "password": password,
        },
      );

      if (response.statusCode == 200) {
        ref.read(isSyncSuccessProvider.notifier).state = true;
        ref.read(loadingProvider.notifier).updateProgress(0.3);

        final result = response.data!['result'];
        return (
          result['accessToken'] as String,
          result['userId'] as int,
        );
      } else {
        ref.read(isSyncSuccessProvider.notifier).state = false;
        throw Exception('Authentication failed. Status Code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      ref.read(isSyncSuccessProvider.notifier).state = false;
      throw Exception('Authentication failed: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<(String token, int userId)> authenticateWithPinCode({
    required String pinCode,
    required WidgetRef ref,
    bool isSupervisor = false,
  }) async {
    await initialize();
    try {
      ref.read(loadingProvider.notifier).reset();
      final tenantId = await AppPreferences().getTenant();
      final deviceName = await AppPreferences().getDeviceName();
      final storeId = await AppPreferences().getStore();

      dio.options.headers['abp.tenantid'] = tenantId;
      Map<String, dynamic> data = {"pinCode": pinCode};
      if (deviceName.isNotEmpty && !isSupervisor && AppConfig.isKiosk) {
        data.addAll({"selfServiceDeviceName": deviceName.toLowerCase()});
        data.addAll({"kioskMode": true});
      }
      final response = await post<Map<String, dynamic>>(
        _baseUrl + AppUrls.authPinCodeUrl,
        data: data,
      );

      if (response.statusCode == 200) {
        ref.read(isSyncSuccessProvider.notifier).state = true;
        ref.read(loadingProvider.notifier).updateProgress(0.3);

        final result = response.data!['result'];
        final userName = result['userName'];
        await AppPreferences().setUsername(userName);
        final List<dynamic> stores = result["userStoreIds"];
        dPrint("storeId is $storeId stores is $stores");
        bool isStoreValid = stores.any((e) => e.toString() == storeId);
        if (isStoreValid) {
          return (
            result['accessToken'] as String? ?? '',
            result['userId'] as int,
          );
        } else {
          ref.read(isSyncSuccessProvider.notifier).state = false;
          throw Exception(
              translator(arText: "المستخدم غير مسجل علي هذا المتجر", enText: "User is Not Register on this store"));
        }
      } else {
        ref.read(isSyncSuccessProvider.notifier).state = false;
        throw Exception('PIN authentication failed. Status Code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      ref.read(isSyncSuccessProvider.notifier).state = false;
      throw Exception('PIN authentication failed: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<bool> checkIsSupervisor({
    required String token,
  }) async {
    await initialize();
    try {
      final tenantId = await AppPreferences().getTenant();
      dio.options.headers['abp.tenantid'] = tenantId;
      dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await get<Map<String, dynamic>>(
        _baseUrl + AppUrls.checkSupervisorUrl,
      );

      if (response.statusCode == 200) {
        return response.data!['result'] as bool;
      } else {
        throw Exception('Failed to check supervisor status. Status Code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to check supervisor status: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<void> logout() async {
    await initialize();
    try {
      await AppPreferences().clear();
      await removeAuthToken();
    } catch (e) {
      throw Exception('Failed to logout: $e');
    }
  }
}
