import 'package:flutter/material.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/features/shared-features/admin/reports/cashier_report/cashier_report_view.dart';
import 'package:kiosk_point_of_sale/core/helpers/responsive_helper.dart';
import 'package:kiosk_point_of_sale/main.dart';

Widget buildReportTitle(ShiftReportModel reportModel, String StoreNumber) {
  return Column(
    children: [
      Container(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(translator(enText: "Store:", arText: "المتجر:"),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                )),
            Text(reportModel.appConfig?.storeNumber ?? StoreNumber,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                )),
            if (reportModel.appConfig?.companyName != null)
              Text("  -  ",
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  )),
            Text(reportModel.appConfig?.companyName ?? '',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                )),
          ],
        ),
      ),
      Container(
        color: Colors.white,
        child: Center(
          child: Text(
              translator(
                  enText: "Employee Sales Report",
                  arText: "تقرير مبيعات كاشير"),
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              )),
        ),
      ),
    ],
  );
}

Widget buildReportFooter(ShiftReportModel reportModel) {
  return Column(
    children: [
      Container(
        color: Colors.white,
        child: Center(
          child: Text("Powerd By ",
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              )),
        ),
      ),
      Container(
        color: Colors.white,
        child: Center(
          child: Text("www.3d-sys.com",
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              )),
        ),
      ),
    ],
  );
}

Widget dotsDivider() {
  final context = navKey.currentState!.context;

  return Container(
    color: Colors.white,
    child: Center(
      child: Text('------------------------------------------',
          style: TextStyle(
            color: Colors.black,
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
            fontWeight: FontWeight.bold,
          )),
    ),
  );
}

Widget infoWidget({
  required String title,
  required String subTitle,
}) {
  return Container(
    color: Colors.white,
    child: Row(
      children: [
        const SizedBox(
          width: 20,
        ),
        Text(title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            )),
        const Spacer(flex: 1),
        Text(subTitle,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            )),
        const SizedBox(
          width: 20,
        ),
      ],
    ),
  );
}

Widget infoDetailsWidget(ReportDetails reportDetails) {
  return Container(
    color: Colors.white,
    child: Row(
      children: [
        const SizedBox(
          width: 20,
        ),
        Text(
            translator(
                arText: reportDetails.nameAr, enText: reportDetails.nameEn),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            )),
        const Spacer(flex: 1),
        SizedBox(
          width: 35,
          child: Center(
            child: Text(reportDetails.qty,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                )),
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        SizedBox(
          width: 70,
          child: Center(
            child: Text(reportDetails.price,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                )),
          ),
        ),
        const SizedBox(
          width: 20,
        ),
      ],
    ),
  );
}

Widget infoDetailsTitleWidget({String? name}) {
  return Container(
    color: Colors.white,
    child: Row(
      children: [
        const SizedBox(
          width: 20,
        ),
        Text(name ?? "",
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            )),
        const Spacer(flex: 1),
        SizedBox(
          width: 35,
          child: Center(
            child: Text(translator(arText: "الكمية", enText: "Qty"),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                )),
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        SizedBox(
          width: 70,
          child: Center(
            child: Text(translator(arText: "السعر", enText: "Price"),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                )),
          ),
        ),
        const SizedBox(
          width: 20,
        ),
      ],
    ),
  );
}
