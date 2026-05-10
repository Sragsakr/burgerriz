import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/models/promotion_codes_fb_model.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/models/promotions_fB_table_model.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_invoice.dart';
import 'package:kiosk_point_of_sale/repository/promotions/enums/promotion_value_type.dart';
import 'package:kiosk_point_of_sale/repository/sales_orders_repository.dart';

class PromotionHelpers {
  // Helper: Calculate promotion value based on type

  // Checks if a promotion is used for a customer (or in general if customerId is null)
  static Future<bool> isPromotionUsed(
    PromotionCodesFBModel promotionCode,
    PromotionsFBTableModel promotionFB,
    String? customerId, // Use String? for customerId, adjust as needed
  ) async {
    return false;
    // final saleTransactions = await getAllSalesInvoices();
    // final isNextInvoice = promotionFB.isNextInvoice;

    // if (isNextInvoice) {
    //   final count = saleTransactions
    //       .where((sale) =>
    //           sale.salesOrderModel.promotionId == promotionCode.id &&
    //           (customerId == null ||
    //               sale.salesOrderModel.customerPhone == customerId) &&
    //           sale.salesOrderModel.isRefund == 0 &&
    //           sale.salesOrderItems
    //               .any((detail) => detail.promotionId == promotionCode.id))
    //       .length;
    //   return count == 2;
    // } else {
    //   return saleTransactions.any((sale) =>
    //       sale.salesOrderModel.promotionId == promotionCode.id ||
    //       (sale.salesOrderModel.customerPhone == customerId &&
    //           sale.salesOrderItems
    //               .any((detail) => detail.promotionId == promotionCode.id)));
    // }
  }

  // Calculate promotion value based on type
  /// Calculate promotion value based on promotion type and value
  ///
  /// [type] - The promotion value type (discountPercentage, discountValue, specificValue)
  /// [value] - The promotion value amount
  /// [subTotal] - The subtotal amount to apply promotion to
  ///
  /// Returns the calculated promotion value
  static double getPromotionValue(int type, double value, double subTotal) {
    final valueType = PromotionIValueTypeExtension.fromValue(type);

    _logPromotionCalculation(type, valueType, value, subTotal);

    switch (valueType) {
      case PromotionIValueType.discountPercentage:
        return _calculatePercentageDiscount(value, subTotal);

      case PromotionIValueType.discountValue:
        return _calculateFixedDiscount(value);

      case PromotionIValueType.specificValue:
        return _calculateSpecificValue(value, subTotal);
      case PromotionIValueType.specificValueWithFreeProduct:
        return 0.0;

      default:
        dPrint("⚠️ Unknown promotion value type: $type");
        return 0.0;
    }
  }

  /// Calculate percentage-based discount
  static double _calculatePercentageDiscount(
      double percentage, double subTotal) {
    final discount = subTotal * (percentage / 100);
    dPrint("   - Percentage discount: $percentage% of $subTotal = $discount");
    return discount;
  }

  /// Calculate fixed amount discount
  static double _calculateFixedDiscount(double discountAmount) {
    dPrint("   - Fixed discount: $discountAmount");
    return discountAmount;
  }

  /// Calculate specific value (subtotal minus specific amount)
  static double _calculateSpecificValue(
      double specificAmount, double subTotal) {
    final result = (subTotal - specificAmount).clamp(0.0, double.infinity);
    dPrint("   - Specific value: $subTotal - $specificAmount = $result");
    return result;
  }

  /// Log promotion calculation details
  static void _logPromotionCalculation(
      int type, PromotionIValueType? valueType, double value, double subTotal) {
    dPrint("🔢 PromotionHelpers.getPromotionValue:");
    dPrint("   - Type: $type (${valueType?.toString() ?? 'Unknown'})");
    dPrint("   - Value: $value");
    dPrint("   - SubTotal: $subTotal");
  }

  // Use repository to fetch all sales invoices
  static Future<List<SalesInvoice>> getAllSalesInvoices() async {
    return await SalesOrdersRepositoryImpl().getAllOrdersFromDataBase();
  }
}
