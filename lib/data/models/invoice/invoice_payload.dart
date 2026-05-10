import 'package:kiosk_point_of_sale/data/models/invoice/invoice_item.dart';

class InvoicePayload {
  final String invoiceType;
  final String datetime;
  final String invoiceNumber;
  final bool direct;
  final String isLink;
  final String vatNumber;
  final String phoneNumber;
  final String address;
  final List<InvoiceItem> items;
  final String totalPrice;
  final String totalDiscountValue;
  final String totalPriceAfterDiscount;
  final String totalVatValue;
  final String totalPriceWithVat;
  final List<InvoicePaymentMethod> paymentMethod;
  final String qrCode;

  const InvoicePayload({
    this.invoiceType = 'simplified_tax_invoice',
    required this.datetime,
    required this.invoiceNumber,
    this.direct = true,
    this.isLink = 'true',
    required this.vatNumber,
    required this.phoneNumber,
    required this.address,
    required this.items,
    required this.totalPrice,
    required this.totalDiscountValue,
    required this.totalPriceAfterDiscount,
    required this.totalVatValue,
    required this.totalPriceWithVat,
    required this.paymentMethod,
    required this.qrCode,
  });

  Map<String, dynamic> toJson() => {
        'invoice_type': invoiceType,
        'datetime': datetime,
        'invoice_number': invoiceNumber,
        'direct': direct,
        'is_link': isLink,
        'vat_number': vatNumber,
        'phone_number': phoneNumber,
        'address': address,
        'items': items.map((i) => i.toJson()).toList(),
        'total_price': totalPrice,
        'total_discount_value': totalDiscountValue,
        'total_price_after_discount': totalPriceAfterDiscount,
        'total_vat_value': totalVatValue,
        'total_price_with_vat': totalPriceWithVat,
        'payment_method': paymentMethod.map((p) => p.toJson()).toList(),
        'qr_code': qrCode,
      };
}
