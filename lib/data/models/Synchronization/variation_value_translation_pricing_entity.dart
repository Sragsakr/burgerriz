import 'package:equatable/equatable.dart';

class VariationValueTranslationPricingEntity extends Equatable {
  final int variantValueId;
  final int priceListId;
  final double price;
  final double factor;
  final bool isDeleted;
  final int? deleterUserId;
  final DateTime? deletionTime;
  final DateTime? lastModificationTime;
  final int? lastModifierUserId;
  final DateTime? creationTime;
  final int creatorUserId;
  final int id;
  int? tableId;

  VariationValueTranslationPricingEntity({
    this.variantValueId = 0,
    this.priceListId = 0,
    this.price = 0.0,
    this.factor = 0.0,
    this.isDeleted = false,
    this.deleterUserId,
    this.deletionTime,
    this.lastModificationTime,
    this.lastModifierUserId,
    this.creationTime,
    this.creatorUserId = 0,
    this.id = 0,
    this.tableId,
  });

  factory VariationValueTranslationPricingEntity.fromJson(
      Map<String, dynamic> json) {
    return VariationValueTranslationPricingEntity(
      tableId: json['tableId'],
      variantValueId: json['variantValueId'] as int? ?? 0,
      priceListId: json['priceListId'] as int? ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      factor: (json['factor'] as num?)?.toDouble() ?? 0.0,
      isDeleted: json['isDeleted'] is bool
          ? json['isDeleted']
          : (json['isDeleted'] as int?) == 1,
      deleterUserId: json['deleterUserId'] as int?,
      deletionTime: json['deletionTime'] != null
          ? DateTime.parse(json['deletionTime'] as String)
          : null,
      lastModificationTime: json['lastModificationTime'] != null
          ? DateTime.parse(json['lastModificationTime'] as String)
          : null,
      lastModifierUserId: json['lastModifierUserId'] as int?,
      creationTime: json['creationTime'] != null
          ? DateTime.parse(json['creationTime'] as String)
          : null,
      creatorUserId: json['creatorUserId'] as int? ?? 0,
      id: json['id'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (tableId != null) 'tableId': tableId,
      'variantValueId': variantValueId,
      'priceListId': priceListId,
      'price': price,
      'factor': factor,
      'isDeleted': isDeleted ? 1 : 0,
      'deleterUserId': deleterUserId,
      if (deletionTime != null) 'deletionTime': deletionTime!.toIso8601String(),
      if (lastModificationTime != null)
        'lastModificationTime': lastModificationTime!.toIso8601String(),
      'lastModifierUserId': lastModifierUserId,
      if (creationTime != null) 'creationTime': creationTime!.toIso8601String(),
      'creatorUserId': creatorUserId,
      'id': id,
    }..removeWhere((key, value) => value == null);
  }

  @override
  List<Object?> get props => [
        variantValueId,
        priceListId,
        price,
        factor,
        isDeleted,
        deleterUserId,
        deletionTime,
        lastModificationTime,
        lastModifierUserId,
        creationTime,
        creatorUserId,
        id,
        tableId,
      ];
}
