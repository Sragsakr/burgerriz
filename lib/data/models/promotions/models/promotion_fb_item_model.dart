class PromotionFBItemModel {
  final int tenantId;
  final int itemId;
  final int itemType;
  final int promotionId;
  final bool isDeleted;
  final int? deleterUserId;
  final DateTime? deletionTime;
  final DateTime? lastModificationTime;
  final int? lastModifierUserId;
  final DateTime? creationTime;
  final int? creatorUserId;
  final int id;
  int? tableId;

  PromotionFBItemModel({
    required this.tenantId,
    required this.itemId,
    required this.itemType,
    required this.promotionId,
    required this.isDeleted,
    this.deleterUserId,
    this.deletionTime,
    this.lastModificationTime,
    this.lastModifierUserId,
    this.creationTime,
    this.creatorUserId,
    required this.id,
    this.tableId,
  });

  factory PromotionFBItemModel.fromJson(Map<String, dynamic> json) {
    return PromotionFBItemModel(
      tenantId: json['tenantId'] as int,
      itemId: json['itemId'] as int,
      itemType: json['itemType'] as int,
      promotionId: json['promotionId'] as int,
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
          json['creatorUserId'] != null ? json['creatorUserId'] as int : null,
      id: json['id'] as int,
      tableId: json['tableId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (tableId != null) 'tableId': tableId,
      'tenantId': tenantId,
      'itemId': itemId,
      'itemType': itemType,
      'promotionId': promotionId,
      'isDeleted': isDeleted ? 1 : 0,
      'deleterUserId': deleterUserId,
      if (deletionTime != null) 'deletionTime': deletionTime!.toIso8601String(),
      if (lastModificationTime != null)
        'lastModificationTime': lastModificationTime!.toIso8601String(),
      'lastModifierUserId': lastModifierUserId,
      if (creationTime != null) 'creationTime': creationTime!.toIso8601String(),
      'creatorUserId': creatorUserId,
      'id': id,
    }..removeWhere((key, value) => value == null);
  }
}
