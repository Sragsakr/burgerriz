// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unused_local_variable, unnecessary_new, deprecated_member_use, use_build_context_synchronously

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/custom_page_with_action_buttons.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/custom_snackbar_widget.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_dialogs.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';
import 'package:kiosk_point_of_sale/core/helpers/login_helpers.dart';
import 'package:kiosk_point_of_sale/core/helpers/responsive_helper.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_invoice.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/device/device_info_table.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/device/shift_table.dart';
import 'package:kiosk_point_of_sale/providers/payment_breakdown_provider.dart';
import 'package:kiosk_point_of_sale/repository/sales_orders_repository.dart';
import 'package:kiosk_point_of_sale/features/shared-features/Cashier/cashier_widget.dart';
import 'package:kiosk_point_of_sale/features/shared-features/Orders/orders_screen.dart';
import 'package:kiosk_point_of_sale/features/shared-features/admin/reports/cashier_report/cashier_report_view.dart';
import 'package:kiosk_point_of_sale/features/shared-features/refunds/refunds_screen.dart';
import 'package:kiosk_point_of_sale/features/shared-features/settings/settings_screen.dart';

import '../../../core/helpers/helper_functions.dart';

class AdminWidget extends ConsumerWidget {
  static String routeName = 'Admin';
  static String routePath = '/admin';
  const AdminWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomPageWithActionButtons(
      buttons: [
        ButtonSettings(
          onTap: () async {
            DateTime now = DateTime.now().toLocal();
            String date = now.toIso8601String().split('T').first; // Extracts date
            String time = now
                .toIso8601String()
                .split('T')
                .last
                .split('.')[0]; // Extracts time without milliseconds
            String? selectedDate = await selectDate(context);
            if (selectedDate != null) {
              await generateCasherReport(selectedDate, time, context);
            }
          },
          title: translator(arText: "تقرير امين الصندوق", enText: "Cashier Report"),
          icon: Icons.receipt,
        ),
        ButtonSettings(
          onTap: () async {
            context.go(OrdersScreen.routePath, extra: true);
          },
          title: translator(arText: 'الطلبات', enText: 'Orders'),
          icon: Icons.list_alt,
        ),
        ButtonSettings(
          onTap: () async {
            context.go(RedundScreen.routePath);
          },
          title: translator(arText: 'المرتجعات', enText: 'Refunds'),
          icon: Icons.refresh,
        ),
        // ButtonSettings(
        //   onTap: () async {
        //     //cashier
        //   },
        //   title: 'Temp print',
        //   icon: Icons.print,
        // ),
      ],
      actions: [
        IconButton(
          icon: Icon(
            Icons.settings,
            size: ResponsiveHelper.getResponsiveSize(
              context,
              24,
            ),
          ),
          onPressed: () {
            context.go(SettingsScreen.routePath);
          },
          tooltip: translator(
            arText: 'الإعدادات',
            enText: 'Settings',
          ),
        ),
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
        // Custom back button logic
        context.go('/home-page');
      },
      pageTitle: '8aj1dytd',
    );
  }

  Future<void> generateCasherReport(String date, String time, BuildContext context) async {
    final deviceInfo = await DeviceConfigTable.getDeviceInfo();
    List<SalesInvoice> invoices = await SalesOrdersRepositoryImpl().getAllOrdersFromDataBase();
    invoices = invoices.where((e) => e.salesOrderModel.workDate == date).toList();
    List<SalesInvoice> totalInvoices = invoices
        .where((e) =>
            e.salesOrderModel.isRefund == 0 &&
            e.salesOrderModel.haveRefund != 1 &&
            e.salesOrderModel.totalAmount != "0")
        .toList();
    List<SalesInvoice> allPtCashInvoices = await SalesOrdersRepositoryImpl().getPtCashDataBase();
    List<SalesInvoice> ptCashInvoices = allPtCashInvoices
        .where((e) =>
            (e.salesOrderModel.workDate == date) &&
            e.salesOrderModel.isRefund == 0 &&
            (double.tryParse(e.salesOrderModel.totalAmount) ?? 0) > 0 &&
            e.salesOrderItems.isEmpty)
        .toList();
    final totalPtCash = ptCashInvoices.fold(
        0.0,
        (previousValue, element) =>
            (previousValue) + double.parse(element.salesOrderModel.totalAmount));
    List<SalesInvoice> refundInvoices =
        await SalesOrdersRepositoryImpl().getAllRefundOrdersFromDataBase();
    refundInvoices = refundInvoices.where((e) => e.salesOrderModel.workDate == date).toList();
    final totalRefund = refundInvoices.fold(
        0.0,
        (previousValue, element) =>
            (previousValue) + double.parse(element.salesOrderModel.totalAmount));
    final totalWithVat = totalInvoices.fold(
        0.0,
        (previousValue, element) =>
            (previousValue) + double.parse(element.salesOrderModel.totalAmount));
    final totalWithOutVat = totalInvoices.fold(
        0.0,
        (previousValue, element) =>
            (previousValue) + double.parse(element.salesOrderModel.subTotal));
    final totalTaxes = totalInvoices.fold(0.0,
        (previousValue, element) => (previousValue) + double.parse(element.salesOrderModel.tax));
    final totalDiscount = totalInvoices.fold(
        0.0,
        (previousValue, element) =>
            (previousValue) + (element.salesOrderModel.discountValue ?? 0.0));
    final totalDicountsAndPromotions = totalInvoices.fold(
        0.0,
        (previousValue, element) =>
            (previousValue) + (element.salesOrderModel.discountValue ?? 0.0));
    if (invoices.isEmpty && refundInvoices.isEmpty) {
      customSnackbar(
          context,
          translator(
              arText: "لا توجد طلبات في هذا اليوم", enText: " There is No orders in this day"),
          false);
      return;
    }
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
          nameEn: sale["nameEn"],
          nameAr: sale["nameAr"],
          qty: sale["orderCount"].toString(),
          price: total.toDouble().roundToTwoDecimals().roundToTwoDecimals().toString());
      tenderDetails.add(rep);
    }
    for (var sale in saleSummary) {
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
    final cashierShifts = await CashierShiftTable.getAll();
    final shift = cashierShifts.first;
    String? username = await AppPreferences().getUsername();
    log(totalInvoices.map((e) => e.toJson()).toList().toString());
    List<PromotionShift> promotions = calculatePromotionsFromInvoices(totalInvoices);
    dPrint("Promotions: $promotions");
    final shiftReport = ShiftReportModel(
        promotions: promotions,
        totalPtCash: totalPtCash.roundToTwoDecimals().toStringAsFixed(2),
        businessDateFrom: shift.startOfDayDate ?? "00:00",
        businessDateTo: shift.endOfDayDate ?? "23:59",
        date: date,
        appConfig: deviceInfo!,
        time: time,
        cashierName: invoices.last.salesOrderModel.cashierName,
        printedBy: "Supervisor",
        totalSalesWithVatNo: totalWithVat.roundToTwoDecimals().toStringAsFixed(2),
        totalDiscount: totalDiscount.roundToTwoDecimals().toStringAsFixed(2),
        totalTaxes: totalTaxes.roundToTwoDecimals().toStringAsFixed(2),
        totalSalesWithOutVatNo:
            (totalWithOutVat - totalDicountsAndPromotions).roundToTwoDecimals().toStringAsFixed(2),
        returnInvoices: ReportDetails(
            nameEn: "Return Invoices",
            nameAr: "الفواتير المرتجعة",
            qty: refundInvoices.length.toString(),
            price: totalRefund.roundToTwoDecimals().toStringAsFixed(2)),
        saleTypes: saleTypeDetails,
        tenderTypes: tenderDetails);
    showAppDialog(
      context: context,
      builder: (context1) => CashierReportView(reportModel: shiftReport),
    );
  }
}
