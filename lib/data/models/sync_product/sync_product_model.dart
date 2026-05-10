import 'package:kiosk_point_of_sale/data/models/Synchronization/variant_table_element_entity.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/variant_translation_element_entity.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/variation_value_entity.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/variation_value_translation_entity.dart';
import 'package:kiosk_point_of_sale/data/models/Synchronization/variation_value_translation_pricing_entity.dart';

// ---------------------------------------------------------------------------
// SyncCategory
// ---------------------------------------------------------------------------

class SyncCategory {
  final int id;
  final String code;
  final String nameEn;
  final String nameAr;
  final String? imageId;
  final int parentId;
  final int secondaryCategoryId;
  final bool isLastLevel;
  final bool isShowInPlugIn;

  const SyncCategory({
    required this.id,
    required this.code,
    required this.nameEn,
    required this.nameAr,
    this.imageId,
    this.parentId = 0,
    this.secondaryCategoryId = 0,
    this.isLastLevel = false,
    this.isShowInPlugIn = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'nameEn': nameEn,
        'nameAr': nameAr,
        'imageId': imageId,
        'parentId': parentId,
        'secondaryCategoryId': secondaryCategoryId,
        'isLastLevel': isLastLevel,
        'isShowInPlugIn': isShowInPlugIn,
      };

  factory SyncCategory.fromJson(Map<String, dynamic> json) => SyncCategory(
        id: json['id'] as int? ?? 0,
        code: json['code'] as String? ?? '',
        nameEn: json['nameEn'] as String? ?? '',
        nameAr: json['nameAr'] as String? ?? '',
        imageId: json['imageId'] as String?,
        parentId: json['parentId'] as int? ?? 0,
        secondaryCategoryId: json['secondaryCategoryId'] as int? ?? 0,
        isLastLevel: json['isLastLevel'] is bool
            ? json['isLastLevel'] as bool
            : (json['isLastLevel'] as int?) == 1,
        isShowInPlugIn: json['isShowInPlugIn'] is bool
            ? json['isShowInPlugIn'] as bool
            : (json['isShowInPlugIn'] as int?) == 1,
      );

  SyncCategory copyWith({
    String? nameEn,
    String? nameAr,
    String? imageId,
  }) =>
      SyncCategory(
        id: id,
        code: code,
        nameEn: nameEn ?? this.nameEn,
        nameAr: nameAr ?? this.nameAr,
        imageId: imageId ?? this.imageId,
        parentId: parentId,
        secondaryCategoryId: secondaryCategoryId,
        isLastLevel: isLastLevel,
        isShowInPlugIn: isShowInPlugIn,
      );
}

// ---------------------------------------------------------------------------
// SyncUnitOfMeasure
// ---------------------------------------------------------------------------

class SyncUnitOfMeasure {
  final int unitOfMeasureId;
  final String nameEn;
  final String nameAr;
  final double price;
  final double factor;
  final int priceListId;
  final String? priceListNameEn;
  final String? priceListNameAr;

  const SyncUnitOfMeasure({
    required this.unitOfMeasureId,
    required this.nameEn,
    required this.nameAr,
    required this.price,
    required this.factor,
    required this.priceListId,
    this.priceListNameEn,
    this.priceListNameAr,
  });

  Map<String, dynamic> toJson() => {
        'unitOfMeasureId': unitOfMeasureId,
        'nameEn': nameEn,
        'nameAr': nameAr,
        'price': price,
        'factor': factor,
        'priceListId': priceListId,
        'priceListNameEn': priceListNameEn,
        'priceListNameAr': priceListNameAr,
      };

  factory SyncUnitOfMeasure.fromJson(Map<String, dynamic> json) =>
      SyncUnitOfMeasure(
        unitOfMeasureId: json['unitOfMeasureId'] as int? ?? 0,
        nameEn: json['nameEn'] as String? ?? '',
        nameAr: json['nameAr'] as String? ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        factor: (json['factor'] as num?)?.toDouble() ?? 1.0,
        priceListId: json['priceListId'] as int? ?? 0,
        priceListNameEn: json['priceListNameEn'] as String?,
        priceListNameAr: json['priceListNameAr'] as String?,
      );
}

// ---------------------------------------------------------------------------
// SyncVariationValue
// ---------------------------------------------------------------------------

class SyncVariationValue {
  final VariationValueEntity value;
  final List<VariationValueTranslationEntity> translations;
  final List<VariationValueTranslationPricingEntity> pricing;

