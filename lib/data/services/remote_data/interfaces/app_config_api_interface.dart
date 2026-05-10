abstract class AppConfigApiInterface {
  /// Get Access Token
  Future<String?> getAccessToken();

  /// Refresh Access Token
  Future<String?> refreshAccessToken(String refreshToken);

  /// List All Devices
  Future<List<dynamic>?> listAllDevices(String accessToken);

  /// Get Device by ID
  Future<Map<String, dynamic>?> getDeviceById();

  /// Create a Device
  Future<Map<String, dynamic>?> createDevice(
      String accessToken, Map<String, dynamic> deviceData);
}
