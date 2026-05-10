import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiosk_point_of_sale/data/services/remote_data/implementations/coding_pattern_settings_api_service.dart';
import 'package:kiosk_point_of_sale/data/services/remote_data/implementations/feedback_api_service.dart';
import 'package:kiosk_point_of_sale/data/services/remote_data/implementations/plugin_sync_log_api_service.dart';
import 'package:kiosk_point_of_sale/data/services/remote_data/implementations/promotions_api_service.dart';
import 'package:kiosk_point_of_sale/data/services/remote_data/implementations/refund_reson_api_service.dart';
import 'package:kiosk_point_of_sale/data/services/remote_data/implementations/unit_of_measure_translation_api_service.dart';
import 'package:kiosk_point_of_sale/data/services/remote_data/implementations/product_category_api_service.dart';
import 'package:kiosk_point_of_sale/data/services/remote_data/implementations/primary_category_api_service.dart';
import 'package:kiosk_point_of_sale/data/services/remote_data/implementations/menu_item_sync_api_service.dart';
import 'package:kiosk_point_of_sale/data/services/remote_data/implementations/secondary_category_api_service.dart';
import 'package:kiosk_point_of_sale/data/services/remote_data/implementations/synchronization_api_service.dart';
import 'package:kiosk_point_of_sale/data/services/remote_data/interfaces/coding_pattern_settings_api_interface.dart';
import 'package:kiosk_point_of_sale/data/services/remote_data/interfaces/feedback_api_interface.dart';
import 'package:kiosk_point_of_sale/data/services/remote_data/interfaces/plugin_sync_log_api_interface.dart';
import 'package:kiosk_point_of_sale/data/services/remote_data/interfaces/promotions_api_interface.dart';
import 'package:kiosk_point_of_sale/data/services/remote_data/interfaces/refund_reson_api_interface.dart';
import 'package:kiosk_point_of_sale/data/services/remote_data/interfaces/unit_of_measure_translation_api_interface.dart';
import 'package:kiosk_point_of_sale/data/services/remote_data/interfaces/product_category_api_interface.dart';
import 'package:kiosk_point_of_sale/data/services/remote_data/interfaces/primary_category_api_interface.dart';
import 'package:kiosk_point_of_sale/data/services/remote_data/interfaces/menu_item_api_interface.dart';
import 'package:kiosk_point_of_sale/data/services/remote_data/interfaces/secondary_category_api_interface.dart';
import 'package:kiosk_point_of_sale/data/services/remote_data/interfaces/synchronization_api_interface.dart';

import 'implementations/app_config_api_service.dart';
import 'implementations/auth_api_service.dart';
import 'implementations/cashier_shift_api_service.dart';
import 'implementations/currency_api_service.dart';
import 'implementations/customer_api_service.dart';
import 'implementations/sale_types_api_service.dart';
import 'implementations/sync_api_service.dart';
import 'implementations/x_report_api_service.dart';
import 'implementations/zatca_api_service.dart';
import 'interfaces/app_config_api_interface.dart';
import 'interfaces/auth_api_interface.dart';
import 'interfaces/cashier_shift_api_interface.dart';
import 'interfaces/currency_api_interface.dart';
import 'interfaces/customer_api_interface.dart';
import 'interfaces/sale_types_api_interface.dart';
import 'interfaces/sync_api_interface.dart';
import 'interfaces/x_report_api_interface.dart';
import 'interfaces/zatca_api_interface.dart';

// Global instances that will be initialized
AuthApiService? _authServiceInstance;
ZatcaApiService? _zatcaServiceInstance;
XReportApiService? _xReportServiceInstance;
CurrencyApiService? _currencyServiceInstance;
CashierShiftApiService? _cashierShiftServiceInstance;
SaleTypesApiService? _saleTypesServiceInstance;
AppConfigApiService? _appConfigServiceInstance;
SyncApiService? _syncServiceInstance;
PromotionsApiService? _promotionsApiServiceInstance;
CustomerApiService? _customerApiServiceInstance;
RefundResonApiService? _refundResonApiServiceInstance;
SynchronizationApiService? _synchronizationApiServiceInstance;
FeedbackApiService? _feedbackApiServiceInstance;
CodingPatternSettingsApiService? _codingPatternSettingsApiServiceInstance;
PluginSyncLogApiService? _pluginSyncLogApiServiceInstance;
UnitOfMeasureTranslationApiService? _unitOfMeasureTranslationApiServiceInstance;
ProductCategoryApiService? _productCategoryApiServiceInstance;
PrimaryCategoryApiService? _primaryCategoryApiServiceInstance;
SecondaryCategoryApiService? _secondaryCategoryApiServiceInstance;
MenuItemSyncApiService? _menuItemSyncApiServiceInstance;

