class VariationValueEntity {
  final int variantId;
  final bool isDefault;
  final bool isDeleted;
  final int deleterUserId;
  final String deletionTime;
  final String lastModificationTime;
  final int lastModifierUserId;
  final String creationTime;
  final int creatorUserId;
  final int id;
  int? tableId;

  VariationValueEntity({
    this.variantId = 0,
    this.isDefault = false,
    this.isDeleted = false,
    this.deleterUserId = 0,
    this.deletionTime = "",
    this.lastModificationTime = "",
    this.lastModifierUserId = 0,
    this.creationTime = "",
    this.creatorUserId = 0,
    this.id = 0,
    this.tableId,
  });

  factory VariationValueEntity.fromJson(Map<String, dynamic> json) {
    return VariationValueEntity(
      tableId: json['tableId'],
      variantId: json['variantId'] as int? ?? 0,
      isDefault: json['isDefault'] is bool
          ? json['isDefault']
          : (json['isDefault'] as int?) == 1,
      isDeleted: json['isDeleted'] is bool
          ? json['isDeleted']
          : (json['isDeleted'] as int?) == 1,
      deleterUserId: json['deleterUserId'] as int? ?? 0,
      deletionTime: json['deletionTime'] as String? ?? "",
      lastModificationTime: json['lastModificationTime'] as String? ?? "",
      lastModifierUserId: json['lastModifierUserId'] as int? ?? 0,
      creationTime: json['creationTime'] as String? ?? "",
      creatorUserId: json['creatorUserId'] as int? ?? 0,
      id: json['id'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (tableId != null) 'tableId': tableId,
      'variantId': variantId,
      'isDefault': isDefault ? 1 : 0,
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
