import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/menu_widget/components/kiosk_product_image_helpers.dart';
import 'package:kiosk_point_of_sale/core/colors/app_colors.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/currency_display_widget.dart';
import 'package:kiosk_point_of_sale/core/extentions/app_extentions.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_icon_button.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_theme.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_util.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/core/services/order_services/order_calculator.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_items_model.dart';
import 'package:kiosk_point_of_sale/data/models/sync_product/sync_product_model.dart';
import 'package:kiosk_point_of_sale/providers/cart_provider.dart';
import 'package:kiosk_point_of_sale/providers/menu_providers.dart';
import 'package:kiosk_point_of_sale/providers/order_summary_provider.dart';
import 'package:kiosk_point_of_sale/providers/payment_breakdown_provider.dart';
import 'package:kiosk_point_of_sale/providers/promotion_provider.dart';
import 'package:kiosk_point_of_sale/repository/promotions/promotions_services.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/tables/promotions_fB_table_table.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/cart/cart_helper.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/cart/delete_order_widget.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/cart/kiosk_cart_line_item.dart';
import 'package:kiosk_point_of_sale/core/helpers/menu_product_tap_handler.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/menu_widget/menu_widget.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/pay_widget/pay_now_widget.dart';
import '../../../core/services/loading_services/enhanced_loading_service.dart';
import '../../../data/models/sales_models/sales_invoice.dart';
import 'cart_model.dart';

export 'cart_model.dart';

class CartWidget extends ConsumerStatefulWidget {
  const CartWidget({super.key});

  static String routeName = 'Cart';
  static String routePath = '/cart';

  @override
  ConsumerState<CartWidget> createState() => _CartWidgetState();
}

