// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unused_local_variable, unnecessary_new, deprecated_member_use, use_build_context_synchronously

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/custom_page_with_action_buttons.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/custom_snackbar_widget.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/x_report_bottom_sheet.dart';
import 'package:kiosk_point_of_sale/core/config/app_mode_session.dart';
import 'package:kiosk_point_of_sale/core/config/auth_flow_config.dart';
import 'package:kiosk_point_of_sale/core/routers/app_routes.dart';
import 'package:kiosk_point_of_sale/core/constants/zatca_constants.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/internationalization.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/core/helpers/login_helpers.dart';
import 'package:kiosk_point_of_sale/core/helpers/responsive_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/sync_request_helper.dart';
import 'package:kiosk_point_of_sale/core/services/sync_services/global_sync_service.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_invoice.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/device/device_info_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/device/shift_table.dart';
import 'package:kiosk_point_of_sale/data/services/remote_data/service_locator.dart';
import 'package:kiosk_point_of_sale/features/shared-features/Login/new_login_widget.dart';
import 'package:kiosk_point_of_sale/providers/payment_breakdown_provider.dart';
import 'package:kiosk_point_of_sale/repository/sales_orders_repository.dart';
import 'package:kiosk_point_of_sale/features/shared-features/Home/home_widget.dart';
import 'package:kiosk_point_of_sale/features/shared-features/Login/login_widget.dart';
import 'package:kiosk_point_of_sale/features/shared-features/Orders/orders_screen.dart';
import 'package:kiosk_point_of_sale/features/shared-features/admin/reports/cashier_report/cashier_report_view.dart';
import 'package:zatca_2_invoice_generator/zatca_2_invoice_generator.dart';

bool isShiftClosed = false;
var imageWidget;

class CashierWidget extends ConsumerStatefulWidget {
  static String routeName = 'Cashier';
  static String routePath = '/cashier';
  const CashierWidget({super.key});

  @override
  _CashierWidgetState createState() => _CashierWidgetState();
}

class _CashierWidgetState extends ConsumerState<CashierWidget> {
  bool isSyncingOrders = false;
  // Remove the local _syncTimer variable since we're using global service

  @override
  void initState() {
    // ESCPrinterService(null).initFont();
    initZacta();
    _initializeGlobalSync();
    super.initState();
  }

  Future<void> _initializeGlobalSync() async {
    if (kDebugMode) return;

    try {
      final globalSyncService = ref.read(globalSyncServiceProvider);
      globalSyncService.initialize(ref);
      dPrint("Global sync service initialized in cashier widget");
    } catch (e) {
      dPrint("Error initializing global sync in cashier: $e");
    }
  }

  @override
  void dispose() {
    // No need to cancel local timer since we're using global service
    super.dispose();
  }

