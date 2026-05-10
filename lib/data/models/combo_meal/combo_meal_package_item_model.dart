import 'package:equatable/equatable.dart';

/// Represents a selectable item within a combo meal package
class ComboMealPackageItem extends Equatable {
  final int id;
  final int menuItemId;
  final String name;
  final String nameAr;
  final String imageId;
  final int maxQuantity;
  final double price;
  final double taxValue;
  final bool isVAT;
  int selectedCount;

  ComboMealPackageItem({
    required this.id,
    required this.menuItemId,
    required this.name,
    required this.nameAr,
    required this.imageId,
    required this.maxQuantity,
    required this.price,
    this.taxValue = 0.15,
    this.isVAT = true,
    this.selectedCount = 0,
  });

  /// Check if this item can still be selected
  bool get canSelect => selectedCount < maxQuantity;

  /// Create a copy with updated selectedCount
  ComboMealPackageItem copyWith({
    int? id,
    int? menuItemId,
    String? name,
    String? nameAr,
    String? imageId,
    int? maxQuantity,
    double? price,
    double? taxValue,
    bool? isVAT,
    int? selectedCount,
  }) {
    return ComboMealPackageItem(
      id: id ?? this.id,
      menuItemId: menuItemId ?? this.menuItemId,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      imageId: imageId ?? this.imageId,
      maxQuantity: maxQuantity ?? this.maxQuantity,
      price: price ?? this.price,
      taxValue: taxValue ?? this.taxValue,
      isVAT: isVAT ?? this.isVAT,
      selectedCount: selectedCount ?? this.selectedCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'menuItemId': menuItemId,
      'name': name,
      'nameAr': nameAr,
      'imageId': imageId,
      'maxQuantity': maxQuantity,
      'price': price,
      'taxValue': taxValue,
      'isVAT': isVAT,
      'selectedCount': selectedCount,
    };
  }

  factory ComboMealPackageItem.fromJson(Map<String, dynamic> json) {
    return ComboMealPackageItem(
      id: json['id'] ?? 0,
      menuItemId: json['menuItemId'] ?? 0,
      name: json['name'] ?? '',
      nameAr: json['nameAr'] ?? '',
      imageId: json['imageId'] ?? 'noImageId',
      maxQuantity: json['maxQuantity'] ?? 1,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      taxValue: (json['taxValue'] as num?)?.toDouble() ?? 0.15,
      isVAT: json['isVAT'] ?? true,
      selectedCount: json['selectedCount'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [
        id,
        menuItemId,
        name,
        nameAr,
        imageId,
        maxQuantity,
        price,
        taxValue,
        isVAT,
        selectedCount,
      ];
}

