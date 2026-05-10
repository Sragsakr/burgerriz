import 'package:flutter/material.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/menu_widget/components/kiosk_product_image_helpers.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/currency_display_widget.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/data/models/menu_item/item_customization_result.dart';
import 'package:kiosk_point_of_sale/data/models/menu_item/menu_item_details.dart';
import 'package:kiosk_point_of_sale/data/models/menu_item/selected_variant.dart';
import 'package:kiosk_point_of_sale/data/models/sync_product/sync_product_model.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/menu_widget/components/item_customization/models/variant_group_data.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/menu_widget/components/item_customization/widgets/kiosk_style_customization_widgets.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/menu_widget/components/item_customization/widgets/validation_popup.dart';

/// Full-screen product detail sheet that shows all customization groups
/// (UOM, modifiers, variants) stacked vertically — no step-by-step wizard.
///
/// Returns [ItemCustomizationResult] via [Navigator.pop].
class KioskProductCustomizationSheet extends StatefulWidget {
  final SyncProduct product;
  final List<MenuItemDetails> unitOptions;
  final List<Map<String, dynamic>> variants;
  final bool isVatExclusive;
  final double taxRate;
  final int initialQuantity;
  final Color themeColor;

  /// When true, seed UOM and variant selections from [initialSelectedUnit] /
  /// [initialSelectedVariants] instead of defaults (cart edit parity).
  final bool isEditMode;
  final MenuItemDetails? initialSelectedUnit;
  final List<SelectedVariant>? initialSelectedVariants;

  const KioskProductCustomizationSheet({
    super.key,
    required this.product,
    required this.unitOptions,
    required this.variants,
    this.isVatExclusive = false,
    this.taxRate = 0.0,
    this.initialQuantity = 1,
    required this.themeColor,
    this.isEditMode = false,
    this.initialSelectedUnit,
    this.initialSelectedVariants,
  });

  @override
  State<KioskProductCustomizationSheet> createState() =>
      _KioskProductCustomizationSheetState();
}