  void initZacta() async {
    final deviceInfo = await DeviceConfigTable.getDeviceInfo();
    if (deviceInfo == null) return;
    if (deviceInfo.privateKey == null || deviceInfo.publicKey == null || deviceInfo.vat.isEmpty) {
      return;
    }
    try {
      ZatcaManager.instance.initializeZacta(
        sellerName: deviceInfo.companyName ?? '',
        sellerTRN: deviceInfo.vat ?? '',
        privateKeyBase64: deviceInfo.privateKey ?? '',
        certificateBase64: deviceInfo.publicKey ?? '',
        supplier: Supplier(
          companyID: deviceInfo.crNumber ?? '',
          registrationName: deviceInfo.vat ?? '',
          address: Address(
            streetName: "",
            buildingNumber: "",
            citySubdivisionName: ZatcaConstants.area,
            cityName: ZatcaConstants.cityName,
            postalZone: ZatcaConstants.postalZone,
          ),
        ),
      );
    } catch (e) {
      dPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPageWithActionButtons(
      buttons: [
        ButtonSettings(
          onTap: () async {
            if (isShiftClosed) {
              customSnackbar(context,
                  translator(arText: "الوردية مغلقة", enText: "Shift is already closed"), false);
              return;
            }
            final cashierShifts = await CashierShiftTable.getAll();
            final shiftTableDetails = cashierShifts.first;
            bool isEndDayWork = shiftTableDetails.isActiveEndOfDay;
            final xReportService = ref.watch(xReportApiServiceProvider);

            // Get shift report data for the bottom sheet
            final shiftReport = await getCashierShiftReport(context);
            final deviceInfo = await DeviceConfigTable.getDeviceInfo();

            // Show X-Report bottom sheet
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => XReportBottomSheet(
                reportModel: shiftReport,
                outletName: deviceInfo?.storeCode,
                shiftId: shiftTableDetails.cashierShiftId.toString(),
              ),
            );
          },
          title: translator(arText: "تقرير امين الصندوق", enText: "X Report"),
          icon: Icons.receipt,
        ),
        ButtonSettings(
          onTap: () async {
            if (isShiftClosed) {
              customSnackbar(
                  context,
                  translator(
                      arText: "لا يمكنك الذهاب للبيع بعد اغلاق الوردية",
                      enText: "You can't go to sell after closing the shift"),
                  false);
              return;
            }
            context.go(AppModeSession.postCashierRoute);
         
          },
          title: FFLocalizations.of(context).getText('tsdd3ule'),
          icon: Icons.sell,
        ),
        ButtonSettings(
          onTap: () async {
            ValueNotifier<double> progressNotifier = ValueNotifier(0.0);
            try {
              showLoading(context, progressNotifier: progressNotifier);
              await syncMenuData(context, ref, progressNotifier);
              syncOrders(ref);
              hideLoading(context);
            } catch (e, t) {
              hideLoading(context);
              final useNewFlow = AuthFlowConfig.isNewFlowEnabled;
              context.go(useNewFlow ? NewLoginWidget.routePath:LoginWidget.routePath);
              dPrint(e.toString());
              dPrint(t.toString());
            }
            hideLoading(context);
          },
          title: FFLocalizations.of(context).getText('g54wbefp'),
          icon: Icons.sync,
        ),
        // ButtonSettings(
        //   onTap: () async {
        //     // Manual sync test
        //     try {
        //       final globalSyncService = ref.read(globalSyncServiceProvider);
        //       await globalSyncService.forceSync(ref);
        //       customSnackbar(context, 'Manual sync completed', true);
        //     } catch (e, t) {
        //       customSnackbar(context, 'Manual sync failed: $e', false);
        //       dPrint("Manual sync error: $e");
        //       dPrint("Manual sync trace: $t");
        //     }
        //   },
        //   title: 'Manual Sync',
        //   icon: Icons.refresh,
        // ),
        ButtonSettings(
          onTap: () async {
            context.go(OrdersScreen.routePath, extra: false);
          },
          title: translator(arText: 'الطلبات', enText: 'Orders'),
          icon: Icons.list_alt,
        ),
        // Debug button - only visible in debug mode
        if (kDebugMode)
          ButtonSettings(
            onTap: () async {
              context.go(AppRoutes.debug);
            },
            title: translator(arText: 'تصحيح الأخطاء', enText: 'Debug'),
            icon: Icons.bug_report,
          ),
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
        context.go(HomeWidget.routePath);
      },
      pageTitle: '5p5nlp2r',
    );
  }
}

