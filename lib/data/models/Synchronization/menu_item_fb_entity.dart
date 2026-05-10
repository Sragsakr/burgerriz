class MenuItemFBEntity {
  final int tenantId;
  final int reportGroupId;
  final int mainGroupId;
  final int materialGroupId;
  final int productCategoryId;
  final bool? isHidden;
  final String? imageId;
  final bool openPrice;
  final int? levelId;
  final bool hasTobaccoTax;
  final String? itemCode;
  final String? startUsageDate;
  final String? endUsageDate;
  final bool isComboMealDefinitionItem;
  final bool isShowInPlugIn;
  final int? menuItemConfigId;
  final bool isHoteSaleing;
  final String? barcode1;
  final String? barcode2;
  final String? numberOfCalories;
  final String? numberOfSteps;
  final bool? allowDecimal;
  final bool isDeleted;
  final int? deleterUserId;
  final String? deletionTime;
  final String? lastModificationTime;
  final int? lastModifierUserId;
  final String creationTime;
  final int creatorUserId;
  final int id;
  int? tableId;

  MenuItemFBEntity({
    this.tenantId = 0,
    this.reportGroupId = 0,
    this.mainGroupId = 0,
    this.materialGroupId = 0,
    this.productCategoryId = 0,
    this.isHidden,
    this.imageId,
    this.openPrice = false,
    this.levelId,
    this.hasTobaccoTax = false,
    this.itemCode,
    this.startUsageDate,
    this.endUsageDate,
    this.isComboMealDefinitionItem = false,
    this.isShowInPlugIn = false,
    this.menuItemConfigId,
    this.isHoteSaleing = false,
    this.barcode1,
    this.barcode2,
    this.numberOfCalories,
    this.numberOfSteps,
    this.allowDecimal,
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

  factory MenuItemFBEntity.fromJson(Map<String, dynamic> json) {
    return MenuItemFBEntity(
      tableId: json['tableId'] as int?,
      tenantId: json['tenantId'] as int? ?? 0,
      reportGroupId: json['reportGroupId'] as int? ?? 0,
      mainGroupId: json['mainGroupId'] as int? ?? 0,
      materialGroupId: json['materialGroupId'] as int? ?? 0,
      productCategoryId: json['productCategoryId'] as int? ?? 0,
      isHidden: json['isHidden'] is bool ? json['isHidden'] as bool : (json['isHidden'] as int?) == 1,
      imageId: json['imageId'] as String? ?? '',
      openPrice: json['openPrice'] is bool ? json['openPrice'] : (json['openPrice'] as int?) == 1,
      levelId: json['levelId'] as int?,
      hasTobaccoTax: json['hasTobaccoTax'] is bool ? json['hasTobaccoTax'] : (json['hasTobaccoTax'] as int?) == 1,
      itemCode: json['itemCode'] as String?,
      startUsageDate: json['startUsageDate'] as String?,
      endUsageDate: json['endUsageDate'] as String?,
      isComboMealDefinitionItem: json['isComboMealDefinitionItem'] is bool
          ? json['isComboMealDefinitionItem']
          : (json['isComboMealDefinitionItem'] as int?) == 1,
      isShowInPlugIn: json['isShowInPlugIn'] is bool ? json['isShowInPlugIn'] : (json['isShowInPlugIn'] as int?) == 1,
      menuItemConfigId: json['menuItemConfigId'] as int?,
      isHoteSaleing: json['isHoteSaleing'] is bool ? json['isHoteSaleing'] : (json['isHoteSaleing'] as int?) == 1,
      barcode1: json['barcode1'] as String?,
      barcode2: json['barcode2'] as String?,
      numberOfCalories: json['numberOfCalories'] != null ? json['numberOfCalories'].toString() : null,
      numberOfSteps: json['numberOfSteps'] != null ? json['numberOfSteps'].toString() : null,
      allowDecimal: json['allowDecimal'] == null
          ? null
          : (json['allowDecimal'] is bool ? json['allowDecimal'] as bool : (json['allowDecimal'] as int?) == 1),
      isDeleted: json['isDeleted'] is bool ? json['isDeleted'] : (json['isDeleted'] as int?) == 1,
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
      'tenantId': tenantId,
      'mainGroupId': mainGroupId,
      'reportGroupId': reportGroupId,
      'materialGroupId': materialGroupId,
      'productCategoryId': productCategoryId,
      'isHidden': isHidden == null ? null : (isHidden! ? 1 : 0),
      'imageId': imageId,
      'openPrice': openPrice ? 1 : 0,
      'levelId': levelId,
      'hasTobaccoTax': hasTobaccoTax ? 1 : 0,
      'itemCode': itemCode,
      'startUsageDate': startUsageDate,
      'endUsageDate': endUsageDate,
      'isComboMealDefinitionItem': isComboMealDefinitionItem ? 1 : 0,
      'isShowInPlugIn': isShowInPlugIn ? 1 : 0,
      'menuItemConfigId': menuItemConfigId,
      'isHoteSaleing': isHoteSaleing ? 1 : 0,
      'barcode1': barcode1,
      'barcode2': barcode2,
      'numberOfCalories': numberOfCalories,
      'numberOfSteps': numberOfSteps,
      'allowDecimal': allowDecimal == null ? null : (allowDecimal! ? 1 : 0),
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
