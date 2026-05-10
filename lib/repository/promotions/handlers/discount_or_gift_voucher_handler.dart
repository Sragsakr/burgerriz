import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/models/promotion_context.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/models/promotion_invoice.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_invoice.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_order_model.dart';
import 'package:kiosk_point_of_sale/repository/promotions/enums/promotion_value_type.dart';
import 'package:kiosk_point_of_sale/repository/promotions/helpers/promotion_helpers.dart';

import '../promotion_handler.dart';

class DiscountOrGiftVoucherHandler implements IPromotionHandler {
  @override
  Future<PromotionInvoice> apply(PromotionContext context) async {
    final invoice = PromotionInvoice(context.saleTrans);
    final promotion = await context.promotionCodesFB.promotionsFB;
    if (promotion == null) return invoice;

    await _handleNormalScenario(context, invoice, 1, false, true);

    return invoice;
  }

  /// <summary>
  /// Handles return/refund scenarios for discount or gift voucher promotions.
  /// </summary>
  Future<void> _handleReturnScenario(
      PromotionContext context,
      PromotionInvoice invoice,
      List<SalesInvoice> salesForThisPromotion,
      List<SalesInvoice> returnSales,
      int saleCount,
      bool notReturnOrReturnHavePromotion,
      bool validDay) async {
    final promotion = await context.promotionCodesFB.promotionsFB;
    if (promotion == null) return;

    // Find the sale being returned
    final sale = salesForThisPromotion.firstWhere(
      (x) =>
          x.salesOrderModel.invoiceId ==
          context.saleTrans.salesOrderModel.invoiceId,
      orElse: () => SalesInvoice(
        salesOrderModel: SalesOrderModel(
          id: null,
          customerId: null,
          orderNumber: '',
          saleTypeId: 0,
          createdAt: '',
          updatedAt: '',
          cashierName: '',
          deletedAt: '',
          workDate: '',
          totalAmount: '',
          totalAmountBeforeDiscount: '',
          note: '',
          isRefund: 0,
          haveRefund: 0,
          change: 0,
          userId: '',
          tenantId: '',
          uuid: '',
          tax: '',
          subTotal: '',
          taxBeforeDiscount: '',
          subTotalBeforeDiscount: '',
          cashierShiftId: 0,
          customerPhone: '',
          isBackOfficeSync: 0,
          isZactaSync: 0,
          paymentMethod: 0,
          saleNotificationDetailId: '',
          refundResonId: '',
        ),
        salesOrderItems: [],
        salesOrderPayMethods: [],
      ),
    );

    if (sale.salesOrderModel.id == null) {
      invoice.notMatch = true;
      invoice.salesTransaction.salesOrderModel.promotionId = null;
      invoice.salesTransaction.salesOrderModel.promotionCode = null;
      invoice.salesTransaction.salesOrderModel.promotionType = null;
      invoice.salesTransaction.salesOrderModel.promotionValue = null;
      invoice.salesTransaction.salesOrderModel.promotionAmount = null;
      return;
    }

    int nextSaleIndex = salesForThisPromotion.indexOf(sale);
    bool condition = (saleCount == nextSaleIndex + 1 && saleCount % 2 != 0) ||
        (saleCount > nextSaleIndex + 1 &&
            salesForThisPromotion.length > nextSaleIndex + 1 &&
            salesForThisPromotion[nextSaleIndex + 1]
                    .salesOrderModel
                    .promotionId ==
                context.promotionCodesFB.id);

    if (condition) {
      double subTotal =
          double.tryParse(context.saleTrans.salesOrderModel.subTotal) ?? 0.0;
      if (subTotal >= (promotion.invoiceAmount ?? 0)) {
        // If invoice meets InvoiceAmount, just reset promotion on return
        invoice.salesTransaction.salesOrderModel.promotionId =
            context.promotionCodesFB.id;
        invoice.salesTransaction.salesOrderModel.promotionCode =
            context.promotionCodesFB.code;
        invoice.salesTransaction.salesOrderModel.promotionType =
            promotion.valueType;
        invoice.salesTransaction.salesOrderModel.promotionValue = 0;
        invoice.salesTransaction.salesOrderModel.promotionAmount =
            promotion.value;
        invoice.salesTransaction.salesOrderModel.promotionName = promotion.name;
      } else {
        // Adjust promotion based on next invoice
        SalesInvoice? nextInvoice = (saleCount > nextSaleIndex + 1)
            ? salesForThisPromotion[nextSaleIndex + 1]
            : null;

        invoice.salesTransaction.salesOrderModel.promotionId = 0;
        invoice.salesTransaction.salesOrderModel.promotionCode = null;
        invoice.salesTransaction.salesOrderModel.promotionType =
            promotion.valueType == PromotionIValueType.discountPercentage.value
                ? PromotionIValueType.discountValue.value
                : promotion.valueType;

        if (nextInvoice != null) {
          invoice.salesTransaction.salesOrderModel.promotionValue =
              -(nextInvoice.salesOrderModel.promotionValue ?? 0);
          invoice.salesTransaction.salesOrderModel.promotionAmount =
              promotion.value;
          invoice.salesTransaction.salesOrderModel.promotionName =
              promotion.name;
        } else {
          invoice.salesTransaction.salesOrderModel.promotionValue = 0;
          invoice.salesTransaction.salesOrderModel.promotionAmount = 0;
          invoice.salesTransaction.salesOrderModel.promotionName = null;
        }
      }
    } else {
      // Just apply normal promotion rules on return
      invoice.salesTransaction.salesOrderModel.promotionId =
          context.promotionCodesFB.id;
      invoice.salesTransaction.salesOrderModel.promotionCode =
          context.promotionCodesFB.code;
      invoice.salesTransaction.salesOrderModel.promotionType =
          promotion.valueType;
      invoice.salesTransaction.salesOrderModel.promotionValue =
          promotion.value ?? 0;
      invoice.salesTransaction.salesOrderModel.promotionAmount =
          promotion.value;
      invoice.salesTransaction.salesOrderModel.promotionName = promotion.name;
    }
  }

