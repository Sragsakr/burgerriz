import 'package:kiosk_point_of_sale/data/models/refund_reson_model.dart';

/// Interface for Refund Reson API operations
abstract class RefundResonApiInterface {
  /// Fetch refund resons from the API and sync with local database
  Future<List<RefundResonModel>> fetchRefundResons();
}
