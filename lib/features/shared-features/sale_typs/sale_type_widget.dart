// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unused_local_variable, unnecessary_new, deprecated_member_use, use_build_context_synchronously

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/custom_page_with_action_buttons.dart';
import 'package:kiosk_point_of_sale/core/config/app_mode_session.dart';
import 'package:kiosk_point_of_sale/core/routers/app_routes.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';
import 'package:kiosk_point_of_sale/core/helpers/clear_cart_with_prices.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/core/helpers/login_helpers.dart';
import 'package:kiosk_point_of_sale/core/helpers/responsive_helper.dart';
import 'package:kiosk_point_of_sale/providers/customer_provider.dart';
import 'package:kiosk_point_of_sale/providers/payment_breakdown_provider.dart';
import 'package:kiosk_point_of_sale/repository/menu_catalog_preload_helper.dart';
import 'package:kiosk_point_of_sale/features/shared-features/Cashier/cashier_widget.dart';

class SaleTypesWidget extends ConsumerStatefulWidget {
  static String routeName = 'SaleTypes';
  static String routePath = '/sale-types';
  const SaleTypesWidget({super.key});

  @override
  _SaleTypesWidgetState createState() => _SaleTypesWidgetState();
}

class _SaleTypesWidgetState extends ConsumerState<SaleTypesWidget> {
  bool loading = false;
  List<SaleType> saleTypes = [];
  Timer? _syncTimer;
  @override
  void initState() {
    // syncTimer();
    setState(() {
      loading = true;
    });
    generateSaleTypeList().then((value) {
      setState(() {
        saleTypes = value;
      });
    });
    setState(() {
      loading = false;
    });
    super.initState();
  }

  void syncTimer() async {
    dPrint("sync timer started");
    final syncTimeString = await AppPreferences().getSyncInterval();
    final syncTime = int.tryParse(syncTimeString) ?? 0;
    bool syncIsNotZero = syncTime != 0;
    _syncTimer =
        Timer.periodic(syncIsNotZero ? Duration(minutes: syncTime) : const Duration(seconds: 30), (timer) async {
      if (mounted) {
        await syncOrders(ref);
      }
    });
  }

  Future<void> _preloadData(SaleType saleType) async {
    await MenuCatalogPreloadHelper.loadCatalogForSaleType(
      ref,
      saleType,
      resetPaymentAndCart: true,
    );
  }

  void _handleSaleTypeSelection(SaleType saleType) async {
    // Check if this is delivery (2) or online (5) sale type
    // if (saleType.saleNature == 2 || saleType.saleNature == 5) {
    // Check if customers are available

    await ref.read(customerNotifierProvider.notifier).loadAllCustomers();
    final allCustomers = ref.read(allCustomersProvider);
    if (allCustomers.isEmpty) {
      // No customers available, proceed directly to sell page with old logic
    
      await _preloadData(saleType);
      dPrint('allCustomers: ${allCustomers.length}');
      dPrint('kDebugMode: $kDebugMode');
      context.go(AppModeSession.postSaleTypeRoute);
    } else {
      // Customers available, route to customers screen
      context.go(AppRoutes.customers, extra: saleType);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';

    return CustomPageWithActionButtons(
      buttons: [
        ...saleTypes.map((e) => ButtonSettings(
            onTap: () => _handleSaleTypeSelection(e),
            title: !isEnglish ? e.nameAr : e.nameEn,
            icon: Icons.sell,
            imageSVgPath: e.imagePath))
      ],
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
      onPressedLeading: () {
        context.go(CashierWidget.routePath);
      },
      pageTitle: 'saleType',
    );
  }
}
