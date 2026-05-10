class PromotionDetailsFBExcludedMenuItemModel {
  int? tableId;
  final int id;
  final int tenantId;
  final int menuItemId;
    int? promotionDetailsFBId;
  final bool isDeleted;
  final int? deleterUserId;
  final DateTime? deletionTime;
  final DateTime? lastModificationTime;
  final int? lastModifierUserId;
  final int creatorUserId;
  final DateTime creationTime;

  PromotionDetailsFBExcludedMenuItemModel({
    this.tableId,
    required this.id,
    required this.tenantId,
    required this.menuItemId,
      this.promotionDetailsFBId,
    required this.isDeleted,
    this.deleterUserId,
    this.deletionTime,
    this.lastModificationTime,
    this.lastModifierUserId,
    required this.creatorUserId,
    required this.creationTime,
  });

  factory PromotionDetailsFBExcludedMenuItemModel.fromMap(
      Map<String, dynamic> map) {
    return PromotionDetailsFBExcludedMenuItemModel(
      tableId: map['tableId'],
      id: map['id'],
      tenantId: map['tenantId'],
      menuItemId: map['menuItemId'],
      promotionDetailsFBId: map['promotionDetailsFBId'],
      isDeleted: map['isDeleted'] == true || map['isDeleted'] == 1,
      deleterUserId: map['deleterUserId'],
      deletionTime: map['deletionTime'] != null
          ? DateTime.parse(map['deletionTime'])
          : null,
      lastModificationTime: map['lastModificationTime'] != null
          ? DateTime.parse(map['lastModificationTime'])
          : null,
      lastModifierUserId: map['lastModifierUserId'],
      creatorUserId: map['creatorUserId'],
      creationTime: DateTime.parse(map['creationTime']),
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'id': id,
      'tenantId': tenantId,
      'menuItemId': menuItemId,
      'promotionDetailsFBId': promotionDetailsFBId,
      'isDeleted': isDeleted ? 1 : 0,
      'deleterUserId': deleterUserId,
      'deletionTime': deletionTime?.toIso8601String(),
      'lastModificationTime': lastModificationTime?.toIso8601String(),
      'lastModifierUserId': lastModifierUserId,
      'creatorUserId': creatorUserId,
      'creationTime': creationTime.toIso8601String(),
    };
    if (tableId != null) {
      map['tableId'] = tableId;
    }
    return map;
  }
}
