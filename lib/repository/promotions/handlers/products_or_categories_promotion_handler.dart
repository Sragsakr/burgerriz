import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/models/promotion_context.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/models/promotion_invoice.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/models/promotions_details_fB_model.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/models/promotions_fB_table_model.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/tables/promotion_fb_item_excluded_menu_item_table.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/tables/promotion_fb_item_table.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/tables/promotions_details_fB_table.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_items_model.dart';
import 'package:meta/meta.dart';
import 'package:kiosk_point_of_sale/repository/promotions/enums/promotion_value_type.dart';
import 'package:kiosk_point_of_sale/repository/promotions/helpers/promotion_helpers.dart';

import '../enums/promotion_item_type.dart';
import '../promotion_handler.dart';

class ProductsOrCategoriesPromotionHandler implements IPromotionHandler {
  @override
  Future<PromotionInvoice> apply(PromotionContext context) async {
    final invoice = PromotionInvoice(context.saleTrans);
    final promotion = await context.promotionCodesFB.promotionsFB;
    dPrint("promotion is From Handler ${promotion?.toJson()}");
    if (promotion == null) return invoice;
    // Fetch details and items from DB
    final promotionDetails =
        (await PromotionDetailsFBTable.getAll()).where((d) => d.promotionId == promotion.id).toList();
    dPrint("promotionDetails is From Handler ${promotionDetails.map((e) => e.toJson())}");
    // --- 1. Check if products/categories match criteria and get numberOfOfferApply ---
    final result = await _checkPromotionMatchesCriteria(context, promotionDetails);
    final isMatch = result[0] as bool;
    final numberOfOfferApply = result[1] as num;

    // Calculate subtotal excluding items with 100% promotion
    final eligibleItems = context.saleTrans.salesOrderItems.where((item) {
      final itemQuantity = double.tryParse(item.quantity) ?? 1;
      final itemPrice = double.tryParse(item.price) ?? 0.0;
      final priceWithoutTax = item.isExclusive ? itemPrice : itemPrice / 1.15;

      final itemSubTotal = itemQuantity * priceWithoutTax;
      final isFullPromotion = itemSubTotal == item.promotionValue;
      dPrint(
          "Item IS isFullPromotion $isFullPromotion priceWithoutTax $priceWithoutTax itemSubTotal $itemSubTotal promotionAmount: ${item.promotionValue}");
      return !isFullPromotion;
    }).toList();

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
    dPrint("promotionDetails isMatch is From Handler $isMatch");
    dPrint("🔍 Products/Categories promotion calculation:");
    dPrint("   - Original subtotal (all items): $originalSubtotal");
    dPrint("   - Eligible subtotal (excluding 100% promotion items): $eligibleSubtotal");
    dPrint("   - Eligible items count: ${eligibleItems.length}");
    dPrint("   - Total items count: ${context.saleTrans.salesOrderItems.length}");
    dPrint("   - Final newSubTotal: $newSubTotal");

    if (!isMatch) {
      // Not matched, clear promotions and return
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

    // --- 2. Branch by isTotalInvoice (matches C# logic) ---
    if (promotion.isTotalInvoice == true) {
      invoice.salesTransaction.salesOrderModel.promotionId = context.promotionCodesFB.id;
      invoice.salesTransaction.salesOrderModel.promotionCode = context.promotionCodesFB.code;
      invoice.salesTransaction.salesOrderModel.promotionType = promotion.templateType;
      invoice.salesTransaction.salesOrderModel.promotionValue =
          PromotionHelpers.getPromotionValue(promotion.valueType, promotion.value, newSubTotal);
      invoice.salesTransaction.salesOrderModel.promotionAmount = promotion.value;
      invoice.salesTransaction.salesOrderModel.promotionName = promotion.name;

      if ((invoice.salesTransaction.salesOrderModel.promotionValue ?? 0.0) <= 0.0) {
        invoice.notMatch = true;
      }
      dPrint("Promotion Value is in invoice : ${invoice.salesTransaction.salesOrderModel.promotionValue}");
      dPrint(
          "Promotion Value is in invoice : ${PromotionHelpers.getPromotionValue(promotion.valueType, promotion.value, originalSubtotal)}");
      return invoice;
    } else {
      // Apply item-level promotion
      await _applyItemLevelPromotion(context, invoice, numberOfOfferApply);
      return invoice;
    }
  }

  // Check if the purchased products meet the criteria defined in the promotion details.
  // Returns [isMatch, numberOfOfferApply]
  Future<List<dynamic>> _checkPromotionMatchesCriteria(
      PromotionContext context, List<PromotionDetailsFBModel> details) async {
    if (details.isEmpty) {
      return [false, 0];
    }

    // Fetch all excluded menu items for all details
    final promotion = await context.promotionCodesFB.promotionsFB;
    // Use promotionItems fetched from DB instead of promotion.promotionFBItems if the latter is not available
    final promotionItems = (await PromotionFBItemTable.getAll()).where((i) => i.promotionId == promotion?.id).toList();
    final excludedItems = await PromotionFBItemExcludedMenuItemTable.getAll();
    var realExcludedItems = [];
    for (var item in promotionItems) {
      final x = excludedItems.where((x) => x.promotionFBItemId == item.id);
      realExcludedItems.addAll(x);
    }
    dPrint('allexcludedMenuItemIds: ${realExcludedItems.map((e) => e.id)}');

    final evaluation = evaluatePromotionCriteriaByGroups(
      details: details,
      matchCountResolver: (detail) {
        dPrint('detail: ${detail.toJson()}');
        final excludedMenuItemIds =
            realExcludedItems.where((e) => e.promotionFBItemId == detail.id).map((e) => e.menuItemId).toSet();
        dPrint('excludedMenuItemIds: $excludedMenuItemIds');

        if (detail.itemType == PromotionItemType.productCategory.value) {
          final matchCount = context.saleTrans.salesOrderItems
              .where((x) =>
                  int.parse(x.categoryId) == detail.itemId && !excludedMenuItemIds.contains(int.parse(x.productId)))
              .fold(0.0, (sum, x) => sum + double.parse(x.quantity));
          dPrint("matchCount: $matchCount");
          return matchCount;
        }
        if (detail.itemType == PromotionItemType.menuItem.value) {
          final matchCount = context.saleTrans.salesOrderItems
              .where((x) => int.parse(x.productId) == detail.itemId)
              .fold(0.0, (sum, x) => sum + double.parse(x.quantity));
          dPrint("matchCount: $matchCount");
          return matchCount;
        }
        return 0.0;
      },
    );

    final isMatch = evaluation.$1;
    final numberOfOfferApply = evaluation.$2;
    dPrint("isMatch: $isMatch, numberOfOfferApply: $numberOfOfferApply");
    return [isMatch, numberOfOfferApply];
  }

  @visibleForTesting
  static (bool, int) evaluatePromotionCriteriaByGroups({
    required List<PromotionDetailsFBModel> details,
    required double Function(PromotionDetailsFBModel detail) matchCountResolver,
  }) {
    if (details.isEmpty) {
      return (false, 0);
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
        final matchCount = matchCountResolver(detail);
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
    return (isMatch, numberOfOfferApply);
  }
  // private bool CheckPromotionMatchesCriteria(PromotionContext context, out decimal numberOfOfferApply)
  // {
  //     numberOfOfferApply = 0;
  //     var promotion = context.PromotionCodesFB.PromotionsFB;
  //     var details = promotion.PromotionDetailsFBs.OrderBy(d => d.Id).ToList();
  //     if (details == null || details.Count == 0)
  //     {
  //         return false;
  //     }

  //     var conditionGroups = new List<List<PromotionDetailsFB>>();
  //     var currentGroup = new List<PromotionDetailsFB>();

  //     for (int i = 0; i < details.Count; i++)
  //     {
  //         var detail = details[i];
  //         string currentOperator = !string.IsNullOrEmpty(detail.Whre?.Trim()) ? detail.Whre?.Trim() : "OR";
  //         if (currentOperator.Equals("OR", System.StringComparison.OrdinalIgnoreCase) && currentGroup.Any())
  //         {
  //             conditionGroups.Add(currentGroup);
  //             currentGroup = new List<PromotionDetailsFB>();
  //         }

  //         currentGroup.Add(detail);

  //         if (i == details.Count - 1)
  //         {
  //             conditionGroups.Add(currentGroup);
  //         }
  //     }

  //     var groupResults = new List<decimal>();
  //     bool anyGroupSucceeded = false;

  //     foreach (var group in conditionGroups)
  //     {
  //         bool groupResult = true;
  //         decimal groupApplyCount = decimal.MaxValue;

  //         foreach (var detail in group)
  //         {
  //             decimal matchCount = 0;

  //             if (detail.ItemType == (int)ItemTypeFB.ProductCategory)
  //             {
  //                 matchCount = context.SaleTrans.SaleTransactionDetails
  //                     .Where(x => x.ProductCategoryId == detail.ItemId &&
  //                                 !detail.PromotionDetailsFBExcludedMenuItems.Any(ex => ex.MenuItemId == x.ProductId))
  //                     .Sum(x => x.Quantity);
  //             }
  //             else if (detail.ItemType == (int)ItemTypeFB.MenuItem)
  //             {
  //                 matchCount = context.SaleTrans.SaleTransactionDetails
  //                     .Where(x => x.ProductId == detail.ItemId)
  //                     .Sum(x => x.Quantity);
  //             }
  //             bool detailMatched = matchCount >= detail.Quantity;
  //             groupResult = groupResult && detailMatched;

  //             decimal applyCount = matchCount > 0 ? System.Math.Floor(matchCount / detail.Quantity) : 0;
  //             groupApplyCount = System.Math.Min(groupApplyCount, applyCount);
  //         }

  //         if (groupResult)
  //         {
  //             anyGroupSucceeded = true;
  //             groupResults.Add(groupApplyCount);
  //         }
  //     }

  //     if (!anyGroupSucceeded)
  //     {
  //         return false;
  //     }

  //     // For OR between groups, we take the maximum apply count from successful groups
  //     numberOfOfferApply = groupResults.Max();
  //     return true;
  // }

  // Applies the promotion at the item level if not IsTotalInvoice.
  Future<void> _applyItemLevelPromotion(
      PromotionContext context, PromotionInvoice invoice, num numberOfOfferApply) async {
    final promotion = await context.promotionCodesFB.promotionsFB;
    bool isDuplicated = context.promotionCodesFB.iDuplicateQunatity;
    dPrint("isDuplicated: $isDuplicated");
    final excludedItems = await PromotionFBItemExcludedMenuItemTable.getAll();
    // Use promotionItems fetched from DB instead of promotion.promotionFBItems if the latter is not available
    final promotionItems = (await PromotionFBItemTable.getAll()).where((i) => i.promotionId == promotion?.id).toList();
    var realExcludedItems = [];
    for (var item in promotionItems) {
      final x = excludedItems.where((x) => x.promotionFBItemId == item.id);
      realExcludedItems.addAll(x);
    }

    // Fetch all excluded menu items for all details
    for (final promotionItem in promotionItems) {
      // Get excluded menu items for this promotion item
      List<bool> appliedForProducts = [];
      // Identify the relevant products
      final items = context.saleTrans.salesOrderItems.where((x) {
        dPrint("excludedItems is From Handler ${realExcludedItems.map((e) => e.menuItemId).toSet().toList()}");
        dPrint(
            "x is From Handler ${x.productId}  ${x.categoryId} ${(!realExcludedItems.any((d) => d.menuItemId == int.parse(x.productId)))}");
        return (promotionItem.itemType == PromotionItemType.menuItem.value &&
                int.parse(x.productId) == promotionItem.itemId) ||
            (promotionItem.itemType == PromotionItemType.productCategory.value &&
                int.parse(x.categoryId) == promotionItem.itemId &&
                (!realExcludedItems.any((d) => d.menuItemId == int.parse(x.productId))));
      });
      dPrint("items is From Handler ${items.map((e) => e.productNameEn)}");
      if (items.isEmpty) {
        dPrint(
            '⚠️  No products found for promotion item: ${promotionItem.itemId} (${promotionItem.itemType}) - skipping');

        appliedForProducts.add(false);
        continue;
      }
      for (final product in items) {
        // Check if promotion is duplicated and adjust numberOfOfferApply accordingly
        double productNumberOfOfferApply;
        final productQty = double.parse(product.quantity);

        if (isDuplicated) {
          // When duplicated: apply promotion to all items in cart
          productNumberOfOfferApply =
              productQty < numberOfOfferApply.toDouble() ? productQty : numberOfOfferApply.toDouble();
        } else {
          // When not duplicated: apply promotion only once
          productNumberOfOfferApply = 1;
        }
        dPrint("product is From Handler ${product.productNameEn}");
        dPrint("productNumberOfOfferApply is From Handler $productNumberOfOfferApply");
        _applyPromotionToProduct(product, promotion, context, productNumberOfOfferApply);
        appliedForProducts.add(true);
      }
      if (appliedForProducts.every((x) => x == false)) {
        dPrint('appliedForProducts is $appliedForProducts');
        invoice.notMatch = true;
      }
    }
  }

  // Applies the promotion to a single product based on the promotion ValueType and Value.
  void _applyPromotionToProduct(
      SalesItemsModel product, PromotionsFBTableModel? promotion, PromotionContext context, num numberOfOfferApply) {
    if (promotion == null) return;
    product.promotionId = context.promotionCodesFB.id;
    product.promotionCode = context.promotionCodesFB.code;
    product.promotionCodeId = context.promotionCodesFB.id;

    product.promotionType = promotion.valueType;
    product.promotionAmount = promotion.value;
    product.promotionName = promotion.name;
    final price2 = product.isExclusive ? double.parse(product.price) : (double.parse(product.price) / 1.15);
    final price = (product.isExclusive ? double.parse(product.price) : (double.parse(product.price) / 1.15));
    final promoValue = promotion.value;
    // if (qty <= numberOfOfferApply) {
    //   if (promotion.valueType == PromotionIValueType.specificValue.value) {
    //     product.promotionValue = ((price - promoValue) * qty);
    //     product.realPromotionValue = ((price2 - promoValue) * qty);
    //   } else if (promotion.valueType ==
    //       PromotionIValueType.discountPercentage.value) {
    //     // DiscountPercentage - with improved rounding for 100% discounts
    //     double calculatedValue = (promoValue / 100) * (price * qty);
    //     double calculatedValue2 = (promoValue / 100) * (price2 * qty);

    //     // Special handling for 100% discount to ensure exact precision
    //     if (promoValue == 100.0) {
    //       calculatedValue = price * qty; // Exact calculation for 100% discount
    //       calculatedValue2 =
    //           price2 * qty; // Exact calculation for 100% discount
    //     }

    //     product.promotionValue = calculatedValue;
    //     product.realPromotionValue = calculatedValue2;
    //   } else {
    //     product.promotionValue = promoValue * qty;
    //     product.realPromotionValue = promoValue * qty;
    //   }
    // } else {
    if (promotion.valueType == PromotionIValueType.specificValue.value) {
      product.promotionValue = (price - promoValue) * numberOfOfferApply;
      product.realPromotionValue = (price2 - promoValue) * numberOfOfferApply;
    } else if (promotion.valueType == PromotionIValueType.discountPercentage.value) {
      // DiscountPercentage - with improved rounding for 100% discounts
      double calculatedValue = (promoValue / 100) * price * numberOfOfferApply;
      double calculatedValue2 = (promoValue / 100) * price2 * numberOfOfferApply;

      // Special handling for 100% discount to ensure exact precision
      if (promoValue == 100.0) {
        calculatedValue = price * numberOfOfferApply;
        calculatedValue2 = price2 * numberOfOfferApply; // Exact calculation for 100% discount
      }

      product.promotionValue = calculatedValue;
      product.realPromotionValue = calculatedValue2;
    } else {
      product.promotionValue = promoValue * numberOfOfferApply;
      product.realPromotionValue = promoValue * numberOfOfferApply;
    }
    // }
  }
}
