import 'handlers/discount_or_gift_voucher_handler.dart';
import 'handlers/highest_and_lowest_price_promotion_handler.dart';
import 'handlers/invoice_amount_promotion_handler.dart';
import 'handlers/products_or_categories_promotion_handler.dart';
import 'handlers/simple_promotion_handler.dart';
import 'promotion_handler.dart';

// productsOrCategories(1),
// invoiceAmount(2),
// disCountVoucher(3),
// giftVoucher(4),
// simplePromotion(5),
// highestAndTheLowestPrice(6);
class PromotionHandlerFactory {
  static IPromotionHandler? getHandler(int promotionType) {
    switch (promotionType) {
      case 1: // ProductsOrCategories
        return ProductsOrCategoriesPromotionHandler();
      case 2: // InvoiceAmount
        return InvoiceAmountPromotionHandler();

      case 3: // DisCountVoucher
        return DiscountOrGiftVoucherHandler();
      case 4: // GiftVoucher
        return DiscountOrGiftVoucherHandler();
      case 5: // SimplePromotion
        return SimplePromotionHandler();
      case 6: // HighestAndTheLowestPrice
        return HighestAndLowestPricePromotionHandler();
      default:
        return null;
    }
  }
}
