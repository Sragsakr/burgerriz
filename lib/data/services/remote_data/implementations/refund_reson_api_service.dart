import 'package:dio/dio.dart';
import 'package:kiosk_point_of_sale/core/constants/app_urls.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';
import 'package:kiosk_point_of_sale/data/models/refund_reson_model.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/refund_reasons/refund_reson_table.dart';
import 'package:kiosk_point_of_sale/data/services/remote_data/interfaces/refund_reson_api_interface.dart';

import 'base_api_service.dart';

class RefundResonApiService extends BaseApiService
    implements RefundResonApiInterface {
  late String _baseUrl;

  RefundResonApiService()
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
  Future<List<RefundResonModel>> fetchRefundResons() async {
    try {
      final token = await AppPreferences().getAccessToken();
      final tenantId = await AppPreferences().getTenant();

      dio.options.headers['abp.tenantId'] = tenantId;
      dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await get<Map<String, dynamic>>(
        _baseUrl + AppUrls.refundResonsList,
      );

      if (response.statusCode == 200 && response.data!['success'] == true) {
        final responseModel = RefundResonResponseModel.fromMap(response.data!);
        final List<RefundResonModel> refundResons = responseModel.result;

        // Update local database
        await RefundResonTable.deleteTable();
        for (var item in refundResons) {
          await RefundResonTable.insert(item);
        }

        return refundResons;
      } else {
        throw Exception('Failed to fetch refund resons');
      }
    } on DioException catch (e) {
      throw Exception(
          'Failed to fetch refund resons: ${e.response?.data ?? e.message}');
    }
  }
}
