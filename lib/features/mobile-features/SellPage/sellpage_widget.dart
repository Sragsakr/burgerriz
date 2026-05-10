import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kiosk_point_of_sale/features/mobile-features/SellPage/widgets/confirm_back_from_sell_dialog.dart';
import 'package:kiosk_point_of_sale/features/mobile-features/SellPage/widgets/custom_tab_bar.dart';
import 'package:kiosk_point_of_sale/features/mobile-features/SellPage/widgets/product_unit_dialog.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/custom_snackbar_widget.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_theme.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/internationalization.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_dialogs.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/permission_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/responsive_helper.dart';
import 'package:kiosk_point_of_sale/data/models/cart_item.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/sale_type_tables/sale_type_price_list_table.dart';
import 'package:kiosk_point_of_sale/providers/cart_provider.dart';
import 'package:kiosk_point_of_sale/providers/payment_breakdown_provider.dart';
import 'package:kiosk_point_of_sale/repository/menu_item_sync_repository.dart';
import 'package:kiosk_point_of_sale/core/sdks/sdk_logic/scanner_lisener.dart';
import 'package:kiosk_point_of_sale/features/mobile-features/SellPage/widgets/sell_page_custom_nav_bar.dart';

import 'widgets/cart_items_widget.dart';
import 'widgets/cart_summary_widget.dart';

export 'sellpage_model.dart';

class SellpageWidget extends ConsumerStatefulWidget {
  const SellpageWidget({
    super.key,
  });

  @override
  ConsumerState<SellpageWidget> createState() => SellpageWidgetState();
}

class SellpageWidgetState extends ConsumerState<SellpageWidget> {
  bool _isTabBarExpanded = true;

  @override
  void initState() {
    requestBluetoothAndLocationPermissions();
    try {
      Future.delayed(Duration(seconds: 1), () {
        ref.read(cartProvider.notifier).initScrolling();
      });
    } catch (e) {}
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(cartProvider.notifier);
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    bool isLandscape = ResponsiveHelper.isTablet(context);
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: buildAppBar(context),
      bottomNavigationBar: const SellPageBottomNavBar(),
      body: CodeScanListener(
        onBarcodeScanned: (String barcode) async {
          await onBarcodeScanned(barcode, context, isEnglish);
        },
        child: SafeArea(
          top: true,
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
            child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CartItemsWidget(isExpanded: _isTabBarExpanded),

                      CartSummaryWidget(),
                      Stack(
                        children: [
                          // Arrow button for portrait mode

                          // CustomTabBar with conditional height
                          SizedBox(
                            height: _isTabBarExpanded
                                ? MediaQuery.sizeOf(context).height * 0.4
                                : MediaQuery.sizeOf(context).height * 0.065,

                            child: _isTabBarExpanded ? CustomTabBar() : Container(),
                          ),
                          PositionedDirectional(
                            top: 0,
                            start: 0,
                            child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isTabBarExpanded = !_isTabBarExpanded;
                                  });
                                },
                                icon: Row(

                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,

                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFFAF2A26),
                                          width: 1,
                                        ),
                                      ),
                                      child: Icon(
                                        _isTabBarExpanded
                                            ? Icons.keyboard_arrow_down
                                            : Icons.keyboard_arrow_up,
                                        color: const Color(0xFFAF2A26),
                                        size: 24,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    if (!_isTabBarExpanded)
                                      Text(
                                        translator(

                                            arText: "اظهار الفئات", enText: "Show categories"),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                  ],
                                )),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> onBarcodeScanned(
      String barcode, BuildContext context, bool isEnglish) async {
    try {
      print('Scanned barcode: $barcode');
      final saleType = ref.watch(saleTypeNotifier.notifier);

      final priceList = await SaleTypePriceListTable.getBySaleTypeId(
          saleType.state?.saleTypeId ?? 0);
      final priceListId = priceList?.priceListId ?? 1;

      final product = await MenuItemSyncRepository()
          .getProductByBarcode(barcode, priceListId);

      if (product != null) {
        final units = product.unitOfMeasures;

        if (units.isEmpty) {
          customSnackbar(
              context, FFLocalizations.of(context).getText('qwer0001'), false);
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
        customSnackbar(
            context, FFLocalizations.of(context).getText('qwer0002'), false);
      }
    } catch (e) {
      print('Error occurred while scanning: $e');
      customSnackbar(
          context, FFLocalizations.of(context).getText('qwer0003'), false);
    }
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          icon: Icon(
            Icons.language,
            size: ResponsiveHelper.getResponsiveSize(
              context,
              24,
            ),
          ),
          onPressed: () async {
            await switchAppLanguage(ref, context);
          },
        ),
      ],
      centerTitle: true,
      elevation: 0.8,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_rounded,
          color: Color(0xFFAF2A26),
          size: 30.0,
        ),
        onPressed: () {
          final cartItems = ref.watch(cartProvider);
          if (cartItems.isEmpty) {
            context.go('/sale_type-page');
          } else {
            showAppDialog(
              context: context,
              builder: (context) => ConfirmBackDialog(),
            );
          }
        },
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(2.0, 0.0, 0.0, 0.0),
          child: Text(
            //
            FFLocalizations.of(context).getText('fpabqk27'),
            // FFLocalizations.of(context).getText('ac1xvmbr'),
            style: FlutterFlowTheme.of(context).headlineSmall.override(
                  fontFamily: 'Outfit',
                  color: FlutterFlowTheme.of(context).gray600,
                ),
          ),
        ),
        centerTitle: true,
        expandedTitleScale: 1.0,
      ),
    );
  }
}
