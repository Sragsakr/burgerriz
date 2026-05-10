import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' as intl;
import 'package:kiosk_point_of_sale/core/assets/app_assets.dart';
import 'package:kiosk_point_of_sale/core/helpers/login_helpers.dart';
import 'package:kiosk_point_of_sale/core/helpers/responsive_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/selected_variant_grouping.dart';
import 'package:kiosk_point_of_sale/core/helpers/zatca_qr_helper.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_invoice.dart';
import 'package:kiosk_point_of_sale/data/models/store/device_info_model.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/device/device_info_table.dart';
import 'package:kiosk_point_of_sale/features/shared-features/Install/install_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../data/services/local_data/db/app_db.dart';
import '../../enums/discount_enum.dart' show DiscountType;

List<pw.Widget> buildInvoicePdfGroupedVariations(List<Map<String, dynamic>> variations) {
  final out = <pw.Widget>[];
  var firstGroup = true;
  for (final group in groupVariationMaps(variations)) {
    if (!firstGroup) {
      out.add(pw.SizedBox(height: 4));
    }
    firstGroup = false;
    final header = variationMapGroupHeaderBilingual(group.first);
    if (header.isNotEmpty) {
      out.add(
        pw.Padding(
          padding: const pw.EdgeInsets.only(left: 16.0, top: 2.0, bottom: 2.0),
          child: pw.Text(
            header,
            style: pw.TextStyle(
              color: PdfColors.black,
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      );
    }
    for (final variation in group) {
      String variationText = "${variation['variationNameAr']} - ${variation['variationNameEn']}";
      final mainAr = variation['mainTranslationAr'] ?? '';
      final mainEn = variation['mainTranslationEn'] ?? '';
      String mainTranslation = '';
      if (mainAr.isNotEmpty || mainEn.isNotEmpty) {
        mainTranslation = "($mainAr - $mainEn)";
      }
      if (variationText.isEmpty || variationText == ' - ') {
        if (variation['variantValueId'] != null) {
          variationText = 'Variant ${variation['variantValueId']}';
        }
      }
      final qty = (variation['quantity'] as num?)?.toDouble() ?? 1.0;
      final qtyLabel = qty > 1 ? ' x${qty.toInt()}' : '';
      final isFree = variation['isFree'] == true;
      final price = (variation['variationPrice'] as num?)?.toDouble() ?? 0.0;
      out.add(
        pw.Padding(
          padding: pw.EdgeInsets.only(
            left: header.isNotEmpty ? 24.0 : 16.0,
            top: 2.0,
          ),
          child: pw.Row(
            children: [
              pw.Expanded(
                child: pw.Text(
                  '  • $variationText$qtyLabel $mainTranslation',
                  style: pw.TextStyle(
                    color: PdfColors.black,
                    fontSize: 10,
                    fontWeight: pw.FontWeight.normal,
                  ),
                ),
              ),
              if (isFree)
                pw.Text(
                  'Free',
                  style: pw.TextStyle(
                    color: PdfColors.green800,
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                )
              else if (price > 0)
                pw.Text(
                  '+${price.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    color: PdfColors.black,
                    fontSize: 10,
                    fontWeight: pw.FontWeight.normal,
                  ),
                ),
            ],
          ),
        ),
      );
    }
  }
  return out;
}

Future<pw.Widget> buildNetworkImageWidget() async {
  final deviceInfo = await DeviceConfigTable.getDeviceInfo();
  final path = "https://zatca.posmena.com.tr";
  // Replace with your network image URL
  final String imageUrl = deviceInfo?.logo ?? "";

  // Fetch the image bytes from the network
  final response = await http.get(Uri.parse(path + imageUrl));

  if (response.statusCode == 200) {
    final Uint8List imageBytes = response.bodyBytes;
    // dPrint("imageBytes is $imageBytes");
    pw.Image image1 = pw.Image(pw.MemoryImage(imageBytes));

    return pw.Container(
      color: PdfColors.white,
      alignment: pw.Alignment.center,
      height: 70,
      width: 100,
      child: image1,
    );
  } else {
    throw Exception('Failed to load network image');
  }
}

Future<pw.MemoryImage> buildNetworkImageWidgetMemoryImage() async {
  await AppDB.init();

  final deviceInfo = await DeviceConfigTable.getDeviceInfo();
  final String baseUrl = "https://zatca.posmena.com.tr";
  final String? logoPath = deviceInfo?.logo;

  if (logoPath == null || logoPath.isEmpty) {
    throw Exception("No logo path found in device info");
  }

  final directory = await getTemporaryDirectory();
  final file = File('${directory.path}/cached_logo.png');

  if (await file.exists()) {
    final bytes = await file.readAsBytes();
    return pw.MemoryImage(bytes);
  }

  final response = await http.get(Uri.parse('$baseUrl$logoPath'));

  if (response.statusCode != 200) {
    throw Exception('Failed to load network image');
  }

  await file.writeAsBytes(response.bodyBytes);
  return pw.MemoryImage(response.bodyBytes);
}

Future<pw.Widget> buildImageWidget() async {
  // Load the image bytes from assets using centralized asset management
  final img = await rootBundle.load(AppAssets.newLogo);
  final imageBytes = img.buffer.asUint8List();
  pw.Image image1 = pw.Image(pw.MemoryImage(imageBytes));
  return pw.Container(
    color: PdfColors.white,
    alignment: pw.Alignment.center,
    height: 70,
    width: 100,
    child: image1,
  );
}

pw.Widget getInvoicePdf({
  required SalesInvoice invoice,
  required DeviceConfigModel? deviceConfigModel,
  required SaleType saleType,
  pw.Widget? logo,
}) {
  final bool isRefund = invoice.salesOrderModel.isRefund == 1;
  String ext = isRefund ? "2" : "1";
  final preRecipe = "${deviceConfigModel?.storeCode ?? ''}-${deviceConfigModel?.deviceNumber ?? ''}$ext-";
  final recieptNumber = preRecipe + (invoice.salesOrderModel.receiptNumber ?? '');
  final refRecieptNumber =
      (invoice.salesOrderModel.refReceiptNumber != null && invoice.salesOrderModel.refReceiptNumber?.length != 0)
          ? (preRecipe + (invoice.salesOrderModel.refReceiptNumber ?? ''))
          : "";

  DateTime dateTime = DateTime.parse(invoice.salesOrderModel.createdAt);

  // Format the date
  String formattedDate = intl.DateFormat('dd/MM/yyyy').format(dateTime);

  // Format the time
  String formattedTime = intl.DateFormat('hh:mm a').format(dateTime);
  String issueDate = '$formattedDate-$formattedTime';
  String regNo = deviceConfigModel?.vat ?? '';
  String arTitle = invoice.salesOrderModel.isRefund == 1 ? 'مذكرة أئتمان مبسطه' : 'فاتورة ضريبية مبسطة';
  String enTitle = invoice.salesOrderModel.isRefund == 1 ? 'Simplified Credit Note' : "Simplified Tax Invoice";

  return pw.Directionality(
    textDirection: pw.TextDirection.rtl,
    child: pw.Container(
      color: PdfColors.white,
      child: pw.Padding(
        padding: pw.EdgeInsetsDirectional.only(start: 10),
        child: pw.Column(
          // mainAxisAlignment: pw.MainAxisAlignment.center,
          // crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            // pw.Center(
            //   child: buildZatcaQrCode(invoice),
            // ),
            if (deviceConfigModel != null && logo != null)
              pw.Container(
                color: PdfColors.white,
                width: 400,
                child: logo,
              ),
            buildInvoiceHeader(
                enTitle,
                arTitle,
                recieptNumber,
                deviceConfigModel?.companyName.toString() ?? '',
                deviceConfigModel?.storeCode.toString() ?? '',
                deviceConfigModel?.address.toString() ?? '',
                deviceConfigModel?.vat.toString() ?? ''),
            buildInvoiceDetails(
              regNo,
              issueDate,
              invoice.salesOrderModel.workDate,
              saleType.nameAr,
              saleType.nameEn,
            ),
            buildInvoiceDetails2(
              invoice,
              deviceConfigModel,
            ),
          ],
        ),
      ),
    ),
  );
}

pw.Widget buildInvoiceHeader(String enTitle, String arTitle, String receiptNumber, String companyName, String storeCode,
    String address, String vatNumber) {
  return pw.Column(
    children: [
      // English Title
      pw.Container(
        color: PdfColors.white,
        child: pw.Center(
          child: pw.Text(
            enTitle,
            style: pw.TextStyle(
              color: PdfColors.black,
              fontSize: 15,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      ),

      // Arabic Title
      pw.Container(
        color: PdfColors.white,
        child: pw.Center(
          child: pw.Text(
            arTitle,
            style: pw.TextStyle(
              color: PdfColors.black,
              fontSize: 15,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      ),

      // Divider
      pw.Container(
        color: PdfColors.white,
        child: pw.Divider(),
      ),

      // Invoice Number
      pw.Container(
        color: PdfColors.white,
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('رقم الفاتورة: ',
                style: pw.TextStyle(
                  color: PdfColors.black,
                  fontSize: 15,
                  fontWeight: pw.FontWeight.bold,
                )),
            // pw.Spacer(flex: 1),
            pw.Text(receiptNumber,
                style: pw.TextStyle(
                  color: PdfColors.black,
                  fontSize: 15,
                  fontWeight: pw.FontWeight.bold,
                )),
            // pw.Spacer(flex: 1),
            pw.Text('Invoice No : ',
                style: pw.TextStyle(
                  color: PdfColors.black,
                  fontSize: 15,
                  fontWeight: pw.FontWeight.bold,
                )),
          ],
        ),
      ),
      pw.SizedBox(height: 5),
      // Store Name
      pw.Container(
        color: PdfColors.white,
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('اسم المتجر',
                style: pw.TextStyle(
                  color: PdfColors.black,
                  fontSize: 15,
                  fontWeight: pw.FontWeight.bold,
                )),
            pw.Text("Store Name",
                style: pw.TextStyle(
                  color: PdfColors.black,
                  fontSize: 15,
                  fontWeight: pw.FontWeight.bold,
                )),
          ],
        ),
      ),
      pw.Text(
        companyName,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          color: PdfColors.black,
          fontSize: 15,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
      pw.SizedBox(height: 5),
      // Store Code
      pw.Container(
        color: PdfColors.white,
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Container(
              color: PdfColors.white,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('كود المتجر',
                      style: pw.TextStyle(
                        color: PdfColors.black,
                        fontSize: 15,
                        fontWeight: pw.FontWeight.bold,
                      )),
                  pw.Text("Store Code : ",
                      style: pw.TextStyle(
                        color: PdfColors.black,
                        fontSize: 15,
                        fontWeight: pw.FontWeight.bold,
                      )),
                ],
              ),
            ),
            pw.Text(storeCode,
                style: pw.TextStyle(
                  color: PdfColors.black,
                  fontSize: 15,
                  fontWeight: pw.FontWeight.bold,
                )),
          ],
        ),
      ),
      pw.SizedBox(height: 5),
      // Store Address
      pw.Container(
        color: PdfColors.white,
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.SizedBox(height: 5),
            pw.Container(
              color: PdfColors.white,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('عنوان المتجر',
                      style: pw.TextStyle(
                        color: PdfColors.black,
                        fontSize: 15,
                        fontWeight: pw.FontWeight.bold,
                      )),
                  pw.Text("Store Address : ",
                      style: pw.TextStyle(
                        color: PdfColors.black,
                        fontSize: 15,
                        fontWeight: pw.FontWeight.bold,
                      )),
                ],
              ),
            ),
            pw.SizedBox(height: 5),
            pw.Text(
              address,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(
                color: PdfColors.black,
                fontSize: 15,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      pw.SizedBox(height: 5),
      // VAT Registration Number
      pw.Container(
        color: PdfColors.white,
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('رقم تسجيل الضريبة: ',
                style: pw.TextStyle(
                  color: PdfColors.black,
                  fontSize: 15,
                  fontWeight: pw.FontWeight.bold,
                )),
            pw.Text('Registration No : ',
                style: pw.TextStyle(
                  color: PdfColors.black,
                  fontSize: 15,
                  fontWeight: pw.FontWeight.bold,
                )),
          ],
        ),
      ),
    ],
  );
}

