class UnitOfMeasureTranslationModel {
  int? tableId;
  final int unitOfMeasureId;
  final String name;
  final int languageId;
  final int? isDeleted;
  final int? deleterUserId;
  final DateTime? deletionTime;
  final DateTime? lastModificationTime;
  final int? lastModifierUserId;
  final DateTime? creationTime;
  final int? creatorUserId;
  final int id;

  UnitOfMeasureTranslationModel({
    this.tableId,
    required this.unitOfMeasureId,
    required this.name,
    required this.languageId,
    this.isDeleted,
    this.deleterUserId,
    this.deletionTime,
    this.lastModificationTime,
    this.lastModifierUserId,
    this.creationTime,
    this.creatorUserId,
    required this.id,
  });

  factory UnitOfMeasureTranslationModel.fromMap(Map<String, dynamic> json) {
    return UnitOfMeasureTranslationModel(
      tableId: json['tableId'],
      unitOfMeasureId: json['unitOfMeasureId'],
      name: json['name'],
      languageId: json['languageId'],
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
      'unitOfMeasureId': unitOfMeasureId,
      'name': name,
      'languageId': languageId,
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
