import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:eitherx/eitherx.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';
import 'package:kiosk_point_of_sale/core/helpers/logger.dart';
import 'package:kiosk_point_of_sale/core/services/kds_service/http_requests.dart';
import 'package:kiosk_point_of_sale/data/models/theme/device_theme_setting_model.dart';
import 'package:kiosk_point_of_sale/data/services/remote_data/implementations/theme_setting_api_service.dart';

class ThemeRepository {
  final ThemeSettingApiService _service;
  final AppPreferences _preferences;

  ThemeRepository({
    ThemeSettingApiService? service,
    AppPreferences? preferences,
  })  : _service = service ?? ThemeSettingApiService(),
        _preferences = preferences ?? AppPreferences();

  Future<Either<Failure, List<DeviceThemeSettingModel>>> getThemes() async {
    try {
      await _service.initialize();
      final deviceName = await _preferences.getDeviceName();
      final ipAddress = await _preferences.getIp();
      final clusterId = await _preferences.getClusterId();

      List<DeviceThemeSettingModel> themes = <DeviceThemeSettingModel>[];

      if (ipAddress.isNotEmpty && clusterId > 0) {
        themes = await _service.getDeviceThemesByClusterAndIpAddress(
          ipAddress: ipAddress,
          clusterId: clusterId,
        );
      }

      if (themes.isEmpty && deviceName.isNotEmpty) {
        themes =
            await _service.getDeviceThemesByDeviceName(deviceName: deviceName);
      }

      if (themes.isNotEmpty) {
        final encoded = jsonEncode(themes.map((e) => e.toMap()).toList());
        await _preferences.setThemeSettingsCache(encoded);
        return Right(themes);
      }

      final cached = await _getCachedThemes();
      if (cached.isNotEmpty) {
        return Right(cached);
      }

      return Left(Failure(404, 'Theme settings not found'));
    } on DioException catch (error, stackTrace) {
      AppLogger.error('ThemeRepository', 'Failed to load themes from API',
          error, stackTrace);
      final cached = await _getCachedThemes();
      if (cached.isNotEmpty) {
        return Right(cached);
      }
      return Left(Failure(error.response?.statusCode ?? 500,
          error.message ?? 'Theme load failure'));
    } catch (error, stackTrace) {
      AppLogger.error('ThemeRepository', 'Unexpected theme loading failure',
          error, stackTrace);
      final cached = await _getCachedThemes();
      if (cached.isNotEmpty) {
        return Right(cached);
      }
      return Left(Failure(500, error.toString()));
    }
  }

  Future<List<DeviceThemeSettingModel>> _getCachedThemes() async {
    try {
      final raw = await _preferences.getThemeSettingsCache();
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(DeviceThemeSettingModel.fromMap)
            .toList();
      }
      return <DeviceThemeSettingModel>[];
    } catch (_) {
      return <DeviceThemeSettingModel>[];
    }
  }
}
