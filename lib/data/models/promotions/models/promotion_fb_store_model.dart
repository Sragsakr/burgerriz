class PromotionFBStoreModel {
  final int id;
  final int promotionFBId;
  final int storeId;
  final bool isDeleted;
  final int? deleterUserId;
  final DateTime? deletionTime;
  final DateTime? lastModificationTime;
  final int? lastModifierUserId;
  final DateTime creationTime;
  final int creatorUserId;
  final int? tableId;

  PromotionFBStoreModel({
    required this.id,
    required this.promotionFBId,
    required this.storeId,
    required this.isDeleted,
    this.deleterUserId,
    this.deletionTime,
    this.lastModificationTime,
    this.lastModifierUserId,
    required this.creationTime,
    required this.creatorUserId,
    this.tableId,
  });

  factory PromotionFBStoreModel.fromJson(Map<String, dynamic> json) {
    return PromotionFBStoreModel(
      id: json['id'] as int,
      promotionFBId: json['promotionFBId'] as int,
      storeId: json['storeId'] as int,
      isDeleted: json['isDeleted'] is bool ? json['isDeleted'] : (json['isDeleted'] as int) == 1,
      deleterUserId: json['deleterUserId'] as int?,
      deletionTime: json['deletionTime'] != null
          ? DateTime.parse(json['deletionTime'] as String)
          : null,
      lastModificationTime: json['lastModificationTime'] != null
          ? DateTime.parse(json['lastModificationTime'] as String)
          : null,
      lastModifierUserId: json['lastModifierUserId'] as int?,
      creationTime: DateTime.parse(json['creationTime'] as String),
      creatorUserId: json['creatorUserId'] as int,
      tableId: json['tableId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'promotionFBId': promotionFBId,
      'storeId': storeId,
      'isDeleted': isDeleted ? 1 : 0,
      'deleterUserId': deleterUserId,
      if (deletionTime != null) 'deletionTime': deletionTime!.toIso8601String(),
      if (lastModificationTime != null) 'lastModificationTime': lastModificationTime!.toIso8601String(),
      'lastModifierUserId': lastModifierUserId,
      'creationTime': creationTime.toIso8601String(),
      'creatorUserId': creatorUserId,
      if (tableId != null) 'tableId': tableId,
    }..removeWhere((key, value) => value == null);
  }
}
