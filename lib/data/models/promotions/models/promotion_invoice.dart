import 'package:kiosk_point_of_sale/data/models/sales_models/sales_invoice.dart';

class PromotionInvoice {
  bool notMatch;
  bool isUsed;
  bool notValidPromotion;
  SalesInvoice salesTransaction;

  PromotionInvoice(
    this.salesTransaction, {
    this.notMatch = false,
    this.isUsed = false,
    this.notValidPromotion = false,
  });
}
