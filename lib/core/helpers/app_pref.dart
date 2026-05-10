import 'dart:convert';

import 'package:kiosk_point_of_sale/data/models/kds_device_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';

class AppPreferences {
  // Singleton instance
  static final AppPreferences _instance = AppPreferences._internal();

  SharedPreferences? _prefs;

  // Private constructor
  AppPreferences._internal();

  // Factory constructor
  factory AppPreferences() => _instance;

  // Initialize SharedPreferences (Call this once in main.dart)
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs => _prefs!;
  // Generic Save Method
  Future<void> _setValue<T>(String key, T value) async {
    if (_prefs == null) throw Exception("AppPreferences not initialized");
    if (value is String) await _prefs!.setString(key, value);
    if (value is int) await _prefs!.setInt(key, value);
    if (value is double) await _prefs!.setDouble(key, value);
    if (value is bool) await _prefs!.setBool(key, value);
    if (value is List<String>) await _prefs!.setStringList(key, value);
  }

  // Generic Retrieve Method
  Future<T> _getValue<T>(String key, T defaultValue) async {
    if (_prefs == null) throw Exception("AppPreferences not initialized");
    final value = _prefs!.get(key);
    return (value is T) ? value : defaultValue;
  }

  // Remove Key
  Future<bool> remove(String key) async {
    if (_prefs == null) throw Exception("AppPreferences not initialized");
    return await _prefs!.remove(key);
  }

  // Clear All Keys
  Future<bool> clear() async {
    if (_prefs == null) throw Exception("AppPreferences not initialized");
    return await _prefs!.clear();
  }

  // Public methods for boolean operations
  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    return await _getValue<bool>(key, defaultValue);
  }

  Future<void> setBool(String key, bool value) async {
    await _setValue<bool>(key, value);
  }

  // Define Your Keys and Values

  // Language
  Future<String> getLanguage() async {
    final language = await _getValue('language', 'en'); // Default: English
    dPrint("AppPreferences.getLanguage() - Retrieved: $language");
    return language;
  }

  Future<void> setLanguage(String value) async {
    dPrint("AppPreferences.setLanguage() - Setting: $value");
    await _setValue('language', value);
  }

  // printing mode (network or bluetooth)
  Future<String> getPrintMode() async => await _getValue('printMode', '');

  Future<void> setPrintMode(String value) async =>
      await _setValue('printMode', value);

  // printer mode (bluetooth/network)
  Future<String> getPrinterMode() async =>
      await _getValue('printerMode', 'bluetooth');

  Future<void> setPrinterMode(String value) async =>
      await _setValue('printerMode', value);

