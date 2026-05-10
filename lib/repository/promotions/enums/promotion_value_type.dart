enum PromotionIValueType {
  discountPercentage(1),
  discountValue(2),

  specificValue(3),
  specificValueWithFreeProduct(5);

  final int value;
  const PromotionIValueType(this.value);
}

extension PromotionIValueTypeExtension on PromotionIValueType {
  /// Returns the numeric value of the enum
  int get intValue => value;

  /// Returns enum from int
  static PromotionIValueType? fromValue(int value) {
    return PromotionIValueType.values.firstWhere(
      (e) => e.value == value,
      orElse: () =>
          throw ArgumentError('Invalid PromotionIValueType value: $value'),
    );
  }
}
