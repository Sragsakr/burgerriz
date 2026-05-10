enum PromotionTemplateType {
  auto(2),
  button(3),
  code(1);

  final int value;
  const PromotionTemplateType(this.value);
}

extension PromotionTemplateTypeExtension on PromotionTemplateType {
  /// Returns the numeric value of the enum
  int get intValue => value;

 

  /// Returns enum from int
  static PromotionTemplateType? fromValue(int value) {
    return PromotionTemplateType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw ArgumentError('Invalid PromotionItemType value: $value'),
    );
  }
}
