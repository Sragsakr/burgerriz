import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/core/services/order_services/free_item_service.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/models/promotion_fb_additional_free_item_model.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/tables/promotion_fb_additional_free_item_excluded_menu_item_table.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/tables/promotion_fb_additional_free_item_table.dart';
import 'package:kiosk_point_of_sale/data/models/sync_product/sync_product_model.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/sale_type_tables/sale_type_price_list_table.dart';
import 'package:kiosk_point_of_sale/providers/payment_breakdown_provider.dart';
import 'package:kiosk_point_of_sale/repository/menu_item_sync_repository.dart';
import 'package:kiosk_point_of_sale/repository/promotions/enums/promotion_item_type.dart';

/// Enum representing the state of free item selection for a sales item
enum FreeItemSelectionState {
  notShown, // Dialog hasn't been shown yet
  selected, // User selected a free item
  ignored, // User cancelled/ignored the dialog
}

class SalesItemsModel {
  int? id;
  String createdAt;
  String updatedAt;
  String productId;
  String categoryId;
  String productNameEn;
  String productNameAr;
  String unitOfMeasureId;
  String? unitNameEn;
  String? unitNameAr;
  String quantity;
  String price;
  String tax;
  String total;
  String note;
  int isRefund;
  String userId;
  String tenantId;
  String invoiceId; // New field
  String uniqueId; // New field
  bool isExclusive;

  ///////////////////
  String? promotionCode; // New field
  int? promotionCodeId; // New field
  int? promotionType; // New field
  double? promotionValue; // New field
  double? realPromotionValue; // New field
  int? promotionId; // New field
  double? promotionAmount; // New field
  String? promotionName; // New field for promotion name
  double? vatBeforeDiscount; // New field
  double? discount;
  double? loyaltyDiscount;
  double? additionalAllowns;
  double? priceIncludeVAT;

  // Free product fields
  String? selectedFreeProductId;
  String? selectedFreeProductName;
  String? selectedFreeProductNameAr;
  String? selectedFreeUUid;
  double? selectedFreeProductQuantity;
  double? selectedFreeProductPrice;
  int? selectedFreeItemId;
  bool? isPromotionDuplicated;
  FreeItemSelectionState? freeItemSelectionState;

  // Variation fields
  List<Map<String, dynamic>>? variations;

  // Combo meal fields
  bool isComboMeal;
  List<Map<String, dynamic>>? comboMealItems;

  SalesItemsModel({
    this.promotionId,
    this.promotionCodeId,
    this.promotionCode,
    this.promotionType,
    this.promotionValue,
    this.realPromotionValue,
    this.promotionAmount,
    this.promotionName,
    this.vatBeforeDiscount,
    this.discount,
    this.loyaltyDiscount,
    this.additionalAllowns,
    this.priceIncludeVAT,
    this.variations,
    // Combo meal fields
    this.isComboMeal = false,
    this.comboMealItems,
    // Free product fields
    this.selectedFreeProductId,
    this.selectedFreeProductName,
    this.selectedFreeProductNameAr,
    this.selectedFreeProductQuantity,
    this.selectedFreeProductPrice,
    this.selectedFreeItemId,
    this.isPromotionDuplicated,
    this.freeItemSelectionState,
    this.selectedFreeUUid,
    /////////////////
    this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.categoryId,
    required this.productId,
    required this.productNameEn,
    required this.productNameAr,
    required this.unitOfMeasureId,
    this.unitNameEn,
    this.unitNameAr,
    required this.quantity,
    required this.price,
    required this.tax,
    required this.total,
    required this.note,
    required this.isRefund,
    required this.userId,
    required this.tenantId,
    required this.invoiceId, // New field in constructor
    required this.uniqueId,
    required this.isExclusive, // New field in constructor
  });

