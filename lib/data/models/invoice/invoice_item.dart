class InvoiceVariation {
  final String variationName;
  final String variationNameAr;
  final String variationPrice;

  const InvoiceVariation({
    required this.variationName,
    required this.variationNameAr,
    required this.variationPrice,
  });

  Map<String, dynamic> toJson() => {
        'variation_name': variationName,
        'variation_name_ar': variationNameAr,
        'variation_price': variationPrice,
      };
}

class InvoiceItem {
  final String productName;
  final String productNameAr;
  final String productPrice;
  final int productQuantity;
  final List<InvoiceVariation> variations;
  final String totalPrice;
  final String discountValue;
  final String totalPriceAfterDiscount;
  final String vatPercentage;
  final String vatValue;
  final String totalWithVat;

  const InvoiceItem({
    required this.productName,
    required this.productNameAr,
    required this.productPrice,
    required this.productQuantity,
    this.variations = const [],
    required this.totalPrice,
    required this.discountValue,
    required this.totalPriceAfterDiscount,
    required this.vatPercentage,
    required this.vatValue,
    required this.totalWithVat,
  });

  Map<String, dynamic> toJson() => {
        'product_name': productName,
        'product_name_ar': productNameAr,
        'product_price': productPrice,
        'product_quantity': productQuantity,
        if (variations.isNotEmpty)
          'variations': variations.map((v) => v.toJson()).toList(),
        'total_price': totalPrice,
        'discount_value': discountValue,
        'total_price_after_discount': totalPriceAfterDiscount,
        'vat_percentage': vatPercentage,
        'vat_value': vatValue,
        'total_with_vat': totalWithVat,
      };
}

class InvoicePaymentMethod {
  final String title;
  final String amount;

  const InvoicePaymentMethod({
    required this.title,
    required this.amount,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'amount': amount,
      };
}
