import 'package:flutter/material.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/currency_display_widget.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/data/models/menu_item/item_customization_result.dart';
import 'package:kiosk_point_of_sale/data/models/menu_item/menu_item_details.dart';
import 'package:kiosk_point_of_sale/data/models/menu_item/selected_variant.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/menu_widget/components/item_customization/models/variant_group_data.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/menu_widget/components/item_customization/widgets/kiosk_style_customization_widgets.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/menu_widget/components/item_customization/widgets/validation_popup.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/menu_widget/components/kiosk_product_image_helpers.dart';

/// Mobile-optimized customization sheet for product customization.
/// Displays UOM, modifiers, and variants in a single scrollable list.
class MobileItemCustomizationSheet extends StatefulWidget {
  final String menuItemName;
  final int menuItemId;
  final String? imageId;
  final List<MenuItemDetails> unitOptions;
  final List<Map<String, dynamic>> variants;
  final bool isVatExclusive;
  final double taxRate;
  final bool isEditMode;
  final MenuItemDetails? initialSelectedUnit;
  final List<SelectedVariant>? initialSelectedVariants;
  final int initialQuantity;
  final Color? accentColor;
  final String? numberOfCalories;
  final String? numberOfSteps;

  const MobileItemCustomizationSheet({
    super.key,
    required this.menuItemName,
    required this.menuItemId,
    this.imageId,
    required this.unitOptions,
    required this.variants,
    this.isVatExclusive = false,
    this.taxRate = 0.0,
    this.isEditMode = false,
    this.initialSelectedUnit,
    this.initialSelectedVariants,
    this.initialQuantity = 1,
    this.accentColor,
    this.numberOfCalories,
    this.numberOfSteps,
  });

  @override
  State<MobileItemCustomizationSheet> createState() =>
      _MobileItemCustomizationSheetState();

  static Future<ItemCustomizationResult?> show(
    BuildContext context, {
    required String menuItemName,
    required int menuItemId,
    String? imageId,
    required List<MenuItemDetails> unitOptions,
    required List<Map<String, dynamic>> variants,
    bool isVatExclusive = false,
    double taxRate = 0.0,
    bool isEditMode = false,
    MenuItemDetails? initialSelectedUnit,
    List<SelectedVariant>? initialSelectedVariants,
    int initialQuantity = 1,
    Color? accentColor,
    String? numberOfCalories,
    String? numberOfSteps,
  }) {
    return showModalBottomSheet<ItemCustomizationResult>(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.85,
        child: MobileItemCustomizationSheet(
          menuItemName: menuItemName,
          menuItemId: menuItemId,
          imageId: imageId,
          unitOptions: unitOptions,
          variants: variants,
          isVatExclusive: isVatExclusive,
          taxRate: taxRate,
          isEditMode: isEditMode,
          initialSelectedUnit: initialSelectedUnit,
          initialSelectedVariants: initialSelectedVariants,
          initialQuantity: initialQuantity,
          accentColor: accentColor,
          numberOfCalories: numberOfCalories,
          numberOfSteps: numberOfSteps,
        ),
      ),
    );
  }
}

