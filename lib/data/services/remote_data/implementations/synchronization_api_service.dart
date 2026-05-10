import 'package:dio/dio.dart';
import 'package:kiosk_point_of_sale/core/constants/app_urls.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/combo_meal_definition_entity.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/combo_meal_package_entity.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/combo_meal_package_item_entity.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/combo_meal_package_item_price_list_entity.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/combo_meal_package_translation_entity.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/report_group_translation_entity.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/tables/report_group_translation_table.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/menu_item_variation_entity.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/tables/combo_meal_definitions_table.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/tables/combo_meal_package_item_price_lists_table.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/tables/combo_meal_package_items_table.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/tables/combo_meal_package_translations_table.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/tables/combo_meal_packages_table.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/tables/menu_item_variation_table.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/tables/variant_table_element_table.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/tables/variant_translation_element_table.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/tables/variation_value_table.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/tables/variation_value_translation_pricing_table.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/tables/variation_value_translation_table.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/variant_table_element_entity.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/variant_translation_element_entity.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/variation_value_entity.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/variation_value_translation_entity.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/variation_value_translation_pricing_entity.dart';
import 'package:kiosk_point_of_sale/data/services/remote_data/implementations/base_api_service.dart';
import 'package:kiosk_point_of_sale/data/services/remote_data/interfaces/synchronization_api_interface.dart';

class SynchronizationApiService extends BaseApiService implements SynchronizationApiInterface {
  late String _baseUrl;

  SynchronizationApiService()
      : super(
          baseUrl: '', // Will be set in initialize()
          defaultHeaders: {'Content-Type': 'application/json'},
        );

  @override
  Future<void> initialize() async {
    _baseUrl = await AppUrls.getBaseUrl();
    await super.initialize();
  }

