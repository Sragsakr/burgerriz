import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/custom_snackbar_widget.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/core/helpers/login_helpers.dart';
import 'package:kiosk_point_of_sale/core/helpers/responsive_helper.dart';
import 'package:kiosk_point_of_sale/core/services/printing_services/drago/drago_printer_controller.dart';
import 'package:kiosk_point_of_sale/core/services/printing_services/network_printing/network_printer_controller.dart';
import 'package:kiosk_point_of_sale/core/services/loading_services/enhanced_loading_service.dart';
import 'package:kiosk_point_of_sale/main.dart';
import 'package:kiosk_point_of_sale/features/shared-features/admin/reports/cashier_report/cashier_report_content.dart';

import '../../../../../core/helpers/app_language_helper.dart';
import '../../../../../data/models/store/device_info_model.dart';
import '../../../../../data/services/local_data/device/device_info_table.dart';

class CashierReportView extends ConsumerStatefulWidget {
  final ShiftReportModel reportModel;

  const CashierReportView({
    super.key,
    required this.reportModel,
  });

  @override
  CashierReportViewState createState() => CashierReportViewState();
}

class CashierReportViewState extends ConsumerState<CashierReportView> {
  DeviceConfigModel? appConfig;
  String storeNumber = '';

  @override
  void initState() {
    getAppConfig();
    getStore();
    super.initState();
  }

  getAppConfig() async {
    appConfig = await DeviceConfigTable.getDeviceInfo();
  }

  getStore() async {
    AppPreferences().getStore().then((value) {
      setState(() {
        storeNumber = value;
        dPrint("&&&&&& $storeNumber  $value");
      });
    });
  }

  ShiftReportModel get report => widget.reportModel;

  @override
  Widget build(BuildContext context) {
    final isEnglish =
        Localizations.localeOf(navKey.currentState!.context).languageCode ==
            'en';
    final path = "https://zatca.posmena.com.tr";
    // Replace with your network image URL
    String imageUrl = "";
    if (widget.reportModel.appConfig != null) {
      imageUrl = widget.reportModel.appConfig?.logo ?? "";
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppBar(ref, context),
      body: Directionality(
        textDirection: isEnglish ? TextDirection.ltr : TextDirection.rtl,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (widget.reportModel.appConfig != null)
                  Container(
                    color: Colors.white,
                    width: 280,
                    child: Image.network(
                      path + imageUrl,
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox.shrink(),
                    ),
                  ),
                buildReportTitle(report, storeNumber),
                buildDivider(),
                infoWidget(
                    title: translator(
                        arText: "تاريخ العمل من ",
                        enText: "Business Data From"),
                    subTitle: report.businessDateFrom),
                infoWidget(
                    title: translator(
                        arText: "تاريخ العمل الي ", enText: "Business Data To"),
                    subTitle: report.businessDateTo),
                infoWidget(
                    title: translator(arText: "التاريخ", enText: "Date"),
                    subTitle: report.date),
                infoWidget(
                    title: translator(arText: "الوقت", enText: "Time"),
                    subTitle: report.time),
                infoWidget(
                    title: translator(arText: "طباعه", enText: "Printed By"),
                    subTitle: report.printedBy),
                infoWidget(
                    title: translator(arText: "كاشير", enText: "Cashier"),
                    subTitle: report.cashierName),
                buildDivider(),
                infoWidget(
                    title: translator(
                      arText: "المبيعات بدون ضريبه",
                      enText: "ToTal Sales WithOut Vat",
                    ),
                    subTitle: report.totalSalesWithOutVatNo),
                infoWidget(
                    title: translator(
                      arText: "الضريبة",
                      enText: "Vat",
                    ),
                    subTitle: report.totalTaxes),
                infoWidget(
                    title: translator(
                      arText: "  المبيعات مع الضريبة ١٥ ٪",
                      enText: "ToTal Sales With Vat 15 %",
                    ),
                    subTitle: report.totalSalesWithVatNo),
                buildDivider(),
                infoDetailsTitleWidget(),
                infoDetailsWidget(report.returnInvoices),
                buildDivider(),
                infoDetailsTitleWidget(
                    name:
                        translator(arText: "نوع البيع", enText: "Sale Types")),
                ...report.saleTypes.map((e) => infoDetailsWidget(e)),
                buildDivider(),
                // infoWidget(
                //     title: translator(
                //       arText: "الخصم",
                //       enText: "Discount",
                //     ),
                //     subTitle: report.totalDiscount),
                // buildDivider(),
                /// promotions
                infoDetailsTitleWidget(
                    name: translator(arText: "الخصم", enText: "Discount")),
                ...report.promotions.map((e) => infoDetailsWidget(ReportDetails(
                      nameAr: e.promotionName ?? '',
                      nameEn: e.promotionName ?? '',
                      qty: e.numbersOfApplies ?? '',
                      price: double.tryParse(e.promotionValue ?? '0')
                              ?.toStringAsFixed(2) ??
                          '',
                    ))),
                buildDivider(),
                infoDetailsTitleWidget(
                    name: translator(
                        arText: "طرق الدفع", enText: "Tender Types")),
                ...report.tenderTypes.map((e) => infoDetailsWidget(e)),
                // infoWidget(
                //     title: translator(
                //       arText: "Petty Cash",
                //       enText: "Petty Cash",
                //     ),
                //     subTitle: report.totalPtCash.toString()),
                buildDivider(),
                buildReportFooter(report),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container buildDivider() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Text('-------------------------------------',
            style: TextStyle(
              color: Colors.black,
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
              fontWeight: FontWeight.bold,
            )),
      ),
    );
  }

