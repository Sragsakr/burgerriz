import 'package:kiosk_point_of_sale/core/enums/environment_enums.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:nearpay_flutter_sdk/nearpay.dart';

import '../../data/NearPay/near_pay_constants.dart';

class AppUrls {
  ////////////// Base Url ////////////
  // static const String baseUrl = 'https://uatapi.posmena.com';

  ////////////// MenuItems apis Urls ////////////
  static const String menuItemsUrl = 'https://posmena-kiosk-api.onrender.com/api/getAllAddedMenuItems';

  ////////////// login apis Urls ////////////
  static const String authUrl = '/api/TokenAuth/Authenticate';
  static const String authPinCodeUrl = '/api/TokenAuth/AuthenticateByPinCode';
  static const String validateInstallationInfoUrl = '/api/TokenAuth/ValidateInstallationInfo';
  static const String authenticateDeviceByPinCodeUrl = '/api/TokenAuth/AuthenticateDeviceByPinCode';

  ////////////// Config Urls ////////////
  ///* sale type
  static const String saleTenderTypeUrl = '/api/services/app/Synchronization/SyncTenderTypeTranslationsTable';

  ///* start shift
  static const String startMyShiftUrl = '/api/services/app/CashierShifts/NewStartShiftWithEndOfDay';

  static const String getOpenedCashierShift = '/api/services/app/CashierShifts/GetOpenedCashierShift';
  static const String xReportApi = '/api/services/app/CashierShifts/XReportFB';

  /// Get Is Supervisor
  static const String checkSupervisorUrl = '/api/services/app/RoleChecker/GetIsSupervisor';
  static const String syncOrdersUrl = '/api/services/app/Transactions/AddSaleTransactions';
  static const String syncRefundOrdersUrl = '/api/services/app/Transactions/AddSaleNotifications';

  //////////// Zacta apis Urls ////////////
  static const String zatcaTokenTestingUrl = "https://simulation-zatca.posmena.com/api/TokenAuth/Authenticate";

  static const String sendInvoiceToPhoneUrl = "https://zigs.posmena.com.tr/invoicing/generate-invoice/";
  static const String zatcaSendInvoiceUrl =
      "https://simulation-zatca.posmena.com/api/services/app/ZatcaTransaction/SendInvoiceToZatca";

  static const String zatcaTokenProductionUrl = "https://zatca.posmena.com/api/TokenAuth/Authenticate";
  static const String zatcaSendInvoiceProductionUrl =
      "https://zatca.posmena.com/api/services/app/ZatcaTransaction/SendInvoiceToZatca";

//////////// SaleType apis Urls ////////////
  static const String syncSaleTypeTable = '/api/services/app/Synchronization/SyncSaleTypeTable';
  static const String syncSaleTypeTranslationsTable = '/api/services/app/Synchronization/SyncSaleTypeTranslationsTable';
  static const String saleTypeStoresTable = '/api/services/app/Synchronization/SaleTypeStoresTable';
  static const String syncSaleTypePriceListTable = '/api/services/app/Synchronization/SyncSaleTypePriceListTable';
  static const String syncCustomers = '/api/services/app/Customers/GetAllCustomersWithAddresses';

  //////////// currency apis Urls ////////////
  static const String currencyListUrl = '/api/services/app/Synchronization/SyncCurrencyTranslationTable';

  //////////// Unit of Measure apis Urls ////////////
  static const String syncUnitOfMeasureTranslationTable =
      '/api/services/app/Synchronization/SyncUnitOfMeasureTranslationTable';

  //////////// Product Category apis Urls ////////////
  static const String syncProductCategoryTable = '/api/services/app/Synchronization/SyncProductCategoryTable';
  static const String syncProductCategoryTranslationTable =
      '/api/services/app/Synchronization/SyncProductCategoryTranslationTable';
  static const String syncProductCategoryLevelTable = '/api/services/app/Synchronization/SyncProductCategoryLevelTable';

  //////////// Primary Category apis Urls ////////////
  static const String syncPrimaryCategoryTable = '/api/services/app/Synchronization/SyncPrimaryCategoryTable';
  static const String syncPrimaryCategoryTranslationTable =
      '/api/services/app/Synchronization/SyncPrimaryCategoryTranslationTable';

  //////////// Secondary Category apis Urls ////////////
  static const String syncSecondaryCategoryTable = '/api/services/app/Synchronization/SyncSecondaryCategoryTable';
  static const String syncSecondaryCategoryTranslationTable =
      '/api/services/app/Synchronization/SyncSecondaryCategoryTranslationTable';

  //////////// Menu Item apis Urls ////////////
  static const String syncMenuItemTableFB = '/api/services/app/Synchronization/SyncMenuItemTableFB';
  static const String syncMenuItemTranslationTable = '/api/services/app/Synchronization/SyncMenuItemTranslationTable';
  static const String syncMenuItemPriceListTable = '/api/services/app/Synchronization/SyncMenuItemPriceListTable';
  static const String syncMenuItemTaxTable = '/api/services/app/Synchronization/SyncMenuItemTaxTable';
  static const String syncPriceListTranslationsTable =
      '/api/services/app/Synchronization/SyncPriceListTranslationsTable';

