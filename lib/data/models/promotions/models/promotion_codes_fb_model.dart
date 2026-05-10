import 'package:kiosk_point_of_sale/data/models/promotions/models/promotions_details_fB_model.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/models/promotions_fB_table_model.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/tables/promotions_details_fB_table.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/tables/promotions_fB_table_table.dart';

class PromotionCodesFBModel {
  String? code;
  final int tenantId;
  final DateTime? fromDate;
  final DateTime? toDate;
  final bool isTiming;
  final bool iDuplicateQunatity;
  final String? fromTime;
  final String? toTime;
  final bool multi;
  final bool isActive;
  final int promotionFBId;
  final bool isDeleted;
  final int? deleterUserId;
  final DateTime? deletionTime;
  final DateTime? lastModificationTime;
  final int? lastModifierUserId;
  final DateTime? creationTime;
  final int? creatorUserId;
  final int id;
  int? tableId;

  PromotionCodesFBModel({
    this.tableId,
    this.code,
    required this.tenantId,
    required this.fromDate,
    required this.toDate,
    required this.isTiming,
    required this.iDuplicateQunatity,
    this.fromTime,
    this.toTime,
    required this.multi,
    required this.isActive,
    required this.promotionFBId,
    required this.isDeleted,
    this.deleterUserId,
    this.deletionTime,
    this.lastModificationTime,
    this.lastModifierUserId,
    this.creationTime,
    this.creatorUserId,
    required this.id,
  });

  factory PromotionCodesFBModel.fromJson(Map<String, dynamic> json) {
    return PromotionCodesFBModel(
      tableId: json['tableId'],
      code: json['code'],
      tenantId: json['tenantId'],
      fromDate:
          json['fromDate'] == null ? null : DateTime.parse(json['fromDate']),
      toDate: json['toDate'] == null ? null : DateTime.parse(json['toDate']),
      isTiming:
          (json['isTiming'] is bool) ? json['isTiming'] : json['isTiming'] == 1,
      iDuplicateQunatity: (json['iDuplicateQunatity'] is bool)
          ? json['iDuplicateQunatity']
          : json['iDuplicateQunatity'] == 1,
      fromTime: json['fromTime'],
      toTime: (json['toTime'] is bool) ? json['toTime'] : json['toTime'],
      multi: (json['multi'] is bool) ? json['multi'] : json['multi'] == 1,
      isActive:
          (json['isActive'] is bool) ? json['isActive'] : json['isActive'] == 1,
      promotionFBId: json['promotionFBId'],
      isDeleted: json['isDeleted'] == 1,
      deleterUserId: json['deleterUserId'],
      deletionTime: json['deletionTime'] != null
          ? DateTime.parse(json['deletionTime'])
          : null,
      lastModificationTime: json['lastModificationTime'] != null
          ? DateTime.parse(json['lastModificationTime'])
          : null,
      lastModifierUserId: json['lastModifierUserId'],
      creationTime: DateTime.parse(json['creationTime']),
      creatorUserId: json['creatorUserId'],
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (tableId != null) 'tableId': tableId,
      if (code != null) 'code': code,
      'tenantId': tenantId,
      'fromDate': fromDate?.toIso8601String(),
      'toDate': toDate?.toIso8601String(),
      'isTiming': isTiming ? 1 : 0,
      'iDuplicateQunatity': iDuplicateQunatity ? 1 : 0,
      'fromTime': fromTime,
      'toTime': toTime,
      'multi': multi ? 1 : 0,
      'isActive': isActive ? 1 : 0,
      'promotionFBId': promotionFBId,
      'isDeleted': isDeleted ? 1 : 0,
      'deleterUserId': deleterUserId,
      'deletionTime': deletionTime?.toIso8601String(),
      'lastModificationTime': lastModificationTime?.toIso8601String(),
      'lastModifierUserId': lastModifierUserId,
      'creationTime': creationTime?.toIso8601String(),
      'creatorUserId': creatorUserId,
      'id': id,
    };
  }

  Future<PromotionsFBTableModel?> get promotionsFB async {
    return await PromotionsFBTable.getByPromotionId(promotionFBId);
  }

  Future<PromotionDetailsFBModel?> get promotionDetails async {
    return await PromotionDetailsFBTable.getByPromotionId(promotionFBId);
  }
}
