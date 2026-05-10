class ProductCategoryLevelModel {
  int? tableId;
  final int? levelId;
  final int productCategoryId;
  final int? isDeleted;
  final int? deleterUserId;
  final DateTime? deletionTime;
  final DateTime? lastModificationTime;
  final int? lastModifierUserId;
  final DateTime? creationTime;
  final int? creatorUserId;
  final int id;

  ProductCategoryLevelModel({
    this.tableId,
    this.levelId,
    required this.productCategoryId,
    this.isDeleted,
    this.deleterUserId,
    this.deletionTime,
    this.lastModificationTime,
    this.lastModifierUserId,
    this.creationTime,
    this.creatorUserId,
    required this.id,
  });

  factory ProductCategoryLevelModel.fromMap(Map<String, dynamic> json) {
    return ProductCategoryLevelModel(
      tableId: json['tableId'],
      levelId: json['levelId'],
      productCategoryId: json['productCategoryId'],
      isDeleted: json['isDeleted'] == true ? 1 : 0,
      deleterUserId: json['deleterUserId'],
      deletionTime: json['deletionTime'] != null
          ? DateTime.parse(json['deletionTime'])
          : null,
      lastModificationTime: json['lastModificationTime'] != null
          ? DateTime.parse(json['lastModificationTime'])
          : null,
      lastModifierUserId: json['lastModifierUserId'],
      creationTime: json['creationTime'] != null
          ? DateTime.parse(json['creationTime'])
          : null,
      creatorUserId: json['creatorUserId'],
      id: json['id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (tableId != null) 'tableId': tableId,
      'levelId': levelId,
      'productCategoryId': productCategoryId,
      'isDeleted': isDeleted,
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
