import 'package:dio/dio.dart';
import 'package:kiosk_point_of_sale/core/constants/app_urls.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';
import 'package:kiosk_point_of_sale/data/models/primary_category/primary_category_model.dart';
import 'package:kiosk_point_of_sale/data/models/primary_category/primary_category_translation_model.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/primary_category/primary_category_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/primary_category/primary_category_translation_table.dart';
import 'package:kiosk_point_of_sale/data/services/remote_data/interfaces/primary_category_api_interface.dart';

import 'base_api_service.dart';

class PrimaryCategoryApiService extends BaseApiService
    implements PrimaryCategoryApiInterface {
  late String _baseUrl;

  PrimaryCategoryApiService()
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
  Future<List<PrimaryCategoryModel>> fetchPrimaryCategories() async {
    try {
      await _setTenantHeader();

      final response = await post<Map<String, dynamic>>(
        _baseUrl + AppUrls.syncPrimaryCategoryTable,
        queryParameters: {'datetime': _formattedDateTime},
      );

      if (response.statusCode == 200 && response.data!['success'] == true) {
        final List<dynamic> data = response.data!['result']['added'];
        final items =
            data.map((e) => PrimaryCategoryModel.fromMap(e)).toList();

        await PrimaryCategoryTable.deleteTable();
        for (var item in items) {
          await PrimaryCategoryTable.insert(item);
        }

        return items;
      } else {
        throw Exception('Failed to fetch primary categories');
      }
    } on DioException catch (e) {
      throw Exception(
          'Failed to fetch primary categories: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<List<PrimaryCategoryTranslationModel>>
      fetchPrimaryCategoryTranslations() async {
    try {
      await _setTenantHeader();

      final response = await post<Map<String, dynamic>>(
        _baseUrl + AppUrls.syncPrimaryCategoryTranslationTable,
        queryParameters: {'datetime': _formattedDateTime},
      );

      if (response.statusCode == 200 && response.data!['success'] == true) {
        final List<dynamic> data = response.data!['result']['added'];
        final items = data
            .map((e) => PrimaryCategoryTranslationModel.fromMap(e))
            .toList();

        await PrimaryCategoryTranslationTable.deleteTable();
        for (var item in items) {
          await PrimaryCategoryTranslationTable.insert(item);
        }

        return items;
      } else {
        throw Exception('Failed to fetch primary category translations');
      }
    } on DioException catch (e) {
      throw Exception(
          'Failed to fetch primary category translations: ${e.response?.data ?? e.message}');
    }
  }
}