// StateNotifier to manage service initialization
class ServicesNotifier extends StateNotifier<AsyncValue<void>> {
  ServicesNotifier()
      : super(const AsyncValue.data(
            null)); // Start with data(null) instead of loading

  Future<void> initializeServices() async {
    state = const AsyncValue.loading();
    try {
      // Initialize all services here
      _authServiceInstance = AuthApiService();
      await _authServiceInstance!.initialize();

      _zatcaServiceInstance = ZatcaApiService();
      await _zatcaServiceInstance!.initialize();

      _xReportServiceInstance = XReportApiService();
      await _xReportServiceInstance!.initialize();

      _currencyServiceInstance = CurrencyApiService();
      await _currencyServiceInstance!.initialize();

      _cashierShiftServiceInstance = CashierShiftApiService();
      await _cashierShiftServiceInstance!.initialize();

      _saleTypesServiceInstance = SaleTypesApiService();
      await _saleTypesServiceInstance!.initialize();

      _appConfigServiceInstance = AppConfigApiService();
      await _appConfigServiceInstance!.initialize();

      _syncServiceInstance = SyncApiService();
      await _syncServiceInstance!.initialize();

      _promotionsApiServiceInstance = PromotionsApiService();
      await _promotionsApiServiceInstance!.initialize();

      _customerApiServiceInstance = CustomerApiService();
      await _customerApiServiceInstance!.initialize();

      _refundResonApiServiceInstance = RefundResonApiService();
      await _refundResonApiServiceInstance!.initialize();

      _synchronizationApiServiceInstance = SynchronizationApiService();
      await _synchronizationApiServiceInstance!.initialize();

      _feedbackApiServiceInstance = FeedbackApiService();
      await _feedbackApiServiceInstance!.initialize();

      _codingPatternSettingsApiServiceInstance =
          CodingPatternSettingsApiService();
      await _codingPatternSettingsApiServiceInstance!.initialize();

      _pluginSyncLogApiServiceInstance = PluginSyncLogApiService();
      await _pluginSyncLogApiServiceInstance!.initialize();

      _unitOfMeasureTranslationApiServiceInstance =
          UnitOfMeasureTranslationApiService();
      await _unitOfMeasureTranslationApiServiceInstance!.initialize();

      _productCategoryApiServiceInstance = ProductCategoryApiService();
      await _productCategoryApiServiceInstance!.initialize();

      _primaryCategoryApiServiceInstance = PrimaryCategoryApiService();
      await _primaryCategoryApiServiceInstance!.initialize();

      _secondaryCategoryApiServiceInstance = SecondaryCategoryApiService();
      await _secondaryCategoryApiServiceInstance!.initialize();

      _menuItemSyncApiServiceInstance = MenuItemSyncApiService();
      await _menuItemSyncApiServiceInstance!.initialize();

      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> reinitializeServices() async {
    // Clear existing instances
    _authServiceInstance = null;
    _zatcaServiceInstance = null;
    _xReportServiceInstance = null;
    _currencyServiceInstance = null;
    _cashierShiftServiceInstance = null;
    _saleTypesServiceInstance = null;
    _appConfigServiceInstance = null;
    _syncServiceInstance = null;
    _promotionsApiServiceInstance = null;
    _customerApiServiceInstance = null;
    _refundResonApiServiceInstance = null;
    _synchronizationApiServiceInstance = null;
    _feedbackApiServiceInstance = null;
    _pluginSyncLogApiServiceInstance = null;
    _unitOfMeasureTranslationApiServiceInstance = null;
    _productCategoryApiServiceInstance = null;
    _primaryCategoryApiServiceInstance = null;
    _secondaryCategoryApiServiceInstance = null;
    _menuItemSyncApiServiceInstance = null;

    // Re-initialize
    await initializeServices();
  }
}

/// Provider that manages service initialization
final servicesNotifierProvider =
    StateNotifierProvider<ServicesNotifier, AsyncValue<void>>((ref) {
  return ServicesNotifier(); // Don't auto-initialize
});

/// Legacy provider for backward compatibility
final apiServicesInitProvider = FutureProvider<void>((ref) async {
  final notifier = ref.read(servicesNotifierProvider.notifier);
  await notifier.initializeServices();
});

final authApiServiceProvider = Provider<AuthApiInterface>((ref) {
  ref.watch(servicesNotifierProvider);
  _authServiceInstance ??= AuthApiService();
  return _authServiceInstance!;
});

/// Provider for the ZatcaApiService instance
final zatcaApiServiceProvider = Provider<ZatcaApiInterface>((ref) {
  // Check if services are initialized
  final servicesState = ref.watch(servicesNotifierProvider);

  // If not initialized, trigger initialization
  if (servicesState is AsyncData && _zatcaServiceInstance == null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(servicesNotifierProvider.notifier).initializeServices();
    });
  }

  if (_zatcaServiceInstance == null) {
    throw Exception(
        'ZatcaApiService not initialized yet. Call initializeServices() first.');
  }
  return _zatcaServiceInstance!;
});

