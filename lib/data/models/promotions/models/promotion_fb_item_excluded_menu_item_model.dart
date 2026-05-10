class PromotionFBItemExcludedMenuItemModel {
    int? tableId;
  final int id;
  final int tenantId;
  final int menuItemId;
  final int promotionFBItemId;
  final bool isDeleted;
  final int? deleterUserId;
  final DateTime? deletionTime;
  final DateTime? lastModificationTime;
  final int? lastModifierUserId;
  final int creatorUserId;
  final DateTime creationTime;

  PromotionFBItemExcludedMenuItemModel({
      this.tableId,
    required this.id,
    required this.tenantId,
    required this.menuItemId,
    required this.promotionFBItemId,
    required this.isDeleted,
    this.deleterUserId,
    this.deletionTime,
    this.lastModificationTime,
    this.lastModifierUserId,
    required this.creatorUserId,
    required this.creationTime,
  });

  factory PromotionFBItemExcludedMenuItemModel.fromMap(
      Map<String, dynamic> map) {
    return PromotionFBItemExcludedMenuItemModel(
      tableId: map['tableId'],
      id: map['id'],
      tenantId: map['tenantId'],
      menuItemId: map['menuItemId'],
      promotionFBItemId: map['promotionFBItemId'],
      isDeleted: map['isDeleted'] == true || map['isDeleted'] == 1,
      deleterUserId: map['deleterUserId'],
      deletionTime: map['deletionTime'] != null
          ? DateTime.parse(map['deletionTime'])
          : null,
      lastModificationTime: map['lastModificationTime'] != null
          ? DateTime.parse(map['lastModificationTime'])
          : null,
      lastModifierUserId: map['lastModifierUserId'],
      creatorUserId: map['creatorUserId']??0,
      creationTime: DateTime.parse(map['creationTime']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
     if(tableId!=null) 'tableId': tableId,
      'id': id,
      'tenantId': tenantId,
      'menuItemId': menuItemId,
      'promotionFBItemId': promotionFBItemId,
      'isDeleted': isDeleted ? 1 : 0,
      'deleterUserId': deleterUserId,
      'deletionTime': deletionTime?.toIso8601String(),
      'lastModificationTime': lastModificationTime?.toIso8601String(),
      'lastModifierUserId': lastModifierUserId,
      'creatorUserId': creatorUserId,
      'creationTime': creationTime.toIso8601String(),
    };
  }
}
