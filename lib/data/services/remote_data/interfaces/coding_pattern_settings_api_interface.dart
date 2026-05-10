import 'package:kiosk_point_of_sale/data/models/coding_pattern_settings_model.dart';

abstract class CodingPatternSettingsApiInterface {
  Future<CodingPatternSettingsModel> getSalesCodePattern();
  Future<CodingPatternSettingsModel> getSalesCodePatternForRefund();
}
