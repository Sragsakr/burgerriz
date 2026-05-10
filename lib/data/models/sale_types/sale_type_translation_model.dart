
class SaleTypeTranslationModel {
  final int saleTypeId;
  final String name;
  final int languageId;
  final bool isDeleted;
  final int? deleterUserId;
  final String? deletionTime;
  final String? lastModificationTime;
  final int? lastModifierUserId;
  final String creationTime;
  final int creatorUserId;
  final int id;
  final int? tableId; // Added for SQLite primary key

  SaleTypeTranslationModel({
    required this.saleTypeId,
    required this.name,
    required this.languageId,
    required this.isDeleted,
    this.deleterUserId,
    this.deletionTime,
    this.lastModificationTime,
    this.lastModifierUserId,
    required this.creationTime,
    required this.creatorUserId,
    required this.id,
    this.tableId,
  });

  /// Convert JSON to `SaleTypeTranslationModel` object
  factory SaleTypeTranslationModel.fromJson(Map<String, dynamic> json) {
    return SaleTypeTranslationModel(
      saleTypeId: json['saleTypeId'],
      name: json['name'],
      languageId: json['languageId'],
      isDeleted: json['isDeleted'],
      deleterUserId: json['deleterUserId'],
      deletionTime: json['deletionTime'],
      lastModificationTime: json['lastModificationTime'],
      lastModifierUserId: json['lastModifierUserId'],
      creationTime: json['creationTime'],
      creatorUserId: json['creatorUserId'],
      id: json['id'],
      tableId: json['tableId'], // For SQLite storage
    );
  }

  /// Convert `SaleTypeTranslationModel` object to JSON
  Map<String, dynamic> toJson() {
    return {
      'saleTypeId': saleTypeId,
      'name': name,
      'languageId': languageId,
      'isDeleted': isDeleted,
      'deleterUserId': deleterUserId,
      'deletionTime': deletionTime,
      'lastModificationTime': lastModificationTime,
      'lastModifierUserId': lastModifierUserId,
      'creationTime': creationTime,
      'creatorUserId': creatorUserId,
      'id': id,
      'tableId': tableId, // Include in SQLite
    };
  }

  /// Convert SQLite row to `SaleTypeTranslationModel` object
  factory SaleTypeTranslationModel.fromMap(Map<String, dynamic> map) {
    return SaleTypeTranslationModel(
      saleTypeId: map['saleTypeId'],
      name: map['name'],
      languageId: map['languageId'],
      isDeleted: map['isDeleted'] == 1, // Convert SQLite boolean representation
      deleterUserId: map['deleterUserId'],
      deletionTime: map['deletionTime'],
      lastModificationTime: map['lastModificationTime'],
      lastModifierUserId: map['lastModifierUserId'],
      creationTime: map['creationTime'],
      creatorUserId: map['creatorUserId'],
      id: map['id'],
      tableId: map['tableId'],
    );
  }

  /// Convert `SaleTypeTranslationModel` to SQLite Map
  Map<String, dynamic> toMap() {
    return {
      'saleTypeId': saleTypeId,
      'name': name,
      'languageId': languageId,
      'isDeleted': isDeleted ? 1 : 0, // Store booleans as integers
      'deleterUserId': deleterUserId,
      'deletionTime': deletionTime,
      'lastModificationTime': lastModificationTime,
      'lastModifierUserId': lastModifierUserId,
      'creationTime': creationTime,
      'creatorUserId': creatorUserId,
      'id': id,
      'tableId': tableId,
    };
  }
}
