class SaleTypePriceListModel {
  int? tableId;
  int saleTypeId;
  int priceListId;
  bool isDeleted;
  int? deleterUserId;
  String? deletionTime;
  String? lastModificationTime;
  int? lastModifierUserId;
  String creationTime;
  int creatorUserId;
  int id;

  SaleTypePriceListModel({
    this.tableId,
    required this.saleTypeId,
    required this.priceListId,
    required this.isDeleted,
    this.deleterUserId,
    this.deletionTime,
    this.lastModificationTime,
    this.lastModifierUserId,
    required this.creationTime,
    required this.creatorUserId,
    required this.id,
  });

  factory SaleTypePriceListModel.fromMap(Map<String, dynamic> map) {
    return SaleTypePriceListModel(
      tableId: map['tableId'],
      saleTypeId: map['saleTypeId'],
      priceListId: map['priceListId'],
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
      'saleTypeId': saleTypeId,
      'priceListId': priceListId,
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
