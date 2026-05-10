import 'dart:async';

import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/models/promotion_context.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/models/promotion_fb_item_model.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/models/promotion_invoice.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/models/promotions_details_fB_model.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/models/promotions_fB_table_model.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/tables/promotion_fb_item_excluded_menu_item_table.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/tables/promotion_fb_item_table.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/tables/promotions_details_fB_table.dart';
import 'package:kiosk_point_of_sale/repository/promotions/enums/promotion_item_type.dart';
import 'package:kiosk_point_of_sale/repository/promotions/enums/promotion_value_type.dart';
import 'package:kiosk_point_of_sale/repository/promotions/helpers/promotion_helpers.dart';

import '../promotion_handler.dart';

class InvoiceAmountPromotionHandler implements IPromotionHandler {
  @override
  Future<PromotionInvoice> apply(PromotionContext context) async {
    dPrint('--- InvoiceAmountPromotionHandler called ---');
    dPrint('Current items: ${context.saleTrans.salesOrderItems.length}');
    dPrint('Subtotal before any promo: ${context.saleTrans.toJson()}');

    final invoice = PromotionInvoice(context.saleTrans);
    final promotion = await context.promotionCodesFB.promotionsFB;
    if (promotion == null) return invoice;

    // Fetch details and items from DB
    final promotionDetails =
        (await PromotionDetailsFBTable.getAll()).where((d) => d.promotionId == promotion.id).toList();
    final promotionItems = (await PromotionFBItemTable.getAll()).where((i) => i.promotionId == promotion.id).toList();
    // Use original subtotal before any promotions for eligibility
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
      return sum + (priceWithoutTax * quantity);
    });

    final originalSubtotal = double.tryParse(context.saleTrans.salesOrderModel.subTotalBeforeDiscount ?? '0') ?? 0.0;
    final orderDiscount = context.saleTrans.salesOrderModel.discountAmount ?? 0.0;
    final itemsPromotionsValue = context.saleTrans.salesOrderItems
        .fold(0.0, (previousValue, element) => previousValue + (element.promotionValue ?? 0.0));
    final orderPromotionValue = context.saleTrans.salesOrderModel.promotionValue ?? 0.0;

    // Use eligible subtotal for invoice-level promotion calculations
    final newSubTotal = eligibleSubtotal - orderDiscount - itemsPromotionsValue - orderPromotionValue;
    dPrint("ordersss: ${context.saleTrans.toJson()}");
    dPrint("🔍 Invoice amount promotion calculation:");
    dPrint("   - Original subtotal (all items): $originalSubtotal");
    dPrint("   - Eligible subtotal (excluding 100% promotion items): $eligibleSubtotal");
    dPrint("   - Eligible items count: ${eligibleItems.length}");
    dPrint("   - Total items count: ${context.saleTrans.salesOrderItems.length}");
    dPrint("   - Final newSubTotal: $newSubTotal");
    dPrint("   - Order discount: $orderDiscount");
    dPrint("   - Items promotions value: $itemsPromotionsValue");
    dPrint("orderPromotionValue: $orderPromotionValue");

    final meetsInvoiceAmount = newSubTotal >= promotion.invoiceAmount;

    // --- 1. Branch by isTotalInvoice (matches C# logic) ---
    dPrint('=== Promotion Test Debug ===');
    dPrint(
        'Original Subtotal Before Any Promos: newSubTotal $newSubTotal $originalSubtotal  ${promotion.invoiceAmount} $meetsInvoiceAmount');
    if (!meetsInvoiceAmount) {
      dPrint("###notMatch1: ${invoice.notMatch}");
      invoice.notMatch = true;
      dPrint("###notMatch3: ${invoice.notMatch}");
      // Remove promotion if not eligible
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
          detail.promotionValue = null;
          detail.promotionAmount = null;
          detail.promotionName = null;
        }
      }
      invoice.notMatch = true;
      return invoice;
    }
    if (promotion.isTotalInvoice == true) {
      // Apply invoice-level promotion (multi-use logic can be added here if needed)
      invoice.salesTransaction.salesOrderModel.promotionId = context.promotionCodesFB.id;
      invoice.salesTransaction.salesOrderModel.promotionCode = context.promotionCodesFB.code;
      invoice.salesTransaction.salesOrderModel.promotionType = promotion.valueType;

      invoice.salesTransaction.salesOrderModel.promotionValue =
          PromotionHelpers.getPromotionValue(promotion.valueType, promotion.value, newSubTotal);
      invoice.salesTransaction.salesOrderModel.promotionAmount = promotion.value;
      invoice.salesTransaction.salesOrderModel.promotionName = promotion.name;
      dPrint('💰 Promotion Value: ${invoice.salesTransaction.salesOrderModel.promotionValue}');
      dPrint('💰 Promotion Amount: ${invoice.salesTransaction.salesOrderModel.promotionAmount}');

      // Do NOT clear item-level promotions here; allow both to be applied together
      return invoice;
    } else {
      // Item-level promotion logic
      invoice.notMatch = false;
      dPrint("promotionDetails is: ${promotionDetails.map((e) => e.toJson())}");
      if (promotionDetails.isEmpty) {
        await _applyNoDetailPromotion(context, promotionItems, invoice);
        return invoice;
      } else {
        final result = await _checkPromotionMatchesCriteria(context, promotionDetails);
        final isMatch = result[0] as bool;
        final numberOfOfferApply = result[1] as num;
        dPrint('💰 isMatch: $isMatch');
        if (isMatch) {
          await _applyDetailedPromotion(context, promotionDetails, numberOfOfferApply, invoice);
        }
        return invoice;
      }
    }
  }

  // Check if the purchased products meet the criteria defined in the promotion details.
  // Returns [isMatch, numberOfOfferApply]
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
          matchCount = context.saleTrans.salesOrderItems
              .where((x) => int.parse(x.categoryId) == detail.itemId)
              .fold(0.0, (sum, x) => sum + double.parse(x.quantity));
        } else if (detail.itemType == PromotionItemType.menuItem.value) {
          matchCount = context.saleTrans.salesOrderItems
              .where((x) => int.parse(x.productId) == detail.itemId)
              .fold(0.0, (sum, x) => sum + double.parse(x.quantity));
        }

        dPrint('matchCount is $matchCount');
        dPrint('detail is ${detail.toJson()}');

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

  // Applies promotion to products if no promotion details are specified.
  Future<void> _applyNoDetailPromotion(
      PromotionContext context, List<PromotionFBItemModel> promotionItems, PromotionInvoice invoice) async {
    final excludedItems = await PromotionFBItemExcludedMenuItemTable.getAll();
    final promotion = await context.promotionCodesFB.promotionsFB;
    dPrint("promotion id is: ${promotion?.id.toString()} ");
    var realExcludedItems = [];
    for (var item in promotionItems) {
      final x = excludedItems.where((x) => x.promotionFBItemId == item.id);
      realExcludedItems.addAll(x);
    }

    dPrint('Excluded items: ${realExcludedItems.map((x) => "${x.menuItemId}")}');
    dPrint('promotion is: ${promotion?.toJson()}');
    if (promotionItems.isEmpty) return;
    dPrint('promotionItems is ${promotionItems.map((e) => e.itemId)}');
    dPrint('salesOrderItems is ${context.saleTrans.salesOrderItems.map((e) => e.productId)}');
    bool isPrmotionsItemsInSalesOrderItems =
        promotionItems.any((x) => context.saleTrans.salesOrderItems.any((y) => int.parse(y.productId) == x.itemId));
    dPrint('isPrmotionsItemsInSalesOrderItems is $isPrmotionsItemsInSalesOrderItems');

    List<bool> appliedForProducts = [];
    for (final promotionItem in promotionItems) {
      List<bool> appliedForItems = [];

      for (var item in context.saleTrans.salesOrderItems) {
        if (realExcludedItems.any((x) => x.menuItemId == int.parse(item.productId))) {
          appliedForItems.add(true);
        } else {
          appliedForItems.add(false);
        }
      }
      dPrint('appliedForItems is $appliedForItems');
      final products = context.saleTrans.salesOrderItems.where((x) =>
          (promotionItem.itemType == PromotionItemType.menuItem.value &&
              int.parse(x.productId) == promotionItem.itemId) ||
          (promotionItem.itemType == PromotionItemType.productCategory.value &&
              int.parse(x.categoryId) == promotionItem.itemId &&
              (!realExcludedItems.any((d) => d.menuItemId == int.parse(x.productId)))));
      dPrint('products is ${products.map((e) => e.productId)}');
      if (products.isEmpty) {
        dPrint(
            '⚠️  No products found for promotion item: ${promotionItem.itemId} (${promotionItem.itemType}) - skipping');

        appliedForProducts.add(false);
        continue;
      }
      dPrint('products is ${products.map((e) => e.productId)}');
      for (final product in products) {
        dPrint('🎁 Applying promotion to product: ${product.productId} (${product.quantity})');
        _applyPromotionToProduct(product, promotion, context, 1);
        appliedForProducts.add(true);
      }
    }
    if (appliedForProducts.every((x) => x == false)) {
      dPrint('appliedForProducts is $appliedForProducts');
      invoice.notMatch = true;
    }
  }

  // Applies the promotion based on PromotionDetailsFBs.
  Future<void> _applyDetailedPromotion(PromotionContext context, List<PromotionDetailsFBModel> details,
      num numberOfOfferApply, PromotionInvoice invoice) async {
    final excludedItems = await PromotionFBItemExcludedMenuItemTable.getAll();
    final promotion = await context.promotionCodesFB.promotionsFB;
    // Use promotionItems fetched from DB instead of promotion.promotionFBItems if the latter is not available
    final promotionItems = (await PromotionFBItemTable.getAll()).where((i) => i.promotionId == promotion?.id).toList();
    var realExcludedItems = [];
    for (var item in promotionItems) {
      final x = excludedItems.where((x) => x.promotionFBItemId == item.id);
      realExcludedItems.addAll(x);
    }

    for (final product in context.saleTrans.salesOrderItems) {
      final detail = details.firstWhere(
        (d) =>
            (d.itemType == PromotionItemType.menuItem.value && d.itemId == int.parse(product.productId)) ||
            ((d.itemType == PromotionItemType.productCategory.value && d.itemId == int.parse(product.categoryId)) &&
                (!realExcludedItems.any((x) => x.menuItemId == int.parse(product.productId)))),
        orElse: () => details.isNotEmpty ? details.first : (throw Exception('No details')),
      );

      if ((((detail.itemType == PromotionItemType.menuItem.value && detail.itemId == int.parse(product.productId)) ||
          (detail.itemType == PromotionItemType.productCategory.value &&
              detail.itemId == int.parse(product.categoryId))))) {
        if (int.parse(product.quantity) >= detail.quantity) {
          final promotion = await context.promotionCodesFB.promotionsFB;
          _applyPromotionToProduct(product, promotion, context, numberOfOfferApply);
        } else {
          product.promotionId = null;
          product.promotionCode = null;
          product.promotionCodeId = null;
          product.promotionType = null;
          product.promotionValue = null;
          product.promotionAmount = null;
          product.promotionName = null;
        }
      }
    }
  }

  // Applies the promotion to a single product based on the promotion ValueType and Value.
  void _applyPromotionToProduct(
      dynamic product, PromotionsFBTableModel? promotion, PromotionContext context, num numberOfOfferApply) {
    if (promotion == null) return;
    product.promotionId = context.promotionCodesFB.id;
    product.promotionCode = context.promotionCodesFB.code;
    product.promotionCodeId = context.promotionCodesFB.id;

    product.promotionType = promotion.valueType;
    product.promotionAmount = promotion.value;
    product.promotionName = promotion.name;
    final qty = double.parse(product.quantity);
    final price = product.isExclusive ? double.parse(product.price) : (double.parse(product.price) / 1.15);
    final promoValue = promotion.value;
    // if (qty <= numberOfOfferApply) {
    if (promotion.valueType == PromotionIValueType.specificValue.value) {
      product.promotionValue = ((price - promoValue) * qty);
      product.realPromotionValue = ((price - promoValue) * qty);
    } else if (promotion.valueType == PromotionIValueType.discountPercentage.value) {
      // DiscountPercentage - with improved rounding for 100% discounts
      double calculatedValue = (promoValue / 100) * (price * qty);

      // Special handling for 100% discount to ensure exact precision
      if (promoValue == 100.0) {
        calculatedValue = price * qty; // Exact calculation for 100% discount
      }

      product.promotionValue = calculatedValue;
      product.realPromotionValue = calculatedValue;
    } else {
      product.promotionValue = promoValue * qty;
      product.realPromotionValue = promoValue * qty;
    }
    // } else {
    //   if (promotion.valueType == PromotionIValueType.specificValue.value) {
    //     product.promotionValue = (price - promoValue) * numberOfOfferApply;
    //   } else if (promotion.valueType ==
    //       PromotionIValueType.discountPercentage.value) {
    //     product.promotionValue =
    //         (promoValue / 100) * price * numberOfOfferApply;
    //   } else {
    //     product.promotionValue = promoValue * numberOfOfferApply;
    //   }
    // }
  }
}
