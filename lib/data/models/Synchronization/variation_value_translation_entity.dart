import 'package:equatable/equatable.dart';

class VariationValueTranslationEntity extends Equatable {
  final int variantValueId;
  final String name;
  final int languageId;
  final bool isDeleted;
  final int deleterUserId;
  final String deletionTime;
  final String lastModificationTime;
  final int lastModifierUserId;
  final String creationTime;
  final int creatorUserId;
  final int id;
  int? tableId;

  VariationValueTranslationEntity({
    this.variantValueId = 0,
    this.name = "",
    this.languageId = 0,
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

  factory VariationValueTranslationEntity.fromJson(Map<String, dynamic> json) {
    return VariationValueTranslationEntity(
      tableId: json['tableId'],
      variantValueId: json['variantValueId'] as int? ?? 0,
      name: json['name'] as String? ?? "",
      languageId: json['languageId'] as int? ?? 0,
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
      'variantValueId': variantValueId,
      'name': name,
      'languageId': languageId,
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

  @override
  List<Object?> get props => [
        variantValueId,
        name,
        languageId,
        isDeleted,
        deleterUserId,
        deletionTime,
        lastModificationTime,
        lastModifierUserId,
        creationTime,
        creatorUserId,
        id,
        tableId,
      ];
}
