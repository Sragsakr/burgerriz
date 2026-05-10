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

// ---------------------------------------------------------------------------
// Customization step enum
// ---------------------------------------------------------------------------

enum CustomizationStep { uom, modifiers, variants }

// ---------------------------------------------------------------------------
// ItemCustomizationDialog
// ---------------------------------------------------------------------------

/// Wizard dialog for selecting UOM + modifiers + variants before adding to cart.
///
/// Returns [ItemCustomizationResult] via [Navigator.pop]:
/// - `wasCancelled: false` + selections + total on confirm
/// - [ItemCustomizationResult.cancelled] on close / cancel
class ItemCustomizationDialog extends StatefulWidget {
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

  /// Starting quantity (add flow). Edit flow keeps this value if the user does not change qty.
  final int initialQuantity;

  /// Brand accent (e.g. [reportGroupThemeProvider]); defaults to steak red when null.
  final Color? accentColor;

  /// Optional nutrition line (matches [KioskProductCustomizationSheet] when non-null).
  final String? numberOfCalories;
  final String? numberOfSteps;

  const ItemCustomizationDialog({
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
  State<ItemCustomizationDialog> createState() =>
      _ItemCustomizationDialogState();
}

class _ItemCustomizationDialogState extends State<ItemCustomizationDialog> {
  // ---------------------------------------------------------------------------
  // Step state
  // ---------------------------------------------------------------------------

  List<CustomizationStep> _availableSteps = [];
  int _currentStepIndex = 0;

  // ---------------------------------------------------------------------------
  // Selection state
  // ---------------------------------------------------------------------------

  MenuItemDetails? _selectedUnit;

  /// keyed by variantId
  Map<int, List<SelectedVariant>> _selectedByGroup = {};
  Map<int, String> _validationErrors = {};
  late int _quantity;
  bool _uomShowError = false;

  Color get _accent => widget.accentColor ?? const Color(0xFFAF2A26);

  static const Color _kioskTotalGreen = Color(0xFF189e55);

  // ---------------------------------------------------------------------------
  // Group data
  // ---------------------------------------------------------------------------

  List<VariantGroupData> _modifierGroups = [];
  List<VariantGroupData> _variantGroups = [];

  // ---------------------------------------------------------------------------
  // Computed helpers
  // ---------------------------------------------------------------------------

  int get _currentStep => _currentStepIndex + 1;
  int get _totalSteps => _availableSteps.isEmpty ? 1 : _availableSteps.length;
  bool get _isFirstStep => _currentStepIndex == 0;
  bool get _isLastStep => _currentStepIndex >= _availableSteps.length - 1;

  CustomizationStep? get _currentStepType =>
      _availableSteps.isNotEmpty ? _availableSteps[_currentStepIndex] : null;

  bool get _isCurrentStepValid {
    switch (_currentStepType) {
      case CustomizationStep.uom:
        return _selectedUnit != null;
      case CustomizationStep.modifiers:
        return _validateGroups(_modifierGroups);
      case CustomizationStep.variants:
        return _validateGroups(_variantGroups);
      case null:
        return true;
    }
  }

  List<VariantGroupData> get _allGroups =>
      [..._modifierGroups, ..._variantGroups];

  // ---------------------------------------------------------------------------
  // Init
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialQuantity.clamp(1, 999);
    _buildVariantGroups();
    _buildAvailableSteps();
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

  void _buildAvailableSteps() {
    _availableSteps = [];
    if (widget.unitOptions.length > 1) {
      _availableSteps.add(CustomizationStep.uom);
    }
    if (_modifierGroups.isNotEmpty) {
      _availableSteps.add(CustomizationStep.modifiers);
    }
    if (_variantGroups.isNotEmpty) {
      _availableSteps.add(CustomizationStep.variants);
    }
  }

  void _prePopulateSelections() {
    // Unit selection
    if (widget.initialSelectedUnit != null) {
      _selectedUnit = widget.initialSelectedUnit;
    } else if (widget.unitOptions.length == 1) {
      _selectedUnit = widget.unitOptions.first;
    }

    if (widget.isEditMode && widget.initialSelectedVariants != null) {
      // Edit mode: restore previous selections
      for (final sv in widget.initialSelectedVariants!) {
        _selectedByGroup.putIfAbsent(sv.variantId, () => []).add(sv);
      }
    } else {
      // Create mode: apply default selections
      for (final group in _allGroups) {
        final defaultSelections = <SelectedVariant>[];

        // First, select all values marked as isDefault
        for (final value in group.values) {
          if (value.isDefault) {
            defaultSelections.add(_toSelectedVariant(group, value));
          }
        }

        // If no defaults found but group is required with minSelections >= 1,
        // select the first value as fallback
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

  // ---------------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------------

  void _goToNextStep() {
    if (_currentStepType == CustomizationStep.uom) {
      if (_selectedUnit == null) {
        setState(() => _uomShowError = true);
        return;
      }
      setState(() => _uomShowError = false);
    }
    if (!_validateCurrentStep()) return;
    setState(() => _currentStepIndex++);
  }

  void _goToPreviousStep() {
    setState(() => _currentStepIndex--);
  }

  bool _validateCurrentStep() {
    final errors = <int, String>{};
    final groups = _currentStepType == CustomizationStep.modifiers
        ? _modifierGroups
        : _currentStepType == CustomizationStep.variants
            ? _variantGroups
            : <VariantGroupData>[];

    for (final group in groups) {
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

  bool _validateGroups(List<VariantGroupData> groups) {
    for (final group in groups) {
      final sels = _selectedByGroup[group.variantId] ?? [];
      final total = sels.fold<double>(0, (s, v) => s + v.quantity);
      final effectiveMin = group.isRequired
          ? group.minSelections.clamp(1, 999)
          : group.minSelections;
      if (effectiveMin > 0 && total < effectiveMin) return false;
    }
    return true;
  }

  // ---------------------------------------------------------------------------
  // Confirm / Cancel
  // ---------------------------------------------------------------------------

  void _confirm() {
    // Final validation across all groups
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

  void _cancel() {
    Navigator.of(context).pop(ItemCustomizationResult.cancelled());
  }

  // ---------------------------------------------------------------------------
  // Pricing
  // ---------------------------------------------------------------------------

  List<SelectedVariant> _applyPricingRules() {
    final result = <SelectedVariant>[];

    for (final group in _allGroups) {
      final sels =
          List<SelectedVariant>.from(_selectedByGroup[group.variantId] ?? []);
      final rule = group.pricingRule;
      final freeCount = group.pricingRuleFreeItemsCount;

      switch (rule) {
        case 3: // allFree
          for (final s in sels) {
            result.add(s.copyWith(isFree: true));
          }
          break;
        case 2: // onlyFirstFree - free items based on TOTAL QUANTITY
          final effectiveFreeCount = freeCount > 0 ? freeCount : 0;
          double freeQtyRemaining = effectiveFreeCount.toDouble();

          for (final s in sels) {
            if (freeQtyRemaining >= s.quantity) {
              // All quantity of this variant is free
              result.add(s.copyWith(isFree: true));
              freeQtyRemaining -= s.quantity;
            } else if (freeQtyRemaining > 0) {
              // Partial: some free, some paid
              // Split into two entries: free portion and paid portion
              final freeQty = freeQtyRemaining;
              final paidQty = s.quantity - freeQty;

              result.add(s.copyWith(isFree: true, quantity: freeQty));
              result.add(s.copyWith(isFree: false, quantity: paidQty));
              freeQtyRemaining = 0;
            } else {
              // No more free items, all paid
              result.add(s.copyWith(isFree: false));
            }
          }
          break;
        default: // noFree (1) or unset (0)
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
      (sum, v) => sum + (v.isFree ? 0 : _effectivePrice(v) * v.quantity),
    );
    return base + variantTotal;
  }

  double _effectivePrice(SelectedVariant v) {
    return v.price;
  }

  // ---------------------------------------------------------------------------
  // Live total — applies pricing rules so free items don't add to display price
  // ---------------------------------------------------------------------------

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
        case 3: // allFree — none add to price
          break;
        case 2: // onlyFirstFree — first N items (by quantity) are free
          final effectiveFreeCount = freeCount > 0 ? freeCount : 0;
          double freeQtyRemaining = effectiveFreeCount.toDouble();

          for (final s in sels) {
            if (freeQtyRemaining >= s.quantity) {
              // All quantity is free, no cost added
              freeQtyRemaining -= s.quantity;
            } else if (freeQtyRemaining > 0) {
              // Partial: charge only the non-free portion
              final paidQty = s.quantity - freeQtyRemaining;
              variantTotal += s.price * paidQty;
              freeQtyRemaining = 0;
            } else {
              // No more free items, full charge
              variantTotal += s.price * s.quantity;
            }
          }
          break;
        default: // noFree (1) or unset (0) — all charged
          for (final s in sels) {
            variantTotal += s.price * s.quantity;
          }
      }
    }

    return base + variantTotal;
  }

  // ---------------------------------------------------------------------------
  // Variant toggle / quantity handlers
  // ---------------------------------------------------------------------------

  Future<void> _onToggleVariant(
      VariantGroupData group, VariantValueOption option) async {
    final sels =
        List<SelectedVariant>.from(_selectedByGroup[group.variantId] ?? []);
    final idx =
        sels.indexWhere((s) => s.variantValueId == option.variantValueId);

    if (idx >= 0) {
      // Deselect
      sels.removeAt(idx);
    } else {
      // Check max selections based on total quantity
      final totalQty = sels.fold<double>(0, (s, v) => s + v.quantity);
      if (group.maxSelections > 0 && totalQty >= group.maxSelections) {
        await showMaxSelectionsExceededPopup(
          context: context,
          group: group,
          currentTotal: totalQty,
        );
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
      // treat as deselect
      setState(() {
        final sels =
            List<SelectedVariant>.from(_selectedByGroup[group.variantId] ?? [])
              ..removeWhere((s) => s.variantValueId == variantValueId);
        _selectedByGroup = Map.from(_selectedByGroup)..[group.variantId] = sels;
      });
      return;
    }

    // Check max quantity per individual modifier
    if (group.maxQtyPerModifier > 0 && newQty > group.maxQtyPerModifier) {
      await showMaxQtyPerModifierExceededPopup(
        context: context,
        group: group,
        maxQty: group.maxQtyPerModifier,
      );
      return;
    }

    // Check total quantity against group maxSelections
    final sels =
        List<SelectedVariant>.from(_selectedByGroup[group.variantId] ?? []);

    // Calculate total quantity excluding current item, then add new quantity
    final otherItemsQty = sels
        .where((s) => s.variantValueId != variantValueId)
        .fold<double>(0, (sum, s) => sum + s.quantity);
    final newTotalQty = otherItemsQty + newQty;

    if (group.maxSelections > 0 && newTotalQty > group.maxSelections) {
      await showMaxSelectionsExceededPopup(
        context: context,
        group: group,
        currentTotal: otherItemsQty,
      );
      return;
    }

    setState(() {
      final idx = sels.indexWhere((s) => s.variantValueId == variantValueId);
      if (idx >= 0) {
        sels[idx] = sels[idx].copyWith(quantity: newQty);
      }
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

  // ---------------------------------------------------------------------------
  // Build — layout aligned with [KioskProductCustomizationSheet]
  // ---------------------------------------------------------------------------

  String _localizedStepTitle() {
    switch (_currentStepType) {
      case CustomizationStep.uom:
        return translator(arText: 'الحجم', enText: 'Size');
      case CustomizationStep.modifiers:
        return translator(arText: 'الإضافات', enText: 'Modifiers');
      case CustomizationStep.variants:
        return translator(arText: 'الخيارات', enText: 'Options');
      case null:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: EdgeInsets.symmetric(
        horizontal: screenSize.width * 0.025,
        vertical: screenSize.height * 0.04,
      ),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: screenSize.width * 0.95,
        height: screenSize.height * 0.92,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: ColoredBox(
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeroImage(),
                      _buildProductInfoBlock(),
                      const Divider(height: 1),
                      _buildStepChipsRow(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: _buildCurrentStepContent(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _buildKioskStyleFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroImage() {
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: 220,
          child: buildImage(widget.imageId ?? '',
              width: double.infinity, height: 220),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: GestureDetector(
            onTap: _cancel,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductInfoBlock() {
    final calories = widget.numberOfCalories;
    final steps = widget.numberOfSteps;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  widget.menuItemName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CurrencyDisplayWidget(
                    width: 20,
                    height: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _liveTotalPrice.toStringAsFixed(2),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _kioskTotalGreen,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (calories != null || steps != null) ...[
            const SizedBox(height: 12),
            Text(
              translator(arText: 'التغذية', enText: 'Nutrition'),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 10,
              runSpacing: 6,
              children: [
                if (calories != null)
                  KioskStyleNutritionTag(
                    icon: Icons.local_fire_department,
                    iconColor: const Color(0xFFFF6A00),
                    label: '$calories Cal',
                  ),
                if (steps != null)
                  KioskStyleNutritionTag(
                    icon: Icons.directions_run,
                    iconColor: const Color(0xFF2F5BFF),
                    label: '$steps Min',
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStepChipsRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: widget.isEditMode
                  ? Colors.orange.shade50
                  : Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.isEditMode
                  ? translator(arText: 'تعديل', enText: 'Edit')
                  : translator(arText: 'تخصيص', enText: 'Customize'),
              style: TextStyle(
                fontSize: 11,
                color: widget.isEditMode
                    ? Colors.orange.shade800
                    : Colors.green.shade800,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_localizedStepTitle()} · $_currentStep / $_totalSteps',
              style: TextStyle(
                fontSize: 11,
                color: _accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStepType) {
      case CustomizationStep.uom:
        return _buildUomKioskStyle();
      case CustomizationStep.modifiers:
        return _buildGroupSectionsColumn(_modifierGroups);
      case CustomizationStep.variants:
        return _buildGroupSectionsColumn(_variantGroups);
      case null:
        return Center(
          child: Text(
            translator(
                arText: 'لا توجد خيارات متاحة', enText: 'No options available'),
            style: const TextStyle(color: Colors.grey),
          ),
        );
    }
  }

  Widget _buildUomKioskStyle() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: KioskStyleSectionHeader(
              title: translator(arText: 'اختر الحجم', enText: 'Choose Size'),
              isRequired: true,
              selectCount: 1,
              selectedCount: _selectedUnit != null ? 1 : 0,
            ),
          ),
          if (_uomShowError) ...[
            const SizedBox(height: 4),
            Text(
              translator(
                  arText: 'يرجى اختيار الحجم', enText: 'Please select a size.'),
              style: const TextStyle(color: Color(0xFFAF2A26), fontSize: 11),
            ),
          ],
          const SizedBox(height: 10),
          LayoutBuilder(builder: (context, constraints) {
            const cols = 4;
            const spacing = 6.0;
            final tileW = (constraints.maxWidth - spacing * (cols - 1)) / cols;
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
                  onTap: () => setState(() {
                    _selectedUnit = unit;
                    _uomShowError = false;
                  }),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGroupSectionsColumn(List<VariantGroupData> groups) {
    if (groups.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groups
          .map(
            (group) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: KioskStyleCustomizationGroupSection(
                group: group,
                selections: _selectedByGroup[group.variantId] ?? [],
                errorMessage: _validationErrors[group.variantId],
                onToggleVariant: (opt) => _onToggleVariant(group, opt),
                onUpdateQuantity: (id, qty) =>
                    _onUpdateQuantity(group, id, qty),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildKioskStyleFooter() {
    final total = _liveTotalPrice;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
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
                  child: Text(
                    '$_quantity',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
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
          if (!_isFirstStep) ...[
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: _goToPreviousStep,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey.shade700,
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              child: Text(translator(arText: 'رجوع', enText: 'Back')),
            ),
          ],
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: _isLastStep ? _confirm : _goToNextStep,
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
                    _isLastStep
                        ? (widget.isEditMode
                            ? translator(arText: 'تحديث', enText: 'Update')
                            : translator(arText: 'إضافة', enText: 'Add'))
                        : translator(arText: 'التالي', enText: 'Next'),
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  if (_isLastStep) ...[
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
                    Text(
                      total.toStringAsFixed(2),
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const Text(')', style: TextStyle(fontSize: 15)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
