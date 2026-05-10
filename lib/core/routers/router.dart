import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/interaction_detector_widget.dart';
import 'package:kiosk_point_of_sale/core/config/app_config.dart';
import 'package:kiosk_point_of_sale/core/config/auth_flow_config.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';
import 'package:kiosk_point_of_sale/core/helpers/login_helpers.dart';
import 'package:kiosk_point_of_sale/core/routers/app_routes.dart';
import 'package:kiosk_point_of_sale/core/routers/route_transitions.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_invoice.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_order_model.dart';
import 'package:kiosk_point_of_sale/features/mobile-features/search_products/search_products.dart';
import 'package:kiosk_point_of_sale/features/shared-features/Install/install_widget_kiosk.dart';
import 'package:kiosk_point_of_sale/features/shared-features/Install/new_install_widget.dart';
import 'package:kiosk_point_of_sale/features/shared-features/customers/customers_table_widget.dart';
import 'package:kiosk_point_of_sale/main.dart';
import 'package:kiosk_point_of_sale/features/shared-features/Cashier/cashier_widget.dart';
import 'package:kiosk_point_of_sale/features/mobile-features/CheckOut/check_out_widget.dart';
import 'package:kiosk_point_of_sale/features/shared-features/Home/home_widget.dart';
import 'package:kiosk_point_of_sale/features/shared-features/Login/login_widget.dart';
import 'package:kiosk_point_of_sale/features/shared-features/Login/new_login_widget.dart';
import 'package:kiosk_point_of_sale/features/shared-features/Orders/orders_screen.dart';
import 'package:kiosk_point_of_sale/features/mobile-features/SellPage/sellpage_widget.dart';
import 'package:kiosk_point_of_sale/features/shared-features/admin/admin_widget.dart';
import 'package:kiosk_point_of_sale/features/shared-features/debug/debug_screen.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/cart/cart_widget.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/entry_widget/entry_widget.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/menu_widget/menu_widget.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/sale_type_kiosk/kiosk_sale_type_screen.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/pay_widget/pay_now_widget.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/success_payment/success_payment_widget.dart';
import 'package:kiosk_point_of_sale/features/shared-features/refunds/refunds_screen.dart';
import 'package:kiosk_point_of_sale/features/shared-features/sale_typs/sale_type_widget.dart';
import 'package:kiosk_point_of_sale/features/shared-features/settings/settings_screen.dart';

Widget popScopeWidget({
  required Widget child,
  bool canPop = false,
  bool detectPointer = false,
  Duration? timeoutDuration,
}) {
  if (detectPointer) {
    return _TimeoutAwareInteractionDetector(
      timeoutDuration: timeoutDuration,
      onInactivity: () {
        print('User inactive - redirecting to home');

        navKey.currentState?.context.go(AppRoutes.entry);
      },
      child: PopScope(
        canPop: canPop,
        child: child,
      ),
    );
  }
  return PopScope(
    canPop: canPop,
    child: child,
  );
}

class _TimeoutAwareInteractionDetector extends StatelessWidget {
  final Widget child;
  final VoidCallback onInactivity;
  final Duration? timeoutDuration;

  const _TimeoutAwareInteractionDetector({
    required this.child,
    required this.onInactivity,
    this.timeoutDuration,
  });

  @override
  Widget build(BuildContext context) {
    if (timeoutDuration != null) {
      // Use provided timeout duration
      return InteractionDetectorWidget(
        timeoutDuration: timeoutDuration!,
        onInactivity: onInactivity,
        child: child,
      );
    } else {
      // Load timeout from settings
      return FutureBuilder<int>(
        future: AppPreferences().getTimeoutDuration(),
        builder: (context, snapshot) {
          final timeoutSeconds = snapshot.data ?? 240;
          return InteractionDetectorWidget(
            timeoutDuration: Duration(seconds: timeoutSeconds),
            onInactivity: onInactivity,
            child: child,
          );
        },
      );
    }
  }
}

