import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiosk_point_of_sale/core/colors/app_colors.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/currency_display_widget.dart';
import 'package:kiosk_point_of_sale/core/extentions/app_extentions.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/services/order_services/order_calculator.dart';
import 'package:kiosk_point_of_sale/data/models/cart_item.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_items_model.dart';
import 'package:kiosk_point_of_sale/providers/cart_provider.dart';
import 'package:kiosk_point_of_sale/providers/order_summary_provider.dart';
import 'package:kiosk_point_of_sale/providers/payment_breakdown_provider.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/cart/cart_helper.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/cart/cart_widget.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/cart/kiosk_cart_line_item.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/cart/delete_order_widget.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/pay_widget/pay_now_widget.dart';

import '../../../../core/services/loading_services/enhanced_loading_service.dart';
import '../../../../data/models/sales_models/sales_invoice.dart';

class MenuCartSummaryBar extends ConsumerWidget {
  const MenuCartSummaryBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final itemCount = cartItems.length;
    final themeColor = ref.watch(reportGroupThemeProvider).accentColor;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8.0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // My Order Header Bar
          InkWell(
            onTap: () {
              _showCartBottomSheet(context, ref);
            },
            child: Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: themeColor,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left side - My Order with badge
                  Row(
                    children: [
                      Icon(
                        Icons.keyboard_arrow_up,
                        color: Colors.white,
                        size: 24.0,
                      ),
                      const SizedBox(width: 8.0),
                      AutoSizeText(
                        translator(arText: 'طلبي', enText: 'My Order'),
                        maxLines: 1,
                        minFontSize: 14,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  // Right side - Cart status
                  Row(
                    children: [
                      AutoSizeText(
                        itemCount > 0
                            ? '$itemCount ${translator(arText: 'عناصر', enText: 'items')}'
                            : translator(
                                arText: 'السلة فارغة', enText: 'Cart Empty'),
                        maxLines: 1,
                        minFontSize: 14,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Stack(
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            color: Colors.white,
                            size: 24.0,
                          ),
                          if (itemCount > 0)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16.0,
                                  minHeight: 16.0,
                                ),
                                child: Text(
                                  itemCount.toString(),
                                  style: TextStyle(
                                    color: themeColor,
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Container(
            color: Colors.white,
            height: 4.h,
            child: Row(
              children: [
                Expanded(
                  child: Material(
                    color: Colors.white,
                    child: InkWell(
                      onTap: () async {
                        await showModalBottomSheet(
                          isScrollControlled: false,
                          backgroundColor: AppColors.overlayTransparent,
                          enableDrag: false,
                          context: context,
                          builder: (context) {
                            return GestureDetector(
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                FocusManager.instance.primaryFocus?.unfocus();
                              },
                              child: Padding(
                                padding: MediaQuery.viewInsetsOf(context),
                                child: DeleteOrderWidget(),
                              ),
                            );
                          },
                        );
                      },
                      child: Center(
                        child: AutoSizeText(
                          translator(
                              arText: 'إلغاء الطلب', enText: 'Cancel Order'),
                          maxLines: 1,
                          minFontSize: 12,
                          style: TextStyle(
                            color: AppColors.gray700,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Material(
                    color: const Color(0xFF249689),
                    child: InkWell(
                      onTap: itemCount > 0
                          ? () {
                              context.pushNamed(CartWidget.routeName);
                            }
                          : null,
                      child: Center(
                        child: AutoSizeText(
                          translator(
                              arText: 'الذهاب إلى السلة', enText: 'Go to Cart'),
                          maxLines: 1,
                          minFontSize: 12,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Action Buttons Row
        ],
      ),
    );
  }

  void _showCartBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      sheetAnimationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 400),
        reverseDuration: Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
      builder: (sheetContext) {
        final animation = ModalRoute.of(sheetContext)!.animation!;
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.06),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            ),
          ),
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: const Interval(0.0, 0.85, curve: Curves.easeOut),
            ),
            child: _CartBottomSheet(),
          ),
        );
      },
    );
  }
}

class _CartBottomSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderSummaryAsync = ref.watch(orderSummaryProvider);
    final saleType = ref.watch(saleTypeNotifier);
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final cartItems = ref.watch(cartProvider);
    final themeColor = ref.watch(reportGroupThemeProvider).accentColor;
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12.0),
              width: 40.0,
              height: 4.0,
              decoration: BoxDecoration(
                color: AppColors.gray400,
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          // Header
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20.0),
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            decoration: BoxDecoration(
              color: themeColor,
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left side - Icon with badge and My Order
                Row(
                  children: [
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: const Icon(
                            Icons.receipt_long_outlined,
                            color: Colors.white,
                            size: 24.0,
                          ),
                        ),
                        if (cartItems.isNotEmpty)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4.0),
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                cartItems.length.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12.0),
                    AutoSizeText(
                      translator(arText: 'طلبي', enText: 'My Order'),
                      maxLines: 1,
                      minFontSize: 14,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                // Right side - Sale Type
                AutoSizeText(
                  saleType != null
                      ? (isEnglish ? saleType.nameEn : saleType.nameAr)
                      : translator(
                          arText: 'تناول في المكان', enText: 'Dine-In'),
                  maxLines: 1,
                  minFontSize: 12,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          // Cart Items List
          Expanded(
            child: orderSummaryAsync.when(
              data: (orderSummary) {
                final orderItems = orderSummary.salesInvoice.salesOrderItems;
                return _buildCartItemsList(
                    context, ref, cartItems, orderItems, isEnglish);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text(
                  translator(arText: 'حدث خطأ', enText: 'Error loading cart'),
                  style: TextStyle(color: AppColors.gray700),
                ),
              ),
            ),
          ),
          // Footer
          orderSummaryAsync.when(
            data: (orderSummary) =>
                _buildFooter(context, ref, orderSummary, themeColor),
            loading: () => _buildFooterLoading(),
            error: (error, stack) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemsList(
    BuildContext context,
    WidgetRef ref,
    List<CartItem> cartItems,
    List<SalesItemsModel> orderItems,
    bool isEnglish,
  ) {
    if (cartItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 80.0,
              color: AppColors.gray400,
            ),
            const SizedBox(height: 16.0),
            AutoSizeText(
              translator(arText: 'السلة فارغة', enText: 'Your cart is empty'),
              maxLines: 1,
              minFontSize: 14,
              style: TextStyle(
                color: AppColors.gray700,
                fontSize: 18.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: cartItems.length,
      itemBuilder: (context, index) {
        final item = cartItems[index];
        final salesItem = orderItems.isNotEmpty
            ? orderItems
                .where((element) => element.productId == item.productId)
                .firstOrNull
            : null;
        return KioskCartLineItem(
          item: item,
          isEnglish: isEnglish,
          salesItem: salesItem,
          cartIndex: index,
          orderItems: orderItems,
          enableDismissible: false,
        );
      },
    );
  }

  Widget _buildFooter(BuildContext context, WidgetRef ref,
      OrderSummary orderSummary, Color themeColor) {
    final cartItems = ref.watch(cartProvider);
    final itemCount = cartItems.length;
    final totalAmount = orderSummary.totalAmount;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8.0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Price Section
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                decoration: BoxDecoration(
                  color: themeColor,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4.0),
                          child: const CurrencyDisplayWidget(
                            variant: CurrencyVisualVariant.white,
                            width: 20.0,
                            height: 20.0,
                            textStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6.0),
                        Text(
                          totalAmount.toStringAsFixed(2),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      translator(
                          arText: 'شامل الضريبة', enText: 'VAT included'),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12.0),
            // Checkout Button
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 56.0,
                child: ElevatedButton(
                  onPressed: itemCount > 0
                      ? () async {
                          Navigator.of(context).pop(); // Close bottom sheet
                          enhancedLoadingService.showEnhancedLoading(
                            context,
                            message: translator(
                                arText: "جاري معالجة الطلب",
                                enText: "Processing Order"),
                            isLottie: true,
                          );
                          SalesInvoice finalInvoice = await CartHelper()
                              .generateTempOrder(ref, context);
                          enhancedLoadingService.hideLoading();
                          context.pushNamed(PayNowWidget.routeName,
                              extra: finalInvoice);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.black,
                    disabledBackgroundColor: Colors.white.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      side: BorderSide(color: AppColors.gray300),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    translator(arText: 'الدفع', enText: 'Checkout'),
                    style: TextStyle(
                      color: AppColors.black,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterLoading() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
