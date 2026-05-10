class SaleTypeStoresModel {
  int? tableId;
  int tenantId;
  int storeId;
  int saleTypeId;
  bool isDeleted;
  int? deleterUserId;
  String? deletionTime;
  String? lastModificationTime;
  int? lastModifierUserId;
  String creationTime;
  int creatorUserId;
  int id;

  SaleTypeStoresModel({
    this.tableId,
    required this.tenantId,
    required this.storeId,
    required this.saleTypeId,
    required this.isDeleted,
    this.deleterUserId,
    this.deletionTime,
    this.lastModificationTime,
    this.lastModifierUserId,
    required this.creationTime,
    required this.creatorUserId,
    required this.id,
  });

  factory SaleTypeStoresModel.fromMap(Map<String, dynamic> map) {
    return SaleTypeStoresModel(
      tableId: map['tableId'],
      tenantId: map['tenantId'],
      storeId: map['storeId'],
      saleTypeId: map['saleTypeId'],
      isDeleted: map['isDeleted'] == 1,
      deleterUserId: map['deleterUserId'],
      deletionTime: map['deletionTime'],
      lastModificationTime: map['lastModificationTime'],
      lastModifierUserId: map['lastModifierUserId'],
      creationTime: map['creationTime'],
      creatorUserId: map['creatorUserId'],
      id: map['id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tableId': tableId,
      'tenantId': tenantId,
      'storeId': storeId,
      'saleTypeId': saleTypeId,
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
