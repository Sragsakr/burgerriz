enum PromotionType {
  productsOrCategories(1),
  invoiceAmount(2),
  disCountVoucher(3),
  giftVoucher(4),
  simplePromotion(5),
  highestAndTheLowestPrice(6);

  final int value;
  const PromotionType(this.value);
}

extension PromotionTypeExtension on PromotionType {
  /// Returns the numeric value of the enum
  int get intValue => value;

  /// Returns a readable name
  String get displayName {
    switch (this) {
      case PromotionType.productsOrCategories:
        return 'Products or Categories';
      case PromotionType.invoiceAmount:
        return 'Invoice Amount';
      case PromotionType.disCountVoucher:
        return 'Discount Voucher';
      case PromotionType.giftVoucher:
        return 'Gift Voucher';
      case PromotionType.simplePromotion:
        return 'Simple Promotion';
      case PromotionType.highestAndTheLowestPrice:
        return 'Highest and Lowest Price';
    }
  }

  /// Returns enum from int
  static PromotionType? fromValue(int value) {
    return PromotionType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw ArgumentError('Invalid PromotionType value: $value'),
    );
  }
}