/// Provider for the XReportApiService instance
final xReportApiServiceProvider = Provider<XReportApiInterface>((ref) {
  // Check if services are initialized
  final servicesState = ref.watch(servicesNotifierProvider);

  // If not initialized, trigger initialization
  if (servicesState is AsyncData && _xReportServiceInstance == null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(servicesNotifierProvider.notifier).initializeServices();
    });
  }

  if (_xReportServiceInstance == null) {
    throw Exception(
        'XReportApiService not initialized yet. Call initializeServices() first.');
  }
  return _xReportServiceInstance!;
});

/// Provider for the CurrencyApiService instance
final currencyApiServiceProvider = Provider<CurrencyApiInterface>((ref) {
  // Check if services are initialized
  final servicesState = ref.watch(servicesNotifierProvider);

  // If not initialized, trigger initialization
  if (servicesState is AsyncData && _currencyServiceInstance == null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(servicesNotifierProvider.notifier).initializeServices();
    });
  }

  if (_currencyServiceInstance == null) {
    throw Exception(
        'CurrencyApiService not initialized yet. Call initializeServices() first.');
  }
  return _currencyServiceInstance!;
});

/// Provider for the CashierShiftApiService instance
final cashierShiftApiServiceProvider =
    Provider<CashierShiftApiInterface>((ref) {
  // Check if services are initialized
  final servicesState = ref.watch(servicesNotifierProvider);

  // If not initialized, trigger initialization
  if (servicesState is AsyncData && _cashierShiftServiceInstance == null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(servicesNotifierProvider.notifier).initializeServices();
    });
  }

  if (_cashierShiftServiceInstance == null) {
    throw Exception(
        'CashierShiftApiService not initialized yet. Call initializeServices() first.');
  }
  return _cashierShiftServiceInstance!;
});

/// Provider for the SaleTypesApiService instance
final saleTypesApiServiceProvider = Provider<SaleTypesApiInterface>((ref) {
  // Check if services are initialized
  final servicesState = ref.watch(servicesNotifierProvider);

  // If not initialized, trigger initialization
  if (servicesState is AsyncData && _saleTypesServiceInstance == null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(servicesNotifierProvider.notifier).initializeServices();
    });
  }

  if (_saleTypesServiceInstance == null) {
    throw Exception(
        'SaleTypesApiService not initialized yet. Call initializeServices() first.');
  }
  return _saleTypesServiceInstance!;
});

/// Provider for the AppConfigApiService instance
final appConfigApiServiceProvider = Provider<AppConfigApiInterface>((ref) {
  // Check if services are initialized
  final servicesState = ref.watch(servicesNotifierProvider);

  // If not initialized, trigger initialization
  if (servicesState is AsyncData && _appConfigServiceInstance == null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(servicesNotifierProvider.notifier).initializeServices();
    });
  }

  if (_appConfigServiceInstance == null) {
    throw Exception(
        'AppConfigApiService not initialized yet. Call initializeServices() first.');
  }
  return _appConfigServiceInstance!;
});

