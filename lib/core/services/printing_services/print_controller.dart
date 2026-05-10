import 'dart:async';
import 'dart:ui' as ui;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fb;
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/core/helpers/login_helpers.dart';
import 'package:kiosk_point_of_sale/core/helpers/toast_utils.dart';
import 'package:kiosk_point_of_sale/core/services/printing_services/invoice_view.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_invoice.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/device/device_info_table.dart';
import 'package:kiosk_point_of_sale/main.dart';
import 'package:kiosk_point_of_sale/providers/payment_breakdown_provider.dart';
import 'package:kiosk_point_of_sale/features/shared-features/admin/reports/cashier_report/cashier_report_content.dart';
import 'package:kiosk_point_of_sale/features/shared-features/admin/reports/cashier_report/cashier_report_view.dart';
import 'package:intl/intl.dart' as intl;

import '../../../data/services/local_data/db/meta_data_table.dart';
import '../../helpers/app_pref.dart';

Completer<void>? printerCompleter; // <void>
Completer<void>? qrCompleter; // <void>

class PrintUtils {
  List<BluetoothDevice> _devices = [];
  BlueThermalPrinter bluetoothPrint = BlueThermalPrinter.instance;

  Future<void> printInvoice(SalesInvoice invoice) async {
    if (qrCompleter != null && !qrCompleter!.isCompleted) {
      await qrCompleter!.future;
    }
    printerCompleter = Completer<void>();
    // dPrint(invoice.salesOrderModel.qrData);
    dPrint(invoice.salesOrderModel.invoiceId.toString());
    try {
      await checkBluetooth(connected: () async {
        List<Uint8List> imgList = [];
        String title =
            isAr() ? 'فاتورة ضريبية مبسطة' : 'Simplified Tax Invoice';
        final deviceInfo = await DeviceConfigTable.getDeviceInfo();
        String invoiceNumber = invoice.salesOrderModel.orderNumber.toString();
        DateTime dateTime = DateTime.parse(invoice.salesOrderModel.createdAt);

        // Format the date
        String formattedDate = intl.DateFormat('dd/MM/yyyy').format(dateTime);

        // Format the time
        String formattedTime = intl.DateFormat('hh:mm a').format(dateTime);
        String issueDate = '$formattedDate-$formattedTime';
        String regNo = deviceInfo?.vat ?? '';

        List<SaleType> saleTypes = await generateSaleTypeList();

        final saleType = saleTypes.firstWhere(
            (element) =>
                element.saleTypeId == invoice.salesOrderModel.saleTypeId,
            orElse: () =>
                SaleType(saleTypeId: 0, nameAr: '', nameEn: '', saleNature: 0));

        Uint8List? invoiceQr = await createImageFromWidget(
            deviceInfo == null
                ? Container(
                    color: Colors.white,
                    height: 10,
                    width: 10,
                  )
                : invoiceQrCode(invoice, size: 200),
            logicalSize: const Size(500, 500),
            imageSize: const Size(680, 680));

        String arTitle = invoice.salesOrderModel.isRefund == 1
            ? 'مذكرة ائتمان مبسطة'
            : 'فاتورة ضريبية مبسطة';
        String enTitle = invoice.salesOrderModel.isRefund == 1
            ? 'Simplified Credit Note'
            : 'Simplified Tax Invoice';
        Uint8List? titleImg = await createImageFromWidget(
            Directionality(
              textDirection: ui.TextDirection.rtl,
              child: Container(
                color: Colors.white,
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        color: Colors.white,
                        child: Center(
                          child: Text(enTitle,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              )),
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        child: Center(
                          child: Text(arTitle,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            logicalSize: const Size(500, 500),
            imageSize: const Size(680, 680));

        Uint8List? logoImg2 = await createImageFromWidget(
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Container(
                // White background
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 1.0),
                ), // Padding around the content
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: 8), // Spacing
                              Text(
                                '3D',
                                style: TextStyle(
                                  fontSize: 65, // Adjust size as needed
                                  fontWeight: FontWeight.normal,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.black, // Black text
                                ),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'شركة الأنظمة الثلاثية',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20, // Adjust size as needed
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black, // Black text
                                ),
                              ),
                              SizedBox(width: 8), // Spacing
                              Text(
                                'SYSTEMS CO.',
                                style: TextStyle(
                                  fontSize: 24, // Adjust size as needed
                                  fontWeight: FontWeight.normal,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.black, // Black text
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 55,
                            height: 10,
                            color: Colors.blue, // Blue bar
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 55,
                            height: 10,
                            color: Colors.red, // Blue bar
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 55,
                            height: 10,
                            color: Colors.blue, // Blue bar
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            logicalSize: const Size(500, 500),
            imageSize: const Size(680, 680));
// await Future.delayed(const Duration(milliseconds: 500));
        final path = "https://zatca.posmena.com.tr";
        // Replace with your network image URL
        final String imageUrl = deviceInfo?.logo ?? "";
        Uint8List? logo = await createImageFromWidget(
            Directionality(
              textDirection: ui.TextDirection.rtl,
              child: Container(
                color: Colors.white,
                width: 280,
                height: 100,
                child: Image.network(
                  // "https://c8.alamy.com/comp/2J581X9/online-test-logo-design-online-exam-checklist-and-online-testing-vector-design-and-illustration-2J581X9.jpg",
                  path + imageUrl,
                  height: 100,
                ),
              ),
            ),
            logicalSize: const Size(500, 500),
            imageSize: const Size(680, 680));
        Uint8List? vSpace = await createImageFromWidget(
            Directionality(
              textDirection: ui.TextDirection.rtl,
              child: Container(
                color: Colors.white,
                width: 280,
                height: 50,
              ),
            ),
            logicalSize: const Size(500, 500),
            imageSize: const Size(680, 680));
        Uint8List? name = await createImageFromWidget(
            Directionality(
              textDirection: ui.TextDirection.rtl,
              child: Container(
                color: Colors.white,
                width: 280,
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Center(
                          child: Text('اسم المتجر',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              )),
                        ),
                        // Spacer(
                        //   flex: 1,
                        // ),
                        Center(
                          child: Text("Store Name",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              )),
                        ),
                      ],
                    ),
                    Container(
                      color: Colors.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(deviceInfo?.companyName ?? '',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              )),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            logicalSize: const Size(500, 500),
            imageSize: const Size(680, 680));
        Uint8List? adress = await createImageFromWidget(
            Directionality(
              textDirection: ui.TextDirection.rtl,
              child: Container(
                color: Colors.white,
                width: 280,
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Center(
                          child: Text('عنوان المتجر',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                              )),
                        ),
                        // Spacer(
                        //   flex: 1,
                        // ),
                        Center(
                          child: Text("Store Address",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                              )),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 280,
                      child: AutoSizeText(
                        deviceInfo?.address ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            logicalSize: const Size(500, 500),
            imageSize: const Size(680, 680));
        Uint8List? workDate = await createImageFromWidget(
            Directionality(
              textDirection: ui.TextDirection.rtl,
              child: Container(
                color: Colors.white,
                width: 280,
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('تاريخ  : ',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            )),
                        Text(' :  Date',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            )),
                      ],
                    ),
                    SizedBox(
                      width: 280,
                      child: AutoSizeText(
                        invoice.salesOrderModel.workDate,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            logicalSize: const Size(500, 500),
            imageSize: const Size(680, 680));
        Uint8List? smallDividerImg = await createImageFromWidget(
            Container(
              color: Colors.white,
              child: const Center(
                child: Text('---------------------------------------------',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    )),
              ),
            ),
            logicalSize: const Size(500, 500),
            imageSize: const Size(680, 680));
        Uint8List? dividerImg = await createImageFromWidget(
            Container(
              color: Colors.white,
              child: const Center(
                child: Text(
                    '-------------------------------------------------------------',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    )),
              ),
            ),
            logicalSize: const Size(500, 500),
            imageSize: const Size(680, 680));
        Uint8List? close = await createImageFromWidget(
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Text(
                      '<<<<<<<<${'  ${invoice.salesOrderModel.orderNumber}اغلاق الفاتورة   '}>>>>>>>>',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      )),
                  Text(
                      '<<<<<<<< close invoice ${invoice.salesOrderModel.orderNumber} >>>>>>>>',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      )),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            logicalSize: const Size(500, 500),
            imageSize: const Size(680, 680));
        Uint8List? refundImg = await createImageFromWidget(
            Directionality(
              textDirection: ui.TextDirection.rtl,
              child: Container(
                color: Colors.white,
                child: const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('مرتجع',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          )),
                      Text(' - ',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          )),
                      Text('Refund',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          )),
                    ],
                  ),
                ),
              ),
            ),
            logicalSize: const Size(500, 500),
            imageSize: const Size(680, 680));
        Uint8List? invoiceNumberImg = await createImageFromWidget(
            Directionality(
              textDirection: ui.TextDirection.rtl,
              child: Container(
                color: Colors.white,
                width: 280,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('رقم الفاتورة : ',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        )),
                    Text(invoice.salesOrderModel.orderNumber.toString(),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        )),
                    const Text(' : Invoice No',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        )),
                  ],
                ),
              ),
            ),
            logicalSize: const Size(500, 500),
            imageSize: const Size(680, 680));

        Uint8List? issueDateImg = await createImageFromWidget(
            Directionality(
              textDirection: ui.TextDirection.rtl,
              child: Container(
                color: Colors.white,
                width: 280,
                child: Column(
                  children: [
                    Container(
                      color: Colors.white,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('تاريخ الإصدار : ',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              )),
                          // Spacer(flex: 1),
                          Text(' : Issue Date',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              )),
                        ],
                      ),
                    ),
                    Container(
                      color: Colors.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(issueDate,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            logicalSize: const Size(500, 500),
            imageSize: const Size(680, 680));
        Uint8List? issueDayImg = await createImageFromWidget(
            Directionality(
              textDirection: ui.TextDirection.rtl,
              child: Container(
                color: Colors.white,
                width: 280,
                child: Column(
                  children: [
                    Container(
                      color: Colors.white,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('تاريخ  : ',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              )),
                          // Spacer(flex: 1),
                          Text(' :  Date',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              )),
                        ],
                      ),
                    ),
                    Container(
                      color: Colors.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(invoice.salesOrderModel.workDate,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            logicalSize: const Size(500, 500),
            imageSize: const Size(680, 680));
        Uint8List? saleTypeImg = await createImageFromWidget(
            Directionality(
              textDirection: ui.TextDirection.rtl,
              child: Container(
                color: Colors.white,
                width: 280,
                child: Column(
                  children: [
                    Container(
                      color: Colors.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              translator(
                                  arText: saleType.nameAr,
                                  enText: saleType.nameAr),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              )),
                          Text("-",
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              )),
                          Text(
                              translator(
                                  arText: saleType.nameEn,
                                  enText: saleType.nameEn),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            logicalSize: const Size(500, 500),
            imageSize: const Size(680, 680));
        Uint8List? vatNumberImg = await createImageFromWidget(
            Directionality(
              textDirection: ui.TextDirection.rtl,
              child: Container(
                color: Colors.white,
                width: 280,
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('رقم تسجيل الضريبة: ',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            )),
                        // Spacer(flex: 1),
                        Text(' : Registration No',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            )),
                      ],
                    ),
                    Container(
                      color: Colors.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(regNo,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              )),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            logicalSize: const Size(500, 500),
            imageSize: const Size(680, 680));
        Uint8List? tableNamesImg = await createImageFromWidget(
            Directionality(
              textDirection: ui.TextDirection.rtl,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 1),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  // border: Border(
                  //     top: BorderSide(color: Colors.black),
                  //     bottom: BorderSide(color: Colors.black))
                ),
                width: 280,
                child: const Row(children: [
                  Expanded(
                    flex: 1,
                    child: Text('المنتجات\nProducts',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        )),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text('الكمية\nQty',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        )),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text('سعر المنتج\nPrice',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        )),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text('قيمة الضريبة \nالمضافة \nTaxs',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        )),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text('سعر المنتج \nشامل الضريبة\nPrice with tax',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        )),
                  ),
                ]),
              ),
            ),
            logicalSize: const Size(500, 500),
            imageSize: const Size(680, 680));

        Uint8List? totalImg = await createImageFromWidget(
            Directionality(
              textDirection: ui.TextDirection.rtl,
              child: Container(
                color: Colors.white,
                width: 280,
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('اجمالي المبلغ الخاضع للضريبه',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            )),
                        Text('Total Without Tax',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            )),
                      ],
                    ),
                    Text(invoice.salesOrderModel.subTotal,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        )),
                  ],
                ),
              ),
            ),
            logicalSize: const Size(500, 500),
            imageSize: const Size(680, 680));
        Uint8List? totalPriceImg = await createImageFromWidget(
            Directionality(
              textDirection: ui.TextDirection.rtl,
              child: Container(
                color: Colors.white,
                width: 280,
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('المجموع مع الضريبة [15 %]',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            )),
                        Text('Total With Tax [15 %]',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            )),
                      ],
                    ),
                    Text(invoice.salesOrderModel.tax,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        )),
                  ],
                ),
              ),
            ),
            logicalSize: const Size(500, 500),
            imageSize: const Size(680, 680));

        Uint8List? totalVatImg = await createImageFromWidget(
            Directionality(
              textDirection: TextDirection.rtl,
              child: Container(
                color: Colors.white,
                width: 280,
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ضريبة القيمة المضافة [15 %]',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            )),
                        Text('Tax [15 %]',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            )),
                      ],
                    ),
                    Text(invoice.salesOrderModel.totalAmount,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        )),
                  ],
                ),
              ),
            ),
            logicalSize: const Size(500, 500),
            imageSize: const Size(680, 680));
        List<Uint8List> products = [];
        for (var item in invoice.salesOrderItems) {
          Uint8List? productImg = await createImageFromWidget(
              Directionality(
                textDirection: ui.TextDirection.rtl,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 1),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  width: 280,
                  child: Row(children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Text(item.productNameAr,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                              )),
                          Text(item.productNameEn,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                              )),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(item.quantity,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          )),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                          (double.parse(item.price) / 1.15)
                              .roundToTwoDecimals()
                              .toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          )),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                          (double.parse(item.price) * 0.15)
                              .roundToTwoDecimals()
                              .toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          )),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                          (double.parse(item.price) *
                                  double.parse(item.quantity))
                              .roundToTwoDecimals()
                              .toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          )),
                    ),
                  ]),
                ),
              ),
              logicalSize: const Size(500, 500),
              imageSize: const Size(680, 680));
          if (productImg != null) {
            products.add(productImg);
          }
        }
        // if (logo != null && (deviceInfo != null)) {
        //   await bluetoothPrint.printImageBytes(logo);
        // }
        // // if (logoImg2 != null) {
        // //   await bluetoothPrint.printImageBytes(logoImg2);
        // // }
        // if (titleImg != null) {
        //   await bluetoothPrint.printImageBytes(titleImg);
        // }
        // // if (refundImg != null && invoice.salesOrderModel.isRefund == 1) {
        // //   await bluetoothPrint.printImageBytes(refundImg);
        // // }
        // if (smallDividerImg != null) {
        //   await bluetoothPrint.printImageBytes(smallDividerImg);
        // }
        // if (invoiceNumberImg != null) {
        //   await bluetoothPrint.printImageBytes(invoiceNumberImg);
        // }
        // if (name != null) {
        //   await bluetoothPrint.printImageBytes(name);
        // }
        // if (adress != null) {
        //   await bluetoothPrint.printImageBytes(adress);
        // }
        // if (issueDateImg != null) {
        //   await bluetoothPrint.printImageBytes(issueDateImg);
        // }
        // if (workDate != null) {
        //   await bluetoothPrint.printImageBytes(workDate);
        // }

        // if (vatNumberImg != null) {
        //   await bluetoothPrint.printImageBytes(vatNumberImg);
        // }
        // if (saleTypeImg != null) {
        //   await bluetoothPrint.printImageBytes(saleTypeImg);
        // }
        // if (dividerImg != null) {
        //   await bluetoothPrint.printImageBytes(dividerImg);
        // }
        // if (tableNamesImg != null) {
        //   await bluetoothPrint.printImageBytes(tableNamesImg);
        // }
        // if (dividerImg != null) {
        //   await bluetoothPrint.printImageBytes(dividerImg);
        // }

        // for (var img in products) {
        //   await bluetoothPrint.printImageBytes(img);
        // }
        // if (dividerImg != null) {
        //   await bluetoothPrint.printImageBytes(dividerImg);
        // }
        // if (totalImg != null) {
        //   await bluetoothPrint.printImageBytes(totalImg);
        // }
        // if (totalVatImg != null) {
        //   await bluetoothPrint.printImageBytes(totalVatImg);
        // }
        // if (totalPriceImg != null) {
        //   await bluetoothPrint.printImageBytes(totalPriceImg);
        // }

        // if (close != null) {
        //   await bluetoothPrint.printImageBytes(close);
        // }
        if (invoiceQr != null) {
          await bluetoothPrint.printImageBytes(invoiceQr);
        }
        // if (vSpace != null) {
        //   await bluetoothPrint.printImageBytes(vSpace);
        // }

        printerCompleter?.complete();
        printerCompleter = null;
      });
      return;
    } catch (ex) {
      printerCompleter?.complete();
      printerCompleter = null;
      if (kDebugMode) {
        print("Error = $ex");
      }
      return;
    }
  }

  Future<void> printCashierReport(ShiftReportModel report) async {
    try {
      await checkBluetooth(connected: () async {
        final deviceInfo = await DeviceConfigTable.getDeviceInfo();
        final store = await AppPreferences().getStore();
        final ptCash = await MetadataTable.getPtCash();
        List<Uint8List?> images = [];
        List<Widget> content = [
          // if ((deviceInfo != null))
          //   Container(
          //     color: Colors.white,
          //     width: 280,
          //     child: Image.asset('assets/images/logo.png'),
          //   ),
          buildReportTitle(report, store),
          dotsDivider(),
          infoWidget(
              title: translator(
                  arText: "تاريخ العمل من ", enText: "Business Data From"),
              subTitle: ""),
          infoWidget(title: "", subTitle: report.businessDateFrom),
          infoWidget(
              title: translator(
                  arText: "تاريخ العمل الي ", enText: "Business Data To"),
              subTitle: ""),
          infoWidget(title: "", subTitle: report.businessDateTo),
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
          dotsDivider(),
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
                arText: "المبيعات مع الضريبة ١٥ ٪",
                enText: "ToTal Sales With Vat 15 %",
              ),
              subTitle: report.totalSalesWithVatNo),

          dotsDivider(),
          infoDetailsTitleWidget(),
          infoDetailsWidget(report.returnInvoices),
          dotsDivider(),
          infoDetailsTitleWidget(
              name: translator(arText: "نوع البيع", enText: "Sale Types")),
          ...report.saleTypes.map((e) => infoDetailsWidget(e)),
          dotsDivider(),
          infoDetailsTitleWidget(
              name: translator(arText: "طرق الدفع", enText: "Tender Types")),
          ...report.tenderTypes.map((e) => infoDetailsWidget(e)),
          // if (ptCash > 0)
          infoWidget(
              title: translator(
                arText: "Petty Cash",
                enText: "Petty Cash",
              ),
              subTitle: report.totalPtCash.toString()),
          dotsDivider(),
          buildReportFooter(report),
        ];
        for (var co in content) {
          final isEnglish = Localizations.localeOf(navKey.currentState!.context)
                  .languageCode ==
              'en';
          Uint8List? img = await createImageFromWidget(
              Directionality(
                textDirection:
                    isEnglish ? ui.TextDirection.ltr : ui.TextDirection.rtl,
                child: Container(
                  color: Colors.white,
                  width: 280,
                  child: co,
                ),
              ),
              logicalSize: const Size(500, 500),
              imageSize: const Size(680, 680));
          images.add(img);
        }

        for (var image in images) {
          if (image != null) {
            await bluetoothPrint.printImageBytes(image);
          }
        }

        await bluetoothPrint.printNewLine();
        await bluetoothPrint.printNewLine();
        await bluetoothPrint.printNewLine();
      });
      return;
    } catch (ex) {
      if (kDebugMode) {
        print("Error = $ex");
      }
      return;
    }
  }

  Future<void> printInvoiceTest(SalesInvoice invoice) async {
    try {
      await checkBluetooth(connected: () async {
        await bluetoothPrint.printNewLine();
        await bluetoothPrint.printNewLine();
        await bluetoothPrint.printNewLine();
        await bluetoothPrint.printNewLine();
        await bluetoothPrint.printNewLine();
      });
      return;
    } catch (ex) {
      if (kDebugMode) {
        print("Error = $ex");
      }
      return;
    }
  }

  checkBluetooth({required Function() connected}) async {
    fb.FlutterBluePlus.adapterState.listen((state) async {
      if (state == fb.BluetoothAdapterState.on) {
        // showToastError("Bluetooth on");
        await _checkListDeviceAvailable(connected: () {
          connected();
        });
      } else {
        showToastError("Bluetooth off");
        await bluetoothPrint.isConnected.then((value) {
          if (value!) {
            bluetoothPrint.disconnect();
          }
        });
      }
    });
  }

  _checkListDeviceAvailable({required Function() connected}) async {
    await scanDevices();
    if (_devices.isEmpty) {
      showToastError("No Devices Connected");
      return;
    }
    if (_devices.isNotEmpty) {
      // showToast(_devices
      //     .map((device) => "${device.name} ${device.address} \n ")
      //     .join(", "));
      // for (var device in _devices) {
      //   if (device.connected) {
      //     showToast("BlueThermalPrinter Connected");
      //   } else {
      //     showToastError("BlueThermalPrinter Not Connected");
      //   }
      // }
      BluetoothDevice? device;
      // final connectedDevices = _devices.where((element) => element.connected);
      // if (connectedDevices.isEmpty) {
      //   showToastError("No BlueThermalPrinter is Connected");
      //   return;
      // }
      device = _devices.first;
      // try {
      //   await bluetoothPrint.disconnect();
      // } catch (ex) {
      //   showToastError(ex.toString());
      // }
      showToastError('${device.name} ${device.connected}');
      if (!device.connected) {
        try {
          await bluetoothPrint.connect(_devices.first);
        } catch (e) {
          showToastError(e.toString());
        }
      }
      connected();
    } else {
      showToastError("No Printers Connected");
    }
  }

  Future<List<BluetoothDevice>> scanDevices() async {
    try {
      _devices = await bluetoothPrint.getBondedDevices();
      return _devices;
    } on PlatformException {
      showToastError("Error no prepare devices founds");
      if (kDebugMode) {
        print("Error no prepare devices founds.");
      }
    }

    bluetoothPrint.onStateChanged().listen((state) {
      switch (state) {
        case BlueThermalPrinter.CONNECTED:
          showToastError("bluetooth device state: connected");
          break;
        case BlueThermalPrinter.DISCONNECTED:
          showToastError("bluetooth device state: disconnected");
          break;
        case BlueThermalPrinter.DISCONNECT_REQUESTED:
          showToastError("bluetooth device state: disconnect requested");
          break;
        case BlueThermalPrinter.STATE_TURNING_OFF:
          showToastError("bluetooth device state: bluetooth turning off");
          break;
        case BlueThermalPrinter.STATE_OFF:
          showToastError("bluetooth device state: bluetooth off");
          break;
        case BlueThermalPrinter.STATE_ON:
          showToastError("bluetooth device state: bluetooth on");
          break;
        case BlueThermalPrinter.STATE_TURNING_ON:
          showToastError("bluetooth device state: bluetooth turning on");
          break;
        case BlueThermalPrinter.ERROR:
          showToastError("bluetooth device state: error");

          break;
        default:
          print(state);
          break;
      }
    });
    return [];
  }
}

