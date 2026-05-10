enum DiscountType {
  percentage(1),
  fixedValue(0);

  final int value;

  const DiscountType(this.value);
}
