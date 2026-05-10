import 'package:dio/dio.dart';
import 'package:kiosk_point_of_sale/core/constants/app_urls.dart';
import 'package:kiosk_point_of_sale/core/helpers/currency_display_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';
import 'package:kiosk_point_of_sale/data/models/store/currency_model.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/currency/currency_table.dart';

import '../interfaces/currency_api_interface.dart';
import 'base_api_service.dart';

class CurrencyApiService extends BaseApiService
    implements CurrencyApiInterface {
  late String _baseUrl;

  CurrencyApiService()
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
  Future<List<CurrencyModel>> fetchCurrencies() async {
    try {
      final token = await AppPreferences().getAccessToken();
      final tenantId = await AppPreferences().getTenant();
      final now = DateTime.now();
      final formattedDateTime = "${now.toLocal()}".split('.')[0];

      dio.options.headers['abp.tenantId'] = tenantId;

      final response = await post<Map<String, dynamic>>(
        _baseUrl + AppUrls.currencyListUrl,
        queryParameters: {
          'datetime': formattedDateTime,
        },
      );

      if (response.statusCode == 200 && response.data!['success'] == true) {
        final List<dynamic> data = response.data!['result']['added'];
        final List<CurrencyModel> currencies =
            data.map((e) => CurrencyModel.fromMap(e)).toList();

        // Update local database
        await CurrencyTable.deleteTable();
        for (var currency in currencies) {
          await CurrencyTable.insert(currency);
        }
        CurrencyDisplayHelper.clearCache();

        return currencies;
      } else {
        throw Exception('Failed to fetch currencies');
      }
    } on DioException catch (e) {
      throw Exception(
          'Failed to fetch currencies: ${e.response?.data ?? e.message}');
    }
  }
}
