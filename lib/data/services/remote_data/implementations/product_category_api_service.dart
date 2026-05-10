import 'package:dio/dio.dart';
import 'package:kiosk_point_of_sale/core/constants/app_urls.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';
import 'package:kiosk_point_of_sale/data/models/product_category/product_category_level_model.dart';
import 'package:kiosk_point_of_sale/data/models/product_category/product_category_model.dart';
import 'package:kiosk_point_of_sale/data/models/product_category/product_category_translation_model.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/product_category/product_category_level_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/product_category/product_category_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/product_category/product_category_translation_table.dart';
import 'package:kiosk_point_of_sale/data/services/remote_data/interfaces/product_category_api_interface.dart';

import 'base_api_service.dart';

class ProductCategoryApiService extends BaseApiService
    implements ProductCategoryApiInterface {
  late String _baseUrl;

  ProductCategoryApiService()
      : super(
          baseUrl: '',
          defaultHeaders: {'Content-Type': 'application/json'},
        );

  @override
  Future<void> initialize() async {
    _baseUrl = await AppUrls.getBaseUrl();
    await super.initialize();
  }

  String get _formattedDateTime =>
      "${DateTime.now().toLocal()}".split('.')[0];

  Future<void> _setTenantHeader() async {
    final tenantId = await AppPreferences().getTenant();
    dio.options.headers['abp.tenantId'] = tenantId;
  }

  @override
  Future<List<ProductCategoryModel>> fetchProductCategories() async {
    try {
      await _setTenantHeader();

      final response = await post<Map<String, dynamic>>(
        _baseUrl + AppUrls.syncProductCategoryTable,
        queryParameters: {'datetime': _formattedDateTime},
      );

      if (response.statusCode == 200 && response.data!['success'] == true) {
        final List<dynamic> data = response.data!['result']['added'];
        final items =
            data.map((e) => ProductCategoryModel.fromMap(e)).toList();

        await ProductCategoryTable.deleteTable();
        for (var item in items) {
          await ProductCategoryTable.insert(item);
        }

        return items;
      } else {
        throw Exception('Failed to fetch product categories');
      }
    } on DioException catch (e) {
      throw Exception(
          'Failed to fetch product categories: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<List<ProductCategoryTranslationModel>>
      fetchProductCategoryTranslations() async {
    try {
      await _setTenantHeader();

      final response = await post<Map<String, dynamic>>(
        _baseUrl + AppUrls.syncProductCategoryTranslationTable,
        queryParameters: {'datetime': _formattedDateTime},
      );

      if (response.statusCode == 200 && response.data!['success'] == true) {
        final List<dynamic> data = response.data!['result']['added'];
        final items =
            data.map((e) => ProductCategoryTranslationModel.fromMap(e)).toList();

        await ProductCategoryTranslationTable.deleteTable();
        for (var item in items) {
          await ProductCategoryTranslationTable.insert(item);
        }

        return items;
      } else {
        throw Exception('Failed to fetch product category translations');
      }
    } on DioException catch (e) {
      throw Exception(
          'Failed to fetch product category translations: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<List<ProductCategoryLevelModel>> fetchProductCategoryLevels() async {
    try {
      await _setTenantHeader();

      final response = await post<Map<String, dynamic>>(
        _baseUrl + AppUrls.syncProductCategoryLevelTable,
        queryParameters: {'datetime': _formattedDateTime},
      );

      if (response.statusCode == 200 && response.data!['success'] == true) {
        final List<dynamic> data = response.data!['result']['added'];
        final items =
            data.map((e) => ProductCategoryLevelModel.fromMap(e)).toList();

        await ProductCategoryLevelTable.deleteTable();
        for (var item in items) {
          await ProductCategoryLevelTable.insert(item);
        }

        return items;
      } else {
        throw Exception('Failed to fetch product category levels');
      }
    } on DioException catch (e) {
      throw Exception(
          'Failed to fetch product category levels: ${e.response?.data ?? e.message}');
    }
  }
}