class _KioskProductCustomizationSheetState
    extends State<KioskProductCustomizationSheet> {
  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  MenuItemDetails? _selectedUnit;
  Map<int, List<SelectedVariant>> _selectedByGroup = {};
  Map<int, String> _validationErrors = {};
  bool _uomError = false;
  int _quantity = 1;

  // ---------------------------------------------------------------------------
  // Group data
  // ---------------------------------------------------------------------------

  List<VariantGroupData> _modifierGroups = [];
  List<VariantGroupData> _variantGroups = [];

  List<VariantGroupData> get _allGroups =>
      [..._modifierGroups, ..._variantGroups];

  // ---------------------------------------------------------------------------
  // Scroll + keys for scroll-to-error
  // ---------------------------------------------------------------------------

  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _groupKeys = {};
  final GlobalKey _uomKey = GlobalKey();

  // ---------------------------------------------------------------------------
  // Init
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialQuantity.clamp(1, 999);
    _buildVariantGroups();
    _prePopulateSelections();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _buildVariantGroups() {
    final all =
        widget.variants.map((v) => VariantGroupData.fromMap(v)).toList();
    _modifierGroups = all.where((g) => g.isModifier).toList()
      ..sort(VariantGroupData.compareByPriority);
    _variantGroups = all.where((g) => !g.isModifier).toList()
      ..sort(VariantGroupData.compareByPriority);
    for (final g in _allGroups) {
      _groupKeys[g.variantId] = GlobalKey();
    }
  }

  void _prePopulateSelections() {
    if (widget.initialSelectedUnit != null) {
      _selectedUnit = widget.initialSelectedUnit;
    } else if (widget.unitOptions.length == 1) {
      _selectedUnit = widget.unitOptions.first;
    }

    if (widget.isEditMode && widget.initialSelectedVariants != null) {
      _selectedByGroup = {};
      for (final sv in widget.initialSelectedVariants!) {
        _selectedByGroup.putIfAbsent(sv.variantId, () => []).add(sv);
      }
    } else {
      for (final group in _allGroups) {
        final defaults = <SelectedVariant>[];
        for (final v in group.values) {
          if (v.isDefault) defaults.add(_toSelectedVariant(group, v));
        }
        if (defaults.isEmpty &&
            group.isRequired &&
            group.minSelections >= 1 &&
            group.values.isNotEmpty) {
          defaults.add(_toSelectedVariant(group, group.values.first));
        }
        if (defaults.isNotEmpty) {
          _selectedByGroup[group.variantId] = defaults;
        }
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Validate
  // ---------------------------------------------------------------------------

  bool _validateAll() {
    final errors = <int, String>{};
    bool uomErr = false;

    if (widget.unitOptions.length > 1 && _selectedUnit == null) {
      uomErr = true;
    }

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

    setState(() {
      _validationErrors = errors;
      _uomError = uomErr;
    });

    if (uomErr) {
      _scrollToKey(_uomKey);
      return false;
    }
    if (errors.isNotEmpty) {
      final key = _groupKeys[errors.keys.first];
      if (key != null) _scrollToKey(key);
      return false;
    }
    return true;
  }

  void _scrollToKey(GlobalKey key) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = key.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0.1,
        );
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Confirm / Cancel
  // ---------------------------------------------------------------------------

  void _confirm() {
    if (!_validateAll()) return;

    final processed = _applyPricingRules();
    final unit = _selectedUnit ??
        (widget.unitOptions.isNotEmpty ? widget.unitOptions.first : null);

    Navigator.of(context).pop(ItemCustomizationResult(
      selectedUnit: unit,
      selectedVariants: processed,
      totalPrice: _getTotalPrice(processed),
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
        case 3:
          for (final s in sels) {
            result.add(s.copyWith(isFree: true));
          }
          break;
        case 2:
          final effectiveFree = freeCount > 0 ? freeCount : 0;
          double freeLeft = effectiveFree.toDouble();
          for (final s in sels) {
            if (freeLeft >= s.quantity) {
              result.add(s.copyWith(isFree: true));
              freeLeft -= s.quantity;
            } else if (freeLeft > 0) {
              result
                ..add(s.copyWith(isFree: true, quantity: freeLeft))
                ..add(
                    s.copyWith(isFree: false, quantity: s.quantity - freeLeft));
              freeLeft = 0;
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

  double _getTotalPrice(List<SelectedVariant> processed) {
    final base = _selectedUnit?.price ??
        (widget.unitOptions.isNotEmpty ? widget.unitOptions.first.price : 0.0);
    return base +
        processed.fold<double>(
            0, (s, v) => s + (v.isFree ? 0 : v.price * v.quantity));
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
          final effectiveFree = freeCount > 0 ? freeCount : 0;
          double freeLeft = effectiveFree.toDouble();
          for (final s in sels) {
            if (freeLeft >= s.quantity) {
              freeLeft -= s.quantity;
            } else if (freeLeft > 0) {
              variantTotal += s.price * (s.quantity - freeLeft);
              freeLeft = 0;
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

  // ---------------------------------------------------------------------------
  // Variant interaction handlers
  // ---------------------------------------------------------------------------

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
        if (group.maxSelections == 1) {
          // Single-select group: swap instead of showing error
          sels.clear();
          sels.add(_toSelectedVariant(group, option));
        } else {
          await showMaxSelectionsExceededPopup(
            context: context,
            group: group,
            currentTotal: totalQty,
          );
          return;
        }
      } else {
        sels.add(_toSelectedVariant(group, option));
      }
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
        context: context,
        group: group,
        maxQty: group.maxQtyPerModifier,
      );
      return;
    }

    final sels =
        List<SelectedVariant>.from(_selectedByGroup[group.variantId] ?? []);
    final otherQty = sels
        .where((s) => s.variantValueId != variantValueId)
        .fold<double>(0, (s, v) => s + v.quantity);

    if (group.maxSelections > 0 && otherQty + newQty > group.maxSelections) {
      await showMaxSelectionsExceededPopup(
        context: context,
        group: group,
        currentTotal: otherQty,
      );
      return;
    }

    setState(() {
      final idx = sels.indexWhere((s) => s.variantValueId == variantValueId);
      if (idx >= 0) sels[idx] = sels[idx].copyWith(quantity: newQty);
      _selectedByGroup = Map.from(_selectedByGroup)..[group.variantId] = sels;
    });
  }

  Future<void> _onSelectAll(VariantGroupData group) async {
    final wouldSelect = group.values.length;
    if (group.maxSelections > 0 && wouldSelect > group.maxSelections) {
      await showSelectAllExceededPopup(
        context: context,
        group: group,
        wouldSelect: wouldSelect,
        maxAllowed: group.maxSelections,
      );
      return;
    }
    setState(() {
      _selectedByGroup = Map.from(_selectedByGroup)
        ..[group.variantId] =
            group.values.map((o) => _toSelectedVariant(group, o)).toList();
      _validationErrors.remove(group.variantId);
    });
  }

  void _onDeselectAll(VariantGroupData group) {
    setState(() {
      _selectedByGroup = Map.from(_selectedByGroup)..[group.variantId] = [];
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
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final productName = isAr ? widget.product.nameAr : widget.product.nameEn;

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
                controller: _scrollController,
                child: ColoredBox(
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImageSection(),
                      _buildProductInfo(productName),
                      const Divider(height: 1),
                      if (widget.unitOptions.length > 1)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                          child: _buildUomSection(),
                        ),
                      ..._allGroups.map((group) => Padding(
                            key: _groupKeys[group.variantId],
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                            child: KioskStyleCustomizationGroupSection(
                              group: group,
                              selections:
                                  _selectedByGroup[group.variantId] ?? [],
                              errorMessage: _validationErrors[group.variantId],
                              onToggleVariant: (opt) =>
                                  _onToggleVariant(group, opt),
                              onUpdateQuantity: (id, qty) =>
                                  _onUpdateQuantity(group, id, qty),
                            ),
                          )),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: 260,
          child: buildSyncProductImage(widget.product),
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

  Widget _buildProductInfo(String productName) {
    final calories = widget.product.numberOfCalories;
    final steps = widget.product.numberOfSteps;

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
                  productName,
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
                      color: Color(0xFF189e55),
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

  // UOM section — same style as group sections: f5f5f5 background, header in grey.shade100 rounded box
  Widget _buildUomSection() {
    final hasError = _uomError;
    return Container(
      key: _uomKey,
      // decoration: _sectionDecoration(hasError),
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
          if (hasError) ...[
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
                    _uomError = false;
                  }),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final total = _liveTotalPrice;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Quantity selector
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                KioskStyleQtyButton(
                  themeColor: widget.themeColor,
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
                  themeColor: widget.themeColor,
                  icon: Icons.add,
                  onTap: () => setState(() => _quantity++),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Add to cart button
          Expanded(
            child: FilledButton(
              onPressed: _confirm,
              style: FilledButton.styleFrom(
                backgroundColor: widget.themeColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    translator(arText: 'أضف إلى السلة', enText: 'Add To Cart'),
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
                  Text(
                    total.toStringAsFixed(2),
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const Text(')', style: TextStyle(fontSize: 15)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _sectionDecoration(bool hasError) => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasError ? const Color(0xFFAF2A26) : Colors.grey.shade200,
          width: hasError ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      );
}