Future<ShiftReportModel?> getCashierShiftReport(BuildContext context) async {
  String createdAt = DateTime.now().toIso8601String();
  final workDate = await SyncRequestHelper().getBusinessDay(createdAt);
  String date = workDate?.toIso8601String().split('T').first ??
      DateTime.now().toIso8601String().split('T').first ??
      '';
  // Extracts date
  String time = DateTime.now()
      .toIso8601String()
      .split('T')
      .last
      .split('.')[0]; // Extracts time without milliseconds
  final deviceInfo = await DeviceConfigTable.getDeviceInfo();
  final cashierShifts = await CashierShiftTable.getAll();
  final shift = cashierShifts.first;
  List<SalesInvoice> invoices = await SalesOrdersRepositoryImpl().getAllOrdersFromDataBase();
  List<SalesInvoice> allPtCashInvoices = await SalesOrdersRepositoryImpl().getPtCashDataBase();
  List<SalesInvoice> ptCashInvoices = allPtCashInvoices
      .where((e) =>
          (e.salesOrderModel.workDate == date &&
              shift.cashierShiftId == e.salesOrderModel.cashierShiftId) &&
          e.salesOrderModel.isRefund == 0 &&
          (double.tryParse(e.salesOrderModel.totalAmount) ?? 0) > 0 &&
          e.salesOrderItems.isEmpty)
      .toList();
  final totalPtCash = ptCashInvoices.fold(
      0.0,
      (previousValue, element) =>
          (previousValue) + double.parse(element.salesOrderModel.totalAmount));
  invoices = invoices.where((e) {
    dPrint(
        " date is ($date) workDate is  (${e.salesOrderModel.workDate})  ${e.salesOrderModel.workDate == date}");
    return e.salesOrderModel.workDate == date &&
        shift.cashierShiftId == e.salesOrderModel.cashierShiftId;
  }).toList();
  List<SalesInvoice> totalInvoices = invoices
      .where((e) =>
          e.salesOrderModel.isRefund == 0 &&
          e.salesOrderModel.haveRefund != 1 &&
          e.salesOrderModel.totalAmount != "0")
      .toList();

  List<SalesInvoice> refundInvoices =
      await SalesOrdersRepositoryImpl().getAllRefundOrdersFromDataBase();
  refundInvoices = refundInvoices
      .where((e) =>
          e.salesOrderModel.workDate == date &&
          shift.cashierShiftId == e.salesOrderModel.cashierShiftId)
      .toList();
  final totalRefund = refundInvoices.fold(
      0.0,
      (previousValue, element) =>
          (previousValue) + double.parse(element.salesOrderModel.totalAmount));
  List<SaleType> saleTypes = await generateSaleTypeList();
  List<Map<String, dynamic>> saleSummary = getSaleTypeSummary(totalInvoices, saleTypes);

  List<ReportDetails> saleTypeDetails = [];
  List<Map<String, dynamic>> tenderSummary = getTenderSummary(
    totalInvoices,
  );
  List<Map<String, dynamic>> bettyCashTenderSummary = getTenderSummary(
    ptCashInvoices,
  );
  List<ReportDetails> tenderDetails = [];
  for (var sale in tenderSummary) {
    num total = sale["totalAmount"];
    ReportDetails rep = ReportDetails(
        tenderId: sale["tenderId"],
        nameEn: sale["nameEn"],
        nameAr: sale["nameAr"],
        qty: sale["orderCount"].toString(),
        price: total.toDouble().roundToTwoDecimals().roundToTwoDecimals().toString());
    tenderDetails.add(rep);
  }
  for (var sale in saleSummary) {
    dPrint("sale is $sale");
    num total = sale["totalAmount"];
    ReportDetails rep = ReportDetails(
        nameEn: sale["saleTypeNameEn"],
        nameAr: sale["saleTypeNameAr"],
        qty: sale["orderCount"].toString(),
        price: total.toDouble().roundToTwoDecimals().roundToTwoDecimals().toString());
    saleTypeDetails.add(rep);
  }
  List<ReportDetails> bettyCashTenderDetails = [];
  for (var sale in bettyCashTenderSummary) {
    num total = sale["totalAmount"];
    ReportDetails rep = ReportDetails(
        tenderId: sale["tenderId"],
        nameEn: "Petty Cash ",
        nameAr: "Petty Cash ",
        qty: sale["orderCount"].toString(),
        price: total.toDouble().roundToTwoDecimals().roundToTwoDecimals().toString());
    tenderDetails.add(rep);
  }
  // if (invoices.isEmpty && refundInvoices.isEmpty) {
  //   customSnackbar(
  //       context,
  //       translator(
  //           arText: "لا توجد طلبات في هذا الفترة", enText: " There is No orders in this Shift"),
  //       false);
  //   return null;
  // }

  String? username = await AppPreferences().getUsername();

  final totalWithVat = totalInvoices.fold(
      0.0,
      (previousValue, element) =>
          (previousValue) + double.parse(element.salesOrderModel.totalAmount));
  final totalWithOutVat = totalInvoices.fold(0.0,
      (previousValue, element) => (previousValue) + double.parse(element.salesOrderModel.subTotal));
  final totalTaxes = totalInvoices.fold(
      0.0, (previousValue, element) => (previousValue) + double.parse(element.salesOrderModel.tax));
  final totalDiscount = totalInvoices.fold(
      0.0,
      (previousValue, element) =>
          (previousValue) + (element.salesOrderModel.discountAmount ?? 0.0));
  final totalDicountsAndPromotions = totalInvoices.fold(0.0,
      (previousValue, element) => (previousValue) + (element.salesOrderModel.discountValue ?? 0.0));

  // Calculate promotions applied on items
  List<PromotionShift> promotions = calculatePromotionsFromInvoices(totalInvoices);
  final userName = await AppPreferences().getUsername();

  final shiftReport = ShiftReportModel(
      promotions: promotions,
      businessDateFrom: shift.startOfDayDate ?? "00:00",
      businessDateTo: shift.endOfDayDate ?? "23:59",
      date: date,
      appConfig: deviceInfo,
      time: time,
      totalTaxes: totalTaxes.roundToTwoDecimals().toStringAsFixed(2),
      totalDiscount: totalDiscount.roundToTwoDecimals().toStringAsFixed(2),
      totalPtCash: totalPtCash.roundToTwoDecimals().toStringAsFixed(2),
      cashierName: userName,
      printedBy: username,
      totalSalesWithVatNo: totalWithVat.roundToTwoDecimals().toStringAsFixed(2),
      totalSalesWithOutVatNo:
          (totalWithOutVat - totalDicountsAndPromotions).roundToTwoDecimals().toStringAsFixed(2),
      returnInvoices: ReportDetails(
          nameEn: "Return Invoices",
          nameAr: "الفواتير المرتجعة",
          qty: refundInvoices.length.toString(),
          price: totalRefund.toString()),
      saleTypes: saleTypeDetails,
      tenderTypes: [...tenderDetails, ...bettyCashTenderDetails]);

  return shiftReport;
}