  const SyncVariationValue({
    required this.value,
    required this.translations,
    required this.pricing,
  });

  VariationValueTranslationEntity? get translationEn =>
      translations.where((t) => t.languageId == 1).firstOrNull;

  VariationValueTranslationEntity? get translationAr =>
      translations.where((t) => t.languageId == 2).firstOrNull;

  Map<String, dynamic> toJson() => {
        'value': value.toJson(),
        'translations': translations.map((t) => t.toJson()).toList(),
        'pricing': pricing.map((p) => p.toJson()).toList(),
      };

  factory SyncVariationValue.fromJson(Map<String, dynamic> json) =>
      SyncVariationValue(
        value: VariationValueEntity.fromJson(
            json['value'] as Map<String, dynamic>),
        translations: (json['translations'] as List? ?? [])
            .map((t) => VariationValueTranslationEntity.fromJson(
                t as Map<String, dynamic>))
            .toList(),
        pricing: (json['pricing'] as List? ?? [])
            .map((p) => VariationValueTranslationPricingEntity.fromJson(
                p as Map<String, dynamic>))
            .toList(),
      );
}

// ---------------------------------------------------------------------------
// SyncVariant
// ---------------------------------------------------------------------------

class SyncVariant {
  final int variantId;

  /// Metadata from VariantTableElementTable: isRequired, minSelections,
  /// maxSelections, pricingRule, allowMultipleQuantitiesPerModifier, etc.
  final VariantTableElementEntity? variantConfig;

  /// Variant group name translations (En + Ar via languageId 1/2)
  final List<VariantTranslationElementEntity> translations;

  /// All option values with their translations and pricing
  final List<SyncVariationValue> values;

  const SyncVariant({
    required this.variantId,
    this.variantConfig,
    required this.translations,
    required this.values,
  });

  VariantTranslationElementEntity? get translationEn =>
      translations.where((t) => t.languageId == 1).firstOrNull;

  VariantTranslationElementEntity? get translationAr =>
      translations.where((t) => t.languageId == 2).firstOrNull;

  bool get isRequired => variantConfig?.isRequired ?? false;
  int get minSelections => variantConfig?.minSelections ?? 0;
  int get maxSelections => variantConfig?.maxSelections ?? 0;

  Map<String, dynamic> toJson() => {
        'variantId': variantId,
        'variantConfig': variantConfig?.toJson(),
        'translations': translations.map((t) => t.toJson()).toList(),
        'values': values.map((v) => v.toJson()).toList(),
      };

  factory SyncVariant.fromJson(Map<String, dynamic> json) => SyncVariant(
        variantId: json['variantId'] as int? ?? 0,
        variantConfig: json['variantConfig'] != null
            ? VariantTableElementEntity.fromJson(
                json['variantConfig'] as Map<String, dynamic>)
            : null,
        translations: (json['translations'] as List? ?? [])
            .map((t) => VariantTranslationElementEntity.fromJson(
                t as Map<String, dynamic>))
            .toList(),
        values: (json['values'] as List? ?? [])
            .map((v) =>
                SyncVariationValue.fromJson(v as Map<String, dynamic>))
            .toList(),
      );
}

// ---------------------------------------------------------------------------
// SyncComboMealInfo
// ---------------------------------------------------------------------------

class SyncComboMealInfo {
  final bool isComboMeal;

  /// ComboMealDefinition.comboMealPackageId list ordered by definition order
  final List<int> comboMealPackageIds;

  const SyncComboMealInfo({
    required this.isComboMeal,
    this.comboMealPackageIds = const [],
  });

  static const empty = SyncComboMealInfo(isComboMeal: false);

  Map<String, dynamic> toJson() => {
        'isComboMeal': isComboMeal,
        'comboMealPackageIds': comboMealPackageIds,
      };

  factory SyncComboMealInfo.fromJson(Map<String, dynamic> json) =>
      SyncComboMealInfo(
        isComboMeal: json['isComboMeal'] as bool? ?? false,
        comboMealPackageIds: (json['comboMealPackageIds'] as List? ?? [])
            .map((id) => id as int)
            .toList(),
      );
}

// ---------------------------------------------------------------------------
// SyncProduct
// ---------------------------------------------------------------------------

class SyncProduct {
  /// API id from MenuItemFBEntity
  final int id;
  final int tenantId;
  final int mainGroupId;
  final int materialGroupId;
  final int productCategoryId;
  final String? itemCode;
  final String nameEn;
  final String nameAr;
  final SyncCategory? category;
  final String? imageId;
  final bool openPrice;
  final bool hasTobaccoTax;
  final int? menuItemConfigId;
  final bool isComboMealDefinitionItem;
  final bool isShowInPlugIn;
  final bool isHoteSaleing;
  final int? levelId;
  final String? barcode1;
  final String? barcode2;
  final String? numberOfCalories;
  final String? numberOfSteps;
  final bool? allowDecimal;
  final String? startUsageDate;
  final String? endUsageDate;

