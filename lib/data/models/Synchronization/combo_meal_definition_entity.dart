class ComboMealDefinitionEntity {
  final int menuItemId;
  final int comboMealPackageId;
  final int order;
  final bool isDeleted;
  final int? deleterUserId;
  final String? deletionTime;
  final String? lastModificationTime;
  final int? lastModifierUserId;
  final String creationTime;
  final int? creatorUserId;
  final int id;
  int? tableId;

  ComboMealDefinitionEntity({
    this.menuItemId = 0,
    this.comboMealPackageId = 0,
    this.order = 0,
    this.isDeleted = false,
    this.deleterUserId,
    this.deletionTime,
    this.lastModificationTime,
    this.lastModifierUserId,
    this.creationTime = "",
    this.creatorUserId,
    this.id = 0,
    this.tableId,
  });

  factory ComboMealDefinitionEntity.fromJson(Map<String, dynamic> json) {
    return ComboMealDefinitionEntity(
      tableId: json['tableId'],
      menuItemId: json['menuItemId'] as int? ?? 0,
      comboMealPackageId: json['comboMealPackageId'] as int? ?? 0,
      order: json['order_index'] as int? ??
          json['order'] as int? ??
          json['Order'] as int? ??
          0,
      isDeleted: json['isDeleted'] is bool
          ? json['isDeleted']
          : (json['isDeleted'] as int?) == 1,
      deleterUserId: json['deleterUserId'] as int?,
      deletionTime: json['deletionTime'] as String?,
      lastModificationTime: json['lastModificationTime'] as String?,
      lastModifierUserId: json['lastModifierUserId'] as int?,
      creationTime: json['creationTime'] as String? ?? "",
      creatorUserId: json['creatorUserId'] as int?,
      id: json['id'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (tableId != null) 'tableId': tableId,
      'menuItemId': menuItemId,
      'comboMealPackageId': comboMealPackageId,
      'order_index': order,
      'isDeleted': isDeleted ? 1 : 0,
      'deleterUserId': deleterUserId,
      'deletionTime': deletionTime,
      'lastModificationTime': lastModificationTime,
      'lastModifierUserId': lastModifierUserId,
      'creationTime': creationTime,
      'creatorUserId': creatorUserId,
      'id': id,
    };
  }
}
