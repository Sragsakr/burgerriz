import 'package:flutter/foundation.dart';
import 'package:kiosk_point_of_sale/core/services/auth/device_pin_login_service.dart';
import 'package:kiosk_point_of_sale/features/shared-features/Login/new_login_state.dart';

class NewLoginController extends ChangeNotifier {
  final DevicePinLoginService _devicePinLoginService;

  NewLoginState _state = const NewLoginState();
  NewLoginState get state => _state;

  NewLoginController({DevicePinLoginService? devicePinLoginService})
      : _devicePinLoginService = devicePinLoginService ?? DevicePinLoginService();

  Future<bool> login(String pin, String Function(String key) localize) async {
    if (pin.trim().isEmpty) {
      _state = _state.copyWith(errorMessage: localize('auth_flow_error_pin_required'));
      notifyListeners();
      return false;
    }

    _state = _state.copyWith(isLoading: true, errorMessage: null);
    notifyListeners();

    try {
      await _devicePinLoginService.authenticate(pinCode: pin.trim());
      _state = _state.copyWith(isLoading: false, errorMessage: null);
      notifyListeners();
      return true;
    } catch (e) {
      var msg = e.toString();
      if (msg.contains('Online authentication is required')) {
        msg = localize('auth_flow_error_online_required');
      } else if (msg.contains('Installation data is missing')) {
        msg = localize('auth_flow_error_install_missing');
      }
      _state = _state.copyWith(isLoading: false, errorMessage: msg);
      notifyListeners();
      return false;
    }
  }
}
