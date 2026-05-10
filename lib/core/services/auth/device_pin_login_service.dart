import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';
import 'package:kiosk_point_of_sale/core/helpers/secure_token_storage.dart';
import 'package:kiosk_point_of_sale/data/models/auth/device_auth_models.dart';
import 'package:kiosk_point_of_sale/data/services/remote_data/implementations/token_auth_api_service.dart';

class DevicePinLoginService {
  final TokenAuthApiService _tokenAuthApiService;
  final SecureTokenStorage _secureTokenStorage;

  DevicePinLoginService({
    TokenAuthApiService? tokenAuthApiService,
    SecureTokenStorage? secureTokenStorage,
  })  : _tokenAuthApiService = tokenAuthApiService ?? TokenAuthApiService(),
        _secureTokenStorage = secureTokenStorage ?? SecureTokenStorage();

  Future<AuthenticateDeviceByPinResponse> authenticate({
    required String pinCode,
  }) async {
    final pref = AppPreferences();
    final ipAddress = await pref.getIp();
    final clusterId = await pref.getClusterId();

    if (ipAddress.isEmpty || clusterId <= 0) {
      throw Exception('Installation data is missing');
    }

    await _tokenAuthApiService.initialize();
    final response = await _tokenAuthApiService.authenticateDeviceByPinCode(
      request: AuthenticateDeviceByPinRequest(
        pinCode: pinCode,
        ipAddress: ipAddress,
        clusterId: clusterId,
      ),
    );

    await _secureTokenStorage.saveAccessToken(response.accessToken);
    await pref.setExpireInSeconds(response.expireInSeconds);
    await pref.setLoginUserId(response.userId);
    await pref.setLoginUserName(response.userName);
    await pref.setUsername(response.userName);
    await pref.setDeviceStoreId(response.deviceStoreId);
    await pref.setInstallDeviceType(response.deviceType);
    await pref.setTenantDataId(response.tenantData.id);
    await pref.setTenantDataTenancyName(response.tenantData.tenancyName);
    await pref.setTenantDataName(response.tenantData.name);
    await pref.setTenant(response.tenantData.id.toString());
    await AppPreferences().setCashierId(response.userId);
    return response;
  }
}