// install
// login
// home
//=> admin or cashier
// sale types
// all this before working
/////////////
// entry screen
// main screen
// after order complete
// entry screen
GoRouter createRouterKiosk({String? path}) {
  print('Creating kiosk router...');
  print('SuccessPaymentWidget route path: ${SuccessPaymentWidget.routePath}');
  print('SuccessPaymentWidget route name: ${SuccessPaymentWidget.routeName}');

  return GoRouter(
    navigatorKey: navKey,
    redirect: (context, state) {
      const kioskOnly = {
        AppRoutes.entry,
        AppRoutes.kioskSaleType,
        AppRoutes.payNow,
        AppRoutes.success,
        AppRoutes.menu,
        AppRoutes.cart,
      };
      const mobileOnly = {AppRoutes.sellPage, AppRoutes.checkout};

      final path = state.uri.path;
      final useNewFlow = AuthFlowConfig.isNewFlowEnabled;
      final oldAuthPaths = {
        InstallWidgetKiosk.routePath,
        LoginWidget.routePath,
      };
      final newAuthPaths = {
        NewInstallWidget.routePath,
        NewLoginWidget.routePath,
      };

      if (useNewFlow && oldAuthPaths.contains(path)) {
        return NewInstallWidget.routePath;
      }
      if (!useNewFlow && newAuthPaths.contains(path)) {
        return InstallWidgetKiosk.routePath;
      }
      if (AppConfig.isMobile && kioskOnly.contains(path)) {
        return AppRoutes.saleTypes;
      }
      if (AppConfig.isKiosk && mobileOnly.contains(path)) {
        return AppRoutes.entry;
      }
      return null;
    },
    // Use the provided path parameter
    // initialLocation: path != null ? '/$path' : '/cashier-page',
    // initialLocation: path != null ? '/$path' : '/login',
    initialLocation: (path ?? InstallWidgetKiosk.routePath),
    //  initialLocation: '/install',

    routes: [
      GoRoute(
        path: PayNowWidget.routePath,
        name: PayNowWidget.routeName,
        pageBuilder: (context, state) => buildTransitionPage(
          pageKey: state.pageKey,
          child: popScopeWidget(
            detectPointer: true,
            child: PayNowWidget(state.extra as SalesInvoice),
          ),
        ),
      ),
      GoRoute(
        path: SuccessPaymentWidget.routePath,
        name: SuccessPaymentWidget.routeName,
        pageBuilder: (context, state) {
          final SalesInvoice salesInvoice = state.extra as SalesInvoice? ??
              SalesInvoice(
                salesOrderModel: SalesOrderModel(
                  id: 0,
                  orderNumber: 'A-720',
                  saleTypeId: 1,
                  createdAt: DateTime.now().toIso8601String(),
                  updatedAt: DateTime.now().toIso8601String(),
                  cashierName: '',
                  deletedAt: DateTime.now().toIso8601String(),
                  workDate: DateTime.now().toIso8601String(),
                  totalAmount: '0.0',
                  totalAmountBeforeDiscount: '0.0',
                  note: '',
                  isRefund: 0,
                  haveRefund: 0,
                  userId: '',
                  tenantId: '',
                  uuid: '',
                  tax: '0.0',
                  subTotal: '0.0',
                  taxBeforeDiscount: '0.0',
                  subTotalBeforeDiscount: '0.0',
                  cashierShiftId: 0,
                  customerPhone: '',
                  isBackOfficeSync: 0,
                  isZactaSync: 0,
                  paymentMethod: 0,
                ),
                salesOrderItems: [],
                salesOrderPayMethods: [],
              );
          return buildTransitionPage(
            pageKey: state.pageKey,
            child: popScopeWidget(
              detectPointer: true,
              child: SuccessPaymentWidget(salesInvoice: salesInvoice),
            ),
          );
        },
      ),
      GoRoute(
        path: InstallWidgetKiosk.routePath,
        name: InstallWidgetKiosk.routeName,
        pageBuilder: (context, state) => buildTransitionPage(
          pageKey: state.pageKey,
          child: popScopeWidget(child: const InstallWidgetKiosk()),
        ),
      ),
      GoRoute(
        path: NewInstallWidget.routePath,
        name: NewInstallWidget.routeName,
        pageBuilder: (context, state) => buildTransitionPage(
          pageKey: state.pageKey,
          child: popScopeWidget(child: const NewInstallWidget()),
        ),
      ),
      GoRoute(
        path: EntryWidget.routePath,
        name: EntryWidget.routeName,
        pageBuilder: (context, state) => buildTransitionPage(
          pageKey: state.pageKey,
          child: popScopeWidget(child: const EntryWidget()),
        ),
      ),
      GoRoute(
        path: LoginWidget.routePath,
        name: LoginWidget.routeName,
        pageBuilder: (context, state) => buildTransitionPage(
          pageKey: state.pageKey,
          child: popScopeWidget(child: const LoginWidget()),
        ),
      ),
      GoRoute(
        path: NewLoginWidget.routePath,
        name: NewLoginWidget.routeName,
        pageBuilder: (context, state) => buildTransitionPage(
          pageKey: state.pageKey,
          child: popScopeWidget(child: const NewLoginWidget()),
        ),
      ),
      GoRoute(
        path: HomeWidget.routePath,
        name: HomeWidget.routeName,
        pageBuilder: (context, state) => buildTransitionPage(
          pageKey: state.pageKey,
          child: popScopeWidget(child: const HomeWidget()),
        ),
      ),
      GoRoute(
        path: CashierWidget.routePath,
        name: CashierWidget.routeName,
        pageBuilder: (context, state) => buildTransitionPage(
          pageKey: state.pageKey,
          child: popScopeWidget(child: const CashierWidget()),
        ),
      ),
      GoRoute(
        path: AdminWidget.routePath,
        name: AdminWidget.routeName,
        pageBuilder: (context, state) => buildTransitionPage(
          pageKey: state.pageKey,
          child: popScopeWidget(child: const AdminWidget()),
        ),
      ),
      GoRoute(
        path: SaleTypesWidget.routePath,
        name: SaleTypesWidget.routeName,
        pageBuilder: (context, state) => buildTransitionPage(
          pageKey: state.pageKey,
          child: popScopeWidget(child: const SaleTypesWidget()),
        ),
      ),
      GoRoute(
        path: KioskSaleTypeScreen.routePath,
        name: KioskSaleTypeScreen.routeName,
        pageBuilder: (context, state) => buildTransitionPage(
          pageKey: state.pageKey,
          child: popScopeWidget(
            detectPointer: true,
            child: const KioskSaleTypeScreen(),
          ),
        ),
      ),
      GoRoute(
        path: MenuWidget.routePath,
        name: MenuWidget.routeName,
        pageBuilder: (context, state) => buildTransitionPage(
          pageKey: state.pageKey,
          child: popScopeWidget(detectPointer: true, child: const MenuWidget()),
        ),
      ),
      GoRoute(
        path: CartWidget.routePath,
        name: CartWidget.routeName,
        pageBuilder: (context, state) => buildTransitionPage(
          pageKey: state.pageKey,
          child: popScopeWidget(detectPointer: true, child: const CartWidget()),
        ),
      ),

      GoRoute(
        path: AppRoutes.sellPage,
        name: 'SellPage',
        pageBuilder: (context, state) => buildTransitionPage(
          pageKey: state.pageKey,
          child: popScopeWidget(child: const SellpageWidget()),
        ),
      ),
      GoRoute(
        path: OrdersScreen.routePath,
        name: OrdersScreen.routeName,
        pageBuilder: (context, state) {
          final bool isAdmin = state.extra as bool? ?? true;
          return buildTransitionPage(
            pageKey: state.pageKey,
            child: popScopeWidget(child: OrdersScreen(isAdmin: isAdmin)),
          );
        },
      ),
      GoRoute(
        path: RedundScreen.routePath,
        name: RedundScreen.routeName,
        pageBuilder: (context, state) => buildTransitionPage(
          pageKey: state.pageKey,
          child: popScopeWidget(child: const RedundScreen()),
        ),
      ),
      GoRoute(
        path: SettingsScreen.routePath,
        name: SettingsScreen.routeName,
        pageBuilder: (context, state) => buildTransitionPage(
          pageKey: state.pageKey,
          child: popScopeWidget(child: const SettingsScreen()),
        ),
      ),
      GoRoute(
        path: '/search',
        name: 'Search',
        builder: (context, state) => popScopeWidget(child: const SearchProductsWidget()),
      ),

      GoRoute(
        path: AppRoutes.customers,
        name: 'CustomersWidget',
        builder: (context, state) {
          final SaleType saleType = state.extra as SaleType;
          return popScopeWidget(child: CustomersTableWidget(saleType: saleType));
        },
      ),
      // GoRoute(
      //   path: '/customer-addresses',
      //   name: 'CustomerAddressesWidget',
      //   builder: (context, state) {
      //     final Map<String, dynamic> extra =
      //         state.extra as Map<String, dynamic>;
      //     final CustomerModel customer = extra['customer'] as CustomerModel;
      //     final SaleType saleType = extra['saleType'] as SaleType;
      //     return popScopeWidget(
      //       child: CustomerAddressesWidget(
      //         customer: customer,
      //         saleType: saleType,
      //       ),
      //     );
      //   },
      // ),

      GoRoute(
        path: AppRoutes.checkout,
        name: 'CheckOutPage',
        pageBuilder: (context, state) => buildTransitionPage(
          pageKey: state.pageKey,
          child: popScopeWidget(child: const CheckOutWidget()),
        ),
      ),

      GoRoute(
        path: AppRoutes.debug,
        name: 'DebugScreen',
        pageBuilder: (context, state) => buildTransitionPage(
          pageKey: state.pageKey,
          child: popScopeWidget(child: const DebugScreen()),
        ),
      ),
      GoRoute(
        path: AppRoutes.error,
        name: 'error',
        pageBuilder: (BuildContext context, GoRouterState state) {
          return buildTransitionPage(
            pageKey: state.pageKey,
            child: popScopeWidget(
              child: Scaffold(
                key: state.pageKey,
                body: const Center(
                  child: Text('Error: Page not found!'),
                ),
              ),
            ),
          );
        },
      ),
    ],
    errorBuilder: (context, state) {
      // final useNewFlow = AuthFlowConfig.isNewFlowEnabled;
      // if (useNewFlow  ) {
      //   return   popScopeWidget(child: const NewInstallWidget());
      // }
      // if (!useNewFlow  ) {
      //   return popScopeWidget(child: const InstallWidgetKiosk());
      // }
      return popScopeWidget(child: const HomeWidget());
    },
  );
}