  factory SalesItemsModel.fromMap(Map<String, dynamic> json) => SalesItemsModel(
        id: json["id"],
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
        productId: json["productId"],
        categoryId: json["categoryId"],
        promotionCodeId: json["promotionCodeId"],
        productNameEn: json["productNameEn"],
        productNameAr: json["productNameAr"],
        unitOfMeasureId: json["unitOfMeasureId"],
        unitNameEn: json["unitOfMeasureNameEn"],
        unitNameAr: json["unitOfMeasureNameAr"],
        quantity: json["quantity"],
        price: json["price"],
        total: json["total"],
        note: json["note"],
        tax: json["tax"],
        isRefund: json["isRefund"],
        userId: json["userId"],
        tenantId: json["tenantId"],
        invoiceId: json["orderId"],
        // New field in fromMap
        uniqueId: json["uniqueId"] ?? '',
        isExclusive: json['isExclusive'] == 1 ? true : false,
        promotionCode: json['promotionCode'],
        promotionType: json['promotionType'],
        promotionValue:
            (json['promotionValue'] != null) ? (json['promotionValue'] as num).toDouble() : null,
        promotionAmount: json['promotionAmount'],
        promotionName: json['promotionName'],
        vatBeforeDiscount: (json['vatBeforeDiscount'] != null)
            ? (json['vatBeforeDiscount'] as num).toDouble()
            : null,
        discount: (json['discount'] != null) ? (json['discount'] as num).toDouble() : null,
        loyaltyDiscount:
            (json['loyaltyDiscount'] != null) ? (json['loyaltyDiscount'] as num).toDouble() : null,
        additionalAllowns: (json['additionalAllowns'] != null)
            ? (json['additionalAllowns'] as num).toDouble()
            : null,
        priceIncludeVAT:
            (json['priceIncludeVAT'] != null) ? (json['priceIncludeVAT'] as num).toDouble() : null,
        variations: json['variations'] != null
            ? (json['variations'] is String)
                ? _parseVariationsFromJson(json['variations'])
                : List<Map<String, dynamic>>.from(json['variations'])
            : null,
        // Combo meal fields
        isComboMeal: json['isComboMeal'] == 1 || json['isComboMeal'] == true,
        comboMealItems: json['comboMealItems'] != null
            ? (json['comboMealItems'] is String)
                ? _parseVariationsFromJson(json['comboMealItems'])
                : List<Map<String, dynamic>>.from(json['comboMealItems'])
            : null,
        // Free product fields
        selectedFreeUUid: json['selectedFreeUUid'],
        selectedFreeProductId: json['selectedFreeProductId'],
        selectedFreeProductName: json['selectedFreeProductName'],
        selectedFreeProductNameAr: json['selectedFreeProductNameAr'],
        selectedFreeProductQuantity: (json['selectedFreeProductQuantity'] != null)
            ? (json['selectedFreeProductQuantity'] as num).toDouble()
            : null,
        selectedFreeProductPrice: json['selectedFreeProductPrice'] != null
            ? (json['selectedFreeProductPrice'] as num).toDouble()
            : null,
        selectedFreeItemId: json['selectedFreeItemId'],
        isPromotionDuplicated: json['isPromotionDuplicated'] == 1,
        // freeItemSelectionState: json['freeItemSelectionState'] != null
        //     ? FreeItemSelectionState.values[json['freeItemSelectionState']]
        //     : null,
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
        "productId": productId,
        "categoryId": categoryId,
        "promotionCodeId": promotionCodeId,
        "productNameEn": productNameEn,
        "productNameAr": productNameAr,
        "unitOfMeasureId": unitOfMeasureId,
        "unitOfMeasureNameEn": unitNameEn,
        "unitOfMeasureNameAr": unitNameAr,
        "quantity": quantity,
        "price": price,
        "total": total,
        "tax": tax,
        "note": note,
        "isRefund": isRefund,
        "userId": userId,
        "tenantId": tenantId,
        "orderId": invoiceId,
        "uniqueId": uniqueId,
        'isExclusive': isExclusive == true ? 1 : 0,
        'promotionCode': promotionCode,
        'promotionId': promotionId,
        'promotionType': promotionType,
        'promotionValue': promotionValue,
        'promotionAmount': promotionAmount,
        'promotionName': promotionName,
        'vatBeforeDiscount': vatBeforeDiscount,
        'discount': discount,
        'loyaltyDiscount': loyaltyDiscount,
        'additionalAllowns': additionalAllowns,
        'priceIncludeVAT': priceIncludeVAT,
        'variations': variations != null ? json.encode(variations) : null,
        // Combo meal fields
        'isComboMeal': isComboMeal ? 1 : 0,
        'comboMealItems': comboMealItems != null ? json.encode(comboMealItems) : null,
        // Free product fields
        'selectedFreeProductId': selectedFreeProductId,
        'selectedFreeProductName': selectedFreeProductName,
        'selectedFreeProductNameAr': selectedFreeProductNameAr,
        'selectedFreeProductQuantity': selectedFreeProductQuantity,
        'selectedFreeProductPrice': selectedFreeProductPrice,
        'selectedFreeItemId': selectedFreeItemId,
        'selectedFreeUUid': selectedFreeUUid,
        'isPromotionDuplicated': isPromotionDuplicated == true ? 1 : 0,
        // 'freeItemSelectionState': freeItemSelectionState?.index,
      };