  /// <summary>
  /// Handles normal (non-return) scenarios for discount or gift voucher promotions.
  /// </summary>
  Future<void> _handleNormalScenario(
      PromotionContext context,
      PromotionInvoice invoice,
      int saleCount,
      bool notReturnOrReturnHavePromotion,
      bool validDay) async {
    final promotion = await context.promotionCodesFB.promotionsFB;
    if (promotion == null) return;
    dPrint("Items Lenght is ${context.saleTrans.salesOrderItems.length}");
    // Calculate subtotal excluding items with 100% promotion
    final eligibleItems = context.saleTrans.salesOrderItems.where((item) {
      final itemQuantity = double.tryParse(item.quantity) ?? 1;
      final itemPrice = double.tryParse(item.price) ?? 0.0;
      final priceWithoutTax = item.isExclusive ? itemPrice : itemPrice / 1.15;

      final itemSubTotal = itemQuantity * priceWithoutTax;
      final isFullPromotion = itemSubTotal == item.promotionValue;
      dPrint(
          "Item IS isFullPromotion $isFullPromotion priceWithoutTax $priceWithoutTax itemSubTotal $itemSubTotal promotionAmount: ${item.promotionValue}");

      //
      // final hasFullPromotion =
      //     item.promotionAmount != null && item.promotionAmount == 100.0;
      // dPrint(
      //     "🔍 Item: ${item.productNameEn} - promotionAmount: ${item.promotionAmount}, hasFullPromotion: $hasFullPromotion");
      return !isFullPromotion;
    }).toList();

    // Calculate subtotal only from eligible items (excluding 100% promotion items)
    final eligibleSubtotal = eligibleItems.fold(0.0, (sum, item) {
      final itemPrice = double.tryParse(item.price) ?? 0.0;
      final quantity = double.tryParse(item.quantity) ?? 1;
      final priceWithoutTax = item.isExclusive ? itemPrice : itemPrice / 1.15;
      final itemTotal = priceWithoutTax * quantity;
      dPrint(
          "🔢 Eligible item: ${item.productNameEn} - Price: $itemPrice, Qty: $quantity, PriceWithoutTax: $priceWithoutTax, Total: $itemTotal");
      return sum + itemTotal;
    });

    final originalSubtotal = double.tryParse(
            context.saleTrans.salesOrderModel.subTotalBeforeDiscount ?? '0') ??
        0.0;
    final orderDiscount =
        context.saleTrans.salesOrderModel.discountAmount ?? 0.0;
    final itemsPromotionsValue = context.saleTrans.salesOrderItems.fold(
        0.0,
        (previousValue, element) =>
            previousValue + (element.promotionValue ?? 0.0));
    final orderPromotionValue =
        context.saleTrans.salesOrderModel.promotionValue ?? 0.0;

    // Use eligible subtotal for invoice-level promotion calculations
    final newSubTotal = eligibleSubtotal -
        orderDiscount -
        itemsPromotionsValue -
        orderPromotionValue;
    final meetsInvoiceAmount = newSubTotal >= promotion.invoiceAmount;
    dPrint("ordersss1: ${context.saleTrans.toJson()}");
    dPrint("🔍 Invoice-level promotion calculation:");
    dPrint("   - Original subtotal (all items):1 $originalSubtotal");
    dPrint(
        "   - Eligible subtotal (excluding 100% promotion items): $eligibleSubtotal");
    dPrint("   - Eligible items count: ${eligibleItems.length}");
    dPrint(
        "   - Total items count: ${context.saleTrans.salesOrderItems.length}");
    dPrint("   - Final newSubTotal: $newSubTotal");

    // Debug: Show which items are excluded
    final excludedItems = context.saleTrans.salesOrderItems.where((item) {
      final hasFullPromotion =
          item.promotionAmount != null && item.promotionAmount == 100.0;
      return hasFullPromotion;
    }).toList();
    dPrint(
        "   - Excluded items (100% promotion): ${excludedItems.map((item) => '${item.productNameEn} (${item.promotionAmount}%)').join(', ')}");
    dPrint("   - Order discount: $orderDiscount");
    dPrint("   - Items promotions value: $itemsPromotionsValue");
    dPrint("   - Order promotion value: $orderPromotionValue");
    // bool nextInvoiceCondition = promotion.isNextInvoice && validDay &&
    //     ((saleCount == 1 && notReturnOrReturnHavePromotion) ||
    //      (context.promotionCodesFB.multi && saleCount % 2 != 0 && notReturnOrReturnHavePromotion));

    if (meetsInvoiceAmount) {
      // bool applyNow = (promotion.isNextInvoice && nextInvoiceCondition) || !promotion.isNextInvoice;
      // if (applyNow) {
      invoice.salesTransaction.salesOrderModel.promotionId =
          context.promotionCodesFB.id;
      invoice.salesTransaction.salesOrderModel.promotionCode =
          context.promotionCodesFB.code;
      invoice.salesTransaction.salesOrderModel.promotionType =
          promotion.valueType;

      // Use PromotionHelpers.getPromotionValue for calculation
      dPrint("🔢 Promotion calculation details:");
      dPrint("   - Promotion type: ${promotion.valueType}");
      dPrint("   - Promotion value: ${promotion.value}");
      dPrint("   - newSubTotal: $newSubTotal");

      final calculatedPromotionValue = PromotionHelpers.getPromotionValue(
          promotion.valueType, promotion.value ?? 0, newSubTotal);
      dPrint("   - Calculated promotion value: $calculatedPromotionValue");

      // Debug: Check if this matches the expected 25% discount
      final expectedDiscount = newSubTotal * 0.25;
      dPrint("   - Expected 25% discount: $expectedDiscount");
      dPrint("   - Difference: ${calculatedPromotionValue - expectedDiscount}");

      invoice.salesTransaction.salesOrderModel.promotionValue =
          calculatedPromotionValue;
      invoice.salesTransaction.salesOrderModel.promotionAmount =
          promotion.value;
      invoice.salesTransaction.salesOrderModel.promotionName = promotion.name;
      // }
    } else {
      // If conditions are not met, set NotMatch
      invoice.notMatch = true;
      invoice.salesTransaction.salesOrderModel.promotionId = null;
      invoice.salesTransaction.salesOrderModel.promotionCode = null;
      invoice.salesTransaction.salesOrderModel.promotionType = null;
      invoice.salesTransaction.salesOrderModel.promotionValue = null;
      invoice.salesTransaction.salesOrderModel.promotionAmount = null;
      invoice.salesTransaction.salesOrderModel.promotionName = null;
    }
  }
}
