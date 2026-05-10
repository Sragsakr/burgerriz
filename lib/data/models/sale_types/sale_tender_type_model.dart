class SaleTenderTypeModel {
  final int tenderTypeId;
  final String name;
  final int languageId;
  final int isDeleted; // Represented as 0 (false) or 1 (true)
  final int? deleterUserId;
  final String? deletionTime; // DateTime as String
  final String? lastModificationTime; // DateTime as String
  final int? lastModifierUserId;
  final String? creationTime; // DateTime as String
  final int? creatorUserId;
  final int id;
  int? tableId;

  SaleTenderTypeModel({
    required this.tenderTypeId,
    required this.name,
    required this.languageId,
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

  // Factory constructor to create an instance from Map
  factory SaleTenderTypeModel.fromMap(Map<String, dynamic> map) {
    return SaleTenderTypeModel(
      tenderTypeId: map['tenderTypeId'],
      name: map['name'].toLowerCase(),
      languageId: map['languageId'],
      isDeleted: map['isDeleted'] == 1 ? 1 : 0, // Ensure it's 0 or 1
      deleterUserId: map['deleterUserId'],
      deletionTime: map['deletionTime'], // Expecting String
      lastModificationTime: map['lastModificationTime'], // Expecting String
      lastModifierUserId: map['lastModifierUserId'],
      creationTime: map['creationTime'], // Expecting String
      creatorUserId: map['creatorUserId'],
      id: map['id'],
      tableId: map['tableId'],
    );
  }

  // Method to convert the instance to Map
  Map<String, dynamic> toMap() {
    return {
      'tenderTypeId': tenderTypeId,
      'name': name.toLowerCase(),
      'languageId': languageId,
      'isDeleted': isDeleted, // Stored as 0 or 1
      'deleterUserId': deleterUserId,
      'deletionTime': deletionTime, // Kept as String
      'lastModificationTime': lastModificationTime, // Kept as String
      'lastModifierUserId': lastModifierUserId,
      'creationTime': creationTime, // Kept as String
      'creatorUserId': creatorUserId,
      'id': id,
      'tableId': tableId,
    };
  }
}