/// Provider for the SyncApiService instance
final syncApiServiceProvider = Provider<SyncApiInterface>((ref) {
  // Check if services are initialized
  final servicesState = ref.watch(servicesNotifierProvider);

  // If not initialized, trigger initialization
  if (servicesState is AsyncData && _syncServiceInstance == null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(servicesNotifierProvider.notifier).initializeServices();
    });
  }

  if (_syncServiceInstance == null) {
    throw Exception(
        'SyncApiService not initialized yet. Call initializeServices() first.');
  }
  return _syncServiceInstance!;
});

/// Provider for the PromotionsApiServices instance
final promotionsApiServiceProvider = Provider<PromotionsApiInterface>((ref) {
  // Check if services are initialized
  final servicesState = ref.watch(servicesNotifierProvider);

  // If not initialized, trigger initialization
  if (servicesState is AsyncData && _promotionsApiServiceInstance == null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(servicesNotifierProvider.notifier).initializeServices();
    });
  }

  if (_promotionsApiServiceInstance == null) {
    throw Exception(
        'PromotionsApiService not initialized yet. Call initializeServices() first.');
  }
  return _promotionsApiServiceInstance!;
});

/// Provider for the CustomerApiService instance
final customerApiServiceProvider = Provider<CustomerApiInterface>((ref) {
  // Check if services are initialized
  final servicesState = ref.watch(servicesNotifierProvider);

  // If not initialized, trigger initialization
  if (servicesState is AsyncData && _customerApiServiceInstance == null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(servicesNotifierProvider.notifier).initializeServices();
    });
  }

  if (_customerApiServiceInstance == null) {
    throw Exception(
        'CustomerApiService not initialized yet. Call initializeServices() first.');
  }
  return _customerApiServiceInstance!;
});

/// Provider for the RefundResonApiService instance
final refundResonApiServiceProvider = Provider<RefundResonApiInterface>((ref) {
  // Check if services are initialized
  final servicesState = ref.watch(servicesNotifierProvider);

  // If not initialized, trigger initialization
  if (servicesState is AsyncData && _refundResonApiServiceInstance == null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(servicesNotifierProvider.notifier).initializeServices();
    });
  }

  if (_refundResonApiServiceInstance == null) {
    throw Exception(
        'RefundResonApiService not initialized yet. Call initializeServices() first.');
  }
  return _refundResonApiServiceInstance!;
});

/// Provider for the SynchronizationApiService instance
final synchronizationApiServiceProvider =
    Provider<SynchronizationApiInterface>((ref) {
  // Check if services are initialized
  final servicesState = ref.watch(servicesNotifierProvider);

  // If not initialized, trigger initialization
  if (servicesState is AsyncData &&
      _synchronizationApiServiceInstance == null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(servicesNotifierProvider.notifier).initializeServices();
    });
  }

  if (_synchronizationApiServiceInstance == null) {
    throw Exception(
        'SynchronizationApiService not initialized yet. Call initializeServices() first.');
  }
  return _synchronizationApiServiceInstance!;
});

/// Provider for the FeedbackApiService instance
final feedbackApiServiceProvider = Provider<FeedbackApiInterface>((ref) {
  // Check if services are initialized
  final servicesState = ref.watch(servicesNotifierProvider);

  // If not initialized, trigger initialization
  if (servicesState is AsyncData && _feedbackApiServiceInstance == null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(servicesNotifierProvider.notifier).initializeServices();
    });
  }

  if (_feedbackApiServiceInstance == null) {
    throw Exception(
        'FeedbackApiService not initialized yet. Call initializeServices() first.');
  }
  return _feedbackApiServiceInstance!;
});

/// Provider for the CodingPatternSettingsApiService instance
final codingPatternSettingsApiServiceProvider =
    Provider<CodingPatternSettingsApiInterface>((ref) {
  final servicesState = ref.watch(servicesNotifierProvider);

  if (servicesState is AsyncData &&
      _codingPatternSettingsApiServiceInstance == null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(servicesNotifierProvider.notifier).initializeServices();
    });
  }

  if (_codingPatternSettingsApiServiceInstance == null) {
    throw Exception(
        'CodingPatternSettingsApiService not initialized yet. Call initializeServices() first.');
  }
  return _codingPatternSettingsApiServiceInstance!;
});

