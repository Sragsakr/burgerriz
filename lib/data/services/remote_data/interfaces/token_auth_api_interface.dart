import 'package:kiosk_point_of_sale/data/models/auth/device_auth_models.dart';
import 'package:kiosk_point_of_sale/data/models/auth/device_install_models.dart';

abstract class TokenAuthApiInterface {
  Future<void> initialize();

  Future<ValidateInstallationInfoResponse> validateInstallationInfo({
    required ValidateInstallationInfoRequest request,
  });

  Future<AuthenticateDeviceByPinResponse> authenticateDeviceByPinCode({
    required AuthenticateDeviceByPinRequest request,
  });
}
