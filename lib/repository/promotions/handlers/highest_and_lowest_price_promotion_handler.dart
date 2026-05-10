import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/models/promotion_context.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/models/promotion_invoice.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/models/promotions_details_fB_model.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/tables/promotion_details_fb_excluded_menu_item_table.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/tables/promotions_details_fB_table.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_items_model.dart';
import 'package:kiosk_point_of_sale/repository/promotions/enums/promotion_item_type.dart';
import 'package:kiosk_point_of_sale/repository/promotions/enums/promotion_value_type.dart';

import '../promotion_handler.dart';

class HighestAndLowestPricePromotionHandler implements IPromotionHandler {
  @override
  Future<PromotionInvoice> apply(PromotionContext context) async {
    final invoice = PromotionInvoice(context.saleTrans);
    final promotion = await context.promotionCodesFB.promotionsFB;
    dPrint("promotion is From Handler ${promotion?.toJson()}");
    if (promotion == null) return invoice;

    // Fetch details from DB
    final promotionDetails =
        (await PromotionDetailsFBTable.getAll()).where((d) => d.promotionId == promotion.id).toList();
    dPrint("promotionDetails is From Handler ${promotionDetails.map((e) => e.toJson())}");
    // 1. Check criteria match
    final result = await _checkPromotionMatchesCriteria(context, promotionDetails);
    final isMatch = result[0] as bool;
    final numberOfOfferApply = result[1] as num;
    dPrint("promotionDetails isMatch is From Handler $isMatch");
    if (!isMatch) {
      invoice.notMatch = true;
      if (context.promotionCodesFB.id == invoice.salesTransaction.salesOrderModel.promotionId) {
        invoice.salesTransaction.salesOrderModel.promotionId = null;
        invoice.salesTransaction.salesOrderModel.promotionCode = null;
        invoice.salesTransaction.salesOrderModel.promotionType = null;
        invoice.salesTransaction.salesOrderModel.promotionValue = null;
        invoice.salesTransaction.salesOrderModel.promotionAmount = null;
        invoice.salesTransaction.salesOrderModel.promotionName = null;
      }
      for (final detail in invoice.salesTransaction.salesOrderItems) {
        if (context.promotionCodesFB.id == detail.promotionId) {
          detail.promotionId = null;
          detail.promotionCode = null;
          detail.promotionType = null;
          detail.promotionCodeId = null;
          detail.promotionValue = null;
          detail.promotionAmount = null;
          detail.promotionName = null;
        }
      }
      return invoice;
    }

    // 2. Apply promotion
    await applyPromotion(context, invoice, numberOfOfferApply);
    dPrint("invoice After Appling is ${invoice.salesTransaction.toJson()}");
    return invoice;
  }

  /// <summary>
  /// Checks if the order matches the promotion criteria. If matched, determines how many times the offer can be applied.
  /// </summary>
  Future<List<dynamic>> _checkPromotionMatchesCriteria(
      PromotionContext context, List<PromotionDetailsFBModel> details) async {
    if (details.isEmpty) {
      return [false, 0];
    }

    final sortedDetails = [...details]..sort((a, b) => a.id.compareTo(b.id));
    final List<List<PromotionDetailsFBModel>> conditionGroups = [];
    List<PromotionDetailsFBModel> currentGroup = [];

    for (var i = 0; i < sortedDetails.length; i++) {
      final detail = sortedDetails[i];
      final currentOperator = (detail.where?.trim().isNotEmpty ?? false) ? detail.where!.trim().toUpperCase() : 'OR';

      if (currentOperator == 'OR' && currentGroup.isNotEmpty) {
        conditionGroups.add(currentGroup);
        currentGroup = [];
      }

      currentGroup.add(detail);

      if (i == sortedDetails.length - 1) {
        conditionGroups.add(currentGroup);
      }
    }

    final List<int> successfulGroupApplyCounts = [];

    for (final group in conditionGroups) {
      var groupResult = true;
      var groupApplyCount = 1 << 30;

      for (final detail in group) {
        double matchCount = 0;
        if (detail.itemType == PromotionItemType.productCategory.value) {
          final exclusions = await _getExcludedMenuItems(detail.id);
          matchCount = context.saleTrans.salesOrderItems
              .where((x) => int.parse(x.categoryId) == detail.itemId && !exclusions.contains(int.parse(x.productId)))
              .fold(0.0, (sum, x) => sum + double.parse(x.quantity));
        } else if (detail.itemType == PromotionItemType.menuItem.value) {
          matchCount = context.saleTrans.salesOrderItems
              .where((x) => int.parse(x.productId) == detail.itemId)
              .fold(0.0, (sum, x) => sum + double.parse(x.quantity));
        }

        if (detail.quantity <= 0) {
          groupResult = false;
          groupApplyCount = 0;
          continue;
        }

        final detailMatched = matchCount >= detail.quantity;
        groupResult = groupResult && detailMatched;
        final applyCount = detailMatched ? (matchCount / detail.quantity).floor() : 0;
        groupApplyCount = applyCount < groupApplyCount ? applyCount : groupApplyCount;
      }

      if (groupResult) {
        successfulGroupApplyCounts.add(groupApplyCount == (1 << 30) ? 0 : groupApplyCount);
      }
    }

    final isMatch = successfulGroupApplyCounts.isNotEmpty;
    final numberOfOfferApply = isMatch ? successfulGroupApplyCounts.reduce((a, b) => a > b ? a : b) : 0;
    return [isMatch, numberOfOfferApply];
  }

