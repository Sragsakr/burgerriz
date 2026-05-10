class VariantTableElementEntity {
  final int categoryId;
  final bool isRequired;
  final int minSelections;
  final int maxSelections;
  final bool allowMultipleQuantitiesPerModifier;
  final int maxQtyPerModifier;
  final bool isAdd;
  final bool isModifier;
  final bool isActive;
  final int pricingRule;
  final int pricingRuleFreeItemsCount;
  final int periorty;
  final bool isDeleted;
  final int? deleterUserId;
  final String? deletionTime;
  final String? lastModificationTime;
  final int? lastModifierUserId;
  final String creationTime;
  final int creatorUserId;
  final int id;
  int? tableId;

  VariantTableElementEntity({
    this.categoryId = 0,
    this.isRequired = false,
    this.minSelections = 0,
    this.maxSelections = 0,
    this.allowMultipleQuantitiesPerModifier = false,
    this.maxQtyPerModifier = 0,
    this.isAdd = false,
    this.isModifier = false,
    this.isActive = false,
    this.pricingRule = 0,
    this.pricingRuleFreeItemsCount = 0,
    this.periorty = 0,
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

  factory VariantTableElementEntity.fromJson(Map<String, dynamic> json) {
    return VariantTableElementEntity(
      tableId: json['tableId'],
      categoryId: json['categoryId'] as int? ?? 0,
      isRequired: json['isRequired'] is bool
          ? json['isRequired']
          : (json['isRequired'] as int?) == 1,
      minSelections: json['minSelections'] as int? ?? 0,
      maxSelections: json['maxSelections'] as int? ?? 0,
      allowMultipleQuantitiesPerModifier:
          json['allowMultipleQuantitiesPerModifier'] is bool
              ? json['allowMultipleQuantitiesPerModifier']
              : (json['allowMultipleQuantitiesPerModifier'] as int?) == 1,
      maxQtyPerModifier: json['maxQtyPerModifier'] as int? ?? 0,
      isAdd: json['isAdd'] is bool
          ? json['isAdd']
          : (json['isAdd'] as int?) == 1,
      isModifier: json['isModifier'] is bool
          ? json['isModifier']
          : (json['isModifier'] as int?) == 1,
      isActive: json['isActive'] is bool
          ? json['isActive']
          : (json['isActive'] as int?) == 1,
      pricingRule: json['pricingRule'] as int? ?? 0,
      pricingRuleFreeItemsCount: json['pricingRuleFreeItemsCount'] as int? ?? 0,
      periorty: json['periorty'] as int? ?? 0,
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
      'categoryId': categoryId,
      'isRequired': isRequired ? 1 : 0,
      'minSelections': minSelections,
      'maxSelections': maxSelections,
      'allowMultipleQuantitiesPerModifier':
          allowMultipleQuantitiesPerModifier ? 1 : 0,
      'maxQtyPerModifier': maxQtyPerModifier,
      'isAdd': isAdd ? 1 : 0,
      'isModifier': isModifier ? 1 : 0,
      'isActive': isActive ? 1 : 0,
      'pricingRule': pricingRule,
      'pricingRuleFreeItemsCount': pricingRuleFreeItemsCount,
      'periorty': periorty,
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
