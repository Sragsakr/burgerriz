import 'package:kiosk_point_of_sale/data/models/promotions/models/promotion_fb_store_model.dart';

class PromotionsFBTableModel {
  final int tenantId;
  final int promotionType;
  final int templateType;
  final String name;
  final double? highestValue;
  final double lowestValue;
  final double value;
  final int valueType;
  final bool isTotalInvoice;
  final bool isNextInvoice;
  final double invoiceAmount;
  final int validForDays;
  final bool isShowInPlugIn;
  List<PromotionFBStoreModel> promotionFBStores;
  final bool isDeleted;
  final int? deleterUserId;
  final DateTime? deletionTime;
  final DateTime? lastModificationTime;
  final int? lastModifierUserId;
  final DateTime creationTime;
  final int creatorUserId;
  final int id;
  int? tableId;

  PromotionsFBTableModel({
    required this.tenantId,
    required this.promotionType,
    required this.templateType,
    required this.name,
    this.highestValue,
    required this.lowestValue,
    required this.value,
    required this.valueType,
    required this.isTotalInvoice,
    required this.isNextInvoice,
    required this.invoiceAmount,
    required this.validForDays,
    required this.isShowInPlugIn,
    required this.promotionFBStores,
    required this.isDeleted,
    this.deleterUserId,
    this.deletionTime,
    this.lastModificationTime,
    this.lastModifierUserId,
    required this.creationTime,
    required this.creatorUserId,
    required this.id,
    this.tableId,
  });

  factory PromotionsFBTableModel.fromJson(Map<String, dynamic> json) {
    return PromotionsFBTableModel(
      tableId: json['tableId'],
      tenantId: json['tenantId'] as int,
      promotionType: json['promotionType'] as int,
      templateType: json['templateType'] as int,
      name: json['name'] as String,
      highestValue: (json['highestValue'] as num?)?.toDouble(),
      lowestValue: (json['lowestValue'] as num).toDouble(),
      value: (json['value'] as num).toDouble(),
      valueType: json['valueType'] as int,
      isTotalInvoice: (json['isTotalInvoice'] is bool)
          ? json['isTotalInvoice']
          : (json['isTotalInvoice'] as int) == 1,
      isNextInvoice: (json['isNextInvoice'] is bool)
          ? json['isNextInvoice']
          : (json['isNextInvoice'] as int) == 1,
      invoiceAmount: (json['invoiceAmount'] as num).toDouble(),
      validForDays: json['validForDays'] as int,
      isShowInPlugIn: (json['isShowInPlugIn'] is bool)
          ? json['isShowInPlugIn']
          : (json['isShowInPlugIn'] as int) == 1,
      promotionFBStores: [],
      isDeleted: (json['isDeleted'] is bool)
          ? json['isDeleted']
          : (json['isDeleted'] as int) == 1,
      deleterUserId: json['deleterUserId'] as int?,
      deletionTime: json['deletionTime'] != null
          ? DateTime.parse(json['deletionTime'] as String)
          : null,
      lastModificationTime: json['lastModificationTime'] != null
          ? DateTime.parse(json['lastModificationTime'] as String)
          : null,
      lastModifierUserId: json['lastModifierUserId'] as int?,
      creationTime: DateTime.parse(json['creationTime'] as String),
      creatorUserId:
          json['creatorUserId'] != null ? json['creatorUserId'] as int : 0,
      id: json['id'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (tableId != null) 'tableId': tableId,
      'tenantId': tenantId,
      'promotionType': promotionType,
      'templateType': templateType,
      'name': name,
      if (highestValue != null) 'highestValue': highestValue,
      'lowestValue': lowestValue,
      'value': value,
      'valueType': valueType,
      'isTotalInvoice': isTotalInvoice ? 1 : 0,
      'isNextInvoice': isNextInvoice ? 1 : 0,
      'invoiceAmount': invoiceAmount,
      'validForDays': validForDays,
      'isShowInPlugIn': isShowInPlugIn ? 1 : 0,
      'promotionFBStores': promotionFBStores.map((e) => e.toJson()).toList(),
      'isDeleted': isDeleted ? 1 : 0,
      'deleterUserId': deleterUserId,
      if (deletionTime != null) 'deletionTime': deletionTime!.toIso8601String(),
      if (lastModificationTime != null)
        'lastModificationTime': lastModificationTime!.toIso8601String(),
      'lastModifierUserId': lastModifierUserId,
      'creationTime': creationTime.toIso8601String(),
      'creatorUserId': creatorUserId,
      'id': id,
    }..removeWhere((key, value) => value == null);
  }
}
