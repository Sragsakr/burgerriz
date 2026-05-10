import 'package:dio/dio.dart';
import 'package:kiosk_point_of_sale/core/constants/app_urls.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';
import 'package:kiosk_point_of_sale/data/models/unit_of_measure/unit_of_measure_translation_model.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/unit_of_measure/unit_of_measure_translation_table.dart';

import '../interfaces/unit_of_measure_translation_api_interface.dart';
import 'base_api_service.dart';

class UnitOfMeasureTranslationApiService extends BaseApiService
    implements UnitOfMeasureTranslationApiInterface {
  late String _baseUrl;

  UnitOfMeasureTranslationApiService()
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
  Future<List<UnitOfMeasureTranslationModel>>
      fetchUnitOfMeasureTranslations() async {
    try {
      final tenantId = await AppPreferences().getTenant();
      final now = DateTime.now();
      final formattedDateTime = "${now.toLocal()}".split('.')[0];

      dio.options.headers['abp.tenantId'] = tenantId;

      final response = await post<Map<String, dynamic>>(
        _baseUrl + AppUrls.syncUnitOfMeasureTranslationTable,
        queryParameters: {
          'datetime': formattedDateTime,
        },
      );

      if (response.statusCode == 200 && response.data!['success'] == true) {
        final List<dynamic> data = response.data!['result']['added'];
        final List<UnitOfMeasureTranslationModel> items =
            data.map((e) => UnitOfMeasureTranslationModel.fromMap(e)).toList();

        await UnitOfMeasureTranslationTable.deleteTable();
        for (var item in items) {
          await UnitOfMeasureTranslationTable.insert(item);
        }

        return items;
      } else {
        throw Exception('Failed to fetch unit of measure translations');
      }
    } on DioException catch (e) {
      throw Exception(
          'Failed to fetch unit of measure translations: ${e.response?.data ?? e.message}');
    }
  }
}