  Map<String, dynamic> toMapWithUniqueId(String saleTransactionId, String qtyType) {
    final taxFreeValue = ((selectedFreeProductPrice ?? 0) * 0.15);
    dPrint("taxFreeValue is $taxFreeValue");
    dPrint("selectedFreeProductPrice is $selectedFreeProductPrice");
    dPrint("selectedFreeProductId is $selectedFreeProductPrice");
    final unit = int.tryParse(unitOfMeasureId) == 0 ? null : int.tryParse(unitOfMeasureId);
    dPrint("unit is $unit");

    return {
      'SaleTransactionId': saleTransactionId,
      'Id': uniqueId,
      'ProductLotId': null,
      'Quantity':
          qtyType == 'Decimal' ? (double.tryParse(quantity) ?? 0.0) : (int.tryParse(quantity) ?? 0),
      'Price': price,
      'priceIncludeVAT': priceIncludeVAT,
      'Discount': 0,
      'TenantId': int.parse(tenantId),
      'UnitOfMeasureId': unit,
      "OfferId": null,
      "VAT": tax,
      "Notes": null,
      "AdditionalAllowns": 0,
      "AllownsReason": "",
      'MenuItemId': int.parse(productId),
      'promotionCode': promotionCode,
      'promotionCodeId': promotionCodeId,
      'promotionId': promotionId,
      'promotionType': promotionType,
      'promotionValue': promotionValue,
      'promotionAmount': promotionAmount,
      'vatBeforeDiscount': vatBeforeDiscount,
      "SaleTransactionDetailVarients": variations
              ?.map((variation) => {
                    'tenantId': int.parse(tenantId),
                    'saleTransactionDetailId': uniqueId,
                    'variantId': variation['variantId'],
                    'variantValueId': variation['variantValueId'],
                  })
              .toList() ??
          [],
      "saleTransactionsDetialsPromotionItems": [
        if (selectedFreeItemId != null &&
            selectedFreeProductQuantity != null &&
            selectedFreeProductPrice != null)
          {
            "id": selectedFreeUUid,
            "saleTransactionDetailId": uniqueId,
            "menuItemId": selectedFreeItemId,
            "quantity": selectedFreeProductQuantity,
            "price": selectedFreeProductPrice! - taxFreeValue,
            "vat": taxFreeValue,
            "priceIncludeVat": selectedFreeProductPrice
          }
      ],
       "SaleTransactionDetailsComboMealsItems":
          _buildComboMealItemsForSync(tenantId, uniqueId, qtyType)
 
    };
  }

  /// Build combo meal items for sync
  List<Map<String, dynamic>> _buildComboMealItemsForSync(
      String tenantId, String saleTransactionDetailId, String qtyType) {
    if (comboMealItems == null || comboMealItems!.isEmpty) {
      return [];
    }
    return comboMealItems!.map((item) {
      final id = item['id'];
      final itemPrice = (item['price'] as num?)?.toDouble() ?? 0.0;
      // final itemTaxValue = (item['taxValue'] as num?)?.toDouble() ?? 0.15;
      final itemQuantity = qtyType == 'Decimal'
          ? ((item['quantity'] as num?)?.toDouble() ?? 1.0)
          : ((item['quantity'] as num?)?.toInt() ?? 1.0);
      // final itemVat = (itemPrice * itemTaxValue).roundToTwoDecimals();
      //       {
      //     "id": "string",
      //   "menuItemId": 0,
      //   "quantity": 0,
      //   "saleTransactionDetailId": "string",
      //   "price": 0,
      //   "tenantId": 0
      // }
      return {
        "id": id,
        'tenantId': int.parse(tenantId),
        'saleTransactionDetailId': saleTransactionDetailId,
        // 'comboMealPackageItemId': item['comboMealPackageItemId'],
        'menuItemId': item['menuItemId'],
        'quantity': itemQuantity,
        'price': itemPrice,
        // 'vat': itemVat,
        // 'priceIncludeVat': (itemPrice + itemVat).roundToTwoDecimals(),

      };
    }).toList();
  }

