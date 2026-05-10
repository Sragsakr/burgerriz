class ProductCategoryModel {
  int? tableId;
  final String code;
  final int secondaryCategoryId;
  final int parentId;
  final DateTime? startUsageDate;
  final DateTime? endUsageDate;
  final int isLastLevel;
  final String? imageId;
  final int isShowInPlugIn;
  final int? isDeleted;
  final int? deleterUserId;
  final DateTime? deletionTime;
  final DateTime? lastModificationTime;
  final int? lastModifierUserId;
  final DateTime? creationTime;
  final int? creatorUserId;
  final int id;

  ProductCategoryModel({
    this.tableId,
    required this.code,
    required this.secondaryCategoryId,
    required this.parentId,
    this.startUsageDate,
    this.endUsageDate,
    required this.isLastLevel,
    this.imageId,
    required this.isShowInPlugIn,
    this.isDeleted,
    this.deleterUserId,
    this.deletionTime,
    this.lastModificationTime,
    this.lastModifierUserId,
    this.creationTime,
    this.creatorUserId,
    required this.id,
  });

  factory ProductCategoryModel.fromMap(Map<String, dynamic> json) {
    return ProductCategoryModel(
      tableId: json['tableId'],
      code: json['code'] ?? '',
      secondaryCategoryId: json['secondaryCategoryId'] ?? 0,
      parentId: json['parentId'] ?? 0,
      startUsageDate: json['startUsageDate'] != null
          ? DateTime.parse(json['startUsageDate'])
          : null,
      endUsageDate: json['endUsageDate'] != null
          ? DateTime.parse(json['endUsageDate'])
          : null,
      isLastLevel: (json['isLastLevel'] == true || json['isLastLevel'] == 1) ? 1 : 0,
      imageId: json['imageId'],
      isShowInPlugIn: (json['isShowInPlugIn'] == true || json['isShowInPlugIn'] == 1) ? 1 : 0,
      isDeleted: (json['isDeleted'] == true || json['isDeleted'] == 1) ? 1 : 0,
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
      'code': code,
      'secondaryCategoryId': secondaryCategoryId,
      'parentId': parentId,
      'startUsageDate': startUsageDate?.toIso8601String(),
      'endUsageDate': endUsageDate?.toIso8601String(),
      'isLastLevel': isLastLevel,
      'imageId': imageId,
      'isShowInPlugIn': isShowInPlugIn,
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
