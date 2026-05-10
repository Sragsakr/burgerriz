import 'package:dio/dio.dart';
import 'package:kiosk_point_of_sale/core/constants/app_urls.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/models/promotion_codes_fb_model.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/models/promotion_details_fb_excluded_menu_item_model.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/models/promotion_fb_additional_free_item_excluded_menu_item_model.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/models/promotion_fb_additional_free_item_model.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/models/promotion_fb_item_excluded_menu_item_model.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/models/promotion_fb_item_model.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/models/promotions_details_fB_model.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/models/promotions_fB_table_model.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/tables/promotion_codes_fb_table.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/tables/promotion_details_fb_excluded_menu_item_table.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/tables/promotion_fb_additional_free_item_excluded_menu_item_table.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/tables/promotion_fb_additional_free_item_table.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/tables/promotion_fb_item_excluded_menu_item_table.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/tables/promotion_fb_item_table.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/tables/promotions_details_fB_table.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/tables/promotions_fB_table_table.dart';
import 'package:kiosk_point_of_sale/data/services/remote_data/interfaces/promotions_api_interface.dart';

import 'base_api_service.dart';

class PromotionsApiService extends BaseApiService implements PromotionsApiInterface {
  late String _baseUrl;

  PromotionsApiService()
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
  Future<List<PromotionsFBTableModel>> getPromotionsFBTable() async {
    try {
      final token = await AppPreferences().getAccessToken();
      final tenantId = await AppPreferences().getTenant();
      final storeId = await AppPreferences().getStore();
      // final now = DateTime.now();
      // final formattedDateTime = "${now.toLocal()}".split('.')[0];

      dio.options.headers.addAll({
        'abp.tenantid': tenantId,
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      final response = await post<Map<String, dynamic>>(
        _baseUrl + AppUrls.promotionsFBTableUrl,
        queryParameters: {
          'StoreId': storeId,
        },
      );

      if (response.statusCode == 200 && response.data!['success'] == true) {
        final List<dynamic> data = response.data!['result']['added'];
        final List<PromotionsFBTableModel> promotions = data.map((e) => PromotionsFBTableModel.fromJson(e)).toList();

        // Update local database
        await PromotionsFBTable.deleteTable();
        for (var promo in promotions) {
          await PromotionsFBTable.insert(promo);
        }

        return promotions;
      } else {
        throw Exception('Failed to fetch Promotions');
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch Promotions: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<List<PromotionCodesFBModel>> getPromotionCodesFB() async {
    try {
      final token = await AppPreferences().getAccessToken();
      final tenantId = await AppPreferences().getTenant();
      final storeId = await AppPreferences().getStore();
      // final now = DateTime.now();
      // final formattedDateTime = "${now.toLocal()}".split('.')[0];

      dio.options.headers.addAll({
        'abp.tenantid': tenantId,
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      final response = await post<Map<String, dynamic>>(
        _baseUrl + AppUrls.promotionCodesFBTableUrl,
        queryParameters: {
          'StoreId': storeId,
        },
      );

      if (response.statusCode == 200 && response.data!['success'] == true) {
        final List<dynamic> data = response.data!['result']['added'];
        final List<PromotionCodesFBModel> promotions = data.map((e) => PromotionCodesFBModel.fromJson(e)).toList();

        // Update local database
        await PromotionCodesFBTable.deleteTable();
        for (var promo in promotions) {
          await PromotionCodesFBTable.insert(promo);
        }

        return promotions;
      } else {
        throw Exception('Failed to fetch currencies');
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch currencies: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<List<PromotionDetailsFBModel>> getPromotionDetailsFB() async {
    try {
      final token = await AppPreferences().getAccessToken();
      final tenantId = await AppPreferences().getTenant();
      final storeId = await AppPreferences().getStore();
      // final now = DateTime.now();
      // final formattedDateTime = "${now.toLocal()}".split('.')[0];

      dio.options.headers.addAll({
        'abp.tenantid': tenantId,
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      final response = await post<Map<String, dynamic>>(
        _baseUrl + AppUrls.promotionDetailsFBTableUrl,
        queryParameters: {
          'StoreId': storeId,
        },
      );

      if (response.statusCode == 200 && response.data!['success'] == true) {
        final List<dynamic> data = response.data!['result']['added'];
        final List<PromotionDetailsFBModel> promotions = data.map((e) => PromotionDetailsFBModel.fromJson(e)).toList();

        // Update local database
        await PromotionDetailsFBTable.deleteTable();
        for (var promo in promotions) {
          await PromotionDetailsFBTable.insert(promo);
        }

        return promotions;
      } else {
        throw Exception('Failed to fetch currencies');
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch currencies: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<List<PromotionFBItemModel>> getPromotionFBItems() async {
    try {
      final token = await AppPreferences().getAccessToken();
      final tenantId = await AppPreferences().getTenant();
      final storeId = await AppPreferences().getStore();
      // final now = DateTime.now();
      // final formattedDateTime = "${now.toLocal()}".split('.')[0];

      dio.options.headers.addAll({
        'abp.tenantid': tenantId,
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      final response = await post<Map<String, dynamic>>(
        _baseUrl + AppUrls.promotionFBItemUrl,
        queryParameters: {
          'StoreId': storeId,
        },
      );

      if (response.statusCode == 200 && response.data!['success'] == true) {
        final List<dynamic> data = response.data!['result']['added'];
        final List<PromotionFBItemModel> promotions = data.map((e) => PromotionFBItemModel.fromJson(e)).toList();

        // Update local database
        await PromotionFBItemTable.deleteTable();
        for (var promo in promotions) {
          await PromotionFBItemTable.insert(promo);
        }

        return promotions;
      } else {
        throw Exception('Failed to fetch currencies');
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch currencies: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<List<PromotionFBItemExcludedMenuItemModel>> getPromotionFBItemExcludedMenuItem() async {
    try {
      final token = await AppPreferences().getAccessToken();
      final tenantId = await AppPreferences().getTenant();
      final storeId = await AppPreferences().getStore();
      // final now = DateTime.now();
      // final formattedDateTime = "${now.toLocal()}".split('.')[0];

      dio.options.headers.addAll({
        'abp.tenantid': tenantId,
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      final response = await post<Map<String, dynamic>>(
        _baseUrl + AppUrls.promotionFBItemExcludedMenuItemTableUrl,
        queryParameters: {
          'StoreId': storeId,
        },
      );

      if (response.statusCode == 200 && response.data!['success'] == true) {
        final List<dynamic> data = response.data!['result']['added'];
        final List<PromotionFBItemExcludedMenuItemModel> promotions =
            data.map((e) => PromotionFBItemExcludedMenuItemModel.fromMap(e)).toList();

        // Update local database
        await PromotionFBItemExcludedMenuItemTable.deleteTable();
        for (var promo in promotions) {
          await PromotionFBItemExcludedMenuItemTable.insert(promo);
        }

        return promotions;
      } else {
        throw Exception('Failed to fetch currencies');
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch currencies: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<List<PromotionDetailsFBExcludedMenuItemModel>> getPromotionDetailsFBExcludedMenuItem() async {
    try {
      final token = await AppPreferences().getAccessToken();
      final tenantId = await AppPreferences().getTenant();
      final storeId = await AppPreferences().getStore();
      // final now = DateTime.now();
      // final formattedDateTime = "${now.toLocal()}".split('.')[0];

      dio.options.headers.addAll({
        'abp.tenantid': tenantId,
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      final response = await post<Map<String, dynamic>>(
        _baseUrl + AppUrls.promotionDetailsFBExcludedMenuItem,
        queryParameters: {
          'StoreId': storeId,
        },
      );

      if (response.statusCode == 200 && response.data!['success'] == true) {
        final List<dynamic> data = response.data!['result']['added'];
        final List<PromotionDetailsFBExcludedMenuItemModel> promotions =
            data.map((e) => PromotionDetailsFBExcludedMenuItemModel.fromMap(e)).toList();

        // Update local database
        await PromotionDetailsFBExcludedMenuItemTable.deleteTable();
        for (var promo in promotions) {
          await PromotionDetailsFBExcludedMenuItemTable.insert(promo);
        }

        return promotions;
      } else {
        throw Exception('Failed to fetch currencies');
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch currencies: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<List<PromotionFBAdditionalFreeItemModel>> getPromotionFBAdditionalFreeItem() async {
    try {
      final token = await AppPreferences().getAccessToken();
      final tenantId = await AppPreferences().getTenant();
      final storeId = await AppPreferences().getStore();

      dio.options.headers.addAll({
        'abp.tenantid': tenantId,
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      final response = await post<Map<String, dynamic>>(
        _baseUrl + AppUrls.promotionFBAdditionalFreeItem,
        queryParameters: {
          'StoreId': storeId,
        },
      );

      if (response.statusCode == 200 && response.data!['success'] == true) {
        final List<dynamic> data = response.data!['result']['added'];
        final List<PromotionFBAdditionalFreeItemModel> promotions =
            data.map((e) => PromotionFBAdditionalFreeItemModel.fromJson(e)).toList();

        // Update local database
        await PromotionFBAdditionalFreeItemTable.deleteTable();
        await PromotionFBAdditionalFreeItemExcludedMenuItemTable.deleteTable();

        for (var promo in promotions) {
          await PromotionFBAdditionalFreeItemTable.insert(promo);

          // Handle excluded menu items if they exist in the response
          if (data.isNotEmpty) {
            final promoData = data.firstWhere((item) => item['id'] == promo.id, orElse: () => {});
            if (promoData['excludedMenuItems'] != null) {
              final List<dynamic> excludedItems = promoData['excludedMenuItems'] as List<dynamic>;
              for (var excludedItem in excludedItems) {
                final excludedMenuItem = PromotionFBAdditionalFreeItemExcludedMenuItemModel.fromJson(excludedItem);
                await PromotionFBAdditionalFreeItemExcludedMenuItemTable.insert(excludedMenuItem);
              }
            }
          }
        }

        return promotions;
      } else {
        throw Exception('Failed to fetch promotion FB additional free items');
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch promotion FB additional free items: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<void> syncAllPromotionTablesFromRemote() async {
    await getPromotionsFBTable();
    await getPromotionFBItems();
    await getPromotionDetailsFB();
    await getPromotionCodesFB();
    await getPromotionFBItemExcludedMenuItem();
    await getPromotionDetailsFBExcludedMenuItem();
    await getPromotionFBAdditionalFreeItem();
  }
}
