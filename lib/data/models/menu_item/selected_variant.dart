import 'package:equatable/equatable.dart';

/// A single selected variant/modifier option within [ItemCustomizationDialog].
class SelectedVariant extends Equatable {
  final int variantId;
  final int variantValueId;
  final String nameEn;
  final String nameAr;

  /// Parent group name used in order/invoice rendering.
  final String groupNameEn;
  final String groupNameAr;

  /// Modifier nature label (e.g. Add / Without), empty for normal variants.
  final String modifierNatureEn;
  final String modifierNatureAr;
  final bool isModifier;

  /// Effective price after [VariantPricingHelper] processes the pricing rule.
  final double price;

  /// True when [pricingRule] marks this item as free (onlyFirstFree / allFree).
  final bool isFree;
  final double quantity;

  const SelectedVariant({
    required this.variantId,
    required this.variantValueId,
    required this.nameEn,
    required this.nameAr,
    this.groupNameEn = '',
    this.groupNameAr = '',
    this.modifierNatureEn = '',
    this.modifierNatureAr = '',
    this.isModifier = false,
    required this.price,
    this.isFree = false,
    this.quantity = 1.0,
  });

  SelectedVariant copyWith({
    double? price,
    bool? isFree,
    double? quantity,
  }) =>
      SelectedVariant(
        variantId: variantId,
        variantValueId: variantValueId,
        nameEn: nameEn,
        nameAr: nameAr,
        groupNameEn: groupNameEn,
        groupNameAr: groupNameAr,
        modifierNatureEn: modifierNatureEn,
        modifierNatureAr: modifierNatureAr,
        isModifier: isModifier,
        price: price ?? this.price,
        isFree: isFree ?? this.isFree,
        quantity: quantity ?? this.quantity,
      );

  @override
  List<Object?> get props => [
        variantId,
        variantValueId,
        nameEn,
        nameAr,
        groupNameEn,
        groupNameAr,
        modifierNatureEn,
        modifierNatureAr,
        isModifier,
        price,
        isFree,
        quantity,
      ];
}