class _CartWidgetState extends ConsumerState<CartWidget> {
  late CartModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _couponExpanded = false;
  final TextEditingController _couponController = TextEditingController();
  String? _couponMessage;
  final ScrollController scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CartModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(milliseconds: 100), () {
      if (scrollController.positions.isNotEmpty) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });
    final orderSummaryAsync = ref.watch(orderSummaryProvider);
    ref.watch(promotionCatalogRevisionProvider);

    return orderSummaryAsync.when(
      data: (orderSummary) {
        dPrint("orderSummary totalAmount1 : ${orderSummary.totalAmount}");
        final orderItems = orderSummary.salesInvoice.salesOrderItems;
        return _buildCartContent(context, orderSummary, orderItems);
      },
      loading: () => _buildCartContent(context, null, const []),
      error: (error, stack) {
        dPrint("Stack Trace: $stack");
        return _buildErrorContent(context, error);
      },
    );
  }

  Widget _buildCartContent(BuildContext context, OrderSummary? orderSummary,
      [List<SalesItemsModel> orderItems = const []]) {
    // ref.read(cartProvider.notifier).initScrolling1();
    final backGroundColor = ref.watch(reportGroupThemeProvider).accentColor;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: AppBar(
            backgroundColor: backGroundColor,
            iconTheme: IconThemeData(color: Colors.black),
            automaticallyImplyLeading: true,
            leading: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(10.0, 0.0, 0.0, 0.0),
              child: FlutterFlowIconButton(
                borderRadius: 8.0,
                buttonSize: 40.0,
                icon: Icon(
                  Icons.chevron_left,
                  color: Colors.white,
                  size: 30.0,
                ),
                onPressed: () async {
                  context.pushNamed(MenuWidget.routeName);
                },
              ),
            ),
            title: Text(
              translator(arText: "السلة", enText: 'Cart'),
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
                    color: Colors.white,
                    fontSize: 30.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.bold,
                    fontStyle:
                        FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                  ),
            ),
            actions: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 10.0, 0.0),
                child: FlutterFlowIconButton(
                  borderRadius: 8.0,
                  buttonSize: 40.0,
                  icon: FaIcon(
                    FontAwesomeIcons.trashAlt,
                    color: AppColors.white,
                    size: 22.0,
                  ),
                  onPressed: () async {
                    await showModalBottomSheet(
                      isScrollControlled: false,
                      backgroundColor: Colors.transparent,
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
                    ).then((value) => safeSetState(() {}));
                  },
                ),
              ),
            ],
            centerTitle: true,
            toolbarHeight: 90.0,
            elevation: 3.0,
          ),
        ),
        body: SafeArea(
          top: true,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        // Cart Items Section
                        _buildCartItemsSection(orderItems),

                        // People also ordered section
                        _buildRecommendedSection(),

                        // // Order Notes Section
                        // _buildOrderNotesSection(),

                        // VAT Details Section
                        // _buildVatSection(),

                        // Price Breakdown Section
                      ],
                    ),
                  ),
                ),

                // Footer with total and checkout
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCartItemsSection(List<SalesItemsModel> orderItems) {
    final cartItems = ref.watch(cartProvider);
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';

    return Container(
      width: double.infinity,
      margin: EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 0.0),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(18.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ...cartItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
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
              enableDismissible: true,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRecommendedSection() {
    final recommendedProducts = ref.watch(recommendedProductsProvider);
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final themeColor = ref.watch(reportGroupThemeProvider).accentColor;
    if (recommendedProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20.0, 24.0, 20.0, 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title with red underline accent
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(4.0, 0.0, 0.0, 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  translator(
                      arText: "اشترى العملاء أيضاً",
                      enText: "People also ordered"),
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.interTight(
                          fontWeight: FontWeight.bold,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                        fontSize: 22.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 6.0),
                Container(
                  width: 25.w,
                  height: 3.0,
                  decoration: BoxDecoration(
                    color: themeColor,
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ],
            ),
          ),
          // Horizontal scrollable cards
          SizedBox(
            height: 17.h,
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 1.w),
              primary: false,
              scrollDirection: Axis.horizontal,
              itemCount: recommendedProducts.length,
              itemBuilder: (context, index) {
                final product = recommendedProducts[index];
                return _buildRecommendedProductCard(product, isEnglish);
              },
            ),
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildRecommendedProductCard(SyncProduct product, bool isEnglish) {
    final firstUnit =
        product.unitOfMeasures.isNotEmpty ? product.unitOfMeasures.first : null;
    final price = firstUnit?.price ?? 0.0;
    final themeColor = ref.watch(reportGroupThemeProvider).accentColor;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 12.0, 10.0),
      child: GestureDetector(
        onTap: () => _addRecommendedProductToCart(product),
        child: Container(
          width: 130.0,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 6.0,
                color: Colors.black.withOpacity(0.08),
                offset: const Offset(0.0, 2.0),
              )
            ],
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Product Image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  topRight: Radius.circular(12.0),
                ),
                child: Container(
                  width: double.infinity,
                  height: 100.0,
                  color: Colors.white,
                  child: Center(
                    child: buildImage(
                      product.imageUrl,
                      width: 120.0,
                      height: 100.0,
                    ),
                  ),
                ),
              ),

              // Product Name
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                child: Text(
                  isEnglish ? product.nameEn : product.nameAr,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.interTight(
                          fontWeight: FontWeight.w600,
                        ),
                        fontSize: 12.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),

              // Price Button
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 10.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 36.0,
                  child: ElevatedButton(
                    onPressed: () => _addRecommendedProductToCart(product),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('+ ',
                            style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                                color: themeColor)),
                        const CurrencyDisplayWidget(
                          variant: CurrencyVisualVariant.green,
                          width: 14.0,
                          height: 14.0,
                        ),
                        const SizedBox(width: 3.0),
                        Text(
                          price.toStringAsFixed(2),
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 13.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addRecommendedProductToCart(SyncProduct product) {
    ProductTapHandler.handleProductTap(
      context,
      ref,
      product,
      false,
      false,
    );
  }

  Widget _buildOrderNotesSection() {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 0.0, 0.0),
      child: Container(
        width: double.infinity,
        height: 105.0,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(18.0),
        ),
        child: InkWell(
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () async {
            await showModalBottomSheet(
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              context: context,
              builder: (context) {
                return GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  child: Padding(
                    padding: MediaQuery.viewInsetsOf(context),
                    child: SizedBox(
                      height: 400.0,
                      child: Center(
                        child: Text(
                          'Order Notes Modal',
                          style: FlutterFlowTheme.of(context).headlineSmall,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ).then((value) => safeSetState(() {}));
          },
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(32.0, 0.0, 0.0, 0.0),
                child: Text(
                  'Order Notes',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.interTight(
                          fontWeight: FontWeight.bold,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                        fontSize: 24.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.bold,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      ),
                ),
              ),
              Align(
                alignment: AlignmentDirectional(0.0, 0.0),
                child: FlutterFlowIconButton(
                  borderRadius: 8.0,
                  buttonSize: 98.3,
                  icon: Icon(
                    Icons.chevron_right,
                    color: FlutterFlowTheme.of(context).primaryText,
                    size: 36.0,
                  ),
                  onPressed: () {
                    print('IconButton pressed ...');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVatSection(OrderSummary? orderSummary) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 0.0, 0.0),
      child: Container(
        width: double.infinity,
        height: 105.0,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(18.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(32.0, 0.0, 0.0, 0.0),
                  child: Text(
                    'Vat 15%',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.interTight(
                            fontWeight: FontWeight.bold,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                          fontSize: 24.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.bold,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(32.0, 0.0, 0.0, 0.0),
                  child: Text(
                    'VAT Registration Number',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.interTight(
                            fontWeight: FontWeight.normal,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                          color: FlutterFlowTheme.of(context).secondaryText,
                          fontSize: 20.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.normal,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 32.0, 0.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(22.0, 0.0, 0.0, 0.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 3.0, 0.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: const CurrencyDisplayWidget(
                              width: 37.3,
                              height: 30.5,
                            ),
                          ),
                        ),
                        Text(
                          orderSummary?.taxAmount.toStringAsFixed(2) ?? '0.00',
                          style:
                              FlutterFlowTheme.of(context).bodySmall.override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .fontStyle,
                                    ),
                                    fontSize: 30.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodySmall
                                        .fontStyle,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(32.0, 0.0, 0.0, 0.0),
                    child: Text(
                      '310409608400003',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.interTight(
                              fontWeight: FontWeight.normal,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                            color: Color(0xFF877350),
                            fontSize: 20.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.normal,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                            decoration: TextDecoration.underline,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Commented out - replaced by new _buildFooterContent
  // Widget _buildPriceBreakdownSection(OrderSummary? orderSummary) {
  //   if (orderSummary == null) {
  //     return const Center(child: CircularProgressIndicator());
  //   }
  //   return _buildPriceBreakdownContent(context, orderSummary);
  // }

  // Widget _buildPriceBreakdownContent(
  //     BuildContext context, OrderSummary summary) {
  //   final totalPaid = ref.watch(paymentBreakdownProvider).fold<num>(
  //         0.0,
  //         (sum, payment) => sum + payment.amount,
  //       );
  //   final remaining = (summary.totalAmount - totalPaid).toStringAsFixed(2);
  //   final String change = (totalPaid > summary.totalAmount)
  //       ? (totalPaid - summary.totalAmount).toStringAsFixed(2)
  //       : '0.00';

  //   return Padding(
  //     padding: EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 0.0, 0.0),
  //     child: Container(
  //       width: double.infinity,
  //       decoration: BoxDecoration(
  //         color: FlutterFlowTheme.of(context).secondaryBackground,
  //         borderRadius: BorderRadius.circular(18.0),
  //       ),
  //       child: Padding(
  //         padding: EdgeInsets.all(20.0),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             _buildPriceRow(
  //               translator(
  //                   arText: 'الاجمالي بدون ضريبة', enText: 'Total without VAT'),
  //               '${summary.subtotal.toStringAsFixed(2)}  ',
  //               isTotal: true,
  //             ),
  //             if ((summary.discountAmount + summary.promotionValue) > 0)
  //               _buildPriceRow(
  //                 translator(arText: 'الخصم', enText: 'Discount'),
  //                 (summary.discountAmount + summary.promotionValue)
  //                     .toStringAsFixed(2),
  //                 isTotal: true,
  //               ),
  //             _buildPriceRow(
  //               translator(arText: 'الضريبة', enText: 'VAT'),
  //               '${summary.taxAmount.toStringAsFixed(2)}  ',
  //               isTotal: true,
  //             ),
  //             _buildPriceRow(
  //               translator(
  //                   arText: 'الاجمالي مع الضريبة', enText: 'Total with VAT'),
  //               '${summary.totalAmount.toStringAsFixed(2)}  ',
  //               isTotal: true,
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildPriceRow(String label, String value,
  //     {bool isTotal = false, Color? textColor}) {
  //   return Padding(
  //     padding: EdgeInsets.symmetric(vertical: 8.0),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Text(
  //           label,
  //           style: FlutterFlowTheme.of(context).bodyMedium.override(
  //                 font: GoogleFonts.interTight(
  //                   fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
  //                   fontStyle:
  //                       FlutterFlowTheme.of(context).bodyMedium.fontStyle,
  //                 ),
  //                 fontSize: isTotal ? 20.0 : 18.0,
  //                 letterSpacing: 0.0,
  //                 fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
  //                 fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
  //                 color: textColor,
  //               ),
  //         ),
  //         Row(
  //           children: [
  //             currencySymbol(),
  //             SizedBox(width: MediaQuery.sizeOf(context).width * 0.01),
  //             Text(
  //               value,
  //               style: FlutterFlowTheme.of(context).bodyMedium.override(
  //                     font: GoogleFonts.interTight(
  //                       fontWeight:
  //                           isTotal ? FontWeight.bold : FontWeight.normal,
  //                       fontStyle:
  //                           FlutterFlowTheme.of(context).bodyMedium.fontStyle,
  //                     ),
  //                     fontSize: isTotal ? 20.0 : 18.0,
  //                     letterSpacing: 0.0,
  //                     fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
  //                     fontStyle:
  //                         FlutterFlowTheme.of(context).bodyMedium.fontStyle,
  //                     color: textColor,
  //                   ),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildFooter() {
    final orderSummaryAsync = ref.watch(orderSummaryProvider);

    return orderSummaryAsync.when(
      data: (orderSummary) {
        dPrint("orderSummary totalAmount : ${orderSummary.totalAmount}");
        return _buildFooterContent(orderSummary);
      },
      loading: () => _buildFooterLoading(),
      error: (error, stack) {
        dPrint("Stack Trace: $stack");
        return _buildFooterError(error);
      },
    );
  }

  Widget _buildFooterContent(OrderSummary orderSummary) {
    final cartItems = ref.watch(cartProvider);
    final itemCount = cartItems.length;
    final subtotal = orderSummary.subtotal;
    final taxAmount = orderSummary.taxAmount;
    final discountAmount =
        orderSummary.discountAmount + orderSummary.promotionValue;
    final totalAmount = orderSummary.totalAmount;
    final themeColor = ref.watch(reportGroupThemeProvider).accentColor;

    return Column(
      children: [
        // Explore Menu row
        _buildExploreMenuRow(),
        const SizedBox(height: 8.0),
        // Apply Coupon section
        _buildApplyCouponSection(orderSummary),
        const SizedBox(height: 8.0),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
                bottomLeft: Radius.circular(20.0),
                bottomRight: Radius.circular(20.0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 12.0,
                  offset: Offset(0, -3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Price breakdown rows
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
                  child: Column(
                    children: [
                      // Sub Total row
                      _buildSummaryRow(
                        translator(
                            arText: 'المجموع الفرعي', enText: 'Sub Total'),
                        subtotal.toStringAsFixed(2),
                        showCurrency: true,
                      ),
                      if (discountAmount > 0) ...[
                        const SizedBox(height: 8.0),
                        _buildSummaryRow(
                          translator(arText: 'الخصم', enText: 'Discount'),
                          '-${discountAmount.toStringAsFixed(2)}',
                          showCurrency: true,
                          isDiscount: true,
                        ),
                      ],
                      const Divider(height: 20.0, color: Color(0xFFEEEEEE)),
                      // Total row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            translator(arText: 'الإجمالي', enText: 'Total'),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CurrencyDisplayWidget(
                                width: 20.0,
                                height: 20.0,
                              ),
                              const SizedBox(width: 4.0),
                              Text(
                                totalAmount.toStringAsFixed(2),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4.0),
                      // VAT inclusive note
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          translator(
                            arText:
                                'شامل ضريبة القيمة المضافة 15٪ أي ${taxAmount.toStringAsFixed(2)} ر.س',
                            enText:
                                'Inclusive of VAT 15% i.e. ${taxAmount.toStringAsFixed(2)} SAR',
                          ),
                          style: TextStyle(
                            color: themeColor,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5),
              ],
            ),
          ),
        ),
        const SizedBox(height: 5.0),
        buildCartFooter(itemCount, themeColor, totalAmount),
        // Bottom row: separated info box + separated Place Order button (target design)
      ],
    );
  }

  Widget _buildExploreMenuRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pop();
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: const Color(0xFFEEEEEE), width: 0.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    translator(
                        arText: 'استعرض القائمة', enText: 'Explore Menu'),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    translator(
                        arText: 'أضف المزيد من العناصر إلى سلتك',
                        enText: 'Add more items in your cart'),
                    style: TextStyle(
                      color: AppColors.gray500,
                      fontSize: 11.0,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.gray400,
                size: 22.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildApplyCouponSection(OrderSummary orderSummary) {
    final themeColor = ref.watch(reportGroupThemeProvider).accentColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: const Color(0xFFEEEEEE), width: 0.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header row (always visible)
            InkWell(
              onTap: () {
                setState(() {
                  _couponExpanded = !_couponExpanded;
                });
              },
              borderRadius: BorderRadius.circular(12.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 14.0),
                child: Row(
                  children: [
                    Text(
                      '% ',
                      style: TextStyle(
                        color: themeColor,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4.0),
                    Expanded(
                      child: Text(
                        translator(
                            arText: 'تطبيق كوبون', enText: 'Apply Coupon'),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      !_couponExpanded
                          ? Icons.chevron_right
                          : Icons.expand_more,
                      color: AppColors.gray400,
                      size: 22.0,
                    ),
                  ],
                ),
              ),
            ),
            // Expandable coupon input
            if (_couponExpanded) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 40.0,
                            child: TextField(
                              controller: _couponController,
                              decoration: InputDecoration(
                                hintText: translator(
                                    arText: 'أدخل رمز الكوبون',
                                    enText: 'Enter Coupon Code'),
                                hintStyle: TextStyle(
                                  color: AppColors.gray400,
                                  fontSize: 12.0,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide:
                                      BorderSide(color: AppColors.gray300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide:
                                      BorderSide(color: AppColors.gray300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide(color: themeColor),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12.0, vertical: 8.0),
                                isDense: true,
                              ),
                              style: const TextStyle(fontSize: 13.0),
                              onSubmitted: (val) async {
                                if (val.isNotEmpty) {
                                  await _applyCouponCode(
                                      val.trim(), orderSummary.salesInvoice);
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        SizedBox(
                          height: 40.0,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_couponController.text.isNotEmpty) {
                                await _applyCouponCode(
                                    _couponController.text.trim(),
                                    orderSummary.salesInvoice);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: themeColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: Text(
                              translator(arText: 'تطبيق', enText: 'APPLY'),
                              style: const TextStyle(
                                fontSize: 12.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_couponMessage != null) ...[
                      const SizedBox(height: 6.0),
                      Text(
                        _couponMessage!,
                        style: TextStyle(
                          color: _couponMessage!.contains('success')
                              ? Colors.green
                              : Colors.orange,
                          fontSize: 11.0,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _applyCouponCode(String code, SalesInvoice invoice) async {
    final appliedPromotions = ref.read(appliedPromotionsProvider);
    final cartItems = ref.read(cartProvider);

    if (cartItems.isEmpty) {
      setState(() {
        _couponMessage = translator(
            arText: 'يرجى إضافة عناصر إلى السلة أولاً',
            enText: 'Please add items to cart first');
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _couponMessage = null);
      });
      return;
    }

    setState(() {
      _couponMessage =
          translator(arText: 'جاري التحقق...', enText: 'Checking promotion...');
    });

    try {
      final offers = await PromotionsServices.instance.getActiveOffersCodes();
      final offer = offers.firstWhereOrNull(
        (o) => o.promotionCode.toLowerCase() == code.toLowerCase(),
      );

      if (offer == null) {
        setState(() {
          _couponMessage = translator(
              arText: 'رمز ترويجي غير صالح', enText: 'Invalid promotion code');
        });
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _couponMessage = null);
        });
        return;
      }

      if (appliedPromotions
          .any((p) => p.promotionCodeId == offer.promotionCodeId)) {
        setState(() {
          _couponMessage = translator(
              arText: 'العرض مطبق بالفعل', enText: 'Offer already applied');
        });
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _couponMessage = null);
        });
        return;
      }

      // Apply the offer using the same logic as PromotionDialog
      final codeModel = await PromotionsServices.instance
          .getPromotionById(offer.promotionCodeId);
      if (codeModel == null) {
        setState(() {
          _couponMessage = translator(
              arText: 'الترويج غير موجود', enText: 'Promotion not found');
        });
        return;
      }

      final allPromos = await PromotionsFBTable.getAll();
      final fbModel = allPromos.firstWhere(
        (p) => p.id == codeModel.promotionFBId,
        orElse: () => allPromos.isNotEmpty
            ? allPromos.first
            : throw Exception('No promotions found'),
      );

      final promoInvoice = await PromotionsServices.instance.applyPromotion(
        codeModel,
        fbModel,
        invoice,
      );

      if (promoInvoice.notMatch) {
        setState(() {
          _couponMessage = translator(
              arText: 'لا يمكن تطبيق هذا العرض',
              enText: 'This offer cannot be applied to your order');
        });
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) setState(() => _couponMessage = null);
        });
        return;
      }

      if (promoInvoice.notValidPromotion) {
        setState(() {
          _couponMessage = translator(
              arText: 'هذا الترويج غير صالح',
              enText: 'This promotion is not valid');
        });
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) setState(() => _couponMessage = null);
        });
        return;
      }

      if (promoInvoice.isUsed) {
        setState(() {
          _couponMessage = translator(
              arText: 'تم استخدام هذا الترويج بالفعل',
              enText: 'This promotion has already been used');
        });
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) setState(() => _couponMessage = null);
        });
        return;
      }

      ref.read(appliedPromotionsProvider.notifier).state = [
        ...appliedPromotions,
        offer
      ];
      ref.read(appliedPromotionsProvider.notifier).state =
          List.from(ref.read(appliedPromotionsProvider));

      setState(() {
        _couponMessage = translator(
            arText: 'تم تطبيق الترويج بنجاح!',
            enText: 'Promotion applied successfully!');
        _couponController.clear();
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _couponMessage = null);
      });
    } catch (e) {
      setState(() {
        _couponMessage = translator(
            arText: 'خطأ في تطبيق الترويج', enText: 'Error applying promotion');
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _couponMessage = null);
      });
    }
  }

  buildCartFooter(int itemCount, Color themeColor, double totalAmount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30.0),
        child: SizedBox(
          height: 60.0,
          child: Row(
            children: [
              // Left section: white background with cart icon + badge
              Container(
                width: 56.0,
                height: 60.0,
                color: Colors.white,
                child: Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(
                        Icons.shopping_bag,
                        color: Colors.black87,
                        size: 28.0,
                      ),
                      if (itemCount > 0)
                        Positioned(
                          top: -4,
                          right: -6,
                          child: Container(
                            padding: const EdgeInsets.all(3.0),
                            decoration: BoxDecoration(
                              color: themeColor,
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white, width: 1.5),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18.0,
                              minHeight: 18.0,
                            ),
                            child: Text(
                              itemCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9.0,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // Right section: colored area filling the rest, no padding, flat left edge
              Expanded(
                child: Container(
                  height: 60.0,
                  color: themeColor,
                  child: Row(
                    children: [
                      // Price and VAT text
                      Expanded(
                        child: Padding(
                          padding:
                              const EdgeInsetsDirectional.only(start: 14.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const CurrencyDisplayWidget(
                                    variant: CurrencyVisualVariant.white,
                                    width: 16.0,
                                    height: 16.0,
                                    textStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 3.0),
                                  Text(
                                    totalAmount.toStringAsFixed(0),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 1.0),
                              Text(
                                translator(
                                    arText: '*جميع الأسعار شاملة الضريبة',
                                    enText: '*All prices are VAT inclusive'),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 8.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Place Order button
                      buildCartbutton(itemCount, themeColor),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCartbutton(int itemCount, Color themeColor) {
    // Darker shade of the theme color for the button
    final darkerColor = HSLColor.fromColor(themeColor)
        .withLightness(
            (HSLColor.fromColor(themeColor).lightness - 0.08).clamp(0.0, 1.0))
        .toColor();

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Material(
        color: darkerColor,
        borderRadius: BorderRadius.circular(22.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(22.0),
          onTap: itemCount > 0
              ? () async {
                  enhancedLoadingService.showEnhancedLoading(
                    context,
                    message: translator(
                        arText: "جاري معالجة الطلب",
                        enText: "Processing Order"),
                    isLottie: true,
                  );
                  SalesInvoice finalInvoice =
                      await CartHelper().generateTempOrder(ref, context);
                  enhancedLoadingService.hideLoading();
                  context.pushNamed(PayNowWidget.routeName,
                      extra: finalInvoice);
                }
              : null,
          child: Opacity(
            opacity: itemCount > 0 ? 1.0 : 0.5,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    translator(arText: 'تأكيد الطلب', enText: 'Place Order'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4.0),
                  const Text(
                    '>>',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool showCurrency = false, bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.gray700,
            fontSize: 14.0,
            fontWeight: FontWeight.normal,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showCurrency) ...[
              const CurrencyDisplayWidget(
                width: 16.0,
                height: 16.0,
              ),
              const SizedBox(width: 4.0),
            ],
            Text(
              value,
              style: TextStyle(
                color: isDiscount ? Colors.red : AppColors.black,
                fontSize: 14.0,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooterLoading() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.gray200,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildFooterError(Object error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.gray200,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: Center(
        child: Text(
          translator(arText: "حدث خطأ ما", enText: 'Error loading cart'),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.black,
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorContent(BuildContext context, Object error) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        title: Text('Cart'),
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
      ),
      body: Center(
        child: Text(
          'Error: ${error.toString()}',
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'Inter Tight',
                color: Colors.red,
              ),
        ),
      ),
    );
  }
}