  /// <summary>
  /// Applies the HighestAndLowestPrice promotion to the matched products.
  /// </summary>
  Future<void> applyPromotion(PromotionContext context, PromotionInvoice invoice, num numberOfOfferApply) async {
    final promotion = await context.promotionCodesFB.promotionsFB;
    if (promotion == null) return;

    dPrint('=== _applyPromotion Debug ===');
    dPrint('Promotion ID From Handler: ${promotion.id}');
    dPrint('Highest value From Handler: ${promotion.highestValue}');
    dPrint('Lowest value From Handler: ${promotion.lowestValue}');
    dPrint('Default value From Handler: ${promotion.value}');
    dPrint('Value type From Handler: ${promotion.valueType}');
    dPrint('Number of offer apply From Handler: $numberOfOfferApply');

    // Collect excluded item IDs from promotion details
    List<int> excludedItemIds = [];
    final promotionDetails =
        (await PromotionDetailsFBTable.getAll()).where((d) => d.promotionId == promotion.id).toList();

    for (final promoDetail in promotionDetails) {
      final exclusions = await _getExcludedMenuItems(promoDetail.id);
      excludedItemIds.addAll(exclusions);
    }

    dPrint('Excluded item IDs: $excludedItemIds');

    // Find highest and lowest priced items
    final orderedByPrice = List<dynamic>.from(context.saleTrans.salesOrderItems)
      ..sort((a, b) => (double.tryParse(a.price) ?? 0.0).compareTo(double.tryParse(b.price) ?? 0.0));

    if (orderedByPrice.isEmpty) return;
    if (orderedByPrice.length == 1) {
      dPrint('Applying lowestValue value is ${promotion.lowestValue} to lowest item');

      await _applyItemPromotion(
          context, orderedByPrice.first, promotion.lowestValue, numberOfOfferApply, excludedItemIds);
      dPrint("invoice After Appling is ${invoice.salesTransaction.toJson()}");

      return;
    }

    final lowestItem = orderedByPrice.first;
    final highestItem = orderedByPrice.last;

    dPrint('Lowest item: ${lowestItem.productNameEn} - Price: ${lowestItem.price}');
    dPrint('Highest item: ${highestItem.productNameEn} - Price: ${highestItem.price}');
    dPrint('Same item? ${lowestItem == highestItem}');

    // Apply promotion to highest, lowest, and all others
    // Highest and lowest have their own values, while others use the default Value
    dPrint('Applying highest value (${promotion.highestValue}) to highest item');
    await _applyItemPromotion(context, highestItem, promotion.highestValue ?? 0, numberOfOfferApply, excludedItemIds);

    // C# applies BOTH values regardless of whether they're the same item
    dPrint('Applying lowest value (${promotion.lowestValue}) to lowest item');
    await _applyItemPromotion(context, lowestItem, promotion.lowestValue, numberOfOfferApply, excludedItemIds);

    // Apply to all other items that are not highest or lowest
    for (final product in context.saleTrans.salesOrderItems) {
      if (product != highestItem && product != lowestItem) {
        if (!excludedItemIds.contains(int.tryParse(product.productId) ?? -1)) {
          dPrint('Applying default value (${promotion.value}) to other item: ${product.productNameEn}');
          await _applyItemPromotion(context, product, promotion.value, numberOfOfferApply, excludedItemIds);
        }
      }
    }

    dPrint('=== End _applyPromotion ===');
  }

