import 'package:intl/intl.dart';
import 'package:kiosk_point_of_sale/core/constants/qr_invoice_constants.dart';
import 'package:kiosk_point_of_sale/data/models/invoice/invoice_item.dart';
import 'package:kiosk_point_of_sale/data/models/invoice/invoice_payload.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_invoice.dart';

class QrInvoiceMapper {
  static InvoicePayload buildPayload(SalesInvoice invoice) {
    final order = invoice.salesOrderModel;
    const vatPercent = QrInvoiceConstants.defaultVatPercentage;

    final now = DateTime.now();
    final dateTimeStr = DateFormat("yyyy-MM-dd'T'HH:mm").format(now);
    final invoiceNumber = order.receiptNumber != null
        ? 'INV-${order.receiptNumber}'
        : 'INV-${now.millisecondsSinceEpoch}';

    final invoiceItems = invoice.salesOrderItems.map((item) {
      final price = double.tryParse(item.price) ?? 0.0;
      final qty = int.tryParse(item.quantity) ?? 1;
      final total = double.tryParse(item.total) ?? (price * qty);
      final discount = item.discount ?? 0.0;
      final totalAfterDiscount = total - discount;
      final vatValue =
          double.tryParse(item.tax) ?? (totalAfterDiscount * vatPercent / 100);
      final totalWithVat = totalAfterDiscount + vatValue;

      final variations = item.variations
              ?.map((v) => InvoiceVariation(
                    variationName: (v['variationNameEn'] ?? '').toString(),
                    variationNameAr: (v['variationNameAr'] ?? '').toString(),
                    variationPrice: (v['variationPrice'] ?? '0.00').toString(),
                  ))
              .toList() ??
          [];

      return InvoiceItem(
        productName: item.productNameEn,
        productNameAr: item.productNameAr,
        productPrice: price.toStringAsFixed(2),
        productQuantity: qty,
        variations: variations,
        totalPrice: total.toStringAsFixed(2),
        discountValue: discount.toStringAsFixed(2),
        totalPriceAfterDiscount: totalAfterDiscount.toStringAsFixed(2),
        vatPercentage: vatPercent.toStringAsFixed(2),
        vatValue: vatValue.toStringAsFixed(2),
        totalWithVat: totalWithVat.toStringAsFixed(2),
      );
    }).toList();

    final paymentMethods = invoice.salesOrderPayMethods
        .map((p) => InvoicePaymentMethod(
              title: p.nameEn,
              amount: p.amount.toStringAsFixed(2),
            ))
        .toList();

    final subtotal = double.tryParse(order.subTotal) ?? 0.0;
    final tax = double.tryParse(order.tax) ?? 0.0;
    final total = double.tryParse(order.totalAmount) ?? 0.0;
    final discount = order.discountAmount ?? 0.0;

    return InvoicePayload(
      datetime: dateTimeStr,
      invoiceNumber: invoiceNumber,
      vatNumber: QrInvoiceConstants.defaultVatNumber,
      phoneNumber: QrInvoiceConstants.defaultPhoneNumber,
      address: QrInvoiceConstants.defaultAddress,
      items: invoiceItems,
      totalPrice: subtotal.toStringAsFixed(2),
      totalDiscountValue: discount.toStringAsFixed(2),
      totalPriceAfterDiscount: (subtotal - discount).toStringAsFixed(2),
      totalVatValue: tax.toStringAsFixed(2),
      totalPriceWithVat: total.toStringAsFixed(2),
      paymentMethod: paymentMethods,
      qrCode: QrInvoiceConstants.defaultQrCode,
    );
  }
}