  //////////// Promotions apis Urls ////////////
  static const String promotionsFBTableUrl = '/api/services/app/Synchronization/SyncPromotionsFBTable';
  static const String promotionDetailsFBTableUrl = '/api/services/app/Synchronization/SyncPromotionDetailsFB';
  static const String promotionFBItemUrl = '/api/services/app/Synchronization/SyncPromotionFBItem';
  static const String promotionCodesFBTableUrl = '/api/services/app/Synchronization/SyncPromotionCodesFB';
  static const String promotionFBItemExcludedMenuItemTableUrl =
      '/api/services/app/Synchronization/SyncPromotionFBItemExcludedMenuItem';
  static const String promotionDetailsFBExcludedMenuItem =
      '/api/services/app/Synchronization/SyncPromotionDetailsFBExcludedMenuItem';
  static const String refundResonsList = '/api/services/app/RefundResons/GetResonsList';
  static const String promotionFBAdditionalFreeItem =
      '/api/services/app/Synchronization/SyncPromotionFBAdditionalFreeItem';
  //////////// Plugin Sync Log apis Urls ////////////
  static const String createPluginSyncLogUrl = '/api/services/app/PluginSyncLog/Create';

  //////////// CodingPatternSettings apis Urls ////////////
  static const String codingPatternGetSalesCodePattern = '/api/services/app/CodingPatternSettings/GetSalesCodePattern';

  //////////// Report Group Translation apis Urls ////////////
  static const String syncReportGroupTranslationTable =
      '/api/services/app/Synchronization/SyncReportGroupTranslationTable';

  /// Variant Tables
  static const String syncUrl = '/api/services/app/Synchronization';
  static const SyncVariantTablesUrl = "$syncUrl/SyncVariantTable";
  static const SyncVariantTranslationTablesUrl = "$syncUrl/SyncVariantTranslationTable";
  static const SyncProductVariantTableUrl = "$syncUrl/SyncProductVariantTable";
  static const SyncProductVariantTranslationTableUrl = "$syncUrl/SyncProductVariantTranslationTable";
  static const SyncVariantValueTableUrl = "$syncUrl/SyncVariantValueTable";
  static const SyncVariantValueTranslationTableUrl = "$syncUrl/SyncVariantValueTranslationTable";
  static const SyncMenuItemVariantTableUrl = "$syncUrl/SyncMenuItemVariantTable";
  static const SyncVariantValuePriceListTableUrl = "$syncUrl/SyncVariantValuePriceListTable";

  /// Combo Meal Tables
  static const SyncComboMealDefinitionsTableUrl = "$syncUrl/SyncComboMealDefinitionsTable";
  static const SyncComboMealPackagesTableUrl = "$syncUrl/ComboMealPackagesTable";
  static const SyncComboMealPackageTranslationsTableUrl = "$syncUrl/ComboMealPackageTranslationsTable";
  static const SyncComboMealPackageItemsTableUrl = "$syncUrl/ComboMealPackageItemsTable";
  static const SyncComboMealPackageItemPriceListTableUrl = "$syncUrl/ComboMealPackageItemPriceListTable";

  static Future<String> getBaseUrl() async {
    final savedEnv = await AppPreferences().getEnvironmentType();
    final env = getEnvType(savedEnv);
    return env.getV2BaseUrl();
  }

  static Future<String> getZatcaTokenUrl() async {
    final savedEnv = await AppPreferences().getEnvironmentType();

    final env = getEnvType(savedEnv);
    if (env == Environment.Production) {
      return AppUrls.zatcaTokenTestingUrl;
    } else if (env == Environment.Testing) {
      return AppUrls.zatcaTokenTestingUrl;
    } else {
      return AppUrls.zatcaTokenTestingUrl;
    }
  }

  static Future<String> getZactaSendInvoiceUrl() async {
    final savedEnv = await AppPreferences().getEnvironmentType();

    final env = getEnvType(savedEnv);
    if (env == Environment.Production) {
      return AppUrls.zatcaSendInvoiceUrl;
    } else if (env == Environment.Testing) {
      return AppUrls.zatcaSendInvoiceUrl;
    } else {
      return AppUrls.zatcaSendInvoiceUrl;
    }
  }

  static Future<Map<String, dynamic>> getNearPayHeader() async {
    final savedEnv = await AppPreferences().getEnvironmentType();

    final env = getEnvType(savedEnv);

    if (env == Environment.Production) {
      return {'Content-Type': 'application/json', 'nearpay_live_key': NearPayConstants.productionKey};
    } else if (env == Environment.Testing) {
      return {'Content-Type': 'application/json', 'nearpay_uat_key': NearPayConstants.nearPayUatKey};
    } else {
      return {'Content-Type': 'application/json', 'nearpay_uat_key': NearPayConstants.nearPayUatKey};
    }
  }

  static Future<String> getNearPayTokenUrl() async {
    final savedEnv = await AppPreferences().getEnvironmentType();

    final env = getEnvType(savedEnv);

    if (env == Environment.Production) {
      return NearPayConstants.generateProductionTokenUrl;
    } else if (env == Environment.Testing) {
      return NearPayConstants.generateSandboxTokenUrl;
    } else {
      return NearPayConstants.generateSandboxTokenUrl;
    }
  }

  static Future<Environments> getNearPayEnvironment() async {
    final savedEnv = await AppPreferences().getEnvironmentType();

    final env = getEnvType(savedEnv);

    if (env == Environment.Production) {
      return Environments.production;
    } else if (env == Environment.Testing) {
      return Environments.sandbox;
    } else {
      return Environments.sandbox;
    }
  }
}