pw.Widget buildInvoiceDetails(String regNo, String issueDate, String workDate, String? saleTypeAr, String? saleTypeEn) {
  return pw.Column(
    children: [
      pw.SizedBox(height: 5),
      // VAT Registration Number
      pw.Container(
        color: PdfColors.white,
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Text(regNo,
                style: pw.TextStyle(
                  color: PdfColors.black,
                  fontSize: 15,
                  fontWeight: pw.FontWeight.bold,
                )),
          ],
        ),
      ),
      pw.SizedBox(height: 5),
      // Date Label
      pw.Container(
        color: PdfColors.white,
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('تاريخ  : ',
                style: pw.TextStyle(
                  color: PdfColors.black,
                  fontSize: 15,
                  fontWeight: pw.FontWeight.bold,
                )),
            pw.Spacer(),
            pw.Text('Date : ',
                style: pw.TextStyle(
                  color: PdfColors.black,
                  fontSize: 15,
                  fontWeight: pw.FontWeight.bold,
                )),
          ],
        ),
      ),
      pw.SizedBox(height: 5),
      // Work Date
      pw.Container(
        color: PdfColors.white,
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Text(workDate,
                style: pw.TextStyle(
                  color: PdfColors.black,
                  fontSize: 15,
                  fontWeight: pw.FontWeight.bold,
                )),
          ],
        ),
      ),

      // Issue Date Label
      pw.Container(
        color: PdfColors.white,
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('تاريخ الإصدار : ',
                style: pw.TextStyle(
                  color: PdfColors.black,
                  fontSize: 15,
                  fontWeight: pw.FontWeight.bold,
                )),
            pw.Spacer(),
            pw.Text('Issue Date : ',
                style: pw.TextStyle(
                  color: PdfColors.black,
                  fontSize: 15,
                  fontWeight: pw.FontWeight.bold,
                )),
          ],
        ),
      ),
      pw.SizedBox(height: 5),
      // Issue Date Value
      pw.Container(
        color: PdfColors.white,
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Text(issueDate,
                style: pw.TextStyle(
                  color: PdfColors.black,
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                )),
          ],
        ),
      ),

      // Sale Type (if available)
      if (saleTypeAr != null && saleTypeEn != null) ...[
        pw.SizedBox(height: 5),
        pw.Container(
          color: PdfColors.white,
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text(saleTypeAr,
                  style: pw.TextStyle(
                    color: PdfColors.black,
                    fontSize: 15,
                    fontWeight: pw.FontWeight.bold,
                  )),
              pw.Text(" - ",
                  style: pw.TextStyle(
                    color: PdfColors.black,
                    fontSize: 15,
                    fontWeight: pw.FontWeight.bold,
                  )),
              pw.Text(saleTypeEn,
                  style: pw.TextStyle(
                    color: PdfColors.black,
                    fontSize: 15,
                    fontWeight: pw.FontWeight.bold,
                  )),
            ],
          ),
        ),
      ]
    ],
  );
}

