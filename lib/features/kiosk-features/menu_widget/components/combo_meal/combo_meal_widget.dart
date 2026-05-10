import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/menu_widget/components/kiosk_product_image_helpers.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/currency_display_widget.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_theme.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';

import 'package:kiosk_point_of_sale/data/models/sync_product/sync_product_model.dart';
import 'package:kiosk_point_of_sale/data/models/cart_item.dart';
import 'package:kiosk_point_of_sale/providers/cart_provider.dart';
import 'package:kiosk_point_of_sale/providers/combo_meal_provider.dart';
import 'package:kiosk_point_of_sale/providers/payment_breakdown_provider.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/menu_widget/components/combo_meal/combo_meal_package_selector.dart';

/// Main widget for combo meal selection, displayed as a dialog (same shell as [KioskProductCustomizationSheet]).
class ComboMealWidget extends ConsumerStatefulWidget {
  final SyncProduct product;
  final double basePrice;
  final int initialQuantity;

  const ComboMealWidget({
    super.key,
    required this.product,
    required this.basePrice,
    required this.initialQuantity,
  });

  @override
  ConsumerState<ComboMealWidget> createState() => _ComboMealWidgetState();
}

class _ComboMealWidgetState extends ConsumerState<ComboMealWidget> {
  final ScrollController _scrollController = ScrollController();
  late int _quantity;

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialQuantity.clamp(1, 999);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(comboMealProvider);
    final screenSize = MediaQuery.of(context).size;
    final themeColor = ref.watch(reportGroupThemeProvider).accentColor;
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
              child: ColoredBox(
                color: FlutterFlowTheme.of(context).primaryBackground,
                child: _buildBody(context, state, themeColor, productName),
              ),
            ),
            _buildBottomBar(context, state, themeColor),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ComboMealState state,
    Color themeColor,
    String productName,
  ) {
    if (state.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: themeColor,
        ),
      );
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              state.error!,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    }

    if (state.comboMeal == null) {
      return Center(
        child: Text(
          translator(
            arText: 'جاري التحميل...',
            enText: 'Loading...',
          ),
          style: GoogleFonts.inter(
            fontSize: 16,
            color: FlutterFlowTheme.of(context).secondaryText,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      controller: _scrollController,
      child: ColoredBox(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(),
            _buildProductInfo(productName, state),
            const Divider(height: 1),
            ...state.comboMeal!.packages.map((package) => Padding(
                  padding: const EdgeInsets.fromLTRB(5, 16, 5, 0),
                  child: ComboMealPackageSelector(
                    package: package,
                    themeColor: themeColor,
                  ),
                )),
            const SizedBox(height: 16),
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
            onTap: () {
              ref.read(comboMealProvider.notifier).reset();
              Navigator.of(context).pop();
            },
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

  Widget _buildProductInfo(String productName, ComboMealState state) {
    final calories = widget.product.numberOfCalories;
    final steps = widget.product.numberOfSteps;
    final total = state.totalPrice;
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
                    variant: CurrencyVisualVariant.green,
                    width: 20,
                    height: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    (total + widget.basePrice).toStringAsFixed(2),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
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
                  _NutritionTag(
                    icon: Icons.local_fire_department,
                    iconColor: const Color(0xFFFF6A00),
                    label: '$calories Cal',
                  ),
                if (steps != null)
                  _NutritionTag(
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

  Widget _buildBottomBar(
      BuildContext context, ComboMealState state, Color themeColor) {
    final total = state.totalPrice + widget.basePrice;
    final isComplete = state.isComplete;
    final themeColor = ref.watch(reportGroupThemeProvider).accentColor;

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
                _QtyButton(
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
                _QtyButton(
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
              onPressed: isComplete ? () => _addToCart(context) : null,
              style: FilledButton.styleFrom(
                backgroundColor: isComplete ? themeColor : Colors.grey,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isComplete
                        ? translator(
                            arText: 'أضف إلى السلة', enText: 'Add To Cart')
                        : translator(
                            arText: 'أكمل اختياراتك',
                            enText: 'Complete your selections'),
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  if (isComplete) ...[
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
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addToCart(BuildContext context) {
    final state = ref.read(comboMealProvider);
    dPrint(" comboMealCartItem price: ${state.totalPrice + widget.basePrice}");

    if (!state.isComplete || state.comboMeal == null) {
      return;
    }

    // Create combo items list from selected items
    final comboItems = state.allSelectedItems.map((item) {
      dPrint("ComboMealItem ${item.name} ${item.id} ${item.menuItemId} ");

      return ComboMealItem(
        comboMealPackageItemId: item.id,
        menuItemId: item.menuItemId,
        nameEn: item.name,
        nameAr: item.nameAr,
        imageUrl: item.imageId,
        price: item.price,
        quantity: _quantity
            .toDouble(), // Use the new quantity! Or maybe item quantity stays 1? Wait, in previous implementation: quantity: widget.initialQuantity.toDouble(). We should use _quantity.
        taxValue: item.taxValue,
        isVAT: item.isVAT,
      );
    }).toList();
    // Create the main combo meal cart item
    final comboMealCartItem = CartItem(
      categoryId: widget.product.category?.id.toString() ?? '',
      imageUrl: widget.product.imageUrl,
      productId: widget.product.productId,
      nameEn: widget.product.nameEn,
      nameAr: widget.product.nameAr,
      itemCode: widget.product.itemCode ?? '',
      quantity: _quantity,
      price: state.totalPrice + widget.basePrice,
      unitId: 0,
      inclusive: widget.product.isExclusive,
      isComboMeal: true,
      comboItems: comboItems,
    );

    // Add to cart
    ref.read(cartProvider.notifier).addItem(comboMealCartItem);

    // Reset combo meal state and close
    ref.read(comboMealProvider.notifier).reset();
    Navigator.of(context).pop();
  }
}

class _NutritionTag extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;

  const _NutritionTag({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade500, width: 1),
        borderRadius: BorderRadius.circular(999),
        color: Colors.white,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Icon(
          icon,
          size: 18,
          color: onTap != null ? const Color(0xFFAF2A26) : Colors.grey.shade400,
        ),
      ),
    );
  }
}
