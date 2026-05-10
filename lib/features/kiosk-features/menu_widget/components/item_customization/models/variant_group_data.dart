import 'package:kiosk_point_of_sale/data/models/menu_item/selected_variant.dart';

/// Safely parses a value that could be a Dart [bool] or an SQLite int (0/1).
bool _parseBool(dynamic value) {
  if (value is bool) return value;
  if (value is int) return value == 1;
  return false;
}

/// One group row built from the raw variant map returned by
/// [MenuItemSyncRepository.fetchMenuItemVariants].
class VariantGroupData {
  final int variantId;
  final String nameEn;
  final String nameAr;
  final bool isModifier;
  final bool isAdd;
  final bool isRequired;
  final int minSelections;
  final int maxSelections;
  final int pricingRule;
  final int pricingRuleFreeItemsCount;
  final bool allowMultipleQuantitiesPerModifier;
  final int maxQtyPerModifier;
  final int periorty;
  final List<VariantValueOption> values;

  const VariantGroupData({
    required this.variantId,
    required this.nameEn,
    required this.nameAr,
    required this.isModifier,
    required this.isAdd,
    required this.isRequired,
    required this.minSelections,
    required this.maxSelections,
    required this.pricingRule,
    required this.pricingRuleFreeItemsCount,
    required this.allowMultipleQuantitiesPerModifier,
    required this.maxQtyPerModifier,
    required this.periorty,
    required this.values,
  });

  /// Sort comparator: lower priority number = higher priority; 0 = shown last.
  static int compareByPriority(VariantGroupData a, VariantGroupData b) {
    final pa = a.periorty == 0 ? 999999 : a.periorty;
    final pb = b.periorty == 0 ? 999999 : b.periorty;
    return pa.compareTo(pb);
  }

  factory VariantGroupData.fromMap(Map<String, dynamic> map) {
    final translations = (map['translations'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    final enTrans = translations.firstWhere(
      (t) => t['languageId'] == 1,
      orElse: () => translations.isNotEmpty ? translations.first : {'name': ''},
    );
    final arTrans = translations.firstWhere(
      (t) => t['languageId'] == 2,
      orElse: () => translations.isNotEmpty ? translations.first : {'name': ''},
    );

    final rawValues = map['values'] as List<dynamic>? ?? [];
    final values = rawValues.map((v) => VariantValueOption.fromMap(v as Map<String, dynamic>)).toList();

    return VariantGroupData(
      variantId: map['variantId'] as int? ?? 0,
      nameEn: enTrans['name'] as String? ?? '',
      nameAr: arTrans['name'] as String? ?? '',
      isModifier: _parseBool(map['isModifier']),
      isAdd: _parseBool(map['isAdd']),
      isRequired: _parseBool(map['isRequired']),
      minSelections: map['minSelections'] as int? ?? 0,
      maxSelections: map['maxSelections'] as int? ?? 0,
      pricingRule: map['pricingRule'] as int? ?? 0,
      pricingRuleFreeItemsCount: map['pricingRuleFreeItemsCount'] as int? ?? 0,
      allowMultipleQuantitiesPerModifier: _parseBool(map['allowMultipleQuantitiesPerModifier']),
      maxQtyPerModifier: map['maxQtyPerModifier'] as int? ?? 0,
      periorty: map['periorty'] as int? ?? 0,
      values: values,
    );
  }
}

/// One selectable option within a [VariantGroupData].
class VariantValueOption {
  final int variantValueId;
  final int variantId;
  final String nameEn;
  final String nameAr;
  final double price;
  final double priceIncludingVAT;
  final bool isDefault;

  const VariantValueOption({
    required this.variantValueId,
    required this.variantId,
    required this.nameEn,
    required this.nameAr,
    required this.price,
    this.priceIncludingVAT = 0.0,
    this.isDefault = false,
  });

  factory VariantValueOption.fromMap(Map<String, dynamic> map) {
    final translations = (map['translations'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    final pricing = map['pricing'] as List<dynamic>? ?? [];

    final enTrans = translations.firstWhere(
      (t) => t['languageId'] == 1,
      orElse: () => translations.isNotEmpty ? translations.first : {'name': ''},
    );
    final arTrans = translations.firstWhere(
      (t) => t['languageId'] == 2,
      orElse: () => translations.isNotEmpty ? translations.first : {'name': ''},
    );

    final firstPricing = pricing.isNotEmpty ? pricing.first as Map<String, dynamic> : null;
    final rawPrice = (firstPricing?['price'] as num?)?.toDouble() ?? 0.0;

    return VariantValueOption(
      variantValueId: map['variantValueId'] as int? ?? 0,
      variantId: map['variantId'] as int? ?? 0,
      nameEn: enTrans['name'] as String? ?? '',
      nameAr: arTrans['name'] as String? ?? '',
      price: rawPrice,
      priceIncludingVAT: rawPrice,
      isDefault: _parseBool(map['isDefault']),
    );
  }

  SelectedVariant toSelectedVariant({
    bool isFree = false,
    double quantity = 1.0,
    String groupNameEn = '',
    String groupNameAr = '',
    bool isModifier = false,
    bool isAdd = true,
  }) =>
      SelectedVariant(
        variantId: variantId,
        variantValueId: variantValueId,
        nameEn: nameEn,
        nameAr: nameAr,
        groupNameEn: groupNameEn,
        groupNameAr: groupNameAr,
        modifierNatureEn: isModifier ? (isAdd ? 'Add' : 'Without') : '',
        modifierNatureAr: isModifier ? (isAdd ? 'إضافة' : 'بدون') : '',
        isModifier: isModifier,
        price: price,
        isFree: isFree,
        quantity: quantity,
      );
}
