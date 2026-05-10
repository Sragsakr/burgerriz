class ReportGroupTranslationEntity {
  final int reportGroupId;
  final String name;
  final bool isDeleted;
  final int? deleterUserId;
  final String? deletionTime;
  final String? lastModificationTime;
  final int? lastModifierUserId;
  final String creationTime;
  final int? creatorUserId;
  final int id;
  int? tableId;

  ReportGroupTranslationEntity({
    this.reportGroupId = 0,
    this.name = '',
    this.isDeleted = false,
    this.deleterUserId,
    this.deletionTime,
    this.lastModificationTime,
    this.lastModifierUserId,
    this.creationTime = '',
    this.creatorUserId,
    this.id = 0,
    this.tableId,
  });

  factory ReportGroupTranslationEntity.fromJson(Map<String, dynamic> json) {
    return ReportGroupTranslationEntity(
      tableId: json['tableId'] as int?,
      reportGroupId: json['reportGroupId'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      isDeleted: json['isDeleted'] is bool
          ? json['isDeleted'] as bool
          : (json['isDeleted'] as int?) == 1,
      deleterUserId: json['deleterUserId'] as int?,
      deletionTime: json['deletionTime'] as String?,
      lastModificationTime: json['lastModificationTime'] as String?,
      lastModifierUserId: json['lastModifierUserId'] as int?,
      creationTime: json['creationTime'] as String? ?? '',
      creatorUserId: json['creatorUserId'] as int?,
      id: json['id'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (tableId != null) 'tableId': tableId,
      'reportGroupId': reportGroupId,
      'name': name,
      'isDeleted': isDeleted ? 1 : 0,
      'deleterUserId': deleterUserId,
      'deletionTime': deletionTime,
      'lastModificationTime': lastModificationTime,
      'lastModifierUserId': lastModifierUserId,
      'creationTime': creationTime,
      'creatorUserId': creatorUserId,
      'id': id,
    }..removeWhere((key, value) => value == null);
  }
}
