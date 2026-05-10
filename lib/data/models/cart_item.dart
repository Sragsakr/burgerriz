import 'package:equatable/equatable.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/variant_translation_element_entity.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/variation_value_translation_entity.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/variation_value_translation_pricing_entity.dart';
import 'package:kiosk_point_of_sale/data/models/menu_item/selected_variant.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_items_model.dart';

import 'Synchronization/variation_value_entity.dart';

class CartItem extends Equatable {
  final String categoryId;
  final String imageUrl;
  final String productId;
  final String nameEn;
  final String nameAr;
  final String itemCode;
  final num quantity;
  final double price;
  final int unitId;
  final String? unitNameEn;
  final String? unitNameAr;
  final bool inclusive;
  final String? numberOfCalories;
  final String? numberOfSteps;
  final bool? allowDecimal;
  // Variation fields - updated to match other app
  List<SingleVariationWithPrice> variations;

  /// Typed variant selections from [ItemCustomizationDialog].
  final List<SelectedVariant> selectedVariants;

  // Promotion fields — used for free-item merge detection
  final int? promotionType;
  final int? promotionId;
  final int? actualPromotionId;

  // Check if this cart item has variations
  bool get hasVariations =>
      variations.isNotEmpty || selectedVariants.isNotEmpty;

  // Check if this cart item has a selected free product
  bool get hasSelectedFreeProduct =>
      selectedFreeProductId != null && selectedFreeProductId!.isNotEmpty;
  // Free item selection state
  FreeItemSelectionState? freeItemSelectionState;

  // Free product selection details
  String? selectedFreeProductId;
  String? selectedFreeProductName;
  String? selectedFreeProductNameAr;
  double? selectedFreeProductQuantity;
  double? selectedFreeProductPrice;
  int? selectedFreeItemId;

  // Combo meal fields
  final bool isComboMeal;
  final List<ComboMealItem>? comboItems;

  // Check if this cart item is a combo meal
  bool get hasComboItems => isComboMeal && comboItems != null && comboItems!.isNotEmpty;

  /// Returns true when both items carry the same [SelectedVariant] selections
  /// (order-independent, quantity-aware).
  bool hasSameVariants(List<SelectedVariant> other) {
    if (selectedVariants.length != other.length) return false;
    final sorted = [...selectedVariants]
      ..sort((a, b) => a.variantValueId.compareTo(b.variantValueId));
    final otherSorted = [...other]
      ..sort((a, b) => a.variantValueId.compareTo(b.variantValueId));
    for (var i = 0; i < sorted.length; i++) {
      final a = sorted[i];
      final b = otherSorted[i];
      if (a.variantValueId != b.variantValueId) return false;
      if (a.quantity != b.quantity) return false;
    }
    return true;
  }

  CartItem({
    required this.categoryId,
    required this.imageUrl,
    required this.productId,
    required this.nameEn,
    required this.nameAr,
    required this.quantity,
    required this.price,
    required this.unitId,
    this.unitNameEn,
    this.unitNameAr,
    required this.itemCode,
    required this.inclusive,
    this.variations = const [],
    this.selectedVariants = const [],
    this.promotionType,
    this.promotionId,
    this.actualPromotionId,
    this.freeItemSelectionState,
    this.selectedFreeProductId,
    this.selectedFreeProductName,
    this.selectedFreeProductNameAr,
    this.selectedFreeProductQuantity,
    this.selectedFreeProductPrice,
    this.selectedFreeItemId,
    this.numberOfCalories,
    this.numberOfSteps,
    this.allowDecimal,
    this.isComboMeal = false,
    this.comboItems,
  });

