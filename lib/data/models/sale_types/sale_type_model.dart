
class SaleTypeModel {
  final int saleNatural;
  final bool? hasRoles;
  final int tenantId;
  final bool isB2B;
  final bool isDeleted;
  final int? deleterUserId;
  final String? deletionTime;
  final String? lastModificationTime;
  final int? lastModifierUserId;
  final String creationTime;
  final int creatorUserId;
  final int id;
  final int? tableId; // Added tableId for SQLite

  SaleTypeModel({
    required this.saleNatural,
    required this.hasRoles,
    required this.tenantId,
    required this.isB2B,
    required this.isDeleted,
    this.deleterUserId,
    this.deletionTime,
    this.lastModificationTime,
    this.lastModifierUserId,
    required this.creationTime,
    required this.creatorUserId,
    required this.id,
    this.tableId, // Optional field
  });

  /// Convert JSON to `SaleTypeModel` object
  factory SaleTypeModel.fromJson(Map<String, dynamic> json) {
    return SaleTypeModel(
      saleNatural: json['saleNatural'],
      hasRoles: json['hasRoles'],
      tenantId: json['tenantId'],
      isB2B: json['isB2B'],
      isDeleted: json['isDeleted'],
      deleterUserId: json['deleterUserId'],
      deletionTime: json['deletionTime'],
      lastModificationTime: json['lastModificationTime'],
      lastModifierUserId: json['lastModifierUserId'],
      creationTime: json['creationTime'],
      creatorUserId: json['creatorUserId'],
      id: json['id'],
      tableId: json['tableId'], // Handling SQLite ID
    );
  }

  /// Convert `SaleTypeModel` object to JSON
  Map<String, dynamic> toJson() {
    return {
      'saleNatural': saleNatural,
      'hasRoles': hasRoles,
      'tenantId': tenantId,
      'isB2B': isB2B,
      'isDeleted': isDeleted,
      'deleterUserId': deleterUserId,
      'deletionTime': deletionTime,
      'lastModificationTime': lastModificationTime,
      'lastModifierUserId': lastModifierUserId,
      'creationTime': creationTime,
      'creatorUserId': creatorUserId,
      'id': id,
      'tableId': tableId, // Include in SQLite storage
    };
  }

  /// Convert SQLite row to `SaleTypeModel` object
  factory SaleTypeModel.fromMap(Map<String, dynamic> map) {
    return SaleTypeModel(
      saleNatural: map['saleNatural'],
      hasRoles: map['hasRoles'] == 1, // Convert SQLite boolean representation
      tenantId: map['tenantId'],
      isB2B: map['isB2B'] == 1, // Convert SQLite boolean representation
      isDeleted: map['isDeleted'] == 1,
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

  /// Convert `SaleTypeModel` to SQLite Map
  Map<String, dynamic> toMap() {
    return {
      'saleNatural': saleNatural,
      'hasRoles': hasRoles == true ? 1 : 0, // Store booleans as integers
      'tenantId': tenantId,
      'isB2B': isB2B == true ? 1 : 0,
      'isDeleted': isDeleted == true ? 1 : 0,
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
