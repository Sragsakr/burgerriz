import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/currency_display_widget.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/menu_widget/components/kiosk_quantity_textfield.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/menu_widget/components/kiosk_product_image_helpers.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/clear_cart_with_prices.dart';
import 'package:kiosk_point_of_sale/core/helpers/responsive_helper.dart';
import 'package:kiosk_point_of_sale/data/models/sync_product/sync_product_model.dart';
import 'package:kiosk_point_of_sale/providers/cart_provider.dart';
import 'package:kiosk_point_of_sale/core/helpers/menu_product_tap_handler.dart';

class MenuProductCardWidget extends ConsumerWidget {
  final SyncProduct product;
  final bool isEnglish;
  final bool fromSearch;

  const MenuProductCardWidget({
    super.key,
    required this.product,
    required this.isEnglish,
    this.fromSearch = false,
  });

  static const double _cardRadius = 16.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(builder: (context, constraints) {
      final height = constraints.maxHeight - (constraints.maxHeight * 0.08);
      final width = constraints.maxWidth;

      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(_cardRadius),
          onTap: () async {
            ProductTapHandler.handleProductTap(
              context,
              ref,
              product,
              isEnglish,
              fromSearch,
            );
          },
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(_cardRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8.0,
                  offset: const Offset(0.0, 2.0),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildImageSection(height, width),
                _buildContentSection(context, height, width),
                Spacer(),
                _buildBottomSection(context, ref, height, width),
              ],
            ),
          ),
        ),
      );
    });
  }

  /// Image at top of card with rounded top corners only (aligned to card)
  Widget _buildImageSection(double height, double width) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(_cardRadius),
        topRight: Radius.circular(_cardRadius),
      ),
      child: SizedBox(
        height: height * 0.45,
        width: double.infinity,
        child: buildSyncProductImage(product),
      ),
    );
  }

  /// Content: product name (bold black), calories (red flame + dark grey), optional description
  Widget _buildContentSection(
      BuildContext context, double height, double width) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildProductName(context),
          if (product.numberOfCalories != null &&
              product.numberOfCalories != '')
            _buildCaloriesRow(context),
          // if (product.numberOfSteps != null) _buildStepsRow(context),
        ],
      ),
    );
  }

  Widget _buildProductName(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        isEnglish ? product.nameEn : product.nameAr,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
      ),
    );
  }

  /// Calories with red flame icon and "X Cal" in dark grey
  Widget _buildCaloriesRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            color: const Color(0xFFE53935),
            size: ResponsiveHelper.getResponsiveSize(context, 18),
          ),
          const SizedBox(width: 4),
          Text(
            '${product.numberOfCalories} ${translator(arText: "كالوري", enText: "Cal")}',
            style: GoogleFonts.inter(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 13),
              fontWeight: FontWeight.w500,
              color: const Color(0xFF424242),
            ),
          ),
        ],
      ),
    );
  }

  /// Steps row (secondary info, dark grey)
  Widget _buildStepsRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        '${product.numberOfSteps} ${translator(arText: "خطوة", enText: "Step")}',
        style: GoogleFonts.inter(
          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
          fontWeight: FontWeight.w400,
          color: const Color(0xFF616161),
        ),
      ),
    );
  }

  /// Bottom section: quantity (+/-) on left, price (green, prominent) on right
  Widget _buildBottomSection(
      BuildContext context, WidgetRef ref, double height, double width) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: buildQuantityTextField(ref),
        ),
        const SizedBox(width: 12),
        _buildPriceSection(context),
        const SizedBox(width: 5),
      ],
    );
  }

  /// Price: vibrant green, bold, large; currency + amount right-aligned
  static const Color _priceGreen = Color(0xFF2E7D32);

  Widget _buildPriceSection(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4.0),
          child: CurrencyDisplayWidget(
            variant: CurrencyVisualVariant.green,
            width: ResponsiveHelper.getResponsiveSize(context, 22),
            height: ResponsiveHelper.getResponsiveSize(context, 16),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          product.unitOfMeasures.isNotEmpty
              ? product.unitOfMeasures.first.price.toStringAsFixed(0)
              : '0',
          style: GoogleFonts.inter(
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 22),
            fontWeight: FontWeight.w700,
            color: _priceGreen,
          ),
        ),
      ],
    );
  }

  buildQuantityTextField(WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final item =
        cartItems.firstWhereOrNull((e) => e.productId == product.productId);

    return QuantityTextField(
      allowDecimal: item?.allowDecimal ?? false,
      productId: item?.productId ?? product.productId,
      unitId: item?.unitId ??
          (product.unitOfMeasures.isNotEmpty
              ? product.unitOfMeasures.first.unitOfMeasureId
              : 0),
      initialQuantity: item?.quantity ?? 0,
      variations: item?.variations ?? [],
      selectedVariants: item?.selectedVariants,
      comboItems: item?.comboItems,
      isComboMeal: item?.isComboMeal,
      onDelete: () {
        if (item != null) {
          ref.read(cartProvider.notifier).removeItem(
                item.productId,
                item.unitId,
                item.variations,
                selectedVariants: item.selectedVariants,
                comboItems: item.comboItems,
                isComboMeal: item.isComboMeal,
              );
          resetPaymentValues(ref);
        }
      },
      product: product,
    );
  }
}