// printer ip
  Future<String> getPrinterIp() async => await _getValue('printerIp', '');

  Future<void> setPrinterIp(String value) async =>
      await _setValue('printerIp', value);

  // KDS ip
  Future<String> getKdsIp() async => await _getValue('kdsIp', '');

  Future<void> setKdsIp(String value) async => await _setValue('kdsIp', value);
  // deviceName
  Future<String> getDeviceName() async => await _getValue('DeviceName', '');

  Future<void> setDeviceName(String value) async =>
      await _setValue('DeviceName', value);

  // deviceNumber
  Future<String> getDeviceNumber() async => await _getValue('DeviceNumber', '');

  Future<void> setDeviceNumber(String value) async =>
      await _setValue('DeviceNumber', value);

  // tenant
  Future<String> getTenant() async => await _getValue('tenant', '');

  Future<void> setTenant(String value) async =>
      await _setValue('tenant', value); // tenant
  Future<String> getVersion() async => await _getValue('version', 'v1');

  Future<void> setVersion(String value) async =>
      await _setValue('version', value);

  // Notification
  Future<String> getStore() async => await _getValue('store', '');

  Future<void> setStore(String value) async => await _setValue('store', value);
  // tenderType
  Future<String> getTenderType() async => await _getValue('tenderType', '');

  Future<void> setTenderType(String value) async =>
      await _setValue('tenderType', value);
  // natural
  Future<String> getNatural() async => await _getValue('natural', '');

  Future<void> setNatural(String value) async =>
      await _setValue('natural', value);
  // timeZone
  Future<String> geTimeZone() async => await _getValue('timeZone', '');

  Future<void> setTimeZone(String value) async =>
      await _setValue('timeZone', value);

  // setEnvironmentType
  Future<String> getEnvironmentType() async =>
      await _getValue('EnvironmentType', '');

  Future<void> setEnvironmentType(String value) async =>
      await _setValue('EnvironmentType', value);
  // loginMethod
  Future<String> getLoginMethod() async => await _getValue('loginMethod', '');

  Future<void> setLoginMethod(String value) async =>
      await _setValue('loginMethod', value);
  // syncInterval
  Future<String> getSyncInterval() async =>
      await _getValue('syncInterval', '0');

  Future<void> setSyncInterval(String value) async =>
      await _setValue('syncInterval', value);

  // syncInterval
  Future<bool> getWorkWithZacta() async =>
      await _getValue('WorkWithZacta', true);

  Future<void> setSecWorkWithZacta(bool value) async =>
      await _setValue('WorkWithZacta', value);
  // syncInterval
  Future<String> getSecLanguage() async => await _getValue('SecLanguage', '');

  Future<void> setSecLanguage(String value) async =>
      await _setValue('SecLanguage', value);
  // syncInterval
  Future<String> getIp() async => await _getValue('IP', '');

  Future<void> setIp(String value) async => await _setValue('IP', value);
  Future<String> getThemeSettingsCache() async =>
      await _getValue('themeSettingsCache', '[]');

  Future<void> setThemeSettingsCache(String value) async =>
      await _setValue('themeSettingsCache', value);
  // username
  Future<String> getUsername() async => await _getValue('username', '');

  Future<void> setUsername(String value) async =>
      await _setValue('username', value);
  // password
  Future<String> getPassword() async => await _getValue('password', '');

  Future<void> setPassword(String value) async =>
      await _setValue('password', value);
  // PinCode
  Future<String> getPinCode() async => await _getValue('PinCode', '');

  Future<void> setPinCode(String value) async =>
      await _setValue('PinCode', value);
  // cashierId
  Future<int> getCashierId() async => await _getValue('cashierId', 0);

  Future<void> setCashierId(int value) async =>
      await _setValue('cashierId', value);
  Future<int> getZatcaTokenExpiry() async =>
      await _getValue('zatcaTokenExpiry', 0);

  Future<void> setZatcaTokenExpiry(int value) async =>
      await _setValue('zatcaTokenExpiry', value);
  // cashierId
  Future<String> getAccessToken() async => await _getValue('accessToken', "");

  setAccessToken(String value) async => await _setValue('accessToken', value);
  Future<int> getExpireInSeconds() async =>
      await _getValue('expireInSeconds', 0);

  Future<void> setExpireInSeconds(int value) async =>
      await _setValue('expireInSeconds', value);
  Future<int> getLoginUserId() async => await _getValue('loginUserId', 0);

  Future<void> setLoginUserId(int value) async =>
      await _setValue('loginUserId', value);
  Future<String> getLoginUserName() async =>
      await _getValue('loginUserName', '');

  Future<void> setLoginUserName(String value) async =>
      await _setValue('loginUserName', value);
  Future<int> getInstallTenantId() async =>
      await _getValue('installTenantId', 0);

  Future<void> setInstallTenantId(int value) async =>
      await _setValue('installTenantId', value);
  Future<int> getInstallStoreId() async => await _getValue('installStoreId', 0);

  Future<void> setInstallStoreId(int value) async =>
      await _setValue('installStoreId', value);
  Future<int> getInstallDeviceType() async =>
      await _getValue('installDeviceType', 0);

  Future<void> setInstallDeviceType(int value) async =>
      await _setValue('installDeviceType', value);
  Future<int> getClusterId() async => await _getValue('clusterId', 0);

  Future<void> setClusterId(int value) async =>
      await _setValue('clusterId', value);
  Future<bool> getInstallCompleted() async =>
      await _getValue('installCompleted', false);

  Future<void> setInstallCompleted(bool value) async =>
      await _setValue('installCompleted', value);
  Future<int> getTenantDataId() async => await _getValue('tenantDataId', 0);

  Future<void> setTenantDataId(int value) async =>
      await _setValue('tenantDataId', value);
  Future<String> getTenantDataTenancyName() async =>
      await _getValue('tenantDataTenancyName', '');

  Future<void> setTenantDataTenancyName(String value) async =>
      await _setValue('tenantDataTenancyName', value);
  Future<String> getTenantDataName() async =>
      await _getValue('tenantDataName', '');

  Future<void> setTenantDataName(String value) async =>
      await _setValue('tenantDataName', value);
  Future<int> getDeviceStoreId() async => await _getValue('deviceStoreId', 0);

  Future<void> setDeviceStoreId(int value) async =>
      await _setValue('deviceStoreId', value);
  // zatcaToken
  Future<String> getZatcaToken() async => await _getValue('zatcaToken', "");

  Future<void> setZatcaToken(String value) async =>
      await _setValue('zatcaToken', value);
  // zatcaToken
  Future<String> getcashierShiftDate() async =>
      await _getValue('cashierShiftDate', "");

  Future<void> setcashierShiftDate(String value) async =>
      await _setValue('cashierShiftDate', value);

  // currentInvoice
  Future<int> getCurrentInvoice() async => await _getValue('currentInvoice', 0);

  Future<void> setCurrentInvoice(int value) async =>
      await _setValue('currentInvoice', value); // currentInvoice
  Future<int> getCurrentInvoiceRefund() async =>
      await _getValue('currentInvoiceRefund', 0);

  Future<void> setCurrentInvoiceRefund(int value) async =>
      await _setValue('currentInvoiceRefund', value);

  // KDS Devices Management
  Future<List<KdsDevice>> getKdsDevices() async {
    final devicesJson = await _getValue('kdsDevices', '[]');
    try {
      final List<dynamic> devicesList = json.decode(devicesJson);
      return devicesList.map((json) => KdsDevice.fromJson(json)).toList();
    } catch (e) {
      dPrint('Error parsing KDS devices: $e');
      return [];
    }
  }

  Future<void> setKdsDevices(List<KdsDevice> devices) async {
    final devicesJson =
        json.encode(devices.map((device) => device.toJson()).toList());
    await _setValue('kdsDevices', devicesJson);
  }

  Future<void> addKdsDevice(KdsDevice device) async {
    final devices = await getKdsDevices();
    devices.add(device);
    await setKdsDevices(devices);
  }

  Future<void> updateKdsDevice(KdsDevice updatedDevice) async {
    final devices = await getKdsDevices();
    final index = devices.indexWhere((device) => device.id == updatedDevice.id);
    if (index != -1) {
      devices[index] = updatedDevice;
      await setKdsDevices(devices);
    }
  }

  Future<void> removeKdsDevice(String deviceId) async {
    final devices = await getKdsDevices();
    devices.removeWhere((device) => device.id == deviceId);
    await setKdsDevices(devices);
  }

  Future<KdsDevice?> getKdsDeviceById(String deviceId) async {
    final devices = await getKdsDevices();
    try {
      return devices.firstWhere((device) => device.id == deviceId);
    } catch (e) {
      return null;
    }
  }

  // Sensor threshold for motion detection
  Future<int> getSensorThreshold() async =>
      await _getValue('sensorThreshold', 15);

  Future<void> setSensorThreshold(int value) async =>
      await _setValue('sensorThreshold', value);

  // Timeout duration for interaction detection (in seconds)
  Future<int> getTimeoutDuration() async =>
      await _getValue('timeoutDuration', 360);

  Future<void> setTimeoutDuration(int value) async =>
      await _setValue('timeoutDuration', value);

  Future<void> setQuantityType(String value) async =>
      await _setValue('quantityType', value);

  // quantityType: controls whether quantities are treated as int or double
  // values: 'int' (default), 'double'
  Future<String> getQuantityType() async =>
      await _getValue('quantityType', 'Decimal');
}
