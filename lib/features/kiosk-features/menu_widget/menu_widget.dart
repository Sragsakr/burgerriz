import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/custom_snackbar_widget.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/internationalization.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/sale_type_tables/sale_type_price_list_table.dart';
import 'package:kiosk_point_of_sale/providers/payment_breakdown_provider.dart';
import 'package:kiosk_point_of_sale/repository/menu_item_sync_repository.dart';
import 'package:kiosk_point_of_sale/core/sdks/sdk_logic/scanner_lisener.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/entry_widget/entry_widget.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/menu_widget/components/menu_main_layout_widget.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/menu_widget/components/menu_cart_summary_bar.dart';

import '../../../core/helpers/menu_product_tap_handler.dart';

class MenuWidget extends ConsumerWidget {
  const MenuWidget({super.key});

  static String routeName = 'MenuWidget';
  static String routePath = '/menuWidget';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CodeScanListener(
        onBarcodeScanned: (String barcode) async {
          await onBarcodeScanned(barcode, context, ref);
        },
        child: Column(
          children: [
            // Main menu content
            Expanded(
              child: MenuMainLayoutWidget(
                onBackPressed: () {
                  context.go(EntryWidget.routePath);
                },
              ),
            ),

            // Cart Summary and Action Buttons combined
            const MenuCartSummaryBar(),
          ],
        ),
      ),
    );
  }

  Future<void> onBarcodeScanned(String barcode, BuildContext context, WidgetRef ref) async {
    try {
      print('Scanned barcode: $barcode');
      final saleType = ref.watch(saleTypeNotifier.notifier);
      final priceList = await SaleTypePriceListTable.getBySaleTypeId(saleType.state?.saleTypeId ?? 0);
      final priceListId = priceList?.priceListId ?? 1;

      final syncRepo = MenuItemSyncRepository();
      final product = await syncRepo.getProductByBarcode(barcode, priceListId);

      if (product != null) {
        ProductTapHandler.handleProductTap(
          context,
          ref,
          product,
          false,
          false,
        );
      } else {
        customSnackbar(context, FFLocalizations.of(context).getText('qwer0002'), false);
      }
    } catch (e) {
      print('Error occurred while scanning: $e');
      customSnackbar(context, FFLocalizations.of(context).getText('qwer0003'), false);
    }
  }
}
