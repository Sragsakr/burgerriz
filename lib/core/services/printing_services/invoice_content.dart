import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/login_helpers.dart';
import 'package:kiosk_point_of_sale/core/services/printing_services/invoice_view.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/device/device_info_table.dart';
import 'package:kiosk_point_of_sale/providers/payment_breakdown_provider.dart';
import 'package:intl/intl.dart' as intl;

import '../../../data/models/sales_models/sales_invoice.dart';
import 'print_controller.dart';

class InvoiceContent {
  static Future<List<Uint8List?>> getInvoiceUint8ListContent(
      SalesInvoice invoice) async {
    String title = isAr() ? 'فاتورة ضريبية مبسطة' : 'Simplified Tax Invoice';
    final deviceInfo = await DeviceConfigTable.getDeviceInfo();
    String invoiceNumber = invoice.salesOrderModel.orderNumber.toString();
    DateTime dateTime = DateTime.parse(invoice.salesOrderModel.createdAt);

    // Format the date
    String formattedDate = intl.DateFormat('dd/MM/yyyy').format(dateTime);

    // Format the time
    String formattedTime = intl.DateFormat('hh:mm a').format(dateTime);
    String issueDate = '$formattedDate-$formattedTime';
    String regNo = deviceInfo?.vat ?? '';
    final totalAmountWithVat =
        double.parse(invoice.salesOrderModel.totalAmount);
    final totalAmountWithoutVat = totalAmountWithVat / 1.15;
    final totalVatPrice = totalAmountWithVat - totalAmountWithoutVat;
    final totalDiscount = (invoice.salesOrderModel.discountValue ?? 0) +
        (invoice.salesOrderModel.promotionValue ?? 0);
    List<SaleType> saleTypes = await generateSaleTypeList();
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
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    child: Center(
                      child: Text(arTitle,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
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
    final saleType = saleTypes.firstWhere(
        (element) => element.saleTypeId == invoice.salesOrderModel.saleTypeId,
        orElse: () =>
            SaleType(saleTypeId: 0, nameAr: '', nameEn: '', saleNature: 0));

    Uint8List? logo = await createImageFromWidget(
        Directionality(
          textDirection: ui.TextDirection.rtl,
          child: Container(
            color: Colors.white,
            width: 190,
            height: 100,
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
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
            width: 190,
            height: 100,
          ),
        ),
        logicalSize: const Size(500, 500),
        imageSize: const Size(680, 680));
    Uint8List? name = await createImageFromWidget(
        Directionality(
          textDirection: ui.TextDirection.rtl,
          child: Container(
            color: Colors.white,
            width: 190,
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Center(
                      child: Text('اسم المتجر',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                    // Spacer(
                    //   flex: 1,
                    // ),
                    Center(
                      child: Text("Store Name",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
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
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
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
            width: 190,
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
                            fontWeight: FontWeight.bold,
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
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                  ],
                ),
                SizedBox(
                  width: 190,
                  child: AutoSizeText(
                    deviceInfo?.address ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
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
            width: 190,
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('تاريخ  : ',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        )),
                    Text(' :  Date',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        )),
                  ],
                ),
                SizedBox(
                  width: 190,
                  child: AutoSizeText(
                    invoice.salesOrderModel.workDate,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
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
                  fontWeight: FontWeight.bold,
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
                  fontWeight: FontWeight.bold,
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
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  )),
              Text(
                  '<<<<<<<< close invoice ${invoice.salesOrderModel.orderNumber} >>>>>>>>',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
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
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      )),
                  Text(' - ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      )),
                  Text('Refund',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
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
            width: 190,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('رقم الفاتورة : ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    )),
                Text(invoice.salesOrderModel.orderNumber.toString(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    )),
                const Text(' : Invoice No',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
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
            width: 190,
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
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          )),
                      // Spacer(flex: 1),
                      Text(' : Issue Date',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
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
                            fontWeight: FontWeight.bold,
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
            width: 190,
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
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          )),
                      // Spacer(flex: 1),
                      Text(' :  Date',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
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
                            fontWeight: FontWeight.bold,
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
            width: 190,
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
                              arText: saleType.nameAr, enText: saleType.nameAr),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          )),
                      Text("-",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          )),
                      Text(
                          translator(
                              arText: saleType.nameEn, enText: saleType.nameEn),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
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
            width: 190,
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('رقم تسجيل الضريبة: ',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        )),
                    // Spacer(flex: 1),
                    Text(' : Registration No',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
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
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
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
            width: 190,
            child: const Row(children: [
              Expanded(
                flex: 1,
                child: Text('المنتجات\nProducts',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    )),
              ),
              Expanded(
                flex: 1,
                child: Text('الكمية\nQty',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    )),
              ),
              Expanded(
                flex: 1,
                child: Text('سعر المنتج\nPrice',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    )),
              ),
              Expanded(
                flex: 1,
                child: Text('قيمة الضريبة \nالمضافة \nTaxs',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    )),
              ),
              Expanded(
                flex: 1,
                child: Text('سعر المنتج \nشامل الضريبة\nPrice with tax',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
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
            width: 190,
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
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        )),
                    Text('Total Without Tax',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        )),
                  ],
                ),
                Text(
                    totalAmountWithoutVat
                        .roundToTwoDecimals()
                        .toStringAsFixed(2),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
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
            width: 190,
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
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        )),
                    Text('Total With Tax [15 %]',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        )),
                  ],
                ),
                Text(totalAmountWithVat.roundToTwoDecimals().toStringAsFixed(2),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
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
            width: 190,
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
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        )),
                    Text('Tax [15 %]',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        )),
                  ],
                ),
                Text(totalVatPrice.roundToTwoDecimals().toStringAsFixed(2),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    )),
              ],
            ),
          ),
        ),
        logicalSize: const Size(500, 500),
        imageSize: const Size(680, 680));
    Uint8List? discountImg;
    if (totalDiscount > 0) {
      discountImg = await createImageFromWidget(
          Directionality(
            textDirection: ui.TextDirection.rtl,
            child: Container(
              color: Colors.white,
              width: 190,
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('الخصم',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          )),
                      Text('Discount',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          )),
                    ],
                  ),
                  Text(totalDiscount.roundToTwoDecimals().toStringAsFixed(2),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      )),
                ],
              ),
            ),
          ),
          logicalSize: const Size(500, 500),
          imageSize: const Size(680, 680));
    }
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
              width: 190,
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
                            fontWeight: FontWeight.bold,
                          )),
                      Text(item.productNameEn,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
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
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      )),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                      (double.parse(item.price) / 1.15)
                          .roundToTwoDecimals()
                          .toStringAsFixed(2),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      )),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                      (double.parse(item.price) * 0.15)
                          .roundToTwoDecimals()
                          .toStringAsFixed(2),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      )),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                      (double.parse(item.price) * double.parse(item.quantity))
                          .roundToTwoDecimals()
                          .toStringAsFixed(2),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
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
    Uint8List? invoiceQr = deviceInfo == null
        ? Container(
            color: Colors.white,
            height: 10,
            width: 10,
          )
        : invoiceQrCode(invoice, size: 200);
    return [
      logo,
      titleImg,
      smallDividerImg,
      invoiceNumberImg,
      name,
      adress,
      issueDateImg,
      workDate,
      vatNumberImg,
      saleTypeImg,
      dividerImg,
      tableNamesImg,
      dividerImg,
      ...products,
      dividerImg,
      totalImg,
      if (discountImg != null) discountImg,
      totalVatImg,
      totalPriceImg,
      close,
      invoiceQr,
      vSpace,
    ];
  }

  static Future<List<Widget>> getInvoiceWidgetsContent(
      SalesInvoice invoice) async {
    String title = isAr() ? 'فاتورة ضريبية مبسطة' : 'Simplified Tax Invoice';
    final deviceInfo = await DeviceConfigTable.getDeviceInfo();
    String invoiceNumber = invoice.salesOrderModel.orderNumber.toString();
    DateTime dateTime = DateTime.parse(invoice.salesOrderModel.createdAt);

    // Format the date
    String formattedDate = intl.DateFormat('dd/MM/yyyy').format(dateTime);

    // Format the time
    String formattedTime = intl.DateFormat('hh:mm a').format(dateTime);
    String issueDate = '$formattedDate-$formattedTime';
    String regNo = deviceInfo?.vat ?? '';
    final totalAmountWithVat =
        double.parse(invoice.salesOrderModel.totalAmount);
    final totalAmountWithoutVat = totalAmountWithVat / 1.15;
    final totalVatPrice = totalAmountWithVat - totalAmountWithoutVat;
    final totalDiscount = (invoice.salesOrderModel.discountValue ?? 0) +
        (invoice.salesOrderModel.promotionValue ?? 0);
    List<SaleType> saleTypes = await generateSaleTypeList();
    String arTitle = invoice.salesOrderModel.isRefund == 1
        ? 'مذكرة ائتمان مبسطة'
        : 'فاتورة ضريبية مبسطة';
    String enTitle = invoice.salesOrderModel.isRefund == 1
        ? 'Simplified Credit Note'
        : 'Simplified Tax Invoice';
    Widget titleImg = Directionality(
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
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      )),
                ),
              ),
              Container(
                color: Colors.white,
                child: Center(
                  child: Text(arTitle,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    final saleType = saleTypes.firstWhere(
        (element) => element.saleTypeId == invoice.salesOrderModel.saleTypeId,
        orElse: () =>
            SaleType(saleTypeId: 0, nameAr: '', nameEn: '', saleNature: 0));

    Widget logo = Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Container(
        color: Colors.white,
        width: 190,
        height: 100,
        child: Image.asset(
          'assets/images/logo.png',
          fit: BoxFit.contain,
        ),
      ),
    );

    Widget vSpace = Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Container(
        color: Colors.white,
        width: 190,
        height: 100,
      ),
    );
    Widget name = Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Container(
        color: Colors.white,
        width: 190,
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Center(
                  child: Text('اسم المتجر',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      )),
                ),
                // Spacer(
                //   flex: 1,
                // ),
                Center(
                  child: Text("Store Name",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
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
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      )),
                ],
              ),
            )
          ],
        ),
      ),
    );
    Widget adress = Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Container(
        color: Colors.white,
        width: 190,
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
                        fontWeight: FontWeight.bold,
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
                        fontWeight: FontWeight.bold,
                      )),
                ),
              ],
            ),
            SizedBox(
              width: 190,
              child: AutoSizeText(
                deviceInfo?.address ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      ),
    );
    Widget workDate = Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Container(
        color: Colors.white,
        width: 190,
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('تاريخ  : ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    )),
                Text(' :  Date',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    )),
              ],
            ),
            SizedBox(
              width: 190,
              child: AutoSizeText(
                invoice.salesOrderModel.workDate,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      ),
    );
    Widget smallDividerImg = Container(
      color: Colors.white,
      child: const Center(
        child: Text('---------------------------------------------',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            )),
      ),
    );
    Widget dividerImg = Container(
      color: Colors.white,
      child: const Center(
        child: Text(
            '-------------------------------------------------------------',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            )),
      ),
    );
    Widget close = Container(
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Text(
              '<<<<<<<<${'  ${invoice.salesOrderModel.orderNumber}اغلاق الفاتورة   '}>>>>>>>>',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              )),
          Text(
              '<<<<<<<< close invoice ${invoice.salesOrderModel.orderNumber} >>>>>>>>',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(height: 10),
        ],
      ),
    );
    Widget refundImg = Directionality(
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
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  )),
              Text(' - ',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  )),
              Text('Refund',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  )),
            ],
          ),
        ),
      ),
    );
    Widget invoiceNumberImg = Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Container(
        color: Colors.white,
        width: 190,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('رقم الفاتورة : ',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                )),
            Text(invoice.salesOrderModel.orderNumber.toString(),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                )),
            const Text(' : Invoice No',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                )),
          ],
        ),
      ),
    );

    Widget issueDateImg = Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Container(
        color: Colors.white,
        width: 190,
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
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      )),
                  // Spacer(flex: 1),
                  Text(' : Issue Date',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
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
                        fontWeight: FontWeight.bold,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    Widget issueDayImg = Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Container(
        color: Colors.white,
        width: 190,
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
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      )),
                  // Spacer(flex: 1),
                  Text(' :  Date',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
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
                        fontWeight: FontWeight.bold,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    Widget saleTypeImg = Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Container(
        color: Colors.white,
        width: 190,
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
                          arText: saleType.nameAr, enText: saleType.nameAr),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      )),
                  Text("-",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      )),
                  Text(
                      translator(
                          arText: saleType.nameEn, enText: saleType.nameEn),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    Widget vatNumberImg = Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Container(
        color: Colors.white,
        width: 190,
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('رقم تسجيل الضريبة: ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    )),
                // Spacer(flex: 1),
                Text(' : Registration No',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
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
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      )),
                ],
              ),
            )
          ],
        ),
      ),
    );
    Widget tableNamesImg = Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 1),
        decoration: const BoxDecoration(
          color: Colors.white,
          // border: Border(
          //     top: BorderSide(color: Colors.black),
          //     bottom: BorderSide(color: Colors.black))
        ),
        width: 190,
        child: const Row(children: [
          Expanded(
            flex: 1,
            child: Text('المنتجات\nProducts',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                )),
          ),
          Expanded(
            flex: 1,
            child: Text('الكمية\nQty',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                )),
          ),
          Expanded(
            flex: 1,
            child: Text('سعر المنتج\nPrice',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                )),
          ),
          Expanded(
            flex: 1,
            child: Text('قيمة الضريبة \nالمضافة \nTaxs',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                )),
          ),
          Expanded(
            flex: 1,
            child: Text('سعر المنتج \nشامل الضريبة\nPrice with tax',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                )),
          ),
        ]),
      ),
    );

    Widget totalImg = Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Container(
        color: Colors.white,
        width: 190,
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
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    )),
                Text('Total Without Tax',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    )),
              ],
            ),
            Text(totalAmountWithoutVat.roundToTwoDecimals().toStringAsFixed(2),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                )),
          ],
        ),
      ),
    );
    Widget totalPriceImg = Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Container(
        color: Colors.white,
        width: 190,
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
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    )),
                Text('Total With Tax [15 %]',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    )),
              ],
            ),
            Text(totalAmountWithVat.roundToTwoDecimals().toStringAsFixed(2),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                )),
          ],
        ),
      ),
    );

    Widget totalVatImg = Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        color: Colors.white,
        width: 190,
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
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    )),
                Text('Tax [15 %]',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    )),
              ],
            ),
            Text(totalVatPrice.roundToTwoDecimals().toStringAsFixed(2),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                )),
          ],
        ),
      ),
    );
    Widget? discountImg;
    if (totalDiscount > 0) {
      discountImg = Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Container(
          color: Colors.white,
          width: 190,
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('الخصم',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      )),
                  Text('Discount',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      )),
                ],
              ),
              Text(totalDiscount.roundToTwoDecimals().toStringAsFixed(2),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  )),
            ],
          ),
        ),
      );
    }
    List<Widget> products = [];
    for (var item in invoice.salesOrderItems) {
      Widget productImg = Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 1),
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          width: 190,
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
                        fontWeight: FontWeight.bold,
                      )),
                  Text(item.productNameEn,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
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
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  )),
            ),
            Expanded(
              flex: 1,
              child: Text(
                  (double.parse(item.price) / 1.15)
                      .roundToTwoDecimals()
                      .toStringAsFixed(2),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  )),
            ),
            Expanded(
              flex: 1,
              child: Text(
                  (double.parse(item.price) * 0.15)
                      .roundToTwoDecimals()
                      .toStringAsFixed(2),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  )),
            ),
            Expanded(
              flex: 1,
              child: Text(
                  (double.parse(item.price) * double.parse(item.quantity))
                      .roundToTwoDecimals()
                      .toStringAsFixed(2),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  )),
            ),
          ]),
        ),
      );
      products.add(productImg);
    }
    Widget invoiceQr = deviceInfo == null
        ? Container(
            color: Colors.white,
            height: 10,
            width: 10,
          )
        : invoiceQrCode(invoice, size: 200);
    return [
      logo,
      titleImg,
      smallDividerImg,
      invoiceNumberImg,
      name,
      adress,
      issueDateImg,
      workDate,
      vatNumberImg,
      saleTypeImg,
      dividerImg,
      tableNamesImg,
      dividerImg,
      ...products,
      dividerImg,
      totalImg,
      if (discountImg != null) discountImg,
      totalVatImg,
      totalPriceImg,
      close,
      invoiceQr,
      vSpace,
    ];
  }
}
