class SalesPayMethodModel {
  int? id;
  String nameEn;
  String nameAr;
  double amount;

  int tenderTypeId;
  String orderId; // New field
  String uniqueId; // New field
  String tenantId; // New field

  SalesPayMethodModel({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.amount,
    required this.tenderTypeId,
    required this.orderId, // New field in constructor
    required this.uniqueId, // New field in constructor
    required this.tenantId, // New field in constructor
  });

  factory SalesPayMethodModel.fromMap(Map<String, dynamic> json) => SalesPayMethodModel(
        id: json["id"],
        nameEn: json["nameEn"],
        nameAr: json["nameAr"],
        amount: json["amount"],
        tenantId: json["tenantId"],

        tenderTypeId: json["tenderTypeId"],
        orderId: json["orderId"], // New field in fromMap
        uniqueId: json["uniqueId"] ?? '', // New field in fromMap
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "nameEn": nameEn,
        "nameAr": nameAr,
        "amount": amount,

        "tenderTypeId": tenderTypeId,
        "orderId": orderId, // New field in toMap
        "uniqueId": uniqueId, // New field in toMap
        "tenantId": tenantId, // New field in toMap
      };
        Map<String, dynamic> toMapWithUniqueId(
      String saleTransactionId, int currencyId) {
    return {
      'TenantId': int.parse(tenantId),
      'CurrencyId': currencyId,
      'TenderTypeId': tenderTypeId,
      'SaleTransactionId': saleTransactionId,
      'Value': amount,
      'Id': uniqueId,
    };
  }

  Map<String, dynamic> toMapWithUniqueIdForRefund(
      String saleTransactionId, int currencyId) {
    return {
      'TenantId': int.parse(tenantId),
      'CurrencyId': currencyId,
      'TenderTypeId': tenderTypeId,
      'saleNotificationId': saleTransactionId,
      'Value': amount,
      'Id': uniqueId,
    };
  }
}
