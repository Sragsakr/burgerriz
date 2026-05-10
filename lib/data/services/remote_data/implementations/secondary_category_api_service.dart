import 'package:dio/dio.dart';
import 'package:kiosk_point_of_sale/core/constants/app_urls.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';
import 'package:kiosk_point_of_sale/data/models/secondary_category/secondary_category_model.dart';
import 'package:kiosk_point_of_sale/data/models/secondary_category/secondary_category_translation_model.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/secondary_category/secondary_category_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/secondary_category/secondary_category_translation_table.dart';
import 'package:kiosk_point_of_sale/data/services/remote_data/interfaces/secondary_category_api_interface.dart';

import 'base_api_service.dart';

class SecondaryCategoryApiService extends BaseApiService
    implements SecondaryCategoryApiInterface {
  late String _baseUrl;

  SecondaryCategoryApiService()
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
  Future<List<SecondaryCategoryModel>> fetchSecondaryCategories() async {
    try {
      await _setTenantHeader();

      final response = await post<Map<String, dynamic>>(
        _baseUrl + AppUrls.syncSecondaryCategoryTable,
        queryParameters: {'datetime': _formattedDateTime},
      );

      if (response.statusCode == 200 && response.data!['success'] == true) {
        final List<dynamic> data = response.data!['result']['added'];
        final items =
            data.map((e) => SecondaryCategoryModel.fromMap(e)).toList();

        await SecondaryCategoryTable.deleteTable();
        for (var item in items) {
          await SecondaryCategoryTable.insert(item);
        }

        return items;
      } else {
        throw Exception('Failed to fetch secondary categories');
      }
    } on DioException catch (e) {
      throw Exception(
          'Failed to fetch secondary categories: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<List<SecondaryCategoryTranslationModel>>
      fetchSecondaryCategoryTranslations() async {
    try {
      await _setTenantHeader();

      final response = await post<Map<String, dynamic>>(
        _baseUrl + AppUrls.syncSecondaryCategoryTranslationTable,
        queryParameters: {'datetime': _formattedDateTime},
      );

      if (response.statusCode == 200 && response.data!['success'] == true) {
        final List<dynamic> data = response.data!['result']['added'];
        final items = data
            .map((e) => SecondaryCategoryTranslationModel.fromMap(e))
            .toList();

        await SecondaryCategoryTranslationTable.deleteTable();
        for (var item in items) {
          await SecondaryCategoryTranslationTable.insert(item);
        }

        return items;
      } else {
        throw Exception('Failed to fetch secondary category translations');
      }
    } on DioException catch (e) {
      throw Exception(
          'Failed to fetch secondary category translations: ${e.response?.data ?? e.message}');
    }
  }
}