/// Provider for the PluginSyncLogApiService instance
final pluginSyncLogApiServiceProvider =
    Provider<PluginSyncLogApiInterface>((ref) {
  final servicesState = ref.watch(servicesNotifierProvider);

  if (servicesState is AsyncData && _pluginSyncLogApiServiceInstance == null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(servicesNotifierProvider.notifier).initializeServices();
    });
  }

  if (_pluginSyncLogApiServiceInstance == null) {
    throw Exception(
        'PluginSyncLogApiService not initialized yet. Call initializeServices() first.');
  }
  return _pluginSyncLogApiServiceInstance!;
});

/// Provider for the UnitOfMeasureTranslationApiService instance
final unitOfMeasureTranslationApiServiceProvider =
    Provider<UnitOfMeasureTranslationApiInterface>((ref) {
  final servicesState = ref.watch(servicesNotifierProvider);

  if (servicesState is AsyncData &&
      _unitOfMeasureTranslationApiServiceInstance == null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(servicesNotifierProvider.notifier).initializeServices();
    });
  }

  if (_unitOfMeasureTranslationApiServiceInstance == null) {
    throw Exception(
        'UnitOfMeasureTranslationApiService not initialized yet. Call initializeServices() first.');
  }
  return _unitOfMeasureTranslationApiServiceInstance!;
});

/// Provider for the ProductCategoryApiService instance
final productCategoryApiServiceProvider =
    Provider<ProductCategoryApiInterface>((ref) {
  final servicesState = ref.watch(servicesNotifierProvider);

  if (servicesState is AsyncData && _productCategoryApiServiceInstance == null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(servicesNotifierProvider.notifier).initializeServices();
    });
  }

  if (_productCategoryApiServiceInstance == null) {
    throw Exception(
        'ProductCategoryApiService not initialized yet. Call initializeServices() first.');
  }
  return _productCategoryApiServiceInstance!;
});

/// Provider for the PrimaryCategoryApiService instance
final primaryCategoryApiServiceProvider =
    Provider<PrimaryCategoryApiInterface>((ref) {
  final servicesState = ref.watch(servicesNotifierProvider);

  if (servicesState is AsyncData &&
      _primaryCategoryApiServiceInstance == null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(servicesNotifierProvider.notifier).initializeServices();
    });
  }

  if (_primaryCategoryApiServiceInstance == null) {
    throw Exception(
        'PrimaryCategoryApiService not initialized yet. Call initializeServices() first.');
  }
  return _primaryCategoryApiServiceInstance!;
});

/// Provider for the SecondaryCategoryApiService instance
final secondaryCategoryApiServiceProvider =
    Provider<SecondaryCategoryApiInterface>((ref) {
  final servicesState = ref.watch(servicesNotifierProvider);

  if (servicesState is AsyncData &&
      _secondaryCategoryApiServiceInstance == null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(servicesNotifierProvider.notifier).initializeServices();
    });
  }

  if (_secondaryCategoryApiServiceInstance == null) {
    throw Exception(
        'SecondaryCategoryApiService not initialized yet. Call initializeServices() first.');
  }
  return _secondaryCategoryApiServiceInstance!;
});

/// Provider for the MenuItemSyncApiService instance
final menuItemSyncApiServiceProvider = Provider<MenuItemApiInterface>((ref) {
  final servicesState = ref.watch(servicesNotifierProvider);

  if (servicesState is AsyncData && _menuItemSyncApiServiceInstance == null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(servicesNotifierProvider.notifier).initializeServices();
    });
  }

  if (_menuItemSyncApiServiceInstance == null) {
    throw Exception(
        'MenuItemSyncApiService not initialized yet. Call initializeServices() first.');
  }
  return _menuItemSyncApiServiceInstance!;
});

/// Helper function to re-initialize services from anywhere in the app
/// Call this after adding new data to ensure services are updated
Future<void> reinitializeServices(WidgetRef ref) async {
  await ref.read(servicesNotifierProvider.notifier).reinitializeServices();
}
