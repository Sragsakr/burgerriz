import 'package:kiosk_point_of_sale/core/config/app_config.dart';
import 'package:kiosk_point_of_sale/core/routers/app_routes.dart';

abstract final class AppModeSession {
  AppModeSession._();

  static bool get isKiosk => AppConfig.isKiosk;

  static String get postCashierRoute => isKiosk ? AppRoutes.entry : AppRoutes.saleTypes;

  static String get postSaleTypeRoute => isKiosk ? AppRoutes.entry : AppRoutes.sellPage;

  static String get postPaymentRoute => isKiosk ? AppRoutes.entry : AppRoutes.saleTypes;

  static bool get useCustomizationWizard => !isKiosk;

  /// Single-store mode disables report-group catalog filtering in all app modes.
  static int? effectiveCatalogReportGroupId([int? selectedReportGroupId]) => null;
}