Future<Uint8List?> createImageFromWidget(Widget widget,
    {Duration? wait, Size? logicalSize, Size? imageSize}) async {
  var cxt = navKey.currentState!.context;
// Create a repaint boundary to capture the image
  final repaintBoundary = RenderRepaintBoundary();

// Calculate logicalSize and imageSize if not provided
  logicalSize ??= View.of(cxt).physicalSize / View.of(cxt).devicePixelRatio;
  imageSize ??= View.of(cxt).physicalSize;

// Ensure logicalSize and imageSize have the same aspect ratio
  assert(logicalSize.aspectRatio == imageSize.aspectRatio,
      'logicalSize and imageSize must not be the same');

// Create the render tree for capturing the widget as an image
  final renderView = RenderView(
    view: View.of(cxt),
    child: RenderPositionedBox(
        alignment: Alignment.center, child: repaintBoundary),
    configuration: const ViewConfiguration(
      logicalConstraints: BoxConstraints(),
      devicePixelRatio: 1,
    ),
  );

  final pipelineOwner = PipelineOwner();
  final buildOwner = BuildOwner(focusManager: FocusManager());

  pipelineOwner.rootNode = renderView;
  renderView.prepareInitialFrame();

// Attach the widget's render object to the render tree
  final rootElement = RenderObjectToWidgetAdapter<RenderBox>(
      container: repaintBoundary,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: widget,
      )).attachToRenderTree(buildOwner);

  buildOwner.buildScope(rootElement);