class _MobileItemCustomizationSheetState
    extends State<MobileItemCustomizationSheet> {
  MenuItemDetails? _selectedUnit;
  Map<int, List<SelectedVariant>> _selectedByGroup = {};
  Map<int, String> _validationErrors = {};
  late int _quantity;
  late bool _uomShowError;

  List<VariantGroupData> _modifierGroups = [];
  List<VariantGroupData> _variantGroups = [];

  Color get _accent => widget.accentColor ?? const Color(0xFFAF2A26);
  static const Color _kioskTotalGreen = Color(0xFF189e55);
  List<VariantGroupData> get _allGroups =>
      [..._modifierGroups, ..._variantGroups];

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialQuantity.clamp(1, 999);
    _uomShowError = false;
    _buildVariantGroups();
    _prePopulateSelections();
  }

  void _buildVariantGroups() {
    final allGroups =
        widget.variants.map((v) => VariantGroupData.fromMap(v)).toList();
    _modifierGroups = allGroups.where((g) => g.isModifier).toList()
      ..sort(VariantGroupData.compareByPriority);
    _variantGroups = allGroups.where((g) => !g.isModifier).toList()
      ..sort(VariantGroupData.compareByPriority);
  }

  void _prePopulateSelections() {
    if (widget.initialSelectedUnit != null) {
      _selectedUnit = widget.initialSelectedUnit;
    } else if (widget.unitOptions.length == 1) {
      _selectedUnit = widget.unitOptions.first;
    }

    if (widget.isEditMode && widget.initialSelectedVariants != null) {
      for (final sv in widget.initialSelectedVariants!) {
        _selectedByGroup.putIfAbsent(sv.variantId, () => []).add(sv);
      }
    } else {
      for (final group in _allGroups) {
        final defaultSelections = <SelectedVariant>[];
        for (final value in group.values) {
          if (value.isDefault) {
            defaultSelections.add(_toSelectedVariant(group, value));
          }
        }
        if (defaultSelections.isEmpty &&
            group.isRequired &&
            group.minSelections >= 1 &&
            group.values.isNotEmpty) {
          defaultSelections.add(_toSelectedVariant(group, group.values.first));
        }
        if (defaultSelections.isNotEmpty) {
          _selectedByGroup[group.variantId] = defaultSelections;
        }
      }
    }
  }

  bool _validateCurrentStep() {
    final errors = <int, String>{};
    for (final group in _allGroups) {
      final sels = _selectedByGroup[group.variantId] ?? [];
      final total = sels.fold<double>(0, (s, v) => s + v.quantity);
      final effectiveMin = group.isRequired
          ? group.minSelections.clamp(1, 999)
          : group.minSelections;
      if (effectiveMin > 0 && total < effectiveMin) {
        errors[group.variantId] =
            'Please select at least $effectiveMin item(s).';
      }
    }
    setState(() => _validationErrors = errors);
    return errors.isEmpty;
  }

  List<SelectedVariant> _applyPricingRules() {
    final result = <SelectedVariant>[];
    for (final group in _allGroups) {
      final sels =
          List<SelectedVariant>.from(_selectedByGroup[group.variantId] ?? []);
      final rule = group.pricingRule;
      final freeCount = group.pricingRuleFreeItemsCount;

      switch (rule) {
        case 3:
          for (final s in sels) {
            result.add(s.copyWith(isFree: true));
          }
          break;
        case 2:
          final effectiveFreeCount = freeCount > 0 ? freeCount : 0;
          double freeQtyRemaining = effectiveFreeCount.toDouble();
          for (final s in sels) {
            if (freeQtyRemaining >= s.quantity) {
              result.add(s.copyWith(isFree: true));
              freeQtyRemaining -= s.quantity;
            } else if (freeQtyRemaining > 0) {
              final freeQty = freeQtyRemaining;
              final paidQty = s.quantity - freeQty;
              result.add(s.copyWith(isFree: true, quantity: freeQty));
              result.add(s.copyWith(isFree: false, quantity: paidQty));
              freeQtyRemaining = 0;
            } else {
              result.add(s.copyWith(isFree: false));
            }
          }
          break;
        default:
          for (final s in sels) {
            result.add(s.copyWith(isFree: false));
          }
      }
    }
    return result;
  }

  double _getTotalPrice(List<SelectedVariant> processedVariants) {
    final base = _selectedUnit?.price ??
        (widget.unitOptions.isNotEmpty ? widget.unitOptions.first.price : 0.0);
    final variantTotal = processedVariants.fold<double>(
      0.0,
      (sum, v) => sum + (v.isFree ? 0 : v.price * v.quantity),
    );
    return base + variantTotal;
  }

  double get _liveTotalPrice {
    final base = _selectedUnit?.price ??
        (widget.unitOptions.isNotEmpty ? widget.unitOptions.first.price : 0.0);
    double variantTotal = 0;
    for (final group in _allGroups) {
      final sels =
          List<SelectedVariant>.from(_selectedByGroup[group.variantId] ?? []);
      final rule = group.pricingRule;
      final freeCount = group.pricingRuleFreeItemsCount;

      switch (rule) {
        case 3:
          break;
        case 2:
          final effectiveFreeCount = freeCount > 0 ? freeCount : 0;
          double freeQtyRemaining = effectiveFreeCount.toDouble();
          for (final s in sels) {
            if (freeQtyRemaining >= s.quantity) {
              freeQtyRemaining -= s.quantity;
            } else if (freeQtyRemaining > 0) {
              final paidQty = s.quantity - freeQtyRemaining;
              variantTotal += s.price * paidQty;
              freeQtyRemaining = 0;
            } else {
              variantTotal += s.price * s.quantity;
            }
          }
          break;
        default:
          for (final s in sels) {
            variantTotal += s.price * s.quantity;
          }
      }
    }
    return base + variantTotal;
  }

  Future<void> _onToggleVariant(
      VariantGroupData group, VariantValueOption option) async {
    final sels =
        List<SelectedVariant>.from(_selectedByGroup[group.variantId] ?? []);
    final idx =
        sels.indexWhere((s) => s.variantValueId == option.variantValueId);

    if (idx >= 0) {
      sels.removeAt(idx);
    } else {
      final totalQty = sels.fold<double>(0, (s, v) => s + v.quantity);
      if (group.maxSelections > 0 && totalQty >= group.maxSelections) {
        await showMaxSelectionsExceededPopup(
            context: context, group: group, currentTotal: totalQty);
        return;
      }
      sels.add(_toSelectedVariant(group, option));
    }

    setState(() {
      _selectedByGroup = Map.from(_selectedByGroup)..[group.variantId] = sels;
      _validationErrors.remove(group.variantId);
    });
  }

  Future<void> _onUpdateQuantity(
      VariantGroupData group, int variantValueId, double newQty) async {
    if (newQty <= 0) {
      setState(() {
        final sels =
            List<SelectedVariant>.from(_selectedByGroup[group.variantId] ?? [])
              ..removeWhere((s) => s.variantValueId == variantValueId);
        _selectedByGroup = Map.from(_selectedByGroup)..[group.variantId] = sels;
      });
      return;
    }

    if (group.maxQtyPerModifier > 0 && newQty > group.maxQtyPerModifier) {
      await showMaxQtyPerModifierExceededPopup(
          context: context, group: group, maxQty: group.maxQtyPerModifier);
      return;
    }

    final sels =
        List<SelectedVariant>.from(_selectedByGroup[group.variantId] ?? []);
    final otherItemsQty = sels
        .where((s) => s.variantValueId != variantValueId)
        .fold<double>(0, (sum, s) => sum + s.quantity);
    final newTotalQty = otherItemsQty + newQty;

    if (group.maxSelections > 0 && newTotalQty > group.maxSelections) {
      await showMaxSelectionsExceededPopup(
          context: context, group: group, currentTotal: otherItemsQty);
      return;
    }

    setState(() {
      final idx = sels.indexWhere((s) => s.variantValueId == variantValueId);
      if (idx >= 0) sels[idx] = sels[idx].copyWith(quantity: newQty);
      _selectedByGroup = Map.from(_selectedByGroup)..[group.variantId] = sels;
    });
  }

  SelectedVariant _toSelectedVariant(
    VariantGroupData group,
    VariantValueOption option,
  ) {
    return option.toSelectedVariant(
      groupNameEn: group.nameEn,
      groupNameAr: group.nameAr,
      isModifier: group.isModifier,
      isAdd: group.isAdd,
    );
  }

  void _confirm() {
    final errors = <int, String>{};
    for (final group in _allGroups) {
      final sels = _selectedByGroup[group.variantId] ?? [];
      final total = sels.fold<double>(0, (s, v) => s + v.quantity);
      final effectiveMin = group.isRequired
          ? group.minSelections.clamp(1, 999)
          : group.minSelections;
      if (effectiveMin > 0 && total < effectiveMin) {
        errors[group.variantId] =
            'Please select at least $effectiveMin item(s).';
      }
    }
    if (errors.isNotEmpty) {
      setState(() => _validationErrors = errors);
      return;
    }
    if (_selectedUnit == null && widget.unitOptions.isNotEmpty) {
      setState(() {});
      return;
    }

    final processedVariants = _applyPricingRules();
    Navigator.of(context).pop(ItemCustomizationResult(
      selectedUnit: _selectedUnit ??
          (widget.unitOptions.isNotEmpty ? widget.unitOptions.first : null),
      selectedVariants: processedVariants,
      totalPrice: _getTotalPrice(processedVariants),
      wasCancelled: false,
      quantity: _quantity,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildDragHandle(),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroImage(),
                _buildProductInfo(),
                const Divider(height: 1),
                if (widget.unitOptions.length > 1) _buildUomSection(),
                ..._modifierGroups.map((g) => _buildGroupSection(g)),
                ..._variantGroups.map((g) => _buildGroupSection(g)),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        _buildFooter(),
      ],
    );
  }

  Widget _buildDragHandle() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2)),
        ),
      ),
    );
  }

  Widget _buildHeroImage() {
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: 160,
          child: buildImage(widget.imageId ?? '',
              width: double.infinity, height: 160),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: GestureDetector(
            onTap: () =>
                Navigator.of(context).pop(ItemCustomizationResult.cancelled()),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  shape: BoxShape.circle),
              child: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: Text(widget.menuItemName,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold))),
              const SizedBox(width: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CurrencyDisplayWidget(
                    width: 20,
                    height: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(_liveTotalPrice.toStringAsFixed(2),
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _kioskTotalGreen)),
                ],
              ),
            ],
          ),
          if (widget.numberOfCalories != null ||
              widget.numberOfSteps != null) ...[
            const SizedBox(height: 12),
            Text(translator(arText: 'التغذية', enText: 'Nutrition'),
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 10,
              runSpacing: 6,
              children: [
                if (widget.numberOfCalories != null)
                  KioskStyleNutritionTag(
                      icon: Icons.local_fire_department,
                      iconColor: const Color(0xFFFF6A00),
                      label: '${widget.numberOfCalories} Cal'),
                if (widget.numberOfSteps != null)
                  KioskStyleNutritionTag(
                      icon: Icons.directions_run,
                      iconColor: const Color(0xFF2F5BFF),
                      label: '${widget.numberOfSteps} Min'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUomSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KioskStyleSectionHeader(
            title: translator(arText: 'اختر الحجم', enText: 'Choose Size'),
            isRequired: widget.unitOptions.length > 1,
            selectCount: 1,
            selectedCount: _selectedUnit != null ? 1 : 0,
          ),
          if (_uomShowError) ...[
            const SizedBox(height: 8),
            Text(
                translator(
                    arText: 'يرجى اختيار الحجم',
                    enText: 'Please select a size.'),
                style: const TextStyle(color: Color(0xFFAF2A26), fontSize: 11)),
          ],
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              const cols = 2;
              const spacing = 8.0;
              final tileW =
                  (constraints.maxWidth - spacing * (cols - 1)) / cols;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: widget.unitOptions.map((unit) {
                  final selected =
                      _selectedUnit?.unitOfMeasureId == unit.unitOfMeasureId;
                  return KioskStyleCustomizationOptionTile(
                    name: translator(
                        arText: unit.unitNameAr, enText: unit.unitNameEn),
                    price: unit.price,
                    isFree: false,
                    isSelected: selected,
                    tileWidth: tileW,
                    onTap: () => setState(() => _selectedUnit = unit),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGroupSection(VariantGroupData group) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: KioskStyleCustomizationGroupSection(
        group: group,
        selections: _selectedByGroup[group.variantId] ?? [],
        errorMessage: _validationErrors[group.variantId],
        onToggleVariant: (opt) => _onToggleVariant(group, opt),
        onUpdateQuantity: (id, qty) => _onUpdateQuantity(group, id, qty),
      ),
    );
  }

  Widget _buildFooter() {
    final total = _liveTotalPrice;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                KioskStyleQtyButton(
                  themeColor: _accent,
                  icon: Icons.remove,
                  onTap:
                      _quantity > 1 ? () => setState(() => _quantity--) : null,
                ),
                SizedBox(
                    width: 36,
                    child: Text('$_quantity',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold))),
                KioskStyleQtyButton(
                  themeColor: _accent,
                  icon: Icons.add,
                  onTap: _quantity < 999
                      ? () => setState(() => _quantity++)
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: _confirm,
              style: FilledButton.styleFrom(
                backgroundColor: _accent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.isEditMode
                        ? translator(arText: 'تحديث', enText: 'Update')
                        : translator(arText: 'إضافة', enText: 'Add'),
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  const Text('(', style: TextStyle(fontSize: 15)),
                  const CurrencyDisplayWidget(
                    variant: CurrencyVisualVariant.white,
                    width: 16,
                    height: 16,
                    textStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(total.toStringAsFixed(2),
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold)),
                  const Text(')', style: TextStyle(fontSize: 15)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
