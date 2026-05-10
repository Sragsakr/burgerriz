import 'package:dio/dio.dart';
import 'package:kiosk_point_of_sale/core/constants/app_urls.dart';
import 'package:kiosk_point_of_sale/core/enums/shift_status_enum.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';
import 'package:kiosk_point_of_sale/data/models/store/shift_model.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/device/shift_table.dart';

import '../interfaces/cashier_shift_api_interface.dart';
import 'base_api_service.dart';

class CashierShiftApiService extends BaseApiService
    implements CashierShiftApiInterface {
  late String _baseUrl;
  bool _isInitialized = false;

  CashierShiftApiService()
      : super(
          baseUrl: '', // Will be set in initialize()
          defaultHeaders: {'Content-Type': 'application/json'},
        );

  @override
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }
    _baseUrl = await AppUrls.getBaseUrl();
    await super.initialize();
    _isInitialized = true;
  }

  @override
  Future<int?> startShift() async {
    await initialize();
    try {
      final now = DateTime.now();
      final formattedDateTime = "${now.toLocal()}".split('.')[0];
      final token = await AppPreferences().getAccessToken();
      final tenantId = await AppPreferences().getTenant();
      final storeId = await AppPreferences().getStore();

      dio.options.headers.addAll({
        "abp.tenant": tenantId,
        "Authorization": "Bearer $token",
      });

      final response = await post<Map<String, dynamic>>(
        _baseUrl + AppUrls.startMyShiftUrl,
        queryParameters: {
          "storeId": int.parse(storeId),
          "datetime": formattedDateTime,
        },
        data: {
          "storeId": int.parse(storeId),
        },
      );

      if (response.statusCode == 200 && response.data!['success'] == true) {
        final shift = CashierShift.fromJson(response.data!['result']);
        final status = ShiftSyncStatus.fromValue(shift.syncStatus);

        if (status == ShiftSyncStatus.Done) {
          await CashierShiftTable.deleteTable();
          await CashierShiftTable.insert(shift);
        } else {
          throw Exception(translator(
            arText: status!.descriptionAr,
            enText: status.descriptionEn,
          ));
        }
      }
      return null;
    } on DioException catch (e) {
      throw Exception(
          'Failed to start shift: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<bool> isHaveOpenedShift() async {
    await initialize();
    try {
      final now = DateTime.now();
      final formattedDateTime = "${now.toLocal()}".split('.')[0];
      final token = await AppPreferences().getAccessToken();
      final tenantId = await AppPreferences().getTenant();
      final storeId = await AppPreferences().getStore();

      dio.options.headers.addAll({
        "abp.tenant": tenantId,
        "Authorization": "Bearer $token",
      });

      final response = await get<Map<String, dynamic>>(
        _baseUrl + AppUrls.getOpenedCashierShift,
        queryParameters: {
          "storeId": int.parse(storeId),
          "datetime": formattedDateTime,
        },
      );

      return response.statusCode == 200 && response.data!['success'] == true;
    } catch (e) {
      return false;
    }
  }
}