  /// taxId from MenuItemTaxTable (taxValue/isExclusive resolved from future tax rates table)
  final int? taxId;

  /// Defaults to 0 until a tax-rates table is created
  final double taxValue;

  /// Defaults to false until a tax-rates table is created
  final bool isExclusive;

  /// Units built from MenuItemPriceListTable + UnitOfMeasureTranslationTable
  final List<SyncUnitOfMeasure> unitOfMeasures;

  /// Variant groups with their values and pricing
  final List<SyncVariant> variants;

  /// Combo meal flag and package IDs
  final SyncComboMealInfo comboMealInfo;

  const SyncProduct({
    required this.id,
    required this.tenantId,
    this.mainGroupId = 0,
    this.materialGroupId = 0,
    required this.productCategoryId,
    this.itemCode,
    required this.nameEn,
    required this.nameAr,
    this.category,
    this.imageId,
    this.openPrice = false,
    this.hasTobaccoTax = false,
    this.menuItemConfigId,
    this.isComboMealDefinitionItem = false,
    this.isShowInPlugIn = false,
    this.isHoteSaleing = false,
    this.levelId,
    this.barcode1,
    this.barcode2,
    this.numberOfCalories,
    this.numberOfSteps,
    this.allowDecimal,
    this.startUsageDate,
    this.endUsageDate,
    this.taxId,
    this.taxValue = 0.0,
    this.isExclusive = false,
    this.unitOfMeasures = const [],
    this.variants = const [],
    this.comboMealInfo = SyncComboMealInfo.empty,
  });

  // Convenience getters
  bool get hasVariants => variants.isNotEmpty;
  bool get isComboMeal => comboMealInfo.isComboMeal;
  bool get hasMultipleUnits => unitOfMeasures.length > 1;
  bool get hasOptions => hasVariants || hasMultipleUnits;

  /// imageId as string for use with image URL builder
  String get imageUrl => imageId?.toString() ?? '';

  /// productId as string for compatibility with cart and existing widgets
  String get productId => id.toString();

  Map<String, dynamic> toJson() => {
        'id': id,
        'tenantId': tenantId,
        'mainGroupId': mainGroupId,
        'materialGroupId': materialGroupId,
        'productCategoryId': productCategoryId,
        'itemCode': itemCode,
        'nameEn': nameEn,
        'nameAr': nameAr,
        'category': category?.toJson(),
        'imageId': imageId,
        'openPrice': openPrice,
        'hasTobaccoTax': hasTobaccoTax,
        'menuItemConfigId': menuItemConfigId,
        'isComboMealDefinitionItem': isComboMealDefinitionItem,
        'isShowInPlugIn': isShowInPlugIn,
        'isHoteSaleing': isHoteSaleing,
        'levelId': levelId,
        'barcode1': barcode1,
        'barcode2': barcode2,
        'numberOfCalories': numberOfCalories,
        'numberOfSteps': numberOfSteps,
        'allowDecimal': allowDecimal,
        'startUsageDate': startUsageDate,
        'endUsageDate': endUsageDate,
        'taxId': taxId,
        'taxValue': taxValue,
        'isExclusive': isExclusive,
        'unitOfMeasures': unitOfMeasures.map((u) => u.toJson()).toList(),
        'variants': variants.map((v) => v.toJson()).toList(),
        'comboMealInfo': comboMealInfo.toJson(),
      };