// Delay if specified
  if (wait != null) {
    await Future.delayed(wait);
  }

// Build and finalize the render tree
  buildOwner
    ..buildScope(rootElement)
    ..finalizeTree();

// Flush layout, compositing, and painting operations
  pipelineOwner
    ..flushLayout()
    ..flushCompositingBits()
    ..flushPaint();

// Capture the image and convert it to byte data
  final image = await repaintBoundary.toImage(pixelRatio: 1.4);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

// Return the image data as Uint8List
  return byteData?.buffer.asUint8List();
}

Future<Uint8List?> createImageFromWidget2(
  Widget widget, {
  double pixelRatio = 3.0,
  Duration? wait,
}) async {
  final boundaryKey = GlobalKey();

  // Create an offscreen widget tree
  final renderWidget = Offstage(
    child: RepaintBoundary(
      key: boundaryKey,
      child: Material(
        type: MaterialType.transparency,
        child: widget,
      ),
    ),
  );

  // Create a separate overlay entry to render it
  final overlayState =
      Overlay.of(navKey.currentState!.context, rootOverlay: true);
  final overlayEntry = OverlayEntry(builder: (context) => renderWidget);
  overlayState.insert(overlayEntry);

  // Wait for the frame to be fully rendered
  await Future.delayed(wait ?? const Duration(milliseconds: 100));
  await Future.microtask(() {});

  final boundary =
      boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

  if (boundary == null) {
    overlayEntry.remove();
    return null;
  }

  // Capture the image
  final image = await boundary.toImage(pixelRatio: pixelRatio);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

  overlayEntry.remove(); // Cleanup the overlay

  return byteData?.buffer.asUint8List();
}

final GlobalKey globalKey = GlobalKey();