  @override
  Future<void> getMenuItemVariations() async {
    try {
      final token = await AppPreferences().getAccessToken();
      final tenantId = await AppPreferences().getTenant();

      dio.options.headers.addAll({
        'abp.tenantid': tenantId,
        'Authorization': 'Bearer $token',
      });

      final response = await post<Map<String, dynamic>>(
        _baseUrl + AppUrls.SyncMenuItemVariantTableUrl,
      );

      if (response.statusCode == 200) {
        await MenuItemVariationTable.deleteTable();
        List<dynamic> data = response.data!["result"]["added"];

        for (var item in data) {
          final menuItemVariation = MenuItemVariationEntity.fromJson(item);
          await MenuItemVariationTable.insertOrUpdate(menuItemVariation);
        }
      } else {
        throw Exception('Failed to get MenuItemVariations. Status Code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      dPrint('Error fetching menu item variations: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<void> getVariantTableElements() async {
    try {
      final token = await AppPreferences().getAccessToken();
      final tenantId = await AppPreferences().getTenant();

      dio.options.headers.addAll({
        'abp.tenantid': tenantId,
        'Authorization': 'Bearer $token',
      });

      final response = await post<Map<String, dynamic>>(
        _baseUrl + AppUrls.SyncVariantTablesUrl,
      );

      if (response.statusCode == 200) {
        await VariantTableElementTable.deleteTable();
        List<dynamic> data = response.data!["result"]["added"];

        for (var item in data) {
          final variantTableElement = VariantTableElementEntity.fromJson(item);
          await VariantTableElementTable.insertOrUpdate(variantTableElement);
        }
      } else {
        throw Exception('Failed to get VariantTableElements. Status Code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      dPrint('Error fetching variant table elements: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<void> getVariantTranslationElements() async {
    try {
      final token = await AppPreferences().getAccessToken();
      final tenantId = await AppPreferences().getTenant();

      dio.options.headers.addAll({
        'abp.tenantid': tenantId,
        'Authorization': 'Bearer $token',
      });

      final response = await post<Map<String, dynamic>>(
        _baseUrl + AppUrls.SyncVariantTranslationTablesUrl,
      );

      if (response.statusCode == 200) {
        await VariantTranslationElementTable.deleteTable();
        List<dynamic> data = response.data!["result"]["added"];

        for (var item in data) {
          final variantTranslationElement = VariantTranslationElementEntity.fromJson(item);
          await VariantTranslationElementTable.insertOrUpdate(variantTranslationElement);
        }
      } else {
        throw Exception(
            'Failed to get VariantTranslationElements. Status Code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      dPrint('Error fetching variant translation elements: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<void> getVariationValues() async {
    try {
      final token = await AppPreferences().getAccessToken();
      final tenantId = await AppPreferences().getTenant();

      dio.options.headers.addAll({
        'abp.tenantid': tenantId,
        'Authorization': 'Bearer $token',
      });

      final response = await post<Map<String, dynamic>>(
        _baseUrl + AppUrls.SyncVariantValueTableUrl,
      );

      if (response.statusCode == 200) {
        await VariationValueTable.deleteTable();
        List<dynamic> data = response.data!["result"]["added"];

        for (var item in data) {
          final variationValue = VariationValueEntity.fromJson(item);
          await VariationValueTable.insertOrUpdate(variationValue);
        }
      } else {
        throw Exception('Failed to get VariationValues. Status Code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      dPrint('Error fetching variation values: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<void> getVariationValueTranslations() async {
    try {
      final token = await AppPreferences().getAccessToken();
      final tenantId = await AppPreferences().getTenant();

      dio.options.headers.addAll({
        'abp.tenantid': tenantId,
        'Authorization': 'Bearer $token',
      });

      final response = await post<Map<String, dynamic>>(
        _baseUrl + AppUrls.SyncVariantValueTranslationTableUrl,
      );

      if (response.statusCode == 200) {
        await VariationValueTranslationTable.deleteTable();
        List<dynamic> data = response.data!["result"]["added"];

        for (var item in data) {
          final variationValueTranslation = VariationValueTranslationEntity.fromJson(item);
          await VariationValueTranslationTable.insertOrUpdate(variationValueTranslation);
        }
      } else {
        throw Exception(
            'Failed to get VariationValueTranslations. Status Code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      dPrint('Error fetching variation value translations: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<void> getVariationValueTranslationPricing() async {
    try {
      final token = await AppPreferences().getAccessToken();
      final tenantId = await AppPreferences().getTenant();

      dio.options.headers.addAll({
        'abp.tenantid': tenantId,
        'Authorization': 'Bearer $token',
      });

      final response = await post<Map<String, dynamic>>(
        _baseUrl + AppUrls.SyncVariantValuePriceListTableUrl,
      );

      if (response.statusCode == 200) {
        await VariationValueTranslationPricingTable.deleteTable();
        List<dynamic> data = response.data!["result"]["added"];

        for (var item in data) {
          final variationValueTranslationPricing =
              VariationValueTranslationPricingEntity.fromJson(item);
          await VariationValueTranslationPricingTable.insertOrUpdate(
              variationValueTranslationPricing);
        }
      } else {
        throw Exception(
            'Failed to get VariationValueTranslationPricing. Status Code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      dPrint(
          'Error fetching variation value translation pricing: ${e.response?.data ?? e.message}');
    }
  }

  // ==================== COMBO MEAL SYNC METHODS ====================

  /// Sync combo meal packages (package groups like "Main Course", "Side Dish")
  Future<void> getComboMealPackages() async {
    try {
      final token = await AppPreferences().getAccessToken();
      final tenantId = await AppPreferences().getTenant();

      dio.options.headers.addAll({
        'abp.tenantid': tenantId,
        'Authorization': 'Bearer $token',
      });

      final response = await post<Map<String, dynamic>>(
        _baseUrl + AppUrls.SyncComboMealPackagesTableUrl,
      );

      if (response.statusCode == 200) {
        await ComboMealPackagesTable.deleteTable();
        List<dynamic> data = response.data!["result"]["added"];

        for (var item in data) {
          final comboMealPackage = ComboMealPackageEntity.fromJson(item);
          await ComboMealPackagesTable.insertOrUpdate(comboMealPackage);
        }
        dPrint('Synced ${data.length} combo meal packages');
      } else {
         throw Exception('Failed to get ComboMealPackages. Status Code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      dPrint('Error fetching combo meal packages: ${e.response?.data ?? e.message}');
 
    }
  }

  /// Sync combo meal package translations (multi-language names)
  Future<void> getComboMealPackageTranslations() async {
    try {
      final token = await AppPreferences().getAccessToken();
      final tenantId = await AppPreferences().getTenant();

      dio.options.headers.addAll({
        'abp.tenantid': tenantId,
        'Authorization': 'Bearer $token',
      });

      final response = await post<Map<String, dynamic>>(
        _baseUrl + AppUrls.SyncComboMealPackageTranslationsTableUrl,
      );

      if (response.statusCode == 200) {
        await ComboMealPackageTranslationsTable.deleteTable();
        List<dynamic> data = response.data!["result"]["added"];

        for (var item in data) {
          final translation = ComboMealPackageTranslationEntity.fromJson(item);
          await ComboMealPackageTranslationsTable.insertOrUpdate(translation);
        }
        dPrint('Synced ${data.length} combo meal package translations');
      } else {
        throw Exception(
            'Failed to get ComboMealPackageTranslations. Status Code: ${response.statusCode}');
      }
    } on DioException catch (e) {
       dPrint('Error fetching combo meal package translations: ${e.response?.data ?? e.message}');
 
    }
  }

  /// Sync combo meal package items (items available in each package)
  Future<void> getComboMealPackageItems() async {
    try {
      final token = await AppPreferences().getAccessToken();
      final tenantId = await AppPreferences().getTenant();
 

      dio.options.headers.addAll({
        'abp.tenantid': tenantId,
        'Authorization': 'Bearer $token',
      });

      final response = await post<Map<String, dynamic>>(
        _baseUrl + AppUrls.SyncComboMealPackageItemsTableUrl,
 
      );

      if (response.statusCode == 200) {
        await ComboMealPackageItemsTable.deleteTable();
        List<dynamic> data = response.data!["result"]["added"];

        for (var item in data) {
          final packageItem = ComboMealPackageItemEntity.fromJson(item);
          await ComboMealPackageItemsTable.insertOrUpdate(packageItem);
        }
        dPrint('Synced ${data.length} combo meal package items');
      } else {
         throw Exception('Failed to get ComboMealPackageItems. Status Code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      dPrint('Error fetching combo meal package items: ${e.response?.data ?? e.message}');
 
    }
  }

  /// Sync combo meal package item price lists (prices for different price lists)
  Future<void> getComboMealPackageItemPriceLists() async {
    try {
      final token = await AppPreferences().getAccessToken();
      final tenantId = await AppPreferences().getTenant();

      dio.options.headers.addAll({
        'abp.tenantid': tenantId,
        'Authorization': 'Bearer $token',
      });

      final response = await post<Map<String, dynamic>>(
        _baseUrl + AppUrls.SyncComboMealPackageItemPriceListTableUrl,
      );

      if (response.statusCode == 200) {
        await ComboMealPackageItemPriceListsTable.deleteTable();
        List<dynamic> data = response.data!["result"]["added"];

        for (var item in data) {
          final priceList = ComboMealPackageItemPriceListEntity.fromJson(item);
          await ComboMealPackageItemPriceListsTable.insertOrUpdate(priceList);
        }
        dPrint('Synced ${data.length} combo meal package item price lists');
      } else {
        throw Exception(
            'Failed to get ComboMealPackageItemPriceLists. Status Code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      dPrint(
          'Error fetching combo meal package item price lists: ${e.response?.data ?? e.message}');
    }
  }

  /// Sync combo meal definitions (links menu items to packages)
  Future<void> getComboMealDefinitions() async {
    try {
      final token = await AppPreferences().getAccessToken();
      final tenantId = await AppPreferences().getTenant();

      dio.options.headers.addAll({
        'abp.tenantid': tenantId,
        'Authorization': 'Bearer $token',
      });

      final response = await post<Map<String, dynamic>>(
        _baseUrl + AppUrls.SyncComboMealDefinitionsTableUrl,
      );

      if (response.statusCode == 200) {
        await ComboMealDefinitionsTable.deleteTable();
        List<dynamic> data = response.data!["result"]["added"];

        for (var item in data) {
          final definition = ComboMealDefinitionEntity.fromJson(item);
          await ComboMealDefinitionsTable.insertOrUpdate(definition);
        }
        dPrint('Synced ${data.length} combo meal definitions');
      } else {
         throw Exception('Failed to get ComboMealDefinitions. Status Code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      dPrint('Error fetching combo meal definitions: ${e.response?.data ?? e.message}');
 
    }
  }

  @override
  Future<void> getReportGroupTranslations() async {
    try {
      final token = await AppPreferences().getAccessToken();
      final tenantId = await AppPreferences().getTenant();

      dio.options.headers.addAll({
        'abp.tenantid': tenantId,
        'Authorization': 'Bearer $token',
      });

      final response = await post<Map<String, dynamic>>(
        _baseUrl + AppUrls.syncReportGroupTranslationTable,
      );

      if (response.statusCode == 200) {
        await ReportGroupTranslationTable.deleteTable();
        List<dynamic> added = response.data!["result"]["added"];
        for (var item in added) {
          final entity = ReportGroupTranslationEntity.fromJson(item);
          await ReportGroupTranslationTable.insertOrUpdate(entity);
        }
        List<dynamic> updated = response.data!["result"]["updated"] ?? [];
        for (var item in updated) {
          final entity = ReportGroupTranslationEntity.fromJson(item);
          await ReportGroupTranslationTable.insertOrUpdate(entity);
        }
      } else {
        throw Exception(
            'Failed to get ReportGroupTranslations. Status Code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      dPrint(
          'Error fetching report group translations: ${e.response?.data ?? e.message}');
    }
  }

  @override

  /// Sync all combo meal related data in the correct order
  Future<void> syncAllComboMealData() async {
    dPrint('Starting combo meal data sync...');

    // Sync in dependency order
    await getComboMealPackages();
    await getComboMealPackageTranslations();
    await getComboMealPackageItems();
    await getComboMealPackageItemPriceLists();
    await getComboMealDefinitions();

    dPrint('Combo meal data sync completed');
  }
}
