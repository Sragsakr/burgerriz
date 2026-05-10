import 'package:equatable/equatable.dart';
import 'package:kiosk_point_of_sale/data/models/combo_meal/combo_meal_package_model.dart';
import 'package:kiosk_point_of_sale/data/models/combo_meal/combo_meal_package_item_model.dart';

/// Represents a complete combo meal with all its packages
class ComboMeal extends Equatable {
  final int menuItemId;
  final String name;
  final String nameAr;
  final String imageId;
  final double parentPrice;
  final List<ComboMealPackage> packages;

  const ComboMeal({
    required this.menuItemId,
    required this.name,
    required this.nameAr,
    required this.imageId,
    required this.parentPrice,
    required this.packages,
  });

  /// Calculate the total price of the combo meal including all selected items
  double get totalPrice {
    return parentPrice +
        packages.fold(0.0, (sum, package) => sum + package.selectedItemsPrice);
  }

  /// Check if all packages have been completed
  bool get isComplete {
    return packages.every((package) => package.isComplete);
  }

  /// Get the first incomplete package
  ComboMealPackage? get currentPackage {
    try {
      return packages.firstWhere((package) => !package.isComplete);
    } catch (e) {
      return null;
    }
  }

  /// Get all selected items across all packages
  List<ComboMealPackageItem> get allSelectedItems {
    List<ComboMealPackageItem> selectedItems = [];
    for (var package in packages) {
      for (var item in package.items) {
        if (item.selectedCount > 0) {
          // Add the item selectedCount times for accurate cart representation
          for (int i = 0; i < item.selectedCount; i++) {
            selectedItems.add(item.copyWith(selectedCount: 1));
          }
        }
      }
    }
    return selectedItems;
  }

  /// Reset all selections in all packages
  void resetAllSelections() {
    for (var package in packages) {
      package.resetSelections();
    }
  }

  ComboMeal copyWith({
    int? menuItemId,
    String? name,
    String? nameAr,
    String? imageId,
    double? parentPrice,
    List<ComboMealPackage>? packages,
  }) {
    return ComboMeal(
      menuItemId: menuItemId ?? this.menuItemId,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      imageId: imageId ?? this.imageId,
      parentPrice: parentPrice ?? this.parentPrice,
      packages: packages ?? this.packages,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menuItemId': menuItemId,
      'name': name,
      'nameAr': nameAr,
      'imageId': imageId,
      'parentPrice': parentPrice,
      'packages': packages.map((p) => p.toJson()).toList(),
    };
  }

  factory ComboMeal.fromJson(Map<String, dynamic> json) {
    return ComboMeal(
      menuItemId: json['menuItemId'] ?? 0,
      name: json['name'] ?? '',
      nameAr: json['nameAr'] ?? '',
      imageId: json['imageId'] ?? 'noImageId',
      parentPrice: (json['parentPrice'] as num?)?.toDouble() ?? 0.0,
      packages: (json['packages'] as List?)
              ?.map((p) => ComboMealPackage.fromJson(p))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [
        menuItemId,
        name,
        nameAr,
        imageId,
        parentPrice,
        packages,
      ];
}