  AppBar buildAppBar(WidgetRef ref, BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      centerTitle: true,
      elevation: 0.8,
      actions: [
        IconButton(
          icon: const Icon(Icons.print),
          onPressed: () async {
            return;
            enhancedLoadingService.showEnhancedLoading(
              context,
              message: translator(
                  arText: "جاري طباعة تقرير الوردية",
                  enText: "Printing Shift Report"),
              isLottie: true,
            );

            await enhancedLoadingService.processPrinting(
              operationType:
                  translator(arText: "تقرير الوردية", enText: "Shift Report"),
              // generateInvoice: () async {
              //   return report;
              // },
              generatePdf: () async {
                // For shift reports, we'll use the existing methods
                String selectedMode = await AppPreferences().getPrinterMode();
                if (selectedMode == 'network') {
                  await NetworkPrinterController.printShiftReport(
                      report: report);
                } else {
                  await DragoPrinterController.printShiftReportPdf(
                      report: report);
                }
                return null; // Shift reports don't return PDF data
              },
              // saveOrder: () async {
              //   return;
              // },
              sendInvoice: null,
              printInvoice: null, // Already handled in generatePdf
            );
            enhancedLoadingService.hideLoading();
            // if (ResponsiveHelper.isTablet(context)) {
            //   await NetworkPrinterController.printShiftReport(report: report);
            // } else {
            //   await DragoPrinterController.printShiftReportPdf(report: report);
            // }
            // printCashierReport(context, report: report);
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(2.0, 0.0, 0.0, 0.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Text(
              //   translator(arText: ' فاتورة  ', enText: "Invoice "),
              //   // 'POS',
              //   style: FlutterFlowTheme.of(context).headlineSmall.override(
              //         fontFamily: 'Outfit',
              //         color: FlutterFlowTheme.of(context).gray600,
              //       ),
              // ),
              // Text(
              //   "#",
              //   // 'POS',
              //   style: FlutterFlowTheme.of(context).headlineSmall.override(
              //         fontFamily: 'Outfit',
              //         color: FlutterFlowTheme.of(context).gray600,
              //       ),
              // ),
            ],
          ),
        ),
        centerTitle: true,
        expandedTitleScale: 1.0,
      ),
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_rounded,
          color: Color(0xFFAF2A26),
          size: 30.0,
        ),
        onPressed: () {
          context.pop();
        },
      ),
    );
  }
}

Future<bool> printCashierReport(BuildContext context,
    {bool cilent = false, required ShiftReportModel report}) async {
  if (!cilent) {
    showLoading(context);
  }
  try {
    // Use Drago printer for PDF printing
    await DragoPrinterController.printShiftReportPdf(report: report);

    await Future.delayed(const Duration(seconds: 2));
    hideLoading(context);
    return true;
  } catch (e) {
    hideLoading(context);
    customSnackbar(context, e.toString(), false);
    return false;
  }
  return false;
}

class ShiftReportModel {
  DeviceConfigModel? appConfig;
  final String businessDateFrom;
  final String businessDateTo;
  final String date;
  final String time;
  final String cashierName;
  final String printedBy;
  final String totalSalesWithVatNo;
  final String totalDiscount;
  final String totalSalesWithOutVatNo;
  final String totalTaxes;
  final String totalPtCash;
  final ReportDetails returnInvoices;
  final List<ReportDetails> saleTypes;
  final List<ReportDetails> tenderTypes;
  List<PromotionShift> promotions;
  ShiftReportModel(
      {required this.businessDateFrom,
      required this.businessDateTo,
      required this.date,
      this.appConfig,
      required this.time,
      required this.cashierName,
      required this.printedBy,
      required this.totalSalesWithVatNo,
      required this.totalSalesWithOutVatNo,
      required this.totalDiscount,
      required this.totalTaxes,
      required this.totalPtCash,
      required this.returnInvoices,
      required this.saleTypes,
      required this.tenderTypes,
      required this.promotions});
}

class ReportDetails {
  final String nameAr;
  final String nameEn;
  final String qty;
  final String price;
  int? tenderId;

  ReportDetails({
    required this.nameAr,
    required this.nameEn,
    required this.qty,
    required this.price,
    this.tenderId,
  });
}

class PromotionShift {
  String? promotionId;
  String? promotionName;
  String? promotionValue;
  String? numbersOfApplies;

  PromotionShift({
    this.promotionId,
    this.promotionName,
    this.promotionValue,
    this.numbersOfApplies,
  });

  factory PromotionShift.fromJson(Map<String, dynamic> json) => PromotionShift(
        promotionId: json["promotionId"],
        promotionName: json["promotionName"],
        promotionValue: json["promotionValue"],
        numbersOfApplies: json["numbersOfApplies"],
      );

  Map<String, dynamic> toJson() => {
        "promotionId": promotionId,
        "promotionName": promotionName,
        "promotionValue": promotionValue,
        "numbersOfApplies": numbersOfApplies,
      };
}
