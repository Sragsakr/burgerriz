import 'package:kiosk_point_of_sale/data/models/promotions/models/promotion_codes_fb_model.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/models/promotion_details_fb_excluded_menu_item_model.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/models/promotion_fb_additional_free_item_model.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/models/promotion_fb_item_excluded_menu_item_model.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/models/promotion_fb_item_model.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/models/promotions_details_fB_model.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/models/promotions_fB_table_model.dart';

abstract class PromotionsApiInterface {
  // SyncPromotionsFBTable
  Future<List<PromotionsFBTableModel>> getPromotionsFBTable();
// SyncPromotionCodesFB
  Future<List<PromotionCodesFBModel>> getPromotionCodesFB();
// SyncPromotionFBItem
  Future<List<PromotionFBItemModel>> getPromotionFBItems();
// SyncPromotionDetailsFB
  Future<List<PromotionDetailsFBModel>> getPromotionDetailsFB();
// SyncPromotionDetailsFB
  Future<List<PromotionFBItemExcludedMenuItemModel>> getPromotionFBItemExcludedMenuItem();
  Future<List<PromotionDetailsFBExcludedMenuItemModel>> getPromotionDetailsFBExcludedMenuItem();
// SyncPromotionFBAdditionalFreeItem
  Future<List<PromotionFBAdditionalFreeItemModel>> getPromotionFBAdditionalFreeItem();

  /// Fetches all promotion-related data from the API into local SQLite.
  Future<void> syncAllPromotionTablesFromRemote();
}