  Map<String, dynamic> toMapNotificationWithUniqueId(
      String saleTransactionId, String refundReasonId, String qtyType) {
    final taxFreeValue = (selectedFreeProductPrice ?? 0 * 0.15).roundToTwoDecimals();
    return {
      'saleNotificationId': saleTransactionId,
      'Id': uniqueId,
      'ProductLotId': null,
      'Quantity':
          qtyType == 'Decimal' ? (double.tryParse(quantity) ?? 0.0) : (int.tryParse(quantity) ?? 0),
      "originalQuantity":
          qtyType == 'Decimal' ? (double.tryParse(quantity) ?? 0.0) : (int.tryParse(quantity) ?? 0),
      'Price': price,
      'priceIncludeVAT': priceIncludeVAT,
      'Discount': 0,
      'TenantId': int.parse(tenantId),
      'UnitOfMeasureId': int.tryParse(unitOfMeasureId) == 0 ? null : int.tryParse(unitOfMeasureId),
      "OfferId": null,
      "OfferType": null,
      "VAT": tax,
      "Notes": null,
      "AdditionalAllowns": 0,
      "AllownsReason": "",
      'MenuItemId': int.parse(productId),
      'promotionCode': promotionCode,
      'promotionCodeId': promotionCodeId,
      'promotionType': promotionType,
      'promotionId': promotionId,
      'promotionValue': promotionValue,
      'promotionAmount': promotionAmount,
      'vatBeforeDiscount': vatBeforeDiscount,
      "saleNotificationDetailVarients": variations
              ?.map((variation) => {
                    'tenantId': int.parse(tenantId),
                    'saleNotificationDetailId': uniqueId,
                    'variantId': variation['variantId'],
                    'variantValueId': variation['variantValueId'],
                  })
              .toList() ??
          [],
      "saleNotificationReasonDetails": [
        {"saleNotificationDetailId": uniqueId, "refundResonId": int.parse(refundReasonId)}
      ],
      "saleNotifcationsDetialsPromotionItems": [
        if (selectedFreeItemId != null &&
            selectedFreeProductQuantity != null &&
            selectedFreeProductPrice != null)
          {
            "id": selectedFreeUUid,
            "saleNotificationDetailId": uniqueId,
            "menuItemId": selectedFreeItemId,
            "quantity": selectedFreeProductQuantity,
            "price": selectedFreeProductPrice! - taxFreeValue,
            "vat": taxFreeValue,
            "priceIncludeVat": 0
          }
      ],
       "SaleNotificationDetailsComboMealsItemSyncDtos":
          _buildComboMealItemsForNotificationSync(tenantId, uniqueId, qtyType)
 
    };
  }

  /// Build combo meal items for notification sync
   List<Map<String, dynamic>> _buildComboMealItemsForNotificationSync(
      String tenantId, String saleNotificationDetailId, String qtyType) {
    if (comboMealItems == null || comboMealItems!.isEmpty) {
 
      return [];
    }

    return comboMealItems!.map((item) {
       final id = item['id'];

      final itemPrice = (item['price'] as num?)?.toDouble() ?? 0.0;
      final itemTaxValue = (item['taxValue'] as num?)?.toDouble() ?? 0.15;
      final itemQuantity = qtyType == 'Decimal'
          ? ((item['quantity'] as num?)?.toDouble() ?? 1.0)
          : ((item['quantity'] as num?)?.toInt() ?? 1.0);
      final itemVat = (itemPrice * itemTaxValue).roundToTwoDecimals();

      return {
        "id": id,
        'tenantId': int.parse(tenantId),
        'saleNotificationDetailId': saleNotificationDetailId,
        // 'comboMealPackageItemId': item['comboMealPackageItemId'],
        'menuItemId': item['menuItemId'],
        'quantity': itemQuantity,
        'originalQuantity': itemQuantity,
        'price': itemPrice,
        // 'vat': itemVat,
        // 'priceIncludeVat': (itemPrice + itemVat).roundToTwoDecimals(),
 
      };
    }).toList();
  }

