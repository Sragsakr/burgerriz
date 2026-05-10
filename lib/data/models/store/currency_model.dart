class CurrencyModel {
  int? tableId;
  final int languageId;
  final int currencyId;
  final String name;
  final int? isDeleted;
  final int? deleterUserId;
  final DateTime? deletionTime;
  final DateTime? lastModificationTime;
  final int? lastModifierUserId;
  final DateTime? creationTime;
  final int? creatorUserId;
  final int id;

  CurrencyModel({
    this.tableId,
    required this.languageId,
    required this.currencyId,
    required this.name,
    this.isDeleted,
    this.deleterUserId,
    this.deletionTime,
    this.lastModificationTime,
    required this.lastModifierUserId,
    required this.creationTime,
    required this.creatorUserId,
    required this.id,
  });

  // Factory method to create a Currency object from JSON
  factory CurrencyModel.fromMap(Map<String, dynamic> json) {
    return CurrencyModel(
      tableId: json['tableId'],
      languageId: json['languageId'],
      currencyId: json['currencyId'],
      name: json['name'],
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

  // Method to convert a CurrencyModel object to JSON
  Map<String, dynamic> toMap() {
    return {
      if (tableId != null) 'tableId': tableId,
      'languageId': languageId,
      'currencyId': currencyId,
      'name': name,
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
