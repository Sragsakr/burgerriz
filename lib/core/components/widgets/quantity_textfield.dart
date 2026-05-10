import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/quantity_input_dialog.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_dialogs.dart';
import 'package:kiosk_point_of_sale/core/helpers/menu_product_tap_handler.dart';
import 'package:kiosk_point_of_sale/core/helpers/responsive_helper.dart';
import 'package:kiosk_point_of_sale/core/services/variations_services/variation_comparison_service.dart';
import 'package:kiosk_point_of_sale/data/models/cart_item.dart';
import 'package:kiosk_point_of_sale/data/models/menu_item/selected_variant.dart';
import 'package:kiosk_point_of_sale/data/models/sync_product/sync_product_model.dart';
import 'package:kiosk_point_of_sale/providers/cart_provider.dart';
import 'package:kiosk_point_of_sale/providers/payment_breakdown_provider.dart';

class QuantityTextField extends ConsumerStatefulWidget {
  final String productId;
  final int unitId;
  final num initialQuantity;
  final bool allowDecimal;
  final List<SingleVariationWithPrice> variations;
  final List<SelectedVariant>? selectedVariants;
  final List<ComboMealItem>? comboItems;
  final bool? isComboMeal;
  final Function() onDelete;
  bool fromMenu;
  SyncProduct? product;

  QuantityTextField({
    required this.productId,
    required this.unitId,
    required this.initialQuantity,
    required this.variations,
    this.selectedVariants,
    this.comboItems,
    this.isComboMeal,
    required this.onDelete,
    this.product,
    this.fromMenu = false,
    required this.allowDecimal,
    super.key,
  });

  @override
  ConsumerState<QuantityTextField> createState() => QuantityTextFieldState();
}

class QuantityTextFieldState extends ConsumerState<QuantityTextField> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initialQuantity.toString());
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _updateQuantity(String value) {
    if (value.isEmpty) {
      ref.read(cartProvider.notifier).updateQuantity(widget.productId, widget.unitId, 1, widget.variations,
          selectedVariants: widget.selectedVariants, comboItems: widget.comboItems, isComboMeal: widget.isComboMeal);
    } else {
      final newQuantity = double.tryParse(value);
      if (newQuantity != null && newQuantity > 0) {
        ref.read(cartProvider.notifier).updateQuantity(widget.productId, widget.unitId, newQuantity, widget.variations,
            selectedVariants: widget.selectedVariants, comboItems: widget.comboItems, isComboMeal: widget.isComboMeal);
      }
    }
  }

  void _incrementQuantity() {
    final currentQuantity = double.tryParse(controller.text) ?? 1;
    final newQuantity = currentQuantity + 1;
    ref.read(cartProvider.notifier).updateQuantity(widget.productId, widget.unitId, newQuantity, widget.variations,
        selectedVariants: widget.selectedVariants, comboItems: widget.comboItems, isComboMeal: widget.isComboMeal);
  }

  void _decrementQuantity() {
    final currentQuantity = double.tryParse(controller.text) ?? 1;
    if (currentQuantity > 1) {
      final newQuantity = currentQuantity - 1;
      ref.read(cartProvider.notifier).updateQuantity(widget.productId, widget.unitId, newQuantity, widget.variations,
          selectedVariants: widget.selectedVariants, comboItems: widget.comboItems, isComboMeal: widget.isComboMeal);
    }
  }

  @override
  Widget build(BuildContext context) {
    final backGroundColor = ref.watch(reportGroupThemeProvider).accentColor;
    final cartItems = ref.watch(cartProvider);
    if (cartItems.isNotEmpty) {
      final currentItem = cartItems.firstWhereOrNull((item) =>
          item.productId == widget.productId &&
          item.unitId == widget.unitId &&
          item.isComboMeal == (widget.isComboMeal ?? false) &&
          VariationComparisonService.areVariationsEqual(item.variations, widget.variations) &&
          item.hasSameVariants(widget.selectedVariants ?? []) &&
          VariationComparisonService.areComboItemsEqual(item.comboItems, widget.comboItems));
      if (currentItem != null) {
        if (controller.text != currentItem.quantity.toString()) {
          controller.text = currentItem.quantity.toString();
        }
      } else {
        controller.text = widget.initialQuantity.toString();
      }
    }
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final isDelete = (double.tryParse(controller.text) ?? 1) == 1;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        // width: MediaQuery.sizeOf(context).width * 0.35,
        height: MediaQuery.sizeOf(context).height * 0.04,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (widget.fromMenu) ...[
              if (widget.initialQuantity > 0)
                if (!widget.allowDecimal)
                  IconButton(
                    onPressed: isDelete ? widget.onDelete : _decrementQuantity,
                    icon: Icon(isDelete ? Icons.delete : Icons.remove, color: Colors.red),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      shape: const CircleBorder(),
                    ),
                  ),
              if (widget.initialQuantity > 0)
                InkWell(
                  onTap: () async {
                    final result = await showAppDialog<String>(
                      context: context,
                      builder: (context) => QuantityInputDialog(
                        value: controller.text,
                        allowDecimal: widget.allowDecimal,
                      ),
                    );
                    if (result != null) {
                      _updateQuantity(result);
                    }
                  },
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      controller.text,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              if (!widget.allowDecimal)
                IconButton(
                  onPressed: () {
                    if (widget.initialQuantity > 0) {
                      _incrementQuantity();
                    } else if (widget.product != null) {
                      ProductTapHandler.handleProductTap(
                        context,
                        ref,
                        widget.product!,
                        isEnglish,
                        false,
                      );
                    }
                  },
                  icon: const Icon(Icons.add, color: Color(0xFF4CAF50)),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50).withOpacity(0.2),
                    shape: const CircleBorder(),
                  ),
                ),
            ] else ...[
              if (widget.initialQuantity > 0)
                if (!widget.allowDecimal)
                  buildHomeIcon(
                    icon: isDelete ? Icons.delete : Icons.remove,
                    onTap: isDelete ? widget.onDelete : _decrementQuantity,
                    color: isDelete ? Colors.red : backGroundColor,
                  ),
              if (widget.initialQuantity > 0)
                Flexible(
                  
                  child: InkWell(
                    onTap: () async {
                      final result = await showAppDialog<String>(
                        context: context,
                        builder: (context) => QuantityInputDialog(
                          value: controller.text,
                          allowDecimal: widget.allowDecimal,
                        ),
                      );
                      if (result != null) {
                        _updateQuantity(result);
                      }
                    },
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        controller.text,
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              if (!widget.allowDecimal)
                buildHomeIcon(
                    icon: Icons.add,
                    color: backGroundColor,
                    onTap: () {
                      if (widget.initialQuantity > 0) {
                        _incrementQuantity();
                      } else if (widget.product != null) {
                        ProductTapHandler.handleProductTap(
                          context,
                          ref,
                          widget.product!,
                          isEnglish,
                          false,
                        );
                      }
                    })
            ],
          ],
        ),
      ),
    );
  }

  Widget buildHomeIcon({
    required IconData icon,
    required GestureTapCallback onTap,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 0.0),
      child: InkWell(
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: onTap,
        onDoubleTap: onTap,
        child: Material(
          color: Colors.transparent,
          elevation: 3.0,
          shape: const CircleBorder(),
          child: Container(
            width: 30.0,
            height: 30.0,
            decoration: BoxDecoration(
              color: color ?? const Color(0xFFAF2A26),
              shape: BoxShape.circle,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: const AlignmentDirectional(0.0, 0.0),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
