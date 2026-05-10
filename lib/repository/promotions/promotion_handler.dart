import 'package:kiosk_point_of_sale/data/models/promotions/models/promotion_context.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/models/promotion_invoice.dart';

abstract class IPromotionHandler {
  Future<PromotionInvoice> apply(PromotionContext context);
}
