class SalesOrderModel {
  int? id;

  // int? invoiceId2; // for table
  String? invoiceId;
  String orderNumber;
  String? receiptNumber;
  String? refReceiptNumber;
  String createdAt;
  String workDate;
  String updatedAt;
  String deletedAt;
  String totalAmount;
  String subTotal;
  String tax;
  String? totalAmountBeforeDiscount;
  String? subTotalBeforeDiscount;
  String? taxBeforeDiscount;
  String note;
  int isRefund;
  int haveRefund;
  String userId;
  int cashierShiftId;
  String tenantId;

  String? refSaleTransactionModelId;
  String customerPhone;
  int isBackOfficeSync;
  int isZactaSync;
  int paymentMethod;
  int saleTypeId;
  String? zatcaReturnedFromTransactionId;

  // discounts
  int? discountType;
  double? discountValue;
  double? discount;
  double? discountAmount;

  String uuid;
  String cashierName;
  String? saleNotificationDetailId;
  String? refundResonId;

  ///////////////////
  String? promotionCode; // New field
  int? promotionType; // New field
  double? promotionValue; // New field
  int? promotionId; // New field
  double? promotionAmount; // New field
  double? change; // New field
  String? promotionName; // New field for promotion name
  String? customerId;
  SalesOrderModel({
    required this.id,
    this.change,
    this.customerId,
    this.discountType,
    this.discountAmount,
    this.discountValue,
    this.discount,
    this.invoiceId,
    this.receiptNumber,
    this.refReceiptNumber,
    this.refSaleTransactionModelId,
    required this.orderNumber,
    required this.saleTypeId,
    required this.createdAt,
    required this.updatedAt,
    required this.cashierName,
    required this.deletedAt,
    required this.workDate,
    required this.totalAmount,
    required this.totalAmountBeforeDiscount,
    required this.note,
    required this.isRefund,
    required this.haveRefund,
    required this.userId,
    required this.tenantId,
    required this.uuid,
    required this.tax,
    required this.subTotal,
    required this.taxBeforeDiscount,
    required this.subTotalBeforeDiscount,
    required this.cashierShiftId,
    required this.customerPhone,
    required this.isBackOfficeSync,
    required this.isZactaSync,
    required this.paymentMethod,
    this.saleNotificationDetailId,
    this.refundResonId,
    this.zatcaReturnedFromTransactionId,
    this.promotionCode,
    this.promotionType,
    this.promotionValue,
    this.promotionAmount,
    this.promotionName,
    /////////////////
  });

  factory SalesOrderModel.fromMap(Map<String, dynamic> json) => SalesOrderModel(
        id: json["id"],
        // invoiceId2: json["invoiceId2"],
        invoiceId: json["invoiceId"],
        change: json["change"],
        customerId: json["customerId"],
        refundResonId: json["refundResonId"],
        saleNotificationDetailId: json["saleNotificationDetailId"],
        refReceiptNumber: json["refReceiptNumber"],
        receiptNumber: json["receiptNumber"],
        saleTypeId: json["saleTypeId"],
        createdAt: json["createdAt"],
        cashierName: json["cashierName"] ?? '',
        updatedAt: json["updatedAt"],
        deletedAt: json["deletedAt"],
        totalAmount: json["totalAmount"],
        totalAmountBeforeDiscount: json["totalAmountBeforeDiscount"],
        note: json["note"],
        isRefund: json["isRefund"],
        haveRefund: json["haveRefund"],
        userId: json["userId"],
        tenantId: json["tenantId"],
        workDate: json["workDate"] ?? '',
        refSaleTransactionModelId: json["refSaleTransactionModelId"] ?? '',
        taxBeforeDiscount: json["taxBeforeDiscount"].toString(),
        tax: json["tax"].toString(),
        subTotal: json["subTotal"].toString(),
        subTotalBeforeDiscount: json["subTotalBeforeDiscount"].toString(),
        uuid: json["uuid"],
        cashierShiftId: json["cashierShiftId"],
        // encodedInvoice: json["encodedInvoice"],
        orderNumber: json["orderNumber"] ?? '',
        customerPhone: json["userPhone"] ?? '',
        zatcaReturnedFromTransactionId: json["returnedFromTransactionId"],
        isBackOfficeSync: json["isBackOfficeSync"] ?? 0,
        isZactaSync: json["isZactaSync"] ?? 0,

        paymentMethod: json["paymentMethod"] ?? 0,
        discountType: json["discountType"],
        discountValue: json["discountValue"],
        discount: json['discount'] != null
            ? (json['discount'] as num).toDouble()
            : null,
        discountAmount: json["discountAmount"],
        promotionCode: json['promotionCode'],
        promotionType: json['promotionType'],
        promotionValue: json['promotionValue'],
        promotionAmount: json['promotionAmount'],
        promotionName: json['promotionName'],
      );

  Map<String, dynamic> toMap() => {
        if (id != null) "id": id,
        // "invoiceId2": invoiceId2,
        "invoiceId": invoiceId,
        "change": change,
        "refundResonId": refundResonId,
        "refReceiptNumber": refReceiptNumber,
        "orderNumber": orderNumber,
        "saleNotificationDetailId": saleNotificationDetailId,
        "receiptNumber": receiptNumber,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
        "deletedAt": deletedAt,
        "saleTypeId": saleTypeId,
        "refSaleTransactionModelId": refSaleTransactionModelId,
        "workDate": workDate,
        "totalAmount": totalAmount,
        "totalAmountBeforeDiscount": totalAmountBeforeDiscount,
        "note": note,
        "customerId": customerId,
        "isRefund": isRefund,
        "haveRefund": haveRefund,
        "cashierName": cashierName,
        "userId": userId,
        "tenantId": tenantId,

        "uuid": uuid,
        "cashierShiftId": cashierShiftId,
        "userPhone": customerPhone,
        "returnedFromTransactionId": zatcaReturnedFromTransactionId,
        "isBackOfficeSync": isBackOfficeSync,
        "isZactaSync": isZactaSync,

        "discount": discount,
        "discountType": discountType,
        "discountAmount": discountAmount,
        "discountValue": discountValue,
        "tax": tax,
        "taxBeforeDiscount": taxBeforeDiscount,
        "subTotal": subTotal,
        "subTotalBeforeDiscount": subTotalBeforeDiscount,
        'promotionCode': promotionCode, // New field in toMap
        'promotionType': promotionType, // New field in toMap
        'promotionValue': promotionValue, // New field in toMap
        'promotionAmount': promotionAmount, // New field in toMap
        'promotionName': promotionName, // New field in toMap
      };
}
