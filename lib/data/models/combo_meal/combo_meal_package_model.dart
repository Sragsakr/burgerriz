import 'package:equatable/equatable.dart';
import 'package:kiosk_point_of_sale/data/models/combo_meal/combo_meal_package_item_model.dart';

/// Represents a package group within a combo meal (e.g., "Main Course", "Side Dish", "Drink")
class ComboMealPackage extends Equatable {
  final int id;
  final String name;
  final String nameAr;
  final String code;
  final int quantity; // Required number of selections
  final List<ComboMealPackageItem> items;
  final int order;
  int remainingSelections;

  ComboMealPackage({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.code,
    required this.quantity,
    required this.items,
    required this.order,
    int? remainingSelections,
  }) : remainingSelections = remainingSelections ?? quantity;

  /// Check if all required selections have been made for this package
  bool get isComplete => remainingSelections == 0;

  /// Get the total price of all selected items in this package
  double get selectedItemsPrice {
    return items.fold(0.0, (sum, item) => sum + (item.price * item.selectedCount));
  }

  /// Get the list of selected items
  List<ComboMealPackageItem> get selectedItems {
    return items.where((item) => item.selectedCount > 0).toList();
  }

  /// Reset all selections in this package
  void resetSelections() {
    remainingSelections = quantity;
    for (var item in items) {
      item.selectedCount = 0;
    }
  }

  ComboMealPackage copyWith({
    int? id,
    String? name,
    String? nameAr,
    String? code,
    int? quantity,
    List<ComboMealPackageItem>? items,
    int? order,
    int? remainingSelections,
  }) {
    return ComboMealPackage(
      id: id ?? this.id,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      code: code ?? this.code,
      quantity: quantity ?? this.quantity,
      items: items ?? this.items,
      order: order ?? this.order,
      remainingSelections: remainingSelections ?? this.remainingSelections,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameAr': nameAr,
      'code': code,
      'quantity': quantity,
      'items': items.map((item) => item.toJson()).toList(),
      'order': order,
      'remainingSelections': remainingSelections,
    };
  }

  factory ComboMealPackage.fromJson(Map<String, dynamic> json) {
    return ComboMealPackage(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      nameAr: json['nameAr'] ?? '',
      code: json['code'] ?? '',
      quantity: json['quantity'] ?? 1,
      items: (json['items'] as List?)
              ?.map((item) => ComboMealPackageItem.fromJson(item))
              .toList() ??
          [],
      order: json['order'] ?? 0,
      remainingSelections: json['remainingSelections'],
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        nameAr,
        code,
        quantity,
        items,
        order,
        remainingSelections,
      ];
}

