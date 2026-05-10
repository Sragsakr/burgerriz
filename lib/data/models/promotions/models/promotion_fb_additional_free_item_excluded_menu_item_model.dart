class PromotionFBAdditionalFreeItemExcludedMenuItemModel {
  final int menuItemId;
  final int promotionFBAdditionalFreeItemId;
  final bool isDeleted;
  final int? deleterUserId;
  final DateTime? deletionTime;
  final DateTime? lastModificationTime;
  final int? lastModifierUserId;
  final DateTime? creationTime;
  final int? creatorUserId;
  final int id;
  int? tableId;

  PromotionFBAdditionalFreeItemExcludedMenuItemModel({
    required this.menuItemId,
    required this.promotionFBAdditionalFreeItemId,
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

  factory PromotionFBAdditionalFreeItemExcludedMenuItemModel.fromJson(
      Map<String, dynamic> json) {
    return PromotionFBAdditionalFreeItemExcludedMenuItemModel(
      menuItemId: json['menuItemId'] as int,
      promotionFBAdditionalFreeItemId:
          json['promotionFBAdditionalFreeItemId'] as int,
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
      creationTime: json['creationTime'] != null
          ? DateTime.parse(json['creationTime'] as String)
          : null,
      creatorUserId: json['creatorUserId'] as int?,
      id: json['id'] as int,
      tableId: json['tableId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (tableId != null) 'tableId': tableId,
      'menuItemId': menuItemId,
      'promotionFBAdditionalFreeItemId': promotionFBAdditionalFreeItemId,
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
