import 'package:dio/dio.dart';
import 'package:kiosk_point_of_sale/core/constants/app_urls.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/menu_item_fb_entity.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/menu_item_price_list_entity.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/menu_item_tax_entity.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/menu_item_translation_entity.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/price_list_translation_entity.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/tables/menu_item_fb_table.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/tables/menu_item_price_list_table.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/tables/menu_item_tax_table.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/tables/menu_item_translation_table.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/tables/price_list_translation_table.dart';
import 'package:kiosk_point_of_sale/data/services/remote_data/implementations/base_api_service.dart';
import 'package:kiosk_point_of_sale/data/services/remote_data/interfaces/menu_item_api_interface.dart';

class MenuItemSyncApiService extends BaseApiService
    implements MenuItemApiInterface {
  late String _baseUrl;

  MenuItemSyncApiService()
      : super(
          baseUrl: '',
          defaultHeaders: {'Content-Type': 'application/json'},
        );

  @override
  Future<void> initialize() async {
    _baseUrl = await AppUrls.getBaseUrl();
    await super.initialize();
  }

  @override
  Future<void> syncMenuItemsFB() async {
    try {
      final token = await AppPreferences().getAccessToken();
      final tenantId = await AppPreferences().getTenant();
      final storeId = await AppPreferences().getStore();

      dio.options.headers.addAll({
        'abp.tenant': tenantId,
        'Authorization': 'Bearer $token',
      });

      final response = await post<Map<String, dynamic>>(
        _baseUrl + AppUrls.syncMenuItemTableFB,
        queryParameters: {'StoreId': storeId},
      );

      if (response.statusCode == 200) {
        await MenuItemFBTable.deleteTable();
        final List<dynamic> data = response.data!['result']['added'];
        for (var item in data) {
          final entity = MenuItemFBEntity.fromJson(item);
          await MenuItemFBTable.insertOrUpdate(entity);
        }
        dPrint('Synced ${data.length} menu items (FB)');
      } else {
        throw Exception(
            'Failed to sync menu items FB. Status Code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      dPrint('Error syncing menu items FB: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<void> syncMenuItemTranslations() async {
    try {
      final token = await AppPreferences().getAccessToken();
      final tenantId = await AppPreferences().getTenant();

      dio.options.headers.addAll({
        'abp.tenantid': tenantId,
        'Authorization': 'Bearer $token',
      });

      final response = await post<Map<String, dynamic>>(
        _baseUrl + AppUrls.syncMenuItemTranslationTable,
      );

      if (response.statusCode == 200) {
        await MenuItemTranslationTable.deleteTable();
        final List<dynamic> data = response.data!['result']['added'];
        for (var item in data) {
          final entity = MenuItemTranslationEntity.fromJson(item);
          await MenuItemTranslationTable.insertOrUpdate(entity);
        }
        dPrint('Synced ${data.length} menu item translations');
      } else {
        throw Exception(
            'Failed to sync menu item translations. Status Code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      dPrint(
          'Error syncing menu item translations: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<void> syncMenuItemPriceLists() async {
    try {
      final token = await AppPreferences().getAccessToken();
      final tenantId = await AppPreferences().getTenant();

      dio.options.headers.addAll({
        'abp.tenantid': tenantId,
        'Authorization': 'Bearer $token',
      });

      final response = await post<Map<String, dynamic>>(
        _baseUrl + AppUrls.syncMenuItemPriceListTable,
      );

      if (response.statusCode == 200) {
        await MenuItemPriceListTable.deleteTable();
        final List<dynamic> data = response.data!['result']['added'];
        for (var item in data) {
          final entity = MenuItemPriceListEntity.fromJson(item);
          await MenuItemPriceListTable.insertOrUpdate(entity);
        }
        dPrint('Synced ${data.length} menu item price lists');
      } else {
        throw Exception(
            'Failed to sync menu item price lists. Status Code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      dPrint(
          'Error syncing menu item price lists: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<void> syncMenuItemTaxes() async {
    try {
      final token = await AppPreferences().getAccessToken();
      final tenantId = await AppPreferences().getTenant();

      dio.options.headers.addAll({
        'abp.tenantid': tenantId,
        'Authorization': 'Bearer $token',
      });

      final response = await post<Map<String, dynamic>>(
        _baseUrl + AppUrls.syncMenuItemTaxTable,
      );

      if (response.statusCode == 200) {
        await MenuItemTaxTable.deleteTable();
        final List<dynamic> data = response.data!['result']['added'];
        for (var item in data) {
          final entity = MenuItemTaxEntity.fromJson(item);
          await MenuItemTaxTable.insertOrUpdate(entity);
        }
        dPrint('Synced ${data.length} menu item taxes');
      } else {
        throw Exception(
            'Failed to sync menu item taxes. Status Code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      dPrint(
          'Error syncing menu item taxes: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<void> syncPriceListTranslations() async {
    try {
      final token = await AppPreferences().getAccessToken();
      final tenantId = await AppPreferences().getTenant();

      dio.options.headers.addAll({
        'abp.tenantid': tenantId,
        'Authorization': 'Bearer $token',
      });

      final response = await post<Map<String, dynamic>>(
        _baseUrl + AppUrls.syncPriceListTranslationsTable,
      );

      if (response.statusCode == 200) {
        await PriceListTranslationTable.deleteTable();
        final List<dynamic> data = response.data!['result']['added'];
        for (var item in data) {
          final entity = PriceListTranslationEntity.fromJson(item);
          await PriceListTranslationTable.insertOrUpdate(entity);
        }
        dPrint('Synced ${data.length} price list translations');
      } else {
        throw Exception(
            'Failed to sync price list translations. Status Code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      dPrint(
          'Error syncing price list translations: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<void> syncAllMenuItemData() async {
    dPrint('Starting menu item data sync...');
    await syncMenuItemsFB();
    await syncMenuItemTranslations();
    await syncMenuItemPriceLists();
    await syncMenuItemTaxes();
    await syncPriceListTranslations();
    dPrint('Menu item data sync completed');
  }
}