  // Helper : Calculate Item Prices(subTotalBeforeDiscount,vatBeforeDiscount,subTotalAfterDiscount,vatAfterDiscount , discount,  promotionAmount, )
  ItemPrices calculateItemPrices() {
    const double taxRate = 0.15;

    // Parse basic values
    double itemPrice = double.parse(price);
    double itemQuantity = double.parse(quantity);

    // Calculate base price and total base amount
    double basePrice = 0.0;
    double totalBaseAmount = 0.0;
    double subTotalBeforeDiscount = 0.0;
    double subTotalBeforeDiscountPerItem = 0.0;
    if (isExclusive) {
      // Price is exclusive of VAT
      totalBaseAmount = itemPrice * 1.15;
      basePrice = itemPrice;
      subTotalBeforeDiscountPerItem = (basePrice);

      subTotalBeforeDiscount = (subTotalBeforeDiscountPerItem * itemQuantity).roundToTwoDecimals();
    } else {
      totalBaseAmount = itemPrice;
      // Price is inclusive of VAT, extract base price
      basePrice = itemPrice / (1 + taxRate);
      subTotalBeforeDiscountPerItem = (basePrice);

      subTotalBeforeDiscount = (subTotalBeforeDiscountPerItem * itemQuantity).roundToTwoDecimals();
    }
    dPrint("####@subTotalBeforeDiscountPerItem is $subTotalBeforeDiscountPerItem");
    dPrint("####@subTotalBeforeDiscount is $subTotalBeforeDiscount");
    // Calculate VAT before discount
    final totalBeforeTax = totalBaseAmount * itemQuantity;
    dPrint("####@totalBeforeDiscount is $totalBeforeTax");
    double vatBeforeDiscount = (totalBeforeTax - subTotalBeforeDiscount).roundToTwoDecimals();
    dPrint(
        "**###@vatBeforeDiscount is $vatBeforeDiscount totalBeforeTax $totalBeforeTax - subTotalBeforeDiscount $subTotalBeforeDiscount");
    // Get promotion amount (if any) - this should be applied to base price
    double promotionAmount = this.promotionAmount ?? 0.0;
    double promotionValue = (this.promotionValue ?? 0.0).roundToTwoDecimals();
    double realPromotionValue1 = (this.promotionValue ?? 0.0).roundToTwoDecimals();
    double realPromotionValue2 = (this.promotionValue ?? 0.0);
    double? realPromotionValue = (this.realPromotionValue);
    dPrint("###@realPromotionValue1 is $realPromotionValue1");
    dPrint("###@realPromotionValue2 is $realPromotionValue2");
    dPrint("###@realPromotionValue is $realPromotionValue");

    double discount = this.discount ?? 0.0;

    double subTotalAfterDiscount = subTotalBeforeDiscount - discount - promotionValue;

    // Ensure subtotal doesn't go negative
    if (subTotalAfterDiscount < 0) {
      subTotalAfterDiscount = 0.0;
    }

    double dicountVat = ((discount + realPromotionValue2) * taxRate).roundToTwoDecimals();
    dPrint("###@dicountVat is $dicountVat ${(discount + (realPromotionValue2 ?? 0.0)) * taxRate}");
    dPrint("******vatBeforeDiscount is $vatBeforeDiscount dicountVat is $dicountVat ");
    // Calculate VAT after discount (tax on the final base amount)
    double vatAfterDiscount = vatBeforeDiscount - dicountVat;
    double vatAfterDiscount2 = (subTotalAfterDiscount * taxRate).roundToTwoDecimals();

    dPrint("******vatAfterDiscount2 is $vatAfterDiscount2 vatAfterDiscount is $vatAfterDiscount ");
    // Debug logging
    print('=== Item Price Calculation Debug ===');
    print('Product: $productNameEn');
    print('Price: $itemPrice (inclusive: ${!isExclusive})');
    print('Quantity: $itemQuantity');
    print('Base Price: $basePrice');
    print('Total Base Amount: $totalBaseAmount');
    print('Subtotal Before Discount: $subTotalBeforeDiscount');
    print('VAT Before Discount: $vatBeforeDiscount');
    print('Promotion Amount: $promotionAmount');
    print('Promotion Valuesss: $promotionValue');
    print('Discount Amount: $discount');
    print('Subtotal After Discount: $subTotalAfterDiscount');
    print('VAT After Discount: $vatAfterDiscount');
    print('Total with Tax: ${subTotalAfterDiscount + vatAfterDiscount}');
    print('=====================================');

    return ItemPrices(
      subTotalBeforeDiscount: subTotalBeforeDiscount,
      vatBeforeDiscount: vatBeforeDiscount,
      subTotalAfterDiscount: subTotalAfterDiscount,
      vatAfterDiscount: vatAfterDiscount,
      discount: discount,
      promotionAmount: promotionAmount,
      promotionValue: promotionValue,
      total: subTotalAfterDiscount + vatAfterDiscount,
    );
  }

  // Helper method to convert SingleVariationWithPrice to Map format for sync
  static List<Map<String, dynamic>> convertVariationsToMap(List<dynamic> variations) {
    return variations.map((variation) {
      if (variation is Map<String, dynamic>) {
        return variation;
      } else {
        // Handle SingleVariationWithPrice objects
        return {
          'variantId': variation.variation?.id,
          'variantValueId': variation.variation?.variantValueId,
        };
      }
    }).toList();
  }

