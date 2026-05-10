import 'package:kiosk_point_of_sale/data/models/theme/device_theme_setting_model.dart';

abstract class ThemeSettingApiInterface {
  Future<List<DeviceThemeSettingModel>> getDeviceThemesByDeviceName({
    required String deviceName,
  });

  Future<List<DeviceThemeSettingModel>> getDeviceThemesByClusterAndIpAddress({
    required String ipAddress,
    required int clusterId,
  });
}
