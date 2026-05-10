import 'package:equatable/equatable.dart';

/// Represents one UOM + price entry for a menu item in the active price list.
/// Returned by [menuItemDetailsProvider] and passed into [ItemCustomizationDialog].
class MenuItemDetails extends Equatable {
  final int menuItemId;
  final int unitOfMeasureId;
  final String unitNameEn;
  final String unitNameAr;
  final double price;
  final double taxValue;
  final bool isVAT;

  const MenuItemDetails({
    required this.menuItemId,
    required this.unitOfMeasureId,
    required this.unitNameEn,
    required this.unitNameAr,
    required this.price,
    this.taxValue = 0.0,
    this.isVAT = false,
  });

  @override
  List<Object?> get props => [
        menuItemId,
        unitOfMeasureId,
        unitNameEn,
        unitNameAr,
        price,
        taxValue,
        isVAT,
      ];
}

/// Parameters for [menuItemDetailsProvider].
class MenuItemDetailsParams extends Equatable {
  final int menuItemId;
  final int priceListId;

  const MenuItemDetailsParams(this.menuItemId, this.priceListId);

  @override
  List<Object?> get props => [menuItemId, priceListId];
}