/// Calculate promotions applied on items from invoices
List<PromotionShift> calculatePromotionsFromInvoices(List<SalesInvoice> invoices) {
  Map<String, PromotionShift> promotionMap = {};

  for (var invoice in invoices) {
    // First, calculate item-level promotions to get the sum
    double totalItemPromotions = 0.0;
    Map<String, double> itemPromotionsByName = {};

    for (var item in invoice.salesOrderItems) {
      if (item.promotionValue != null && item.promotionValue! > 0) {
        // Track item promotions by promotion name
        String promotionName = item.promotionName ?? 'Item Promotion';
        if (itemPromotionsByName.containsKey(promotionName)) {
          itemPromotionsByName[promotionName] =
              itemPromotionsByName[promotionName]! + item.promotionValue!;
        } else {
          itemPromotionsByName[promotionName] = item.promotionValue!;
        }
        totalItemPromotions += item.promotionValue!;
      }
    }

    // Check invoice-level promotions (subtract item promotions to avoid double counting)
    if (invoice.salesOrderModel.promotionName != null &&
        invoice.salesOrderModel.promotionName! != "" &&
        invoice.salesOrderModel.promotionValue != null &&
        invoice.salesOrderModel.promotionValue! > 0) {
      String promotionName = invoice.salesOrderModel.promotionName ?? 'Invoice Promotion';
      String promotionKey = 'invoice_$promotionName';
      dPrint("promotionName is $promotionName");
      // Calculate the actual invoice-level promotion (total - item promotions)
      double actualInvoicePromotion = invoice.salesOrderModel.promotionValue! - totalItemPromotions;
      dPrint("actualInvoicePromotion is $actualInvoicePromotion");
      if (actualInvoicePromotion > 0) {
        if (promotionMap.containsKey(promotionKey)) {
          // Update existing promotion
          var existing = promotionMap[promotionKey]!;
          double currentValue = double.tryParse(existing.promotionValue ?? '0') ?? 0;
          double newValue = currentValue + actualInvoicePromotion;
          existing.promotionValue = newValue.toString();

          // Update number of applies
          int currentApplies = int.tryParse(existing.numbersOfApplies ?? '0') ?? 0;
          existing.numbersOfApplies = (currentApplies + 1).toString();
        } else {
          promotionMap[promotionKey] = PromotionShift(
            promotionId: invoice.salesOrderModel.promotionId.toString(),
            promotionName: promotionName,
            promotionValue: actualInvoicePromotion.toString(),
            numbersOfApplies: '1',
          );
        }
      }
    }

    // Add item-level promotions (these are already calculated above)
    for (var item in invoice.salesOrderItems) {
      if (item.promotionValue != null && item.promotionValue! > 0) {
        String promotionName = item.promotionName ?? 'Item Promotion';
        String promotionKey = 'item_$promotionName';
        if (promotionMap.containsKey(promotionKey)) {
          // Update existing promotion
          var existing = promotionMap[promotionKey]!;
          double currentValue = double.tryParse(existing.promotionValue ?? '0') ?? 0;
          double newValue = currentValue + item.promotionValue!;
          existing.promotionValue = newValue.toString();

          // Update number of applies
          int currentApplies = int.tryParse(existing.numbersOfApplies ?? '0') ?? 0;
          existing.numbersOfApplies = (currentApplies + 1).toString();
        } else {
          promotionMap[promotionKey] = PromotionShift(
            promotionId: item.promotionCodeId.toString(),
            promotionName: promotionName,
            promotionValue: item.promotionValue.toString(),
            numbersOfApplies: '1',
          );
        }
      }

      // Check item-level discounts
      if (item.discount != null && item.discount! > 0) {
        String discountKey = 'item_discount';
        if (promotionMap.containsKey(discountKey)) {
          // Update existing discount
          var existing = promotionMap[discountKey]!;
          double currentValue = double.tryParse(existing.promotionValue ?? '0') ?? 0;
          double newValue = currentValue + (item.discount! * (double.tryParse(item.quantity) ?? 1));
          existing.promotionValue = newValue.toString();

          // Update number of applies
          int currentApplies = int.tryParse(existing.numbersOfApplies ?? '0') ?? 0;
          existing.numbersOfApplies = (currentApplies + 1).toString();
        } else {
          promotionMap[discountKey] = PromotionShift(
            promotionId: '0', // 0 for discount
            promotionName: 'Item Discount',
            promotionValue: (item.discount! * (double.tryParse(item.quantity) ?? 1)).toString(),
            numbersOfApplies: '1',
          );
        }
      }

      // Check loyalty discounts
      if (item.loyaltyDiscount != null && item.loyaltyDiscount! > 0) {
        String loyaltyKey = 'loyalty_discount';
        if (promotionMap.containsKey(loyaltyKey)) {
          // Update existing loyalty discount
          var existing = promotionMap[loyaltyKey]!;
          double currentValue = double.tryParse(existing.promotionValue ?? '0') ?? 0;
          double newValue = currentValue + item.loyaltyDiscount!;
          existing.promotionValue = newValue.toString();

          // Update number of applies
          int currentApplies = int.tryParse(existing.numbersOfApplies ?? '0') ?? 0;
          existing.numbersOfApplies = (currentApplies + 1).toString();
        } else {
          promotionMap[loyaltyKey] = PromotionShift(
            promotionId: '-1', // -1 for loyalty discount
            promotionName: 'Loyalty Discount',
            promotionValue: item.loyaltyDiscount.toString(),
            numbersOfApplies: '1',
          );
        }
      }
    }

    // Check invoice-level discounts
    if (invoice.salesOrderModel.discountAmount != null &&
        invoice.salesOrderModel.discountAmount! > 0) {
      String discountKey = 'invoice_discount';
      if (promotionMap.containsKey(discountKey)) {
        // Update existing discount
        var existing = promotionMap[discountKey]!;
        double currentValue = double.tryParse(existing.promotionValue ?? '0') ?? 0;
        double newValue = currentValue + invoice.salesOrderModel.discountAmount!;
        existing.promotionValue = newValue.toString();

        // Update number of applies
        int currentApplies = int.tryParse(existing.numbersOfApplies ?? '0') ?? 0;
        existing.numbersOfApplies = (currentApplies + 1).toString();
      } else {
        promotionMap[discountKey] = PromotionShift(
          promotionId: '0', // 0 for discount
          promotionName: 'Invoice Discount',
          promotionValue: invoice.salesOrderModel.discountAmount.toString(),
          numbersOfApplies: '1',
        );
      }
    }
  }

  return promotionMap.values.toList();
}