  CartItem copyWith({
    String? categoryId,
    String? productId,
    String? nameEn,
    String? nameAr,
    num? quantity,
    double? price,
    int? unitId,
    String? unitNameEn,
    String? unitNameAr,
    bool? inclusive,
    String? itemCode,
    String? imageUrl,
    List<SingleVariationWithPrice>? variations,
    List<SelectedVariant>? selectedVariants,
    int? promotionType,
    int? promotionId,
    int? actualPromotionId,
    FreeItemSelectionState? freeItemSelectionState,
    String? selectedFreeProductId,
    String? selectedFreeProductName,
    String? selectedFreeProductNameAr,
    double? selectedFreeProductQuantity,
    double? selectedFreeProductPrice,
    int? selectedFreeItemId,
    String? numberOfCalories,
    String? numberOfSteps,
    bool? allowDecimal,
    bool? isComboMeal,
    List<ComboMealItem>? comboItems,
  }) {
    return CartItem(
      categoryId: categoryId ?? this.categoryId,
      imageUrl: imageUrl ?? this.imageUrl,
      productId: productId ?? this.productId,
      nameEn: nameEn ?? this.nameEn,
      nameAr: nameAr ?? this.nameAr,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      unitId: unitId ?? this.unitId,
      unitNameEn: unitNameEn ?? this.unitNameEn,
      unitNameAr: unitNameAr ?? this.unitNameAr,
      inclusive: inclusive ?? this.inclusive,
      itemCode: itemCode ?? this.itemCode,
      variations: variations ?? this.variations,
      selectedVariants: selectedVariants ?? this.selectedVariants,
      promotionType: promotionType ?? this.promotionType,
      promotionId: promotionId ?? this.promotionId,
      actualPromotionId: actualPromotionId ?? this.actualPromotionId,
      freeItemSelectionState:
          freeItemSelectionState ?? this.freeItemSelectionState,
      selectedFreeProductId:
          selectedFreeProductId ?? this.selectedFreeProductId,
      selectedFreeProductName:
          selectedFreeProductName ?? this.selectedFreeProductName,
      selectedFreeProductNameAr:
          selectedFreeProductNameAr ?? this.selectedFreeProductNameAr,
      selectedFreeProductQuantity:
          selectedFreeProductQuantity ?? this.selectedFreeProductQuantity,
      selectedFreeProductPrice:
          selectedFreeProductPrice ?? this.selectedFreeProductPrice,
      selectedFreeItemId: selectedFreeItemId ?? this.selectedFreeItemId,
      numberOfCalories: numberOfCalories ?? this.numberOfCalories,
      numberOfSteps: numberOfSteps ?? this.numberOfSteps,
      allowDecimal: allowDecimal ?? this.allowDecimal,
      isComboMeal: isComboMeal ?? this.isComboMeal,
      comboItems: comboItems ?? this.comboItems,
    );
  }

  CartItem resetFreeItemSelection() {
    return CartItem(
      imageUrl: imageUrl,
      categoryId: categoryId,
      productId: productId,
      nameEn: nameEn,
      nameAr: nameAr,
      quantity: quantity,
      price: price,
      unitId: unitId,
      unitNameEn: unitNameEn,
      unitNameAr: unitNameAr,
      inclusive: inclusive,
      itemCode: itemCode,
      numberOfCalories: numberOfCalories,
      numberOfSteps: numberOfSteps,
      allowDecimal: allowDecimal,
      variations: variations,
      selectedVariants: selectedVariants,
      promotionType: promotionType,
      promotionId: promotionId,
      actualPromotionId: actualPromotionId,
      freeItemSelectionState: null,
      selectedFreeProductId: null,
      selectedFreeProductName: null,
      selectedFreeProductNameAr: null,
      selectedFreeProductQuantity: null,
      selectedFreeProductPrice: null,
      selectedFreeItemId: null,
      isComboMeal: isComboMeal,
      comboItems: comboItems,
    );
  }

  /// Check if a free item has been selected
  bool isFreeItemSelected() {
    return freeItemSelectionState == FreeItemSelectionState.selected;
  }

  @override
  List<Object?> get props => [
        categoryId,
        productId,
        nameEn,
        nameAr,
        quantity,
        price,
        unitId,
        unitNameEn,
        unitNameAr,
        inclusive,
        variations,
        selectedVariants,
        promotionType,
        promotionId,
        actualPromotionId,
        itemCode,
        imageUrl,
        freeItemSelectionState,
        selectedFreeProductId,
        selectedFreeProductName,
        selectedFreeProductNameAr,
        selectedFreeProductQuantity,
        selectedFreeProductPrice,
        selectedFreeItemId,
        numberOfCalories,
        numberOfSteps,
        allowDecimal,
        isComboMeal,
        comboItems,
      ];
}