pw.Widget buildInvoiceDetails2(
  SalesInvoice invoice,
  DeviceConfigModel? deviceInfo,
) {
  return pw.Column(
    children: [
      // Divider
      pw.SizedBox(height: 5),
      pw.Container(
        color: PdfColors.white,
        child: pw.Divider(),
      ),
      pw.SizedBox(height: 5),
      // Table Header
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 5),
        color: PdfColors.white, // Light grey background for header
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Expanded(
              child: pw.Text('المنتجات\nProducts',
                  textAlign: pw.TextAlign.center,
                  style: _tableHeaderStyle(
                    fontSize: 15,
                  )),
            ),
            pw.Expanded(
              child: pw.Text('الكمية\nQty',
                  textAlign: pw.TextAlign.center,
                  style: _tableHeaderStyle(
                    fontSize: 15,
                  )),
            ),
            pw.Expanded(
              child: pw.Text('سعر المنتج\nPrice',
                  textAlign: pw.TextAlign.center,
                  style: _tableHeaderStyle(
                    fontSize: 15,
                  )),
            ),
            pw.Expanded(
              child: pw.Text('الضريبة\nTax',
                  textAlign: pw.TextAlign.center,
                  style: _tableHeaderStyle(
                    fontSize: 15,
                  )),
            ),
            pw.Expanded(
              child: pw.Text('الإجمالي\nTotal',
                  textAlign: pw.TextAlign.center,
                  style: _tableHeaderStyle(
                    fontSize: 15,
                  )),
            ),
          ],
        ),
      ),
      pw.Container(
        color: PdfColors.white,
        child: pw.Divider(),
      ),
      // Product List
      ...invoice.salesOrderItems.map((item) {
        // double priceWithoutVat = double.parse(item.price) / 1.15;
        // double taxAmount = double.parse(item.price) - priceWithoutVat;
        // double totalPrice =
        //     double.parse(item.price) * double.parse(item.quantity);

        return pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 2),
          child: pw.Column(
            children: [
              // First line: Product name (full width)
              pw.Row(children: [
                pw.Expanded(
                  child: pw.Column(
                    children: [
                      pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(
                            '${item.productNameAr}${item.unitNameAr != null && item.unitNameAr!.isNotEmpty ? " - ${item.unitNameAr}" : ""}',
                            textAlign: pw.TextAlign.center,
                            style: _tableTextStyle()),
                      ),
                      pw.Align(
                        alignment: pw.Alignment.centerLeft,
                        child: pw.Text(
                            '${item.productNameEn}${item.unitNameEn != null && item.unitNameEn!.isNotEmpty ? " - ${item.unitNameEn}" : ""}',
                            textAlign: pw.TextAlign.center,
                            style: _tableTextStyle()),
                      ),
                    ],
                  ),
                ),
              ]),
              // Display variations if any
              if (item.variations != null && item.variations!.isNotEmpty)
                ...buildInvoicePdfGroupedVariations(item.variations!),
              if (item.comboMealItems != null && item.comboMealItems!.isNotEmpty)
                ...item.comboMealItems!.map((combo) {
                  String mainTranslation = "${combo['comboNameAr']} - ${combo['comboNameEn']}";

                  return pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 16.0, top: 2.0),
                    child: pw.Row(
                      children: [
                        pw.Expanded(
                          child: pw.Text(
                            '  •  $mainTranslation',
                            style: pw.TextStyle(
                              color: PdfColors.black,
                              fontSize: 10,
                              fontWeight: pw.FontWeight.normal,
                            ),
                          ),
                        ),
                        if (combo['price'] != null && (combo['price'] as num) > 0)
                          pw.Text(
                            '+${(combo['price'] as num).toStringAsFixed(2)}',
                            style: pw.TextStyle(
                              color: PdfColors.black,
                              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 10),
                              fontWeight: pw.FontWeight.normal,
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              // Second line: Empty, Quantity, Price, Tax, Total
              pw.Row(children: [
                pw.Expanded(
                  flex: 1,
                  child: pw.Text("", textAlign: pw.TextAlign.center, style: _tableTextStyle()),
                ),
                pw.Expanded(
                  flex: 1,
                  child: pw.Text(item.quantity, textAlign: pw.TextAlign.center, style: _tableTextStyle()),
                ),
                pw.Expanded(
                  flex: 1,
                  child: pw.Text(item.price, textAlign: pw.TextAlign.center, style: _tableTextStyle()),
                ),
                pw.Expanded(
                  flex: 1,
                  child: pw.Text(item.vatBeforeDiscount.toString(),
                      textAlign: pw.TextAlign.center, style: _tableTextStyle()),
                ),
                pw.Expanded(
                  flex: 1,
                  child: pw.Text(item.total, textAlign: pw.TextAlign.center, style: _tableTextStyle()),
                ),
              ]),
              // Divider line
              pw.Container(
                child: pw.Center(
                  child: pw.Text('---------------------------------------------',
                      style: pw.TextStyle(
                        color: PdfColors.black,
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      )),
                ),
              ),
            ],
          ),
        );
      }),
      pw.SizedBox(height: 5),
      // Divider
      pw.Container(
        color: PdfColors.white,
        child: pw.Divider(color: PdfColors.black),
      ),

      // Total Section
      _buildTotalRow(
          'اجمالي المبلغ الخاضع للضريبة', 'Total Without Tax', double.parse(invoice.salesOrderModel.subTotal)),
      if (((invoice.salesOrderModel.discountValue ?? 0) +
              (invoice.salesOrderModel.promotionValue ?? 0)) >
          0)
        _buildTotalRow(
            'الخصم',
            'Discount',
            (invoice.salesOrderModel.discountValue ?? 0) +
                (invoice.salesOrderModel.promotionValue ?? 0),
            sub: (invoice.salesOrderModel.discountType ==
                        DiscountType.percentage.value &&
                    (invoice.salesOrderModel.promotionValue ?? 0) == 0)
                ? ' (${invoice.salesOrderModel.discount}%) '
                : null),

      _buildTotalRow('ضريبة القيمة المضافة [15%]', 'Tax [15%]', double.parse(invoice.salesOrderModel.tax)),
      _buildTotalRow('الإجمالي شامل الضريبة', 'Total With Tax', double.parse(invoice.salesOrderModel.totalAmount)),
      if (invoice.salesOrderModel.change != null && invoice.salesOrderModel.change! > 0.0)
        _buildTotalRow("الباقي", 'change', invoice.salesOrderModel.change ?? 0.0),
      // if ((invoice.salesOrderModel.discount ?? 0) > 0)
      //   _buildTotalRow(
      //       'الإجمالي شامل الضريبة (قبل الخصم)',
      //       'Total With Tax(Before Discount)',
      //       double.parse(
      //           invoice.salesOrderModel.totalAmountBeforeDiscount ?? "0.0")),

      // Payment Methods Section
      pw.SizedBox(height: 5),
      pw.Container(
        color: PdfColors.white,
        child: pw.Divider(color: PdfColors.black),
      ),
      pw.SizedBox(height: 5),

      // Payment Methods Header
      pw.Container(
        color: PdfColors.white,
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Text('طرق الدفع',
                style: pw.TextStyle(
                  color: PdfColors.black,
                  fontSize: 15,
                  fontWeight: pw.FontWeight.bold,
                )),
            pw.SizedBox(width: 10),
            pw.Text('Payment Methods',
                style: pw.TextStyle(
                  color: PdfColors.black,
                  fontSize: 15,
                  fontWeight: pw.FontWeight.bold,
                )),
          ],
        ),
      ),

      pw.SizedBox(height: 5),
      pw.Container(
        color: PdfColors.white,
        child: pw.Divider(color: PdfColors.black),
      ),
      pw.SizedBox(height: 5),

      // Payment Methods Details
      ...invoice.salesOrderPayMethods.map((paymentMethod) {
        return pw.Container(
          color: PdfColors.white,
          padding: const pw.EdgeInsets.symmetric(vertical: 2),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(paymentMethod.nameAr,
                      style: pw.TextStyle(
                        color: PdfColors.black,
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      )),
                  pw.Text(paymentMethod.nameEn,
                      style: pw.TextStyle(
                        color: PdfColors.black,
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      )),
                ],
              ),
              pw.Text(paymentMethod.amount.toStringAsFixed(2),
                  style: pw.TextStyle(
                    color: PdfColors.black,
                    fontSize: 15,
                    fontWeight: pw.FontWeight.bold,
                  )),
            ],
          ),
        );
      }),

      pw.SizedBox(height: 5),
      pw.Container(
        color: PdfColors.white,
        child: pw.Divider(color: PdfColors.black),
      ),
      pw.SizedBox(height: 5),

      // Invoice Closing
      pw.Center(
        child: pw.Text(
          '<<<<<< إغلاق الفاتورة ${invoice.salesOrderModel.orderNumber} >>>>>>',
          style: pw.TextStyle(
            color: PdfColors.black,
            fontSize: 15,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ),

      pw.Center(
        child: pw.Text(
          '<<<<<< Close Invoice ${invoice.salesOrderModel.orderNumber} >>>>>>',
          style: pw.TextStyle(
            color: PdfColors.black,
            fontSize: 15,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ),

      pw.SizedBox(height: 20),

      if (deviceInfo == null && deviceInfo?.privateKey != null ||
          deviceInfo?.publicKey != null && deviceInfo?.crNumber != null)
        // QR Code (if applicable)
        pw.Center(
          child: buildZatcaQrCode(invoice),
        ),

      pw.SizedBox(height: 100),
    ],
  );
}

// Styling Helpers
pw.TextStyle _tableHeaderStyle({double fontSize = 7}) {
  return pw.TextStyle(
    color: PdfColors.black,
    fontSize: fontSize,
    fontWeight: pw.FontWeight.bold,
  );
}

pw.TextStyle _tableTextStyle() {
  return pw.TextStyle(
    color: PdfColors.black,
    fontSize: 15,
    fontWeight: pw.FontWeight.bold,
  );
}

pw.Widget _buildTotalRow(String arText, String enText, double amount, {String? sub}) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(vertical: 3),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(arText,
                style: _tableHeaderStyle(
                  fontSize: 15,
                )),
            pw.Text(enText,
                style: _tableHeaderStyle(
                  fontSize: 15,
                )),
          ],
        ),
        pw.Text(sub ?? '',
            style: _tableHeaderStyle(
              fontSize: 15,
            )),
        pw.Text(amount.toStringAsFixed(2),
            style: _tableHeaderStyle(
              fontSize: 15,
            )),
      ],
    ),
  );
}
