import 'package:dio/dio.dart';
import 'package:kiosk_point_of_sale/core/constants/app_urls.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/data/models/sale_types/sale_tender_type_model.dart';
import 'package:kiosk_point_of_sale/data/models/sale_types/sale_type_model.dart';
import 'package:kiosk_point_of_sale/data/models/sale_types/sale_type_price_list_model.dart';
import 'package:kiosk_point_of_sale/data/models/sale_types/sale_type_store_model.dart';
import 'package:kiosk_point_of_sale/data/models/sale_types/sale_type_translation_model.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/sale_type_tables/sale__tender_type_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/sale_type_tables/sale_type_price_list_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/sale_type_tables/sale_type_store_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/sale_type_tables/sale_type_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/sale_type_tables/sale_type_translation_table.dart';

import '../interfaces/sale_types_api_interface.dart';
import 'base_api_service.dart';

class SaleTypesApiService extends BaseApiService
    implements SaleTypesApiInterface {
  late String _baseUrl;

  SaleTypesApiService()
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
  Future<void> getSaleTenderTypes() async {
    try {
      final token = await AppPreferences().getAccessToken();
      final tenantId = await AppPreferences().getTenant();

      dio.options.headers.addAll({
        'abp.tenantid': tenantId,
        'Authorization': 'Bearer $token',
      });

      final response = await post<Map<String, dynamic>>(
        _baseUrl + AppUrls.saleTenderTypeUrl,
      );

      if (response.statusCode == 200) {
        await SaleTenderTypeTable.deleteTable();
        List<dynamic> data = response.data!["result"]["added"];
        List<SaleTenderTypeModel> types =
            data.map((e) => SaleTenderTypeModel.fromMap(e)).toList();

        for (var type in types) {
          dPrint('TenderType: $type');
          try {
            await SaleTenderTypeTable.insert(type);
          } catch (e, t) {
            dPrint('SaleTenderTypeError');
            dPrint(e.toString());
            dPrint(t.toString());
          }
        }
      } else {
        throw Exception(
            'Failed to get SaleTenderTypes. Status Code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(
          'Failed to get SaleTenderTypes: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<void> getSaleTypes() async {
    try {
      final token = await AppPreferences().getAccessToken();
      final tenantId = await AppPreferences().getTenant();

      dio.options.headers.addAll({
        'abp.tenantid': tenantId,
        'Authorization': 'Bearer $token',
      });

      final response = await post<Map<String, dynamic>>(
        _baseUrl + AppUrls.syncSaleTypeTable,
      );

      if (response.statusCode == 200) {
        await SaleTypeTable.deleteTable();
        List<dynamic> data = response.data!["result"]["added"];
        List<SaleTypeModel> types =
            data.map((e) => SaleTypeModel.fromMap(e)).toList();

        for (var type in types) {
          await SaleTypeTable.insert(type);
        }
      } else {
        throw Exception(
            'Failed to get SaleTypes. Status Code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(
          'Failed to get SaleTypes: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<void> getSaleTypeTranslations() async {
    try {
      final token = await AppPreferences().getAccessToken();
      final tenantId = await AppPreferences().getTenant();

      dio.options.headers.addAll({
        'abp.tenantid': tenantId,
        'Authorization': 'Bearer $token',
      });

      final response = await post<Map<String, dynamic>>(
        _baseUrl + AppUrls.syncSaleTypeTranslationsTable,
      );

      if (response.statusCode == 200) {
        await SaleTypeTranslationTable.deleteTable();
        List<dynamic> data = response.data!["result"]["added"];
        List<SaleTypeTranslationModel> translations =
            data.map((e) => SaleTypeTranslationModel.fromMap(e)).toList();

        for (var translation in translations) {
          await SaleTypeTranslationTable.insert(translation);
        }
      } else {
        throw Exception(
            'Failed to get SaleTypeTranslations. Status Code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(
          'Failed to get SaleTypeTranslations: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<void> getSaleTypeStores() async {
    try {
      final token = await AppPreferences().getAccessToken();
      final tenantId = await AppPreferences().getTenant();

      dio.options.headers.addAll({
        'abp.tenantid': tenantId,
        'Authorization': 'Bearer $token',
      });

      final response = await post<Map<String, dynamic>>(
        _baseUrl + AppUrls.saleTypeStoresTable,
      );

      if (response.statusCode == 200) {
        await SaleTypeStoresTable.create();
        List<dynamic> data = response.data!["result"]["added"];
        List<SaleTypeStoresModel> stores =
            data.map((e) => SaleTypeStoresModel.fromMap(e)).toList();

        for (var store in stores) {
          await SaleTypeStoresTable.insert(store);
        }
      } else {
        throw Exception(
            'Failed to get SaleTypeStores. Status Code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(
          'Failed to get SaleTypeStores: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<void> getSaleTypePriceLists() async {
    try {
      final token = await AppPreferences().getAccessToken();
      final tenantId = await AppPreferences().getTenant();

      dio.options.headers.addAll({
        'abp.tenantid': tenantId,
        'Authorization': 'Bearer $token',
      });

      final response = await post<Map<String, dynamic>>(
        _baseUrl + AppUrls.syncSaleTypePriceListTable,
      );

      if (response.statusCode == 200) {
        await SaleTypePriceListTable.deleteTable();
        List<dynamic> data = response.data!["result"]["added"];
        List<SaleTypePriceListModel> priceLists =
            data.map((e) => SaleTypePriceListModel.fromMap(e)).toList();

        for (var priceList in priceLists) {
          await SaleTypePriceListTable.insert(priceList);
        }
      } else {
        throw Exception(
            'Failed to get SaleTypePriceLists. Status Code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(
          'Failed to get SaleTypePriceLists: ${e.response?.data ?? e.message}');
    }
  }
}
