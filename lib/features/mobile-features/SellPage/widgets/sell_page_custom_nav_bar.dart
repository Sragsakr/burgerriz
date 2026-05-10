// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kiosk_point_of_sale/features/mobile-features/SellPage/widgets/product_unit_dialog.dart';
import 'package:kiosk_point_of_sale/features/mobile-features/SellPage/widgets/promotion_dialog.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/custom_snackbar_widget.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/login_dialog.dart';
import 'package:kiosk_point_of_sale/core/enums/discount_enum.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_icon_button.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_theme.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_widgets.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/internationalization.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_dialogs.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/clear_cart_with_prices.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/core/helpers/responsive_helper.dart';
import 'package:kiosk_point_of_sale/data/models/cart_item.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/sale_type_tables/sale_type_price_list_table.dart';
import 'package:kiosk_point_of_sale/providers/cart_provider.dart';
import 'package:kiosk_point_of_sale/providers/customer_provider.dart';
import 'package:kiosk_point_of_sale/providers/payment_breakdown_provider.dart';
import 'package:kiosk_point_of_sale/providers/promotion_provider.dart';
import 'package:kiosk_point_of_sale/repository/menu_item_sync_repository.dart';
import 'package:kiosk_point_of_sale/repository/promotions/promotions_services.dart';

export '../sellpage_model.dart';

