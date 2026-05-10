class ZatcaInvoiceModel {
  final String receiptNumber;
  final double totalPrice;
  final double totalInLineDiscountValue;
  final double discountValue;
  final double totalPriceAfterDiscount;
  final double totalVatValue;
  final double totalPriceWithVat;
  final String issueDate;
  final String issueTime;
  final int icvuuid;
  final String uuid;
  final String encodedInvoice;
  final String invoiceHash;
  final String invoiceTypeCode;
  final String qrCode;
  final int statusId;
  final String? notValidReason;
  final int mode;
  final int templateType;
  final int paymentMethod;
  final int? customerId;
  final String? returnedFromTransactionId;
  final String notes;
  final String? customer;
  final List<ZatcaInvoiceItem> zatcaInvoiceItems;
  final List<dynamic>
      zatcaInvoiceDiscounts; // Assuming this contains unknown discount objects
  final String id;

  ZatcaInvoiceModel({
    required this.receiptNumber,
    required this.totalPrice,
    required this.totalInLineDiscountValue,
    required this.discountValue,
    required this.totalPriceAfterDiscount,
    required this.totalVatValue,
    required this.totalPriceWithVat,
    required this.issueDate,
    required this.issueTime,
    required this.icvuuid,
    required this.uuid,
    required this.encodedInvoice,
    required this.invoiceHash,
    required this.invoiceTypeCode,
    required this.qrCode,
    required this.statusId,
    this.notValidReason,
    required this.mode,
    required this.templateType,
    required this.paymentMethod,
    this.customerId,
    this.returnedFromTransactionId,
    required this.notes,
    this.customer,
    required this.zatcaInvoiceItems,
    required this.zatcaInvoiceDiscounts,
    required this.id,
  });

  factory ZatcaInvoiceModel.fromJson(Map<String, dynamic> json) {
    return ZatcaInvoiceModel(
      receiptNumber: json['receiptNumber'],
      totalPrice: json['totalPrice'],
      totalInLineDiscountValue: json['totalInLineDiscountValue'],
      discountValue: json['discountValue'],
      totalPriceAfterDiscount: json['totalPriceAfterDiscount'],
      totalVatValue: json['totalVatValue'],
      totalPriceWithVat: json['totalPriceWithVat'],
      issueDate: json['issueDate'],
      issueTime: json['issueTime'],
      icvuuid: json['icvuuid'],
      uuid: json['uuid'],
      encodedInvoice: json['encodedInvoice'],
      invoiceHash: json['invoiceHash'],
      invoiceTypeCode: json['invoiceTypeCode'],
      qrCode: json['qrCode'],
      statusId: json['statusId'],
      notValidReason: json['notValidReason'],
      mode: json['mode'],
      templateType: json['templateType'],
      paymentMethod: json['paymentMethod'],
      customerId: json['customerId'],
      returnedFromTransactionId: json['returnedFromTransactionId'],
      notes: json['notes'],
      customer: json['customer'],
      zatcaInvoiceItems: (json['zatcaInvoiceItems'] as List)
          .map((item) => ZatcaInvoiceItem.fromJson(item))
          .toList(),
      zatcaInvoiceDiscounts: json['zatcaInvoiceDiscounts'] ?? [],
      id: json['id'],
    );
  }
}

class InvoiceTypeCode {
  final int id;
  final String name;

  InvoiceTypeCode({
    required this.id,
    required this.name,
  });

  factory InvoiceTypeCode.fromJson(Map<String, dynamic> json) {
    return InvoiceTypeCode(
      id: json['id'],
      name: json['Name'],
    );
  }
}

class ZatcaInvoiceItem {
  final String productName;
  final double productPrice;
  final double productQuantity;
  final double totalPrice;
  final double discountValue;
  final double totalPriceAfterDiscount;
  final double vatPercentage;
  final double vatValue;
  final double totalWithVat;
  final String id;

  ZatcaInvoiceItem({
    required this.productName,
    required this.productPrice,
    required this.productQuantity,
    required this.totalPrice,
    required this.discountValue,
    required this.totalPriceAfterDiscount,
    required this.vatPercentage,
    required this.vatValue,
    required this.totalWithVat,
    required this.id,
  });

  factory ZatcaInvoiceItem.fromJson(Map<String, dynamic> json) {
    return ZatcaInvoiceItem(
      productName: json['productName'],
      productPrice: json['productPrice'],
      productQuantity: json['productQuantity'],
      totalPrice: json['totalPrice'],
      discountValue: json['discountValue'],
      totalPriceAfterDiscount: json['totalPriceAfterDiscount'],
      vatPercentage: json['vatPercentage'],
      vatValue: json['vatValue'],
      totalWithVat: json['totalWithVat'],
      id: json['id'],
    );
  }
}
