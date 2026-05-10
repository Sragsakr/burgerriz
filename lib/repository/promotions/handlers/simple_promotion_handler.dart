import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/models/promotion_context.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/models/promotion_fb_item_model.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/models/promotion_invoice.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/models/promotions_details_fB_model.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/models/promotions_fB_table_model.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/tables/promotion_fb_item_excluded_menu_item_table.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/tables/promotion_fb_item_table.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/tables/promotions_details_fB_table.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_items_model.dart';
import 'package:kiosk_point_of_sale/repository/promotions/enums/promotion_item_type.dart';
import 'package:kiosk_point_of_sale/repository/promotions/enums/promotion_value_type.dart';

import '../promotion_handler.dart';

class SimplePromotionHandler extends IPromotionHandler {
  @override
  Future<PromotionInvoice> apply(PromotionContext context) async {
    dPrint('🎯 === SimplePromotionHandler.apply START ===');
    dPrint('📊 Promotion code: ${context.promotionCodesFB.code}');
    dPrint('🆔 Promotion ID: ${context.promotionCodesFB.id}');
    dPrint('📦 Items in transaction: ${context.saleTrans.salesOrderItems.length}');

    // Debug: Check free item states at the start of promotion processing
    dPrint('🎁 === FREE ITEM STATES AT PROMOTION START ===');
    for (int i = 0; i < context.saleTrans.salesOrderItems.length; i++) {
      final item = context.saleTrans.salesOrderItems[i];
      dPrint('🎁 FREE ITEM STATES $i: ${item.productNameEn} - State: ${item.freeItemSelectionState}');
    }
    dPrint('🎁 === END FREE ITEM STATES ===');

    final invoice = PromotionInvoice(context.saleTrans);
    final promotion = await context.promotionCodesFB.promotionsFB;

    dPrint('🎁 Promotion details: ${promotion?.name ?? 'Not found'}');
    dPrint('💰 Invoice total amount: ${invoice.salesTransaction.salesOrderModel.totalAmount}');

    if (promotion == null) {
      dPrint('❌ Promotion not found - returning original invoice');
      return invoice;
    }

    // Fetch details and items from DB
    dPrint('🔍 Fetching promotion details and items...');
    final promotionDetails =
        (await PromotionDetailsFBTable.getAll()).where((d) => d.promotionId == promotion.id).toList();
    final promotionItems = (await PromotionFBItemTable.getAll()).where((i) => i.promotionId == promotion.id).toList();

    dPrint('📋 Loaded data:');
    dPrint('   - Promotion details: ${promotionDetails.length}');
    dPrint('   - Promotion items: ${promotionItems.length}');

    // If no details are defined, just apply promotion to the defined PromotionFBItems

    dPrint('📝 No promotion details found - applying simple promotion');
    await _applyNoDetailPromotion(context, promotionItems, invoice);
    dPrint('✅ Simple promotion applied successfully');
    dPrint(
        '📊 Final items: ${invoice.salesTransaction.salesOrderItems.map((e) => '${e.productNameEn}: ${e.isPromotionDuplicated}').toList()}');

    // Debug: Check free item states at the end of simple promotion processing
    dPrint('🎁 === FREE ITEM STATES AT SIMPLE PROMOTION END ===');
    for (int i = 0; i < invoice.salesTransaction.salesOrderItems.length; i++) {
      final item = invoice.salesTransaction.salesOrderItems[i];
      dPrint('🎁 Item $i: ${item.productNameEn} - State: ${item.freeItemSelectionState}');
    }
    dPrint('🎁 === END FREE ITEM STATES ===');

    return invoice;
  }

