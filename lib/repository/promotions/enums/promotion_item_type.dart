enum PromotionItemType {
  productCategory(1),
  menuItem(0);

  final int value;
  const PromotionItemType(this.value);
}

extension PromotionItemTypeExtension on PromotionItemType {
  /// Returns the numeric value of the enum
  int get intValue => value;

  /// Returns enum from int
  static PromotionItemType? fromValue(int value) {
    return PromotionItemType.values.firstWhere(
      (e) => e.value == value,
      orElse: () =>
          throw ArgumentError('Invalid PromotionItemType value: $value'),
    );
  }
}
