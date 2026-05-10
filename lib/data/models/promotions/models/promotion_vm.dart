import 'package:kiosk_point_of_sale/data/models/promotions/models/promotion_codes_fb_model.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/models/promotions_fB_table_model.dart';

class PromotionVM {
  int promotionCodeId;
  String promotionCode;
  String name;
  PromotionCodesFBModel? codeModel;

  PromotionsFBTableModel? promotionFB;

  PromotionVM({
    required this.promotionCodeId,
    required this.promotionCode,
    required this.name,
    required this.promotionFB,
    required this.codeModel,
  });
}