class SellPageBottomNavBar extends ConsumerWidget {
  const SellPageBottomNavBar({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    ref.watch(cartProvider);
    ref.watch(paymentBreakdownProvider);
    ref.watch(promotionCatalogRevisionProvider);
    final totalAmount = ref.watch(totalAmountProvider);

    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color.fromARGB(125, 186, 186, 186),
            width: 2.0,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            BottomNavButton(
              icon: Icons.delete_outline,
              onPressed: () {
                // Clear cart
                ref.read(cartProvider.notifier).clearCart();
                resetPaymentAndCartValues(ref);
              },
            ),
            BottomNavButton(
              icon: Icons.local_offer_rounded,
              onPressed: () async {
                final customer = ref.watch(selectedCustomerProvider);
                // Check if customer is valid before applying discount
                double customerDiscountValue = 0.0;
                if (customer != null) {
                  // Check if customer has valid date range
                  if (customer.isDateRangeValid()) {
                    customerDiscountValue = customer.discountPrcnt ?? 0.0;
                  } else {
                    // Customer is not valid, don't apply discount
                    customerDiscountValue = 0.0;
                  }
                }
                if (customerDiscountValue > 0) {
                  customSnackbar(
                      context,
                      translator(
                          arText: "العميل لديه خصم لا يسمح بتطبيق أي عروض",
                          enText: "The customer has a discount not allow any offers"),
                      false);
                  return;
                }
                // Fetch offers before opening the dialog
                final offers = await PromotionsServices.instance.getActiveOffers();
                dPrint("###offers: ${offers.map((e) => e.promotionFB?.toJson())}");
                await showAppDialog(
                  context: context,
                  builder: (context) {
                    return Consumer(
                      builder: (context, ref, _) {
                        final appliedPromotions = ref.watch(appliedPromotionsProvider);
                        return PromotionDialog(
                          availableOffers: offers,
                          initialAppliedPromotions: appliedPromotions,
                          onConfirm: (newPromos) {
                            ref.read(appliedPromotionsProvider.notifier).state = List.from(newPromos);
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
            BottomNavButton(
              icon: Icons.discount,
              onPressed: () async {
                final result = kDebugMode
                    ? true
                    : await showAppDialog(context: context, builder: (context1) => const LoginDialog());
                if (result == true) {
                  final discountResult = await showDiscountInputDialog(context);
                  dPrint("discountResult $discountResult");
                }
              },
            ),
            BottomNavButton(
              icon: Icons.search,
              onPressed: () {
                context.go('/search');
              },
            ),
            BottomNavButton(
              icon: Icons.barcode_reader,
              onPressed: () async {
                // final excludedItems =
                //     await PromotionFBItemExcludedMenuItemTable.getAll();
                //     // await PromotionDetailsFBExcludedMenuItemTable.getAll();
                // dPrint(
                //     "###excludedItems: ${excludedItems.map((e) => e.toMap())}");
                await scanBarcodeManually(context, ref, isEnglish);
              },
            ),
            BottomNavButton(
              icon: Icons.payments,
              onPressed: () {
                final cartItems = ref.watch(cartProvider);

                if (cartItems.isEmpty) {
                  customSnackbar(context, FFLocalizations.of(context).getText('qwer0005'), false);
                  return;
                }
                print('payments pressed ...');
                context.go('/checkout-page');
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> scanBarcodeManually(BuildContext context, WidgetRef ref, bool isEnglish) async {
    try {
      final barcode = await showBarcodeInputDialog(context);
      if (barcode != null) {
        print('Scanned barcode: $barcode');
        final saleType = ref.watch(saleTypeNotifier.notifier);

        final priceList = await SaleTypePriceListTable.getBySaleTypeId(saleType.state?.saleTypeId ?? 0);
        final priceListId = priceList?.priceListId ?? 1;

        final product = await MenuItemSyncRepository().getProductByBarcode(barcode, priceListId);

        if (product != null) {
          final units = product.unitOfMeasures;

          if (units.isEmpty) {
            customSnackbar(context, FFLocalizations.of(context).getText('qwer0001'), false);
          } else if (!product.hasOptions) {
            final unit = units.first;
            ref.read(cartProvider.notifier).addItem(
                  CartItem(
                    imageUrl: product.imageUrl,
                    itemCode: product.itemCode ?? '',
                    inclusive: product.isExclusive,
                    categoryId: product.category?.id.toString() ?? '',
                    productId: product.productId,
                    nameEn: product.nameEn,
                    nameAr: product.nameAr,
                    quantity: 1,
                    price: unit.price,
                    unitId: unit.unitOfMeasureId,
                  ),
                );
            customSnackbar(
                context,
                '${FFLocalizations.of(context).getText('w3e4rsd1')} ${isEnglish ? product.nameEn : product.nameAr}',
                true);
          } else {
            showAppDialog(
              context: context,
              builder: (context) => ProductUnitDialog(
                product: product,
                isEnglish: isEnglish,
              ),
            );
          }
        } else {
          dPrint('Product not found');
          customSnackbar(context, FFLocalizations.of(context).getText('qwer0002'), false);
        }
      }
    } catch (e) {
      print('Error occurred while scanning: $e');
      customSnackbar(context, FFLocalizations.of(context).getText('qwer0003'), false);
    }
  }
}

class BottomNavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const BottomNavButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterFlowIconButton(
      borderColor: Colors.transparent,
      borderRadius: 28,
      borderWidth: 1,
      buttonSize: ResponsiveHelper.isMobile(context) ? 56 : 76,
      fillColor: const Color(0xFFAF2A26),
      icon: Icon(
        icon,
        color: Colors.white,
        size: ResponsiveHelper.isMobile(context) ? 28 : 40,
      ),
      onPressed: onPressed,
    );
  }
}

class BarcodeInputDialog extends ConsumerStatefulWidget {
  const BarcodeInputDialog({super.key});

  @override
  ConsumerState<BarcodeInputDialog> createState() => _BarcodeInputDialogState();
}

class _BarcodeInputDialogState extends ConsumerState<BarcodeInputDialog> {
  final TextEditingController _barcodeController = TextEditingController();
  final FocusNode _barcodeFocusNode = FocusNode();
  TextInputType keyBoardType = TextInputType.number;

  toggleKeyBoard() async {
    setState(() {
      if (keyBoardType == TextInputType.number) {
        keyBoardType = TextInputType.text;
      } else {
        keyBoardType = TextInputType.number;
      }
    });
    FocusManager.instance.primaryFocus?.unfocus();
    await Future.delayed(Duration(milliseconds: 100));
    _barcodeFocusNode.requestFocus();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _barcodeFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              translator(arText: 'ادخل الباركود', enText: 'Enter Barcode'),
              style: FlutterFlowTheme.of(context).titleMedium.copyWith(color: Colors.black),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _barcodeController,
              focusNode: _barcodeFocusNode,
              autofocus: true,
              keyboardType: keyBoardType,
              decoration: InputDecoration(
                hintText: translator(arText: 'ادخل الباركود', enText: 'Enter Barcode'),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () {
                toggleKeyBoard();
              },
              child: const Icon(Icons.keyboard_alt_outlined, color: Color(0xFFAF2A26), size: 24),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildButton(
                  context,
                  text: translator(arText: 'الغاء', enText: 'Cancel'),
                  color: Colors.grey.shade300,
                  textColor: Colors.black,
                  onPressed: () => Navigator.of(context).pop(null),
                ),
                _buildButton(
                  context,
                  text: translator(arText: 'تأكيد', enText: 'Confirm'),
                  color: Colors.green,
                  textColor: Colors.white,
                  onPressed: () {
                    if (_barcodeController.text.isEmpty) {
                      Navigator.of(context).pop(null);
                      return;
                    }
                    Navigator.of(context).pop(_barcodeController.text.trim());
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context,
      {required String text, required Color color, required Color textColor, required VoidCallback onPressed}) {
    return FFButtonWidget(
      onPressed: onPressed,
      text: text,
      options: FFButtonOptions(
        width: 100,
        height: 40,
        color: color,
        textStyle: FlutterFlowTheme.of(context).titleSmall.override(
              fontFamily: 'Readex Pro',
              color: textColor,
            ),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

// Usage example (call this where needed):
Future<String?> showBarcodeInputDialog(BuildContext context) async {
  return await showAppDialog<String>(
    context: context,
    builder: (context) => const BarcodeInputDialog(),
  );
}

class DiscountInputDialog extends ConsumerStatefulWidget {
  const DiscountInputDialog({super.key});

  @override
  ConsumerState<DiscountInputDialog> createState() => _DiscountInputDialogState();
}

class _DiscountInputDialogState extends ConsumerState<DiscountInputDialog> {
  final TextEditingController _discountController = TextEditingController();
  final FocusNode _discountFocusNode = FocusNode();

  void toggleDiscountType(DiscountType type) {
    ref.read(discountTypeProvider.notifier).state = type;
  }

  @override
  void dispose() {
    _discountController.dispose();
    _discountFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DiscountType? selectedDiscountType = ref.watch(discountTypeProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              translator(arText: 'ادخل الخصم', enText: 'Enter Discount'),
              style: FlutterFlowTheme.of(context).titleMedium.copyWith(color: Colors.black),
            ),
            const SizedBox(width: 10),
            _toggleDiscountButton(selectedDiscountType),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _discountController,
                    focusNode: _discountFocusNode,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: translator(
                          arText:
                              selectedDiscountType == DiscountType.percentage ? 'ادخل النسبة المئوية' : 'ادخل المبلغ',
                          enText:
                              selectedDiscountType == DiscountType.percentage ? 'Enter Percentage' : 'Enter Amount'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(selectedDiscountType == DiscountType.percentage ? "%" : "\$",
                            style: TextStyle(fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18))),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildButton(
                  context,
                  text: translator(arText: 'الغاء', enText: 'Cancel'),
                  color: Colors.grey.shade300,
                  textColor: Colors.black,
                  onPressed: () => Navigator.of(context).pop(null),
                ),
                _buildButton(
                  context,
                  text: translator(arText: 'تأكيد', enText: 'Confirm'),
                  color: Colors.green,
                  textColor: Colors.white,
                  onPressed: () {
                    final discountText = _discountController.text.trim();
                    ref.read(discountValueProvider.notifier).update(
                          (state) => double.tryParse(discountText) ?? 0.0,
                        );

                    if (selectedDiscountType == null) {
                      customSnackbar(
                          context, translator(arText: "حدد نوع الخصم", enText: "Select Discount Type"), false);
                      return;
                    }
                    if (discountText.isEmpty) {
                      Navigator.of(context).pop(null);
                      return;
                    }
                    final msg = selectedDiscountType == DiscountType.percentage
                        ? "${translator(arText: 'تم أضافة خصم', enText: 'Discount Added')}  $discountText%"
                        : "${translator(arText: 'تم أضافة خصم', enText: 'Discount Added')}   $discountText";
                    Navigator.of(context).pop();
                    customSnackbar(context, msg, true);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _toggleDiscountButton(DiscountType? selected) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        buildDiscountItem(discountType: DiscountType.percentage, isSelected: selected == DiscountType.percentage),
        SizedBox(width: 10),
        buildDiscountItem(discountType: DiscountType.fixedValue, isSelected: selected == DiscountType.fixedValue),
      ],
    );
  }

  Widget buildDiscountItem({
    required DiscountType discountType,
    required bool isSelected,
  }) {
    String title = discountType == DiscountType.percentage
        ? "% ${translator(arText: "نسبة", enText: "Percentage")}"
        : "\$ ${translator(arText: "قيمة", enText: "Value")}";
    Color textColor = isSelected ? Colors.white : Colors.black;
    return Expanded(
      child: InkWell(
        onTap: () {
          toggleDiscountType(discountType);
        },
        child: Container(
          height: 50,
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFFAF2A26) : Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(color: textColor, fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context,
      {required String text, required Color color, required Color textColor, required VoidCallback onPressed}) {
    return FFButtonWidget(
      onPressed: onPressed,
      text: text,
      options: FFButtonOptions(
        width: 100,
        height: 40,
        color: color,
        textStyle: FlutterFlowTheme.of(context).titleSmall.override(
              fontFamily: 'Readex Pro',
              color: textColor,
            ),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

// Usage example:
Future<String?> showDiscountInputDialog(BuildContext context) async {
  return await showAppDialog<String>(
    context: context,
    builder: (context) => const DiscountInputDialog(),
  );
}
