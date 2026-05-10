import 'package:kiosk_point_of_sale/core/sdks/sdk_logic/led_status_manager.dart';

/// Helper class to manage LED status during navigation
/// This can be used throughout the app to notify LED status manager
/// about navigation events
class NavigationLEDHelper {
  static NavigationLEDHelper? _instance;
  static NavigationLEDHelper get instance =>
      _instance ??= NavigationLEDHelper._();

  NavigationLEDHelper._();

  /// Get current LED status description for debugging
  String getCurrentLEDStatus() {
    return LEDStatusManager.instance.getStatusDescription();
  }

  /// Manually set LED color (for testing purposes)
  Future<void> setManualLEDColor(LEDColor color) async {
    await LEDStatusManager.instance.setManualLEDColor(color);
  }
}