  factory SyncProduct.fromJson(Map<String, dynamic> json) => SyncProduct(
        id: json['id'] as int? ?? 0,
        tenantId: json['tenantId'] as int? ?? 0,
        mainGroupId: json['mainGroupId'] as int? ?? 0,
        materialGroupId: json['materialGroupId'] as int? ?? 0,
        productCategoryId: json['productCategoryId'] as int? ?? 0,
        itemCode: json['itemCode'] as String?,
        nameEn: json['nameEn'] as String? ?? '',
        nameAr: json['nameAr'] as String? ?? '',
        category: json['category'] != null
            ? SyncCategory.fromJson(json['category'] as Map<String, dynamic>)
            : null,
        imageId: json['imageId'] as String?,
        openPrice: json['openPrice'] as bool? ?? false,
        hasTobaccoTax: json['hasTobaccoTax'] as bool? ?? false,
        menuItemConfigId: json['menuItemConfigId'] as int?,
        isComboMealDefinitionItem:
            json['isComboMealDefinitionItem'] as bool? ?? false,
        isShowInPlugIn: json['isShowInPlugIn'] as bool? ?? false,
        isHoteSaleing: json['isHoteSaleing'] as bool? ?? false,
        levelId: json['levelId'] as int?,
        barcode1: json['barcode1'] as String?,
        barcode2: json['barcode2'] as String?,
        numberOfCalories: json['numberOfCalories']  ,
        numberOfSteps: json['numberOfSteps'] ,
        allowDecimal: json['allowDecimal'] as bool?,
        startUsageDate: json['startUsageDate'] as String?,
        endUsageDate: json['endUsageDate'] as String?,
        taxId: json['taxId'] as int?,
        taxValue: (json['taxValue'] as num?)?.toDouble() ?? 0.0,
        isExclusive: json['isExclusive'] as bool? ?? false,
        unitOfMeasures: (json['unitOfMeasures'] as List? ?? [])
            .map((u) =>
                SyncUnitOfMeasure.fromJson(u as Map<String, dynamic>))
            .toList(),
        variants: (json['variants'] as List? ?? [])
            .map((v) => SyncVariant.fromJson(v as Map<String, dynamic>))
            .toList(),
        comboMealInfo: json['comboMealInfo'] != null
            ? SyncComboMealInfo.fromJson(
                json['comboMealInfo'] as Map<String, dynamic>)
            : SyncComboMealInfo.empty,
      );

  SyncProduct copyWith({
    List<SyncUnitOfMeasure>? unitOfMeasures,
    List<SyncVariant>? variants,
    SyncComboMealInfo? comboMealInfo,
    SyncCategory? category,
    double? taxValue,
    bool? isExclusive,
    int? taxId,
  }) =>
      SyncProduct(
        id: id,
        tenantId: tenantId,
        mainGroupId: mainGroupId,
        materialGroupId: materialGroupId,
        productCategoryId: productCategoryId,
        itemCode: itemCode,
        nameEn: nameEn,
        nameAr: nameAr,
        category: category ?? this.category,
        imageId: imageId,
        openPrice: openPrice,
        hasTobaccoTax: hasTobaccoTax,
        menuItemConfigId: menuItemConfigId,
        isComboMealDefinitionItem: isComboMealDefinitionItem,
        isShowInPlugIn: isShowInPlugIn,
        isHoteSaleing: isHoteSaleing,
        levelId: levelId,
        barcode1: barcode1,
        barcode2: barcode2,
        numberOfCalories: numberOfCalories,
        numberOfSteps: numberOfSteps,
        allowDecimal: allowDecimal,
        startUsageDate: startUsageDate,
        endUsageDate: endUsageDate,
        taxId: taxId ?? this.taxId,
        taxValue: taxValue ?? this.taxValue,
        isExclusive: isExclusive ?? this.isExclusive,
        unitOfMeasures: unitOfMeasures ?? this.unitOfMeasures,
        variants: variants ?? this.variants,
        comboMealInfo: comboMealInfo ?? this.comboMealInfo,
      );
}

// ---------------------------------------------------------------------------
// VariationWithPrice — helper used when building variation UI from SyncProduct
// ---------------------------------------------------------------------------

class VariationWithPrice {
  final VariationValueTranslationEntity variation;
  final VariationValueEntity variationValue;
  final List<VariationValueTranslationPricingEntity> pricingList;

  const VariationWithPrice({
    required this.variation,
    required this.variationValue,
    required this.pricingList,
  });

  Map<String, dynamic> toMap() => {
        'variation': variation.toJson(),
        'variationValue': variationValue.toJson(),
        'pricingList': pricingList.map((e) => e.toJson()).toList(),
      };

  factory VariationWithPrice.fromMap(Map<String, dynamic> map) =>
      VariationWithPrice(
        variation:
            VariationValueTranslationEntity.fromJson(map['variation'] as Map<String, dynamic>),
        variationValue:
            VariationValueEntity.fromJson(map['variationValue'] as Map<String, dynamic>),
        pricingList: (map['pricingList'] as List<dynamic>? ?? [])
            .map((e) =>
                VariationValueTranslationPricingEntity.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
