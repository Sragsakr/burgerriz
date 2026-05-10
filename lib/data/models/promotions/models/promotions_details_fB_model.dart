class PromotionDetailsFBModel {
  final int tenantId;
  final int itemId;
  final int itemType;
  final String? where;
  final double quantity;
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

  PromotionDetailsFBModel({
    required this.tenantId,
    required this.itemId,
    required this.itemType,
    this.where,
    required this.quantity,
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

  factory PromotionDetailsFBModel.fromJson(Map<String, dynamic> json) {
    return PromotionDetailsFBModel(
      tenantId: json['tenantId'],
      itemId: json['itemId'],
      itemType: json['itemType'],
      where: json['Where'],
      quantity: json['quantity'].toDouble(),
      promotionId: json['promotionId'],
      isDeleted: (json['isDeleted'] is bool)
          ? json['isDeleted']
          : json['isDeleted'] == 1,
      deleterUserId: json['deleterUserId'],
      deletionTime: json['deletionTime'] != null
          ? DateTime.parse(json['deletionTime'])
          : null,
      lastModificationTime: json['lastModificationTime'] != null
          ? DateTime.parse(json['lastModificationTime'])
          : null,
      lastModifierUserId: json['lastModifierUserId'],
      creationTime: DateTime.parse(json['creationTime']),
      creatorUserId:  json['creatorUserId'] ?? json['creatorUserId'],
      id: json['id'],
      tableId: json['tableId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (tableId != null) 'tableId': tableId,
      'tenantId': tenantId,
      'itemId': itemId,
      'itemType': itemType,
      'Where': where,
      'quantity': quantity,
      'promotionId': promotionId,
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
}