/// Class to hold a combo meal sub-item
class ComboMealItem extends Equatable {
  final int comboMealPackageItemId;
  final int menuItemId;
  final String nameEn;
  final String nameAr;
  final String imageUrl;
  final double price;
  final double quantity;
  final double taxValue;
  final bool isVAT;

  const ComboMealItem({
    required this.comboMealPackageItemId,
    required this.menuItemId,
    required this.nameEn,
    required this.nameAr,
    required this.imageUrl,
    required this.price,
    this.quantity = 1,
    this.taxValue = 0.15,
    this.isVAT = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'comboMealPackageItemId': comboMealPackageItemId,
      'menuItemId': menuItemId,
      'nameEn': nameEn,
      'nameAr': nameAr,
      'imageUrl': imageUrl,
      'price': price,
      'quantity': quantity,
      'taxValue': taxValue,
      'isVAT': isVAT,
    };
  }

  factory ComboMealItem.fromJson(Map<String, dynamic> json) {
    return ComboMealItem(
      comboMealPackageItemId: json['comboMealPackageItemId'] ?? 0,
      menuItemId: json['menuItemId'] ?? 0,
      nameEn: json['nameEn'] ?? '',
      nameAr: json['nameAr'] ?? '',
      imageUrl: json['imageUrl'] ?? 'noImageId',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1.0,
      taxValue: (json['taxValue'] as num?)?.toDouble() ?? 0.15,
      isVAT: json['isVAT'] ?? true,
    );
  }

  @override
  List<Object?> get props => [
        comboMealPackageItemId,
        menuItemId,
        nameEn,
        nameAr,
        imageUrl,
        price,
        quantity,
        taxValue,
        isVAT,
      ];
}

/// Class to hold a single variation with its pricing information
class SingleVariationWithPrice extends Equatable {
  final VariantTranslationElementEntity? mainTranslationAr;
  final VariantTranslationElementEntity? mainTranslationEn;
  final VariationValueTranslationEntity? variationAr;
  final VariationValueTranslationEntity? variationEn;
  final VariationValueTranslationPricingEntity? price;
  final VariationValueEntity variationValue;
  const SingleVariationWithPrice({
    required this.mainTranslationAr,
    required this.mainTranslationEn,
    required this.variationValue,
    this.variationAr,
    this.variationEn,
    this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'variationAr': variationAr?.toJson(),
      'variationEn': variationEn?.toJson(),
      'price': price?.toJson(),
      'variationValue': variationValue.toJson(),
      'mainTranslationAr': mainTranslationAr?.toJson(),
      'mainTranslationEn': mainTranslationEn?.toJson(),
    };
  }

  factory SingleVariationWithPrice.fromMap(Map<String, dynamic> map) {
    return SingleVariationWithPrice(
      mainTranslationAr: map['mainTranslationAr'] != null
          ? VariantTranslationElementEntity.fromJson(map['mainTranslationAr'])
          : null,
      mainTranslationEn: map['mainTranslationEn'] != null
          ? VariantTranslationElementEntity.fromJson(map['mainTranslationEn'])
          : null,
      variationValue: VariationValueEntity.fromJson(map['variationValue']),
      variationAr: map['variationAr'] != null
          ? VariationValueTranslationEntity.fromJson(map['variationAr'])
          : null,
      variationEn: map['variationEn'] != null
          ? VariationValueTranslationEntity.fromJson(map['variationEn'])
          : null,
      price: map['price'] != null
          ? VariationValueTranslationPricingEntity.fromJson(map['price'])
          : null,
    );
  }

  @override
  List<Object?> get props => [
        variationAr,
        variationEn,
        price,
        mainTranslationAr,
        mainTranslationEn,
        variationValue,
      ];
}