  // Check if the purchased products meet the criteria defined in the promotion details.
  // Returns [isMatch, numberOfOfferApply]
  Future<List<dynamic>> _checkPromotionMatchesCriteria(
      PromotionContext context, List<PromotionDetailsFBModel> details) async {
    dPrint('🔍 Checking promotion criteria match...');
    dPrint('📋 Number of criteria to check: ${details.length}');

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

    for (int groupIndex = 0; groupIndex < conditionGroups.length; groupIndex++) {
      final group = conditionGroups[groupIndex];
      var groupResult = true;
      var groupApplyCount = 1 << 30;

      for (int i = 0; i < group.length; i++) {
        final detail = group[i];
        dPrint('🔍 Checking criteria G${groupIndex + 1}.${i + 1}:');
        dPrint('   - Item type: ${detail.itemType}');
        dPrint('   - Item ID: ${detail.itemId}');
        dPrint('   - Required quantity: ${detail.quantity}');

        double matchCount = 0;

        if (detail.itemType == PromotionItemType.productCategory.value) {
          matchCount = context.saleTrans.salesOrderItems
              .where((x) => int.parse(x.categoryId) == detail.itemId)
              .fold(0.0, (sum, x) => sum + double.parse(x.quantity));
          dPrint('   📦 Category match count: $matchCount');
        } else if (detail.itemType == PromotionItemType.menuItem.value) {
          matchCount = context.saleTrans.salesOrderItems
              .where((x) => int.parse(x.productId) == detail.itemId)
              .fold(0.0, (sum, x) => sum + double.parse(x.quantity));
          dPrint('   🍽️  Product match count: $matchCount');
        }

        if (detail.quantity <= 0) {
          groupResult = false;
          groupApplyCount = 0;
          continue;
        }

        final detailMatched = matchCount >= detail.quantity;
        groupResult = groupResult && detailMatched;
        if (detailMatched) {
          dPrint('   ✅ Criteria met');
        } else {
          dPrint('   ❌ Criteria not met (required: ${detail.quantity}, found: $matchCount)');
        }

        final offerApply = detailMatched ? (matchCount / detail.quantity).floor() : 0;
        groupApplyCount = offerApply < groupApplyCount ? offerApply : groupApplyCount;
        dPrint('   🎯 Offers that can be applied: $offerApply');
      }

      if (groupResult) {
        successfulGroupApplyCounts.add(groupApplyCount == (1 << 30) ? 0 : groupApplyCount);
      }
    }

    final isMatch = successfulGroupApplyCounts.isNotEmpty;
    final numberOfOfferApply = isMatch ? successfulGroupApplyCounts.reduce((a, b) => a > b ? a : b) : 0;

    dPrint('📊 Final criteria check results:');
    dPrint('   - Is match: $isMatch');
    dPrint('   - Number of offers to apply: $numberOfOfferApply');

    return [isMatch, numberOfOfferApply];
  }

