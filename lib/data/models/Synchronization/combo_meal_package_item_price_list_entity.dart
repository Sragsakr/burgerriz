class ComboMealPackageItemPriceListEntity {
  final int comboMealPackageItemId;
  final int priceListId;
  final double price;
  final bool isDeleted;
  final int? deleterUserId;
  final String? deletionTime;
  final String? lastModificationTime;
  final int? lastModifierUserId;
  final String creationTime;
  final int? creatorUserId;
  final int id;
  int? tableId;

  ComboMealPackageItemPriceListEntity({
    this.comboMealPackageItemId = 0,
    this.priceListId = 0,
    this.price = 0,
    this.isDeleted = false,
    this.deleterUserId,
    this.deletionTime,
    this.lastModificationTime,
    this.lastModifierUserId,
    this.creationTime = "",
    this.creatorUserId,
    this.id = 0,
    this.tableId,
  });

  factory ComboMealPackageItemPriceListEntity.fromJson(Map<String, dynamic> json) {
    return ComboMealPackageItemPriceListEntity(
      tableId: json['tableId'],
      comboMealPackageItemId: json['comboMealPackageItemId'] as int? ?? 0,
      priceListId: json['priceListId'] as int? ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      isDeleted: json['isDeleted'] is bool
          ? json['isDeleted']
          : (json['isDeleted'] as int?) == 1,
      deleterUserId: json['deleterUserId'] as int?,
      deletionTime: json['deletionTime'] as String?,
      lastModificationTime: json['lastModificationTime'] as String?,
      lastModifierUserId: json['lastModifierUserId'] as int?,
      creationTime: json['creationTime'] as String? ?? "",
      creatorUserId: json['creatorUserId'] as int?,
      id: json['id'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (tableId != null) 'tableId': tableId,
      'comboMealPackageItemId': comboMealPackageItemId,
      'priceListId': priceListId,
      'price': price,
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

