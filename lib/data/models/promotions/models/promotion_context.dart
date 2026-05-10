import 'package:kiosk_point_of_sale/data/models/promotions/models/promotion_codes_fb_model.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_invoice.dart';

class PromotionContext {
  final PromotionCodesFBModel promotionCodesFB;
  final SalesInvoice saleTrans;

  PromotionContext(this.promotionCodesFB, this.saleTrans);
}
