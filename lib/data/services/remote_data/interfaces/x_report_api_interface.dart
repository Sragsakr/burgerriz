import 'package:kiosk_point_of_sale/features/shared-features/admin/reports/cashier_report/cashier_report_view.dart';

/// Interface for X-Report related API operations
abstract class XReportApiInterface {
  /// Generate and send X-Report for the current shift
  Future<ShiftReportModel?> xReport();
}
