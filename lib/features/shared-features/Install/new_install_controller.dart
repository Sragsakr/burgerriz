import 'package:flutter/foundation.dart';
import 'package:kiosk_point_of_sale/core/services/auth/install_validation_service.dart';
import 'package:kiosk_point_of_sale/features/shared-features/Install/new_install_state.dart';

class NewInstallController extends ChangeNotifier {
  final InstallValidationService _installValidationService;

  NewInstallState _state = const NewInstallState();
  NewInstallState get state => _state;

  NewInstallController({InstallValidationService? installValidationService})
      : _installValidationService = installValidationService ?? InstallValidationService();

  Future<bool> submit({
    required String ipAddress,
    required int clusterId,
    required String environment,
    required String firstLanguageCode,
    required String secondLanguageCode,
    required String syncInterval,
    required String tenderType,
    String Function(String key)? localizeKey,
  }) async {
    _state = _state.copyWith(isLoading: true, errorMessage: null);
    notifyListeners();

    try {
      final response = await _installValidationService.validateAndPersist(
        ipAddress: ipAddress,
        clusterId: clusterId,
        environment: environment,
        firstLanguageCode: firstLanguageCode,
        secondLanguageCode: secondLanguageCode,
        syncInterval: syncInterval,
        tenderType: tenderType,
      );

      if (!response.isValid) {
        final fallback = localizeKey?.call('auth_flow_install_validation_failed') ?? 'Installation validation failed';
        _state = _state.copyWith(
          isLoading: false,
          isSuccess: false,
          errorMessage: response.message.isEmpty ? fallback : response.message,
        );
        notifyListeners();
        return false;
      }

      _state = _state.copyWith(isLoading: false, isSuccess: true);
      notifyListeners();
      return true;
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        isSuccess: false,
        errorMessage: e.toString(),
      );
      notifyListeners();
      return false;
    }
  }
}