  /// <summary>
  /// Applies the calculated promotion value to a single product item.
  /// Adjusts the product's PromotionValue based on ValueType and quantity.
  /// </summary>
  Future<void> _applyItemPromotion(PromotionContext context, SalesItemsModel product, double promotionUnitValue,
      num numberOfOfferApply, List<int> excludedItemIds) async {
    final promotion = await context.promotionCodesFB.promotionsFB;
    if (promotion == null) return;

    if (excludedItemIds.contains(int.tryParse(product.productId) ?? -1)) {
      // If excluded, do not apply promotion
      return;
    }

    product.promotionType = promotion.valueType;
    product.promotionId = context.promotionCodesFB.id;
    product.promotionCode = context.promotionCodesFB.code;
    product.promotionCodeId = context.promotionCodesFB.id;

    product.promotionAmount = promotionUnitValue;
    product.promotionName = promotion.name;

    final qty = double.parse(product.quantity);
    final price = product.isExclusive ? double.parse(product.price) : (double.parse(product.price) / 1.15);
    dPrint("isExclusive is ${product.isExclusive}");
    dPrint("=== HighestAndLowestPrice Debug ===");
    dPrint("Product: ${product.productNameEn}");
    dPrint("Original price: $price");
    dPrint("Quantity: $qty");
    dPrint("Promotion unit value: $promotionUnitValue");
    dPrint("Promotion unit value2: ${product.promotionAmount}");
    dPrint("Value type: ${promotion.valueType}");
    dPrint("Number of offer apply: $numberOfOfferApply");

    if (qty <= numberOfOfferApply) {
      // If qty is fully covered by promotion application
      if (promotion.valueType == PromotionIValueType.specificValue.value) {
        // SpecificValue - calculate the discount amount
        product.promotionValue = ((price - promotionUnitValue) * qty);
        product.realPromotionValue = ((price - promotionUnitValue) * qty);
        dPrint("SpecificValue calculation: ($promotionUnitValue * $qty) = ${product.promotionValue}");
      } else if (promotion.valueType == PromotionIValueType.discountPercentage.value) {
        // promotionUnitValue here represents percentage
        double calculatedValue = (promotionUnitValue / 100) * (price * qty);

        // Special handling for 100% discount to ensure exact precision
        if (promotionUnitValue == 100.0) {
          calculatedValue = price * qty; // Exact calculation for 100% discount
        }

        product.promotionValue = calculatedValue;
        product.realPromotionValue = calculatedValue;
        dPrint(
            "DiscountPercentage calculation: (promotionUnitValue / 100) * (price * qty) = ${product.promotionValue}");
      } else {
        // Treat as a direct discount value applied per qty
        product.promotionValue = promotionUnitValue * qty;
        product.realPromotionValue = promotionUnitValue * qty;
        dPrint("Direct discount calculation: promotionUnitValue * qty = ${product.promotionValue}");
      }
    } else {
      // If qty > numberOfOfferApply, partial promotion applies to some portion
      if (promotion.valueType == PromotionIValueType.specificValue.value) {
        // SpecificValue - calculate the discount amount
        product.promotionValue = (price - promotionUnitValue) * numberOfOfferApply;
        product.realPromotionValue = (price - promotionUnitValue) * numberOfOfferApply;
        dPrint(
            "Partial SpecificValue calculation: ($promotionUnitValue * $numberOfOfferApply) = ${product.promotionValue}");
      } else if (promotion.valueType == PromotionIValueType.discountPercentage.value) {
        // promotionUnitValue is a percentage
        double calculatedValue = (promotionUnitValue / 100) * price * numberOfOfferApply;

        // Special handling for 100% discount to ensure exact precision
        if (promotionUnitValue == 100.0) {
          calculatedValue = price * numberOfOfferApply; // Exact calculation for 100% discount
        }

        product.promotionValue = calculatedValue;
        product.realPromotionValue = calculatedValue;
        dPrint(
            "Partial DiscountPercentage calculation: (promotionUnitValue / 100) * price * numberOfOfferApply = ${product.promotionValue}");
      } else {
        // Direct discount value
        product.promotionValue = promotionUnitValue * numberOfOfferApply;
        product.realPromotionValue = promotionUnitValue * numberOfOfferApply;
        dPrint(
            "Partial direct discount calculation: promotionUnitValue * numberOfOfferApply = ${product.promotionValue}");
      }
    }

    dPrint("Final product.promotionValue: ${product.promotionValue}");
    dPrint("=====================================");
  }

  /// Helper method to get excluded menu items for a promotion detail
  Future<List<int>> _getExcludedMenuItems(int promotionDetailsId) async {
    final exclusions = (await PromotionDetailsFBExcludedMenuItemTable.getAll())
        .where((e) => e.promotionDetailsFBId == promotionDetailsId)
        .map((e) => e.menuItemId)
        .toList();
    return exclusions;
  }
}