  // Applies promotion to products if no promotion details are specified.
  Future<void> _applyNoDetailPromotion(
      PromotionContext context, List<PromotionFBItemModel> promotionItems, PromotionInvoice invoice) async {
    dPrint('🎁 Applying no-detail promotion...');

    final promotion = await context.promotionCodesFB.promotionsFB;
    final excludedItems = await PromotionFBItemExcludedMenuItemTable.getAll();
    var realExcludedItems = [];
    for (var item in promotionItems) {
      final x = excludedItems.where((x) => x.promotionFBItemId == item.id);
      realExcludedItems.addAll(x);
    }
    if (promotionItems.isEmpty) {
      dPrint('⚠️  No promotion items found - skipping');
      return;
    }

    dPrint('📦 Promotion items to apply: ${promotionItems.map((e) => '${e.itemId} (${e.itemType})').toList()}');
    dPrint('🚫 Excluded items count: ${realExcludedItems.map((e) => e.menuItemId).toList()}');

    List<bool> appliedForProducts = [];

    for (final promotionItem in promotionItems) {
      dPrint('🎯 Processing promotion item: ${promotionItem.itemId} (${promotionItem.itemType})');
      dPrint(context.saleTrans.salesOrderItems.map((e) => e.productId).toList().toString());

      final products = context.saleTrans.salesOrderItems.where((x) =>
          (promotionItem.itemType == PromotionItemType.menuItem.value &&
              int.parse(x.productId) == promotionItem.itemId) ||
          ((promotionItem.itemType == PromotionItemType.productCategory.value &&
                  int.parse(x.categoryId) == promotionItem.itemId) &&
              !realExcludedItems.any((e) => e.menuItemId == int.parse(x.productId))));

      dPrint('📦 Found ${products.length} matching products');
      dPrint('   - Product IDs: ${products.map((e) => e.productId).toList()}');
      dPrint('   - Categories: ${products.map((e) => e.categoryId).toList()}');
      if (products.isEmpty) {
        dPrint(
            '⚠️  No products found for promotion item: ${promotionItem.itemId} (${promotionItem.itemType}) - skipping');

        appliedForProducts.add(false);
        continue;
      }
      for (final product in products) {
        _applyPromotionToProduct(product, promotion, context, 1);

        // Update the invoice item
        final invoiceItem =
            invoice.salesTransaction.salesOrderItems.where((p) => p.productId == product.productId).first;
        invoiceItem.promotionId = product.promotionId;
        invoiceItem.promotionCode = product.promotionCode;
        invoiceItem.promotionType = product.promotionType;
        invoiceItem.promotionValue = product.promotionValue;
        invoiceItem.promotionAmount = product.promotionAmount;
        invoiceItem.promotionName = product.promotionName;
        invoiceItem.promotionCodeId = product.promotionCodeId;
        if (promotion?.valueType == PromotionIValueType.specificValueWithFreeProduct.value) {
          invoiceItem.price = product.promotionAmount.toString();
          invoiceItem.selectedFreeProductName = product.selectedFreeProductName;
          invoiceItem.selectedFreeProductNameAr = product.selectedFreeProductNameAr;
          invoiceItem.selectedFreeProductQuantity = product.getEffectiveFreeProductQuantity();
          invoiceItem.selectedFreeProductPrice = product.selectedFreeProductPrice;
          invoiceItem.selectedFreeItemId = product.selectedFreeItemId;
          invoiceItem.isPromotionDuplicated = product.isPromotionDuplicated;
          invoiceItem.freeItemSelectionState = product.freeItemSelectionState;
        }
        appliedForProducts.add(true);
        dPrint('✅ No-detail promotion completed  ${invoiceItem.price}');
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
    dPrint('📋 Applying detailed promotion...');
    dPrint('🎯 Number of offers to apply: $numberOfOfferApply');

    int itemsProcessed = 0;
    int itemsSkipped = 0;

    for (final product in context.saleTrans.salesOrderItems) {
      dPrint('🔍 Processing product: ${product.productNameEn} (ID: ${product.productId})');

      final detail = details.firstWhere(
        (d) =>
            (d.itemType == PromotionItemType.menuItem.value && d.itemId == int.parse(product.productId)) ||
            (d.itemType == PromotionItemType.productCategory.value && d.itemId == int.parse(product.categoryId)),
        orElse: () => details.isNotEmpty ? details.first : throw Exception('No details'),
      );

      dPrint('📋 Found matching detail:');
      dPrint('   - Item type: ${detail.itemType}');
      dPrint('   - Item ID: ${detail.itemId}');
      dPrint('   - Required quantity: ${detail.quantity}');
      dPrint('   - Product quantity: ${product.quantity}');

      if (((detail.itemType == PromotionItemType.menuItem.value && detail.itemId == int.parse(product.productId)) ||
          (detail.itemType == PromotionItemType.productCategory.value &&
              detail.itemId == int.parse(product.categoryId)))) {
        if (double.parse(product.quantity) >= detail.quantity) {
          dPrint('✅ Product meets quantity requirement - applying promotion');
          final promotion = await context.promotionCodesFB.promotionsFB;
          _applyPromotionToProduct(product, promotion, context, numberOfOfferApply);
          dPrint('🎁 Promotion applied - Amount: ${product.promotionAmount}, Value: ${product.promotionValue}');
          itemsProcessed++;
        } else {
          dPrint('❌ Product quantity insufficient - clearing promotion');
          product.promotionId = null;
          product.promotionCode = null;
          product.promotionCodeId = null;

          product.promotionType = null;
          product.promotionValue = null;
          product.promotionAmount = null;
          product.promotionName = null;
          itemsSkipped++;
        }
      }
    }

    dPrint('✅ Detailed promotion completed:');
    dPrint('   - Items processed: $itemsProcessed');
    dPrint('   - Items skipped: $itemsSkipped');
  }

  /// Applies the promotion to a single product based on the promotion ValueType and Value.
  void _applyPromotionToProduct(
      SalesItemsModel product, PromotionsFBTableModel? promotion, PromotionContext context, num numberOfOfferApply) {
    if (promotion == null) {
      dPrint('❌ Promotion is null - skipping product');
      return;
    }

    // Preserve the free item selection state at the beginning
    final preservedFreeItemState = product.freeItemSelectionState;
    // dPrint(
    //     '🎁 Preserving free item isPromotionDuplicated: ${product.isPromotionDuplicated}');

    // if (promotion.valueType ==
    //     PromotionIValueType.specificValueWithFreeProduct.value) {
    //   return;
    // }

    _logPromotionApplication(product, promotion, numberOfOfferApply);
    _setPromotionMetadata(product, promotion, context);

    final productDetails = _extractProductDetails(product);
    final effectiveQuantity = _calculateEffectiveQuantity(productDetails.quantity, numberOfOfferApply);

    product.promotionValue = _calculatePromotionValue(
        promotion.valueType, promotion.value, productDetails.price, effectiveQuantity, productDetails.quantity);

    product.realPromotionValue = _calculatePromotionValue(
        promotion.valueType, promotion.value, productDetails.price, effectiveQuantity, productDetails.quantity);

    dPrint('🎁 Preserving free item isPromotionDuplicated: ${promotion.valueType}');

    // Ensure the free item selection state is preserved at the end
    product.freeItemSelectionState = preservedFreeItemState;
    dPrint('🎁 Final free item state: ${product.freeItemSelectionState} for ${product.price}');

    _logPromotionResult(product);
  }

  /// Extract and calculate product details for promotion calculation
  ProductDetails _extractProductDetails(SalesItemsModel product) {
    final quantity = double.parse(product.quantity);
    final price = product.isExclusive ? double.parse(product.price) : (double.parse(product.price) / 1.15);

    return ProductDetails(
      quantity: quantity,
      price: price,
    );
  }

  /// Calculate the effective quantity for promotion application
  num _calculateEffectiveQuantity(num productQuantity, num numberOfOfferApply) {
    return productQuantity <= numberOfOfferApply ? productQuantity : numberOfOfferApply;
  }

  /// Set promotion metadata on the product
  void _setPromotionMetadata(SalesItemsModel product, PromotionsFBTableModel promotion, PromotionContext context) {
    // Preserve the free item selection state before setting promotion metadata
    final preservedFreeItemState = product.freeItemSelectionState;
    dPrint('🎁 Preserving free item state: $preservedFreeItemState for ${product.productNameEn}');

    product.promotionId = promotion.id;
    dPrint("product.promotionId is ${product.promotionId}");
    product.promotionCode = context.promotionCodesFB.code;
    product.promotionCodeId = context.promotionCodesFB.id;
    product.promotionType = promotion.valueType;
    product.promotionAmount = promotion.value;
    product.promotionName = promotion.name;

    // Restore the free item selection state after setting promotion metadata
    product.freeItemSelectionState = preservedFreeItemState;
    dPrint('🎁 Restored free item state: ${product.freeItemSelectionState} for ${product.productNameEn}');
  }

  /// Calculate promotion value based on type and effective quantity
  double _calculatePromotionValue(
      int valueType, double promoValue, double price, num effectiveQuantity, num totalQuantity) {
    final isFullApplication = effectiveQuantity == totalQuantity;
    dPrint('🎯 Applying promotion to $valueType (effective qty: $effectiveQuantity, full: $isFullApplication)');

    if (valueType == PromotionIValueType.specificValue.value) {
      return _calculateSpecificValuePromotion(price, promoValue, effectiveQuantity);
    } else if (valueType == PromotionIValueType.discountPercentage.value) {
      return _calculatePercentagePromotion(promoValue, price, effectiveQuantity);
    } else if (valueType == PromotionIValueType.discountValue.value) {
      return _calculateFixedValuePromotion(promoValue, effectiveQuantity);
    } else if (valueType == PromotionIValueType.specificValueWithFreeProduct.value) {
      return 0.0;
    }

    // Default case for unknown promotion types
    dPrint('⚠️ Unknown promotion value type: $valueType');
    return 0.0;
  }

  /// Calculate specific value promotion
  double _calculateSpecificValuePromotion(double price, double promoValue, num quantity) {
    final result = (price - promoValue) * quantity;
    dPrint('💰 Specific value calculation: ($price - $promoValue) * $quantity = $result');
    return result;
  }

  /// Calculate percentage-based promotion
  double _calculatePercentagePromotion(double promoValue, double price, num quantity) {
    double calculatedValue;

    if (promoValue == 100.0) {
      // Special handling for 100% discount to ensure exact precision
      calculatedValue = price * quantity;
    } else {
      calculatedValue = (promoValue / 100) * (price * quantity);
    }

    dPrint('💰 Percentage calculation: ($promoValue% / 100) * ($price * $quantity) = $calculatedValue');
    return calculatedValue;
  }

  /// Calculate fixed value promotion
  double _calculateFixedValuePromotion(double promoValue, num quantity) {
    final result = promoValue * quantity;
    dPrint('💰 Fixed value calculation: $promoValue * $quantity = $result');
    return result;
  }

  /// Log promotion application details
  void _logPromotionApplication(SalesItemsModel product, PromotionsFBTableModel promotion, num numberOfOfferApply) {
    dPrint('🎁 Applying promotion to product: ${product.productNameEn}');
    dPrint('📊 Promotion details:');
    dPrint('   - Value type: ${promotion.valueType}');
    dPrint('   - Value: ${promotion.value}');
    dPrint('   - Number of offers: $numberOfOfferApply');
  }

  /// Log promotion application result
  void _logPromotionResult(SalesItemsModel product) {
    dPrint('✅ Promotion applied successfully:');
    dPrint('   - Promotion ID: ${product.promotionId}');
    dPrint('   - Promotion code: ${product.promotionCode}');
    dPrint('   - Promotion type: ${product.promotionType}');
    dPrint('   - Promotion amount: ${product.promotionAmount}');
    dPrint('   - Promotion value: ${product.promotionValue}');
  }
}

/// Data class to hold product details for promotion calculation
class ProductDetails {
  final double quantity;
  final double price;

  ProductDetails({
    required this.quantity,
    required this.price,
  });
}
