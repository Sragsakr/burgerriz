import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';
import 'package:kiosk_point_of_sale/data/models/auth/device_install_models.dart';
import 'package:kiosk_point_of_sale/data/services/remote_data/implementations/token_auth_api_service.dart';
import 'package:kiosk_point_of_sale/data/services/remote_data/interfaces/token_auth_api_interface.dart';

class InstallValidationService {
  final TokenAuthApiInterface _tokenAuthApiService;

  InstallValidationService({TokenAuthApiInterface? tokenAuthApiService})
      : _tokenAuthApiService = tokenAuthApiService ?? TokenAuthApiService();

  Future<ValidateInstallationInfoResponse> validateAndPersist({
    required String ipAddress,
    required int clusterId,
    required String environment,
    required String firstLanguageCode,
    required String secondLanguageCode,
    required String syncInterval,
    required String tenderType,
  }) async {
    final pref = AppPreferences();
    await pref.setEnvironmentType(environment);
    await pref.setIp(ipAddress);

    await _tokenAuthApiService.initialize();
    final response = await _tokenAuthApiService.validateInstallationInfo(
      request: ValidateInstallationInfoRequest(
        ipAddress: ipAddress,
        clusterId: clusterId,
        tenderTypeId: int.tryParse(tenderType) ?? 0,
      ),
    );

    if (response.isValid) {
      await pref.setLanguage(firstLanguageCode);
      await pref.setSecLanguage(secondLanguageCode);
      await pref.setSyncInterval(syncInterval);
      await pref.setTenderType(tenderType);
      await pref.setClusterId(clusterId);
      await pref.setInstallTenantId(response.tenantId);
      await pref.setInstallStoreId(response.storeId);
      await pref.setInstallDeviceType(response.deviceType);
      await pref.setInstallCompleted(true);
      await pref.setTenant(response.tenantId.toString());
      await pref.setStore(response.storeId.toString());
    }

    return response;
  }
}
