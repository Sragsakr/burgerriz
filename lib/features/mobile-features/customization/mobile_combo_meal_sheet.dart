import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/currency_display_widget.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/data/models/cart_item.dart';
import 'package:kiosk_point_of_sale/data/models/sync_product/sync_product_model.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/menu_widget/components/kiosk_product_image_helpers.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/menu_widget/components/combo_meal/combo_meal_package_selector.dart';
import 'package:kiosk_point_of_sale/providers/cart_provider.dart';
import 'package:kiosk_point_of_sale/providers/combo_meal_provider.dart';
import 'package:kiosk_point_of_sale/providers/payment_breakdown_provider.dart';

/// Mobile-optimized combo meal sheet for building combo meals.
class MobileComboMealSheet extends ConsumerStatefulWidget {
  final SyncProduct product;
  final double basePrice;
  final int initialQuantity;

  const MobileComboMealSheet({
    super.key,
    required this.product,
    required this.basePrice,
    required this.initialQuantity,
  });

  @override
  ConsumerState<MobileComboMealSheet> createState() =>
      _MobileComboMealSheetState();

  static Future<void> show(
    BuildContext context, {
    required SyncProduct product,
    required double basePrice,
    required int initialQuantity,
  }) {
    return showModalBottomSheet<void>(
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
        child: MobileComboMealSheet(
          product: product,
          basePrice: basePrice,
          initialQuantity: initialQuantity,
        ),
      ),
    );
  }
}

class _MobileComboMealSheetState extends ConsumerState<MobileComboMealSheet> {
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

  void _addToCart(BuildContext context) {
    final state = ref.read(comboMealProvider);
    dPrint(" comboMealCartItem price: ${state.totalPrice + widget.basePrice}");

    if (!state.isComplete || state.comboMeal == null) {
      return;
    }

    final comboItems = state.allSelectedItems.map((item) {
      dPrint("ComboMealItem ${item.name} ${item.id} ${item.menuItemId}");
      return ComboMealItem(
        comboMealPackageItemId: item.id,
        menuItemId: item.menuItemId,
        nameEn: item.name,
        nameAr: item.nameAr,
        imageUrl: item.imageId,
        price: item.price,
        quantity: _quantity.toDouble(),
        taxValue: item.taxValue,
        isVAT: item.isVAT,
      );
    }).toList();

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

    ref.read(cartProvider.notifier).addItem(comboMealCartItem);
    ref.read(comboMealProvider.notifier).reset();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(comboMealProvider);
    final themeColor = ref.watch(reportGroupThemeProvider).accentColor;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final productName = isAr ? widget.product.nameAr : widget.product.nameEn;

    return Column(
      children: [
        _buildDragHandle(),
        Expanded(
          child: state.isLoading
              ? Center(child: CircularProgressIndicator(color: themeColor))
              : state.error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 48, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(state.error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.red)),
                        ],
                      ),
                    )
                  : state.comboMeal == null
                      ? Center(
                          child: Text(translator(
                              arText: 'جاري التحميل...', enText: 'Loading...')))
                      : SingleChildScrollView(
                          controller: _scrollController,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildImageSection(),
                              _buildProductInfo(productName, state, themeColor),
                              const Divider(height: 1),
                              ...state.comboMeal!.packages
                                  .map((package) => Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            16, 16, 16, 0),
                                        child: ComboMealPackageSelector(
                                            package: package,
                                            themeColor: themeColor),
                                      )),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
        ),
        _buildBottomBar(state, themeColor),
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

  Widget _buildImageSection() {
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: 160,
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
                  shape: BoxShape.circle),
              child: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductInfo(
      String productName, ComboMealState state, Color themeColor) {
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
                  child: Text(productName,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold))),
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
                  Text((total + widget.basePrice).toStringAsFixed(2),
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green)),
                ],
              ),
            ],
          ),
          if (calories != null || steps != null) ...[
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
                if (calories != null)
                  _NutritionTag(
                      icon: Icons.local_fire_department,
                      iconColor: const Color(0xFFFF6A00),
                      label: '$calories Cal'),
                if (steps != null)
                  _NutritionTag(
                      icon: Icons.directions_run,
                      iconColor: const Color(0xFF2F5BFF),
                      label: '$steps Min'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomBar(ComboMealState state, Color themeColor) {
    final total = state.totalPrice + widget.basePrice;
    final isComplete = state.isComplete;

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
                _QtyButton(
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
                _QtyButton(
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
                    Text(total.toStringAsFixed(2),
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
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
}

class _NutritionTag extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;

  const _NutritionTag(
      {required this.icon, required this.iconColor, required this.label});

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
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600)),
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
        child: Icon(icon,
            size: 18,
            color:
                onTap != null ? const Color(0xFFAF2A26) : Colors.grey.shade400),
      ),
    );
  }
}
