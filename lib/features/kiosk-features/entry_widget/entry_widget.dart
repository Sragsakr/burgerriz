import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/login_dialog.dart';
import 'package:kiosk_point_of_sale/core/colors/app_colors.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_dialogs.dart';
import 'package:kiosk_point_of_sale/core/extentions/app_extentions.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_model.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_util.dart';
import 'package:kiosk_point_of_sale/core/sdks/view/sensor_screen.dart';
import 'package:kiosk_point_of_sale/features/shared-features/Cashier/cashier_widget.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/sale_type_kiosk/kiosk_sale_type_screen.dart';

import '../../../core/helpers/clear_cart_with_prices.dart';
import 'entry_model.dart';
import 'widgets/entry_page_view.dart';

export 'entry_model.dart';

/// Main entry widget for the kiosk application
/// Displays promotional slides with call-to-action buttons
class EntryWidget extends ConsumerStatefulWidget {
  const EntryWidget({super.key});

  static String routeName = 'Entry';
  static String routePath = '/entry';

  @override
  ConsumerState<EntryWidget> createState() => _EntryWidgetState();
}

class _EntryWidgetState extends ConsumerState<EntryWidget> {
  late AdPageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _resetSensorsOnInit = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AdPageModel());
    Future.delayed(const Duration(seconds: 1), () {
      resetPaymentAndCartValues(ref);
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if we're returning from navigation by checking the current route
    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute == EntryWidget.routeName) {
      // We're on the entry screen, check if we need to reset sensors
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _resetSensorsOnInit = true;
          });
          // Reset the flag after a short delay
          Future.delayed(Duration(milliseconds: 100), () {
            if (mounted) {
              setState(() {
                _resetSensorsOnInit = false;
              });
            }
          });
        }
      });
    }
  }

  /// Handles the start order button press
  void _handleStartOrder() {
    context.go(KioskSaleTypeScreen.routePath);
  }

  bool show = true;
  @override
  Widget build(BuildContext context) {
    return SensorScreen(
      resetSensorsOnInit: _resetSensorsOnInit,
      onChangeShow: (showValue) {
        setState(() {
          show = showValue;
        });
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: Colors.transparent,
          extendBody: true,
          extendBodyBehindAppBar: true,
          body: SafeArea(
            top: false,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(),
              child: Stack(
                children: [
                  EntryPageView(
                    pageController: _model.pageViewController ??=
                        PageController(initialPage: 0),
                    onButtonPressed: _handleStartOrder,
                    show: show,
                  ),
                  // PositionedDirectional(
                  //   top: MediaQuery.of(context).size.height * 0.3,
                  //   start: 50,
                  //   end: 50,
                  //   child: Container(
                  //     padding: EdgeInsets.all(30),
                  //     decoration: BoxDecoration(
                  //       color: Colors.white,
                  //       borderRadius: BorderRadius.circular(15.0),
                  //       boxShadow: [
                  //         BoxShadow(
                  //           color: Colors.black.withOpacity(0.2),
                  //           blurRadius: 10,
                  //           offset: Offset(0, 10),
                  //         ),
                  //       ],
                  //     ),
                  //     child: ClipRRect(
                  //       borderRadius: BorderRadius.circular(8.0),
                  //       child: Image.asset(
                  //         AppAssets.newLogo,
                  //         // width: ResponsiveHelper.getResponsiveSize(context, 200.12),
                  //         // height:
                  //         //     ResponsiveHelper.getResponsiveSize(context, 75.0),
                  //         fit: BoxFit.cover,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  PositionedDirectional(
                      top: 20,
                      start: 20,
                      child: IconButton(
                          onPressed: () {
                            if(kDebugMode) {
                              context.go(CashierWidget.routePath);
                              return;
                            }
                            showAppDialog(
                                context: context,
                                builder: (context1) => LoginDialog(
                                      path: CashierWidget.routePath,
                                    ));
                          },
                          icon: Icon(
                            Icons.chevron_left,
                            color: AppColors.primary,
                            size: 50,
                          ))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