  // Helper method to parse variations from JSON string stored in database
  static List<Map<String, dynamic>>? _parseVariationsFromJson(String jsonString) {
    try {
      if (jsonString.isEmpty) return null;

      // Parse the JSON string to a list
      final List<dynamic> parsedList = json.decode(jsonString);

      // Convert to List<Map<String, dynamic>>
      return parsedList.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (e) {
      print('Error parsing variations JSON: $e');
      return null;
    }
  }

  /// Get free items for this sales item based on promotion rules
  /// Returns free items if promotionCodeId matches the promotionId in free items
  ///
  /// Usage example:
  /// ```dart
  /// final freeItems = await salesItem.getFreeItems();
  /// for (var freeItem in freeItems) {
  ///   print('Free item: ${freeItem.quantity} x itemId: ${freeItem.itemId}');
  /// }
  /// ```
  Future<List<PromotionFBAdditionalFreeItemModel>> getFreeItems() async {
    try {
      if (promotionCodeId == null) return [];
      dPrint('Promotion ids: $promotionId $promotionCodeId');
      // final promotionFB =
      //     await PromotionsFBTable.getByPromotionId(promotionCodeId);
      // dPrint('PromotionFB: ${promotionFB?.toJson()}');
      //
      // if (promotionFB == null) return [];
      final allFreeItems = await PromotionFBAdditionalFreeItemTable.getAll();
      dPrint('All free items: ${allFreeItems.map((e) => e.toJson())}');
      final free = allFreeItems.where((freeItem) {
        return freeItem.promotionId == promotionId;
      }).toList();
      dPrint('Main free items: ${free.map((e) => e.toJson())}');

      return free;
    } catch (e) {
      // Return empty list if there's an error
      return [];
    }
  }

  Future<List<SyncProduct>> getFreeProducts(Ref ref) async {
    try {
      final freeItems = await getFreeItems();
      final List<SyncProduct> freeProducts = [];
      final saleType = ref.watch(saleTypeNotifier.notifier);
      final priceList = await SaleTypePriceListTable.getBySaleTypeId(
          saleType.state?.saleTypeId ?? 0);
      final priceListId = priceList?.priceListId ?? 1;
      final syncRepo = MenuItemSyncRepository();

      for (var freeItem in freeItems) {
        if (freeItem.itemType == PromotionItemType.menuItem.value) {
          dPrint('Free item: ${freeItem.toJson()}');
          final product =
              await syncRepo.getProductById(freeItem.itemId, priceListId);
          dPrint('Free product: ${product?.nameEn}');
          if (product != null) {
            freeProducts.add(product);
          }
        } else if (freeItem.itemType ==
            PromotionItemType.productCategory.value) {
          final categoryProducts = await syncRepo.getProductsByCategory(
              freeItem.itemId, priceListId);

          final excludedItems =
              await PromotionFBAdditionalFreeItemExcludedMenuItemTable
                  .getByPromotionFBAdditionalFreeItemId(freeItem.id);
          final excludedProductIds =
              excludedItems.map((e) => e.menuItemId.toString()).toSet();

          final filteredProducts = categoryProducts
              .where((p) => !excludedProductIds.contains(p.productId))
              .toList();

          freeProducts.addAll(filteredProducts);
        }
      }

      return freeProducts;
    } catch (e) {
      return [];
    }
  }

  Future<Map<SyncProduct, Map<String, dynamic>>> getFreeProductsWithDetails(
      Ref ref) async {
    try {
      final freeItems = await getFreeItems();
      final Map<SyncProduct, Map<String, dynamic>> result = {};
      final saleType = ref.watch(saleTypeNotifier.notifier);
      final priceList = await SaleTypePriceListTable.getBySaleTypeId(
          saleType.state?.saleTypeId ?? 0);
      final priceListId = priceList?.priceListId ?? 1;
      final syncRepo = MenuItemSyncRepository();

      for (var freeItem in freeItems) {
        if (freeItem.itemType == PromotionItemType.menuItem.value) {
          final product =
              await syncRepo.getProductById(freeItem.itemId, priceListId);
          if (product != null) {
            final excludedItems =
                await PromotionFBAdditionalFreeItemExcludedMenuItemTable
                    .getByPromotionFBAdditionalFreeItemId(freeItem.id);

            result[product] = {
              'quantity': freeItem.quantity,
              'price': freeItem.price,
              'excludedItems': excludedItems,
              'freeItemId': freeItem.itemId,
            };
          }
        } else if (freeItem.itemType ==
            PromotionItemType.productCategory.value) {
          final categoryProducts = await syncRepo.getProductsByCategory(
              freeItem.itemId, priceListId);

          final excludedItems =
              await PromotionFBAdditionalFreeItemExcludedMenuItemTable
                  .getByPromotionFBAdditionalFreeItemId(freeItem.id);
          final excludedProductIds =
              excludedItems.map((e) => e.menuItemId.toString()).toSet();

          for (var product in categoryProducts) {
            if (!excludedProductIds.contains(product.productId)) {
              result[product] = {
                'quantity': freeItem.quantity,
                'price': freeItem.price,
                'excludedItems': excludedItems,
                'freeItemId': freeItem.id,
              };
            }
          }
        }
      }

      return result;
    } catch (e) {
      return {};
    }
  }

  Future<void> selectFreeProduct({
    required SyncProduct product,
    required double quantity,
    required double price,
    required int freeItemId,
    bool isPromotionDuplicated = false,
  }) async {
    print('🎁 selectFreeProduct for $productNameEn:');
    print('   - Product: ${product.nameEn}');
    print('   - Quantity: $quantity');
    print('   - Price: $price');

    selectedFreeProductId = product.productId;
    selectedFreeProductName = product.nameEn;
    selectedFreeProductNameAr = product.nameAr;
    selectedFreeProductQuantity = quantity;
    selectedFreeProductPrice = price;
    selectedFreeItemId = freeItemId;
    this.isPromotionDuplicated = isPromotionDuplicated;
    freeItemSelectionState = FreeItemSelectionState.selected;

    print('🎁 Free product selected, state set to: $selectedFreeProductName ');
  }

  /// Remove the selected free product from this sales item
  ///
  /// Usage example:
  /// ```dart
  /// await salesItem.removeFreeProduct();
  /// ```
  void removeFreeProduct() {
    print('🎁 removeFreeProduct for $productNameEn');
    print('   - Current state: $freeItemSelectionState');

    selectedFreeProductId = null;
    selectedFreeProductName = null;
    selectedFreeProductNameAr = null;
    selectedFreeProductQuantity = null;
    selectedFreeProductPrice = null;
    selectedFreeItemId = null;
    isPromotionDuplicated = null;

    // Only reset to notShown if the user had selected a free product
    // If they ignored it, keep the ignored state
    if (freeItemSelectionState == FreeItemSelectionState.selected) {
      freeItemSelectionState = FreeItemSelectionState.notShown;
      print('🎁 Reset state to notShown (was selected)');
    } else {
      print('🎁 Keeping state as: $freeItemSelectionState');
    }
  }

  /// Check if this sales item has a selected free product
  ///
  /// Usage example:
  /// ```dart
  /// if (salesItem.hasSelectedFreeProduct()) {
  ///   print('Free product: ${salesItem.selectedFreeProductName}');
  /// }
  /// ```
  bool hasSelectedFreeProduct() {
    return selectedFreeProductId != null && selectedFreeProductId!.isNotEmpty;
  }

  /// Get the selected free product details
  ///
  /// Usage example:
  /// ```dart
  /// if (salesItem.hasSelectedFreeProduct()) {
  ///   final details = salesItem.getSelectedFreeProductDetails();
  ///   print('Free product: ${details['name']} x ${details['quantity']}');
  /// }
  /// ```
  Map<String, dynamic>? getSelectedFreeProductDetails() {
    if (!hasSelectedFreeProduct()) return null;

    return {
      'productId': selectedFreeProductId,
      'name': selectedFreeProductName,
      'nameAr': selectedFreeProductNameAr,
      'quantity': selectedFreeProductQuantity,
      'price': selectedFreeProductPrice,
      'freeItemId': selectedFreeItemId,
      'isPromotionDuplicated': isPromotionDuplicated,
    };
  }

  /// Get the effective free product quantity based on duplication setting
  /// If isPromotionDuplicated is true, multiplies by sales item quantity
  /// If false, returns the original free product quantity
  ///
  /// Usage example:
  /// ```dart
  /// final effectiveQuantity = salesItem.getEffectiveFreeProductQuantity();
  /// print('Effective free quantity: $effectiveQuantity');
  /// ```
  double getEffectiveFreeProductQuantity() {
    if (!hasSelectedFreeProduct() || selectedFreeProductQuantity == null) {
      return 0;
    }

    if (isPromotionDuplicated == true) {
      dPrint('🎁 isPromotionDuplicated is true');
      // Multiply free quantity by sales item quantity
      final salesItemQuantity = double.tryParse(quantity) ?? 1;
      dPrint(
          "salesItemQuantity $quantity selectedFreeProductQuantity ${selectedFreeProductQuantity!}");
      final totalQuantity = selectedFreeProductQuantity! * salesItemQuantity;
      dPrint("totalQuantity of Free $totalQuantity");
      return totalQuantity;
    } else {
      dPrint('🎁 isPromotionDuplicated is false');

      // Return original free quantity regardless of sales item quantity
      return selectedFreeProductQuantity!;
    }
  }

  num getEffectiveFreeProductQuantityForInvoice({
    required num productQuantity,
    required num freeQuantity,
  }) {
    if (isPromotionDuplicated == true) {
      final totalQuantity = freeQuantity * productQuantity;
      dPrint("totalQuantity of Free $totalQuantity");
      return totalQuantity;
    } else {
      dPrint('🎁 isPromotionDuplicated is false');

      // Return original free quantity regardless of sales item quantity
      return freeQuantity;
    }
  }

  /// Clear free product selection when promotion is removed
  /// This method should be called when promotionCodeId becomes null
  ///
  /// Usage example:
  /// ```dart
  /// salesItem.promotionCodeId = null;
  /// salesItem.clearFreeProductOnPromotionRemoval();
  /// ```
  void clearFreeProductOnPromotionRemoval() {
    if (promotionCodeId == null) {
      removeFreeProduct();
    }
  }

  /// Set the free item selection state
  ///
  /// Usage example:
  /// ```dart
  /// salesItem.setFreeItemSelectionState(FreeItemSelectionState.selected);
  /// ```
  void setFreeItemSelectionState(FreeItemSelectionState state) {
    print('🎁 Setting free item selection state for $productNameEn: $state');

    freeItemSelectionState = state;
    print('🎁 State set to: $freeItemSelectionState');

    // Store the state in the service for persistence across recalculations

    FreeItemService.storeFreeItemState(this);
  }

  /// Check if the free item dialog should be shown
  /// Returns true if the state is notShown and the item has a promotion
  ///
  /// Usage example:
  /// ```dart
  /// if (salesItem.shouldShowFreeItemDialog()) {
  ///   // Show dialog
  /// }
  /// ```
  bool shouldShowFreeItemDialog() {
    final shouldShow = promotionCodeId != null &&
        (freeItemSelectionState == null ||
            freeItemSelectionState == FreeItemSelectionState.notShown);

    // Debug logging
    print('🎁 shouldShowFreeItemDialog for $productNameEn:');
    print('   - promotionCodeId: $promotionCodeId');
    print('   - freeItemSelectionState: $freeItemSelectionState');

    print('   - shouldShow: $shouldShow');

    // Additional debugging for state issues
    if (promotionCodeId != null && shouldShow) {
      print('   - ⚠️ This item will show dialog!');
    }

    return shouldShow;
  }

  /// Check if the free item dialog has been ignored
  ///
  /// Usage example:
  /// ```dart
  /// if (salesItem.isFreeItemDialogIgnored()) {
  ///   // Don't show dialog again
  /// }
  /// ```
  bool isFreeItemDialogIgnored() {
    return freeItemSelectionState == FreeItemSelectionState.ignored;
  }

  /// Check if a free item has been selected
  ///
  /// Usage example:
  /// ```dart
  /// if (salesItem.isFreeItemSelected()) {
  ///   // Show selected free item in cart
  /// }
  /// ```
  bool isFreeItemSelected() {
    return freeItemSelectionState == FreeItemSelectionState.selected;
  }

  /// Reset the free item selection state to notShown
  /// This allows the dialog to be shown again
  ///
  /// Usage example:
  /// ```dart
  /// salesItem.resetFreeItemSelectionState();
  /// ```
  void resetFreeItemSelectionState() {
    print('🎁 resetFreeItemSelectionState for $productNameEn');
    print('   - Previous state: $freeItemSelectionState');
    freeItemSelectionState = FreeItemSelectionState.notShown;
    print('🎁 State reset to: $freeItemSelectionState');
  }

  /// Ensure the free item selection state is synchronized with storage
  /// This should be called after the SalesItemsModel is created
  void syncFreeItemSelectionState() {
    final storedState = FreeItemService.getFreeItemState(this);
    if (storedState != null) {
      print('🎁 Syncing state for $productNameEn: $storedState');
      freeItemSelectionState = storedState;

      // Immediately store the state again to ensure it persists
      FreeItemService.storeFreeItemState(this);
      print('🎁 Re-stored state during sync');
    }
  }

  /// Force preserve the free item selection state
  /// This ensures the state is maintained even during multiple recalculations
  void forcePreserveFreeItemState() {
    if (freeItemSelectionState != null) {
      print('🎁 Force preserving state for $productNameEn: $freeItemSelectionState');
      FreeItemService.storeFreeItemState(this);
    }
  }
}

class ItemPrices {
  double subTotalBeforeDiscount;
  double vatBeforeDiscount;
  double subTotalAfterDiscount;
  double vatAfterDiscount;
  double discount;
  double promotionAmount;
  double promotionValue;
  double total;

  ItemPrices({
    required this.subTotalBeforeDiscount,
    required this.vatBeforeDiscount,
    required this.subTotalAfterDiscount,
    required this.vatAfterDiscount,
    required this.discount,
    required this.promotionAmount,
    required this.promotionValue,
    required this.total,
  });
}
