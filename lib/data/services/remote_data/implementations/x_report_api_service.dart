import 'package:dio/dio.dart';
import 'package:kiosk_point_of_sale/core/constants/app_urls.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/currency/currency_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/device/shift_table.dart';
import 'package:kiosk_point_of_sale/main.dart';
import 'package:kiosk_point_of_sale/features/shared-features/Cashier/cashier_widget.dart';
import 'package:kiosk_point_of_sale/features/shared-features/admin/reports/cashier_report/cashier_report_view.dart';
import 'package:uuid/uuid.dart';

import '../interfaces/x_report_api_interface.dart';
import 'base_api_service.dart';

class XReportApiService extends BaseApiService implements XReportApiInterface {
  late String _baseUrl;
  final _uuid = const Uuid();

  XReportApiService()
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
  Future<ShiftReportModel?> xReport() async {
    try {
      final token = await AppPreferences().getAccessToken();
      final tenantId = await AppPreferences().getTenant();
      final cashierShifts = await CashierShiftTable.getAll();
      final shift = cashierShifts.first;
      final shiftReport = await getCashierShiftReport(navKey.currentState!.context);
      final currency = await CurrencyTable.getSarCurrency();

      // if (shiftReport == null) return null;
      // if (shiftReport == null) return shiftReport;

      final data = {
        "cashierShiftId": shift.cashierShiftId,
        "cashierShiftPaymentDto": shiftReport == null
            ? []
            : [
                ...shiftReport.tenderTypes.map((e) => {
                      "Id": _uuid.v4(),
                      "CurrencyId": currency?.currencyId,
                      "TenderTypeId": e.tenderId,
                      "CashierTransactionsValue": 0.0000,
                      "ActualTransactionsValue": 0.0000,
                      "TotalTransactionsValue": e.price,
                      "CashierShiftId": shift.cashierShiftId
                    })
              ],
        "masterCashInOutSyncDto": []
      };

      dio.options.headers.addAll({
        "abp.tenantId": tenantId,
        "Authorization": "Bearer $token",
      });

      final response = await post<Map<String, dynamic>>(
        _baseUrl + AppUrls.xReportApi,
        data: data,
      );

      if (response.statusCode == 200 && response.data!["success"] == true) {
        return shiftReport;
      } else {
        throw Exception(
            'Failed to generate X-Report: ${response.data?["error"] ?? "Unknown error"}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to generate X-Report: ${e.response?.data ?? e.message}');
    }
  }
}
