class MenuItemPriceListEntity {
  final int menuItemId;
  final int? menuItemConfigId;
  final int priceListId;
  final double price;
  final int unitOfMeasureId;
  final double factor;
  final bool isDeleted;
  final int? deleterUserId;
  final String? deletionTime;
  final String? lastModificationTime;
  final int? lastModifierUserId;
  final String creationTime;
  final int creatorUserId;
  final int id;
  int? tableId;

  MenuItemPriceListEntity({
    this.menuItemId = 0,
    this.menuItemConfigId,
    this.priceListId = 0,
    this.price = 0.0,
    this.unitOfMeasureId = 0,
    this.factor = 1.0,
    this.isDeleted = false,
    this.deleterUserId,
    this.deletionTime,
    this.lastModificationTime,
    this.lastModifierUserId,
    this.creationTime = '',
    this.creatorUserId = 0,
    this.id = 0,
    this.tableId,
  });

  factory MenuItemPriceListEntity.fromJson(Map<String, dynamic> json) {
    return MenuItemPriceListEntity(
      tableId: json['tableId'] as int?,
      menuItemId: json['menuItemId'] as int? ?? 0,
      menuItemConfigId: json['menuItemConfigId'] as int?,
      priceListId: json['priceListId'] as int? ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      unitOfMeasureId: json['unitOfMeasureId'] as int? ?? 0,
      factor: (json['factor'] as num?)?.toDouble() ?? 1.0,
      isDeleted: json['isDeleted'] is bool
          ? json['isDeleted']
          : (json['isDeleted'] as int?) == 1,
      deleterUserId: json['deleterUserId'] as int?,
      deletionTime: json['deletionTime'] as String?,
      lastModificationTime: json['lastModificationTime'] as String?,
      lastModifierUserId: json['lastModifierUserId'] as int?,
      creationTime: json['creationTime'] as String? ?? '',
      creatorUserId: json['creatorUserId'] as int? ?? 0,
      id: json['id'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (tableId != null) 'tableId': tableId,
      'menuItemId': menuItemId,
      'menuItemConfigId': menuItemConfigId,
      'priceListId': priceListId,
      'price': price,
      'unitOfMeasureId': unitOfMeasureId,
      'factor': factor,
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
