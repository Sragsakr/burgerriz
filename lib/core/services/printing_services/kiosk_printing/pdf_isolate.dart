import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/core/services/printing_services/invoice_pdf_content.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_invoice.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_items_model.dart';
import 'package:kiosk_point_of_sale/data/models/store/device_info_model.dart';
import 'package:kiosk_point_of_sale/features/shared-features/admin/reports/cashier_report/cashier_report_view.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdfx/pdfx.dart' as pdfx;

/// Main body that mirrors your "design" but uses only injected assets (isolate-safe).
pw.Widget buildInvoiceBody({
  required SalesInvoice inv,
  required pw.Font fontReg,
  required pw.Font fontBold,
  required pw.ImageProvider logo,
  required pw.ImageProvider sarGlyph,
  required DeviceConfigModel? device,
  pw.Widget? qr, // optional ZATCA QR passed in Payload
  String? saleTypeNameAr,
  String? saleTypeNameEn,
}) {
  // ---------- helpers ----------
  pw.TextStyle ts({bool b = false, double fs = 7, double h = 1}) =>
      pw.TextStyle(font: b ? fontBold : fontReg, fontSize: fs, height: h, color: PdfColors.black);

  pw.Widget txt(String s,
      {bool b = false,
      double fs = 7,
      pw.TextAlign a = pw.TextAlign.left,
      double h = 1,
      pw.TextDirection? dir}) {
    return pw.Text(s, style: ts(b: b, fs: fs, h: h), textAlign: a, textDirection: dir);
  }

  pw.TextStyle headStyle() => ts(b: true, fs: 7);
  pw.TextStyle cellStyle() => ts(b: true, fs: 7);

  pw.Widget money(String v, {bool big = false}) => pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          txt(v, b: big, fs: big ? 9 : 7, a: pw.TextAlign.right),
          // pw.SizedBox(width: 3),
          // pw.Image(sarGlyph, width: 10, height: 10),
        ],
      );

  String fmt(num? v) => (v ?? 0).toStringAsFixed(2);
  num? parseNum(String? s) => num.tryParse((s ?? '').trim()) ?? 0;

  // ---------- computed/meta ----------
  final isRefund = inv.salesOrderModel.isRefund == 1;
  final ext = isRefund ? "2" : "1";
  final preReceipt = "${device?.storeCode ?? ''}-${device?.deviceNumber ?? ''}$ext-";
  final receiptNumber = preReceipt + (inv.salesOrderModel.receiptNumber ?? '');
  final refReceiptNumber = (inv.salesOrderModel.refReceiptNumber != null &&
          (inv.salesOrderModel.refReceiptNumber?.isNotEmpty ?? false))
      ? (preReceipt + (inv.salesOrderModel.refReceiptNumber ?? ''))
      : "";

  final dt = DateTime.parse(inv.salesOrderModel.createdAt);
  final formattedDate = intl.DateFormat('dd/MM/yyyy').format(dt);
  final formattedTime = intl.DateFormat('hh:mm a').format(dt);
  final issueDate = '$formattedDate-$formattedTime';
  final regNo = device?.vat ?? '';

  final titleAr = isRefund ? 'مذكرة أئتمان مبسطه' : 'فاتورة ضريبية مبسطة';
  final titleEn = isRefund ? 'Simplified Credit Note' : 'Simplified Tax Invoice';

  // ---------- sections ----------
  pw.Widget header() => pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Center(child: pw.Image(logo, height: 70)),
            pw.SizedBox(height: 6),
            pw.Center(child: txt(titleEn, b: true)),
            pw.Center(child: txt(titleAr, b: true, dir: pw.TextDirection.rtl)),
            pw.SizedBox(height: 6),
            pw.Divider(),
            // Invoice No (AR | value | EN)
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                txt('رقم الفاتورة: ', b: true),
                txt(receiptNumber, b: true),
                txt('Invoice No : ', b: true),
              ],
            ),
            pw.SizedBox(height: 5),
            // Store Name
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                txt('اسم المتجر', b: false),
                txt('Store Name', b: false),
              ],
            ),
            pw.Center(child: txt(device?.companyName ?? '', b: true)),
            pw.SizedBox(height: 5),
            // Store Code
            pw.Column(children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  txt('كود المتجر', b: true),
                  txt('Store Code : ', b: true),
                ],
              ),
              txt(device?.storeCode ?? '', b: true, a: pw.TextAlign.center),
            ]),
            pw.SizedBox(height: 5),
            // Address
            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  txt('عنوان المتجر', b: true),
                  txt('Store Address : ', b: true),
                ],
              ),
              pw.SizedBox(height: 5),
              txt(device?.address ?? '', b: true, a: pw.TextAlign.center),
            ]),
            pw.SizedBox(height: 5),
            // VAT Reg (labels row), value centered below
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                txt('رقم تسجيل الضريبة: ', b: true),
                txt('Registration No : ', b: true),
              ],
            ),
            pw.SizedBox(height: 5),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: [txt(regNo, b: true)]),
          ]);

  pw.Widget details() => pw.Column(children: [
        pw.SizedBox(height: 5),
        // Date (labels)
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            txt('تاريخ  : ', b: true),
            pw.Spacer(),
            txt('Date : ', b: true),
          ],
        ),
        pw.SizedBox(height: 5),
        pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [txt(inv.salesOrderModel.workDate, b: true)]),
        // Issue Date
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            txt('تاريخ الإصدار : ', b: true),
            pw.Spacer(),
            txt('Issue Date : ', b: true),
          ],
        ),
        pw.SizedBox(height: 5),
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
          txt(issueDate, b: true, fs: 7),
        ]),
        if ((saleTypeNameAr ?? '').isNotEmpty && (saleTypeNameEn ?? '').isNotEmpty) ...[
          pw.SizedBox(height: 5),
          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
            txt(saleTypeNameAr!, b: true),
            txt(' - ', b: true),
            txt(saleTypeNameEn!, b: true),
          ]),
        ],
      ]);

  pw.Widget tableHeader() => pw.Column(children: [
        pw.SizedBox(height: 5),
        pw.Divider(),
        pw.SizedBox(height: 5),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 5),
          child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
            pw.Expanded(
                child: pw.Text('المنتجات\nProducts',
                    textAlign: pw.TextAlign.center, style: headStyle())),
            pw.Expanded(
                child: pw.Text('الكمية\nQty', textAlign: pw.TextAlign.center, style: headStyle())),
            pw.Expanded(
                child: pw.Text('سعر المنتج\nPrice',
                    textAlign: pw.TextAlign.center, style: headStyle())),
            pw.Expanded(
                child: pw.Text('الضريبة\nTax', textAlign: pw.TextAlign.center, style: headStyle())),
            pw.Expanded(
                child:
                    pw.Text('الإجمالي\nTotal', textAlign: pw.TextAlign.center, style: headStyle())),
          ]),
        ),
        pw.Divider(),
      ]);

  pw.Widget itemRow(SalesItemsModel item) {
    // numbers
    final qty = parseNum(item.quantity);
    final price = parseNum(item.price);
    final tax = parseNum(item.vatBeforeDiscount?.toString());
    final total = parseNum(item.total);
    final combos = <pw.Widget>[];
    dPrint("comboMealItems ${item.comboMealItems?.length}");
    if (item.comboMealItems != null && item.comboMealItems!.isNotEmpty) {
      for (var combo in item.comboMealItems!) {
        String line = "${combo['comboNameAr']} - ${combo['comboNameEn']}";
        combos.add(
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 16.0, top: 2.0),
            child: pw.Row(children: [pw.Expanded(child: pw.Text(line, style: ts(fs: 7)))]),
          ),
        );
      }
    }
    // variations list (both AR/EN)
    final variations = <pw.Widget>[];
    if (item.variations != null && item.variations!.isNotEmpty) {
      for (final v in item.variations!) {
        final varAr = (v['variationNameAr'] ?? '').toString();
        final varEn = (v['variationNameEn'] ?? '').toString();
        final mainAr = (v['mainTranslationAr'] ?? '').toString();
        final mainEn = (v['mainTranslationEn'] ?? '').toString();
        
        // Build quantity label if quantity > 1
        final qty = (v['quantity'] as num?)?.toDouble() ?? 1.0;
        final qtyLabel = qty > 1 ? ' x${qty.toInt()}' : '';
        
        // Check if this variation is free
        final isFree = v['isFree'] == true;
        final price = (v['variationPrice'] as num?)?.toDouble() ?? 0.0;
        
        // Build main translation text only if not empty
        final mainText = (mainAr.isNotEmpty || mainEn.isNotEmpty) 
            ? '($mainAr - $mainEn)' 
            : '';
        
        // Build price/free label
        final priceLabel = isFree 
            ? ' [Free]' 
            : (price > 0 ? ' +${price.toStringAsFixed(2)}' : '');
        
        final line = '• $varAr - $varEn$qtyLabel $mainText$priceLabel';
        variations.add(
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 16.0, top: 2.0),
            child: pw.Row(children: [pw.Expanded(child: pw.Text(line, style: ts(fs: 7)))]),
          ),
        );
      }
    }

    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Column(children: [
        // product name AR (right) / EN (left)
        pw.Row(children: [
          pw.Expanded(
            child: pw.Column(children: [
              pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                      '${item.productNameAr ?? ""}${item.unitNameAr != null && item.unitNameAr!.isNotEmpty ? " - ${item.unitNameAr}" : ""}',
                      style: cellStyle())),
              pw.Align(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Text(
                      '${item.productNameEn ?? ""}${item.unitNameEn != null && item.unitNameEn!.isNotEmpty ? " - ${item.unitNameEn}" : ""}',
                      style: cellStyle())),
            ]),
          ),
        ]),
        ...variations,
        ...combos,
        // Display free product information if available
        if (item.selectedFreeProductName != null && item.selectedFreeProductName!.isNotEmpty)
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 16.0, top: 4.0, bottom: 2.0),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                // Free product quantity and "Free" label
                pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      children: [
                        pw.Text(
                          " ${"Free )"}  ",
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            color: PdfColors.black,
                            fontSize: 7,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          " (   ${item.selectedFreeProductQuantity?.toString() ?? ''}  ${"Qty"}",
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            color: PdfColors.black,
                            fontSize: 7,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Free product name
                pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      item.selectedFreeProductName ?? '',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        color: PdfColors.black,
                        fontSize: 7,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      item.selectedFreeProductNameAr ?? '',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        color: PdfColors.black,
                        fontSize: 7,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        // qty/price/tax/total
        pw.Row(children: [
          pw.Expanded(
              flex: 1, child: pw.Text('', textAlign: pw.TextAlign.center, style: cellStyle())),
          pw.Expanded(
              flex: 1,
              child: pw.Text(fmt(qty), textAlign: pw.TextAlign.center, style: cellStyle())),
          pw.Expanded(
              flex: 1,
              child: pw.Text(fmt(price), textAlign: pw.TextAlign.center, style: cellStyle())),
          pw.Expanded(
              flex: 1,
              child: pw.Text(fmt(tax), textAlign: pw.TextAlign.center, style: cellStyle())),
          pw.Expanded(
              flex: 1,
              child: pw.Text(fmt(total), textAlign: pw.TextAlign.center, style: cellStyle())),
        ]),
        pw.Center(
            child: pw.Text('---------------------------------------------', style: headStyle())),
      ]),
    );
  }

  pw.Widget totals() {
    final subTotal = parseNum(inv.salesOrderModel.subTotal);
    final tax = parseNum(inv.salesOrderModel.tax);
    final total = parseNum(inv.salesOrderModel.totalAmount);
    final discountVal = inv.salesOrderModel.discountValue ?? 0;
    final discountPct = inv.salesOrderModel.discount ?? 0;
    final totalDiscount =
        (inv.salesOrderModel.discountValue ?? 0) + (inv.salesOrderModel.promotionValue ?? 0);
    final isPct = (() {
      // If you have DiscountType enum, replace with: inv.salesOrderModel.discountType == DiscountType.percentage.value
      final dt = inv.salesOrderModel.discountType;
      // best-effort: treat 1 as percentage (adjust to your enum)
      return dt == 1;
    })();

    pw.Widget row(String ar, String en, String amount, {String? sub}) => pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 3),
          child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text(ar, style: headStyle()),
              pw.Text(en, style: headStyle()),
            ]),
            pw.Text(sub ?? '', style: headStyle()),
            money(amount),
          ]),
        );

    return pw.Column(children: [
      pw.SizedBox(height: 5),
      pw.Divider(color: PdfColors.black),
      row('اجمالي المبلغ الخاضع للضريبة', 'Total Without Tax', fmt(subTotal)),
      if (discountVal > 0)
        row(
          'الخصم',
          'Discount',
          fmt(discountVal),
          sub: isPct ? ' (${fmt(discountPct)}%) ' : null,
        ),
      row('ضريبة القيمة المضافة [15%]', 'Tax [15%]', fmt(tax)),
      if ((totalDiscount) > 0) row('الخصم', 'Discount', fmt(totalDiscount)),
      row('الإجمالي شامل الضريبة', 'Total With Tax', fmt(total)),
      if ((inv.salesOrderModel.change ?? 0) > 0)
        row('الباقي', 'change', fmt(inv.salesOrderModel.change ?? 0)),
    ]);
  }

  pw.Widget paymentMethods() => pw.Column(children: [
        pw.SizedBox(height: 5),
        pw.Divider(color: PdfColors.black),
        pw.SizedBox(height: 5),
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
          txt('طرق الدفع', b: true),
          pw.SizedBox(width: 10),
          txt('Payment Methods', b: true),
        ]),
        pw.SizedBox(height: 5),
        pw.Divider(color: PdfColors.black),
        pw.SizedBox(height: 5),
        ...inv.salesOrderPayMethods.map((pm) => pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 2),
              child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  // txt(pm.nameAr, b: true),
                  txt(pm.nameEn, b: true),
                ]),
                txt(pm.amount.toStringAsFixed(2), b: true),
              ]),
            )),
        pw.SizedBox(height: 5),
        pw.Divider(color: PdfColors.black),
      ]);

  pw.Widget closers() => pw.Column(children: [
        pw.Center(
            child: txt('<<<<<< إغلاق الفاتورة ${inv.salesOrderModel.orderNumber} >>>>>>', b: true)),
        pw.Center(
            child: txt('<<<<<< Close Invoice ${inv.salesOrderModel.orderNumber} >>>>>>', b: true)),
        pw.SizedBox(height: 20),
      ]);

  // ---------- build ----------
  return pw.Directionality(
    textDirection: pw.TextDirection.rtl,
    child: pw.Container(
      color: PdfColors.white,
      child: pw.Padding(
        padding: const pw.EdgeInsetsDirectional.symmetric(horizontal: 3),
        child: pw.Column(children: [
          header(),
          details(),
          tableHeader(),
          ...inv.salesOrderItems.map(itemRow),
          totals(),
          paymentMethods(),
          closers(),
          // QR (show when keys are present)
          if (device != null &&
              ((device.privateKey?.isNotEmpty ?? false) &&
                  (device.publicKey?.isNotEmpty ?? false) &&
                  (device.crNumber?.isNotEmpty ?? false)) &&
              qr != null)
            pw.SizedBox(
              width: double.infinity,
              height: 200, // or any height you want
              child: pw.FittedBox(
                fit: pw.BoxFit.contain,
                child: qr,
              ),
            ),

          pw.SizedBox(height: 40),
        ]),
      ),
    ),
  );
}

/// Payload passed to the isolate
class InvoicePayload {
  const InvoicePayload({
    required this.invoice,
    required this.fontReg,
    required this.fontBold,
    required this.sar,
    required this.logo,
    required this.headDots,
    required this.rootToken,
    required this.zatcaQrCode,
    required this.zatcaDeviceInfo,
    this.saleTypeNameAr,
    this.saleTypeNameEn,
  });

  final SalesInvoice invoice;
  final Uint8List fontReg, fontBold, sar, logo;
  final int headDots;
  final RootIsolateToken rootToken;
  final pw.Widget zatcaQrCode;
  final DeviceConfigModel zatcaDeviceInfo;

  // Optional sale-type labels (if you want them displayed)
  final String? saleTypeNameAr;
  final String? saleTypeNameEn;
}

/// Payload passed to the isolate

Future<List<Uint8List>> buildInvoiceFrames(InvoicePayload p) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(p.rootToken);

  // 1) fonts
  final fontReg = pw.Font.ttf(ByteData.view(p.fontReg.buffer));
  final fontBold = pw.Font.ttf(ByteData.view(p.fontBold.buffer));
  late pw.MemoryImage logo;
  // 2) images
  final sar = pw.MemoryImage(p.sar);
  const double point = 1.0;
  const double inch = 72.0;
  const double cm = inch / 2.54;
  const double mm = inch / 25.4;
  final pageFormat58 = PdfPageFormat(70 * mm, double.infinity, marginAll: 0 * mm);
  final pageFormat80 = PdfPageFormat(125 * mm, double.infinity, marginAll: 0 * mm);
  // 3) page & doc
  final pagePts = (p.headDots / 8) * PdfPageFormat.mm;
  final pdf = pw.Document();
  try {
    logo = await buildNetworkImageWidgetMemoryImage();
  } catch (e) {
    logo = pw.MemoryImage(p.logo);
  }
  pdf.addPage(
    pw.Page(
      pageFormat: pageFormat58,
      // margin: const pw.EdgeInsets.symmetric(horizontal: 5),
      build: (_) => buildInvoiceBody(
        inv: p.invoice,
        fontReg: fontReg,
        fontBold: fontBold,
        logo: logo,
        sarGlyph: sar,
        device: p.zatcaDeviceInfo,
        qr: p.zatcaQrCode,
        saleTypeNameAr: p.saleTypeNameAr,
        saleTypeNameEn: p.saleTypeNameEn,
      ),
    ),
  );

  final pdfBytes = await pdf.save();

  // 4) raster → PNG frames
  final doc = await pdfx.PdfDocument.openData(pdfBytes);
  final List<Uint8List> frames = [];

  for (var i = 1; i <= doc.pagesCount; i++) {
    final page = await doc.getPage(i);
    final scale = p.headDots / page.width;
    final hPx = (page.height * scale).round();

    final imgP = await page.render(
      width: p.headDots.toDouble(),
      height: hPx.toDouble(),
      forPrint: true,
      format: pdfx.PdfPageImageFormat.png,
      quality: 100,
      backgroundColor: '#FFFFFF',
    );

    frames.add(Uint8List.fromList(imgP!.bytes));
    log('------frames ${frames.length}');
    await page.close();
  }
  await doc.close();
  return frames;
}

class ShiftPayload {
  const ShiftPayload({
    required this.report,
    required this.fontReg,
    required this.fontBold,
    required this.sar,
    required this.logo,
    required this.headDots,
    required this.rootToken,
    required this.isEnglish,
  });

  final bool isEnglish;
  final ShiftReportModel report;
  final Uint8List fontReg, fontBold, sar, logo;
  final int headDots;
  final RootIsolateToken rootToken;
}

Future<List<Uint8List>> buildShiftFrames(ShiftPayload p) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(p.rootToken);

  // 1) fonts
  final fontReg = pw.Font.ttf(ByteData.view(p.fontReg.buffer));
  final fontBold = pw.Font.ttf(ByteData.view(p.fontBold.buffer));

  // 2) images
  final sar = pw.MemoryImage(p.sar);
  final logo = pw.MemoryImage(p.logo);
  const double inch = 72.0;
  const double mm = inch / 25.4;
  final pageFormat58 = PdfPageFormat(70 * mm, double.infinity, marginAll: 0 * mm);

  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: pageFormat58,
      build: (_) => getShiftReportPdf(
        report: p.report,
        fontReg: fontReg,
        fontBold: fontBold,
        logo: logo,
        sarGlyph: sar,
        isEnglish: p.isEnglish,
      ),
    ),
  );

  final pdfBytes = await pdf.save();

  // 4) raster → PNG frames
  final doc = await pdfx.PdfDocument.openData(pdfBytes);
  final List<Uint8List> frames = [];

  for (var i = 1; i <= doc.pagesCount; i++) {
    final page = await doc.getPage(i);
    final scale = p.headDots / page.width;
    final hPx = (page.height * scale).round();

    final imgP = await page.render(
      width: p.headDots.toDouble(),
      height: hPx.toDouble(),
      forPrint: true,
      format: pdfx.PdfPageImageFormat.png,
      quality: 100,
      backgroundColor: '#FFFFFF',
    );

    frames.add(Uint8List.fromList(imgP!.bytes));
    log('------frames ${frames.length}');
    await page.close();
  }
  await doc.close();
  return frames;
}

pw.Widget getShiftReportPdf({
  required ShiftReportModel report,
  bool isEnglish = true,
  required pw.Font fontReg,
  required pw.Font fontBold,
  required pw.ImageProvider logo,
  required pw.ImageProvider sarGlyph,
}) {
  return pw.Directionality(
    textDirection: isEnglish ? pw.TextDirection.ltr : pw.TextDirection.rtl,
    child: pw.Container(
        child: pw.Padding(
      padding: pw.EdgeInsetsDirectional.only(start: 10),
      child: pw.Column(
        children: [
          // Report Title
          pw.Container(
            color: PdfColors.white,
            child: pw.Center(
              child: pw.Text(
                translator(arText: 'تقرير الكاشير', enText: 'Cashier Report'),
                style: pw.TextStyle(
                  color: PdfColors.black,
                  fontSize: 7,
                  fontWeight: pw.FontWeight.bold,
                  font: fontBold,
                ),
              ),
            ),
          ),

          // Store Information
          pw.Container(
            color: PdfColors.white,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  translator(enText: "Store:", arText: "المتجر:"),
                  style: pw.TextStyle(
                    color: PdfColors.black,
                    fontSize: 7,
                    fontWeight: pw.FontWeight.bold,
                    font: fontBold,
                  ),
                ),
                pw.Text(
                  report.appConfig?.storeNumber ?? '',
                  style: pw.TextStyle(
                    color: PdfColors.black,
                    fontSize: 7,
                    fontWeight: pw.FontWeight.bold,
                    font: fontBold,
                  ),
                ),
                if (report.appConfig?.companyName != null)
                  pw.Text(
                    "  -  ",
                    style: pw.TextStyle(
                      color: PdfColors.black,
                      fontSize: 7,
                      fontWeight: pw.FontWeight.bold,
                      font: fontBold,
                    ),
                  ),
                pw.Text(
                  report.appConfig?.companyName ?? '',
                  style: pw.TextStyle(
                    color: PdfColors.black,
                    fontSize: 7,
                    fontWeight: pw.FontWeight.bold,
                    font: fontBold,
                  ),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 10),
          pw.Divider(),
          pw.SizedBox(height: 5),

          // Business Date Range
          _buildInfoRow(
            translator(arText: "تاريخ العمل من ", enText: "Business Data From"),
            report.businessDateFrom,
            fontBold,
          ),
          _buildInfoRow(
            translator(arText: "تاريخ العمل الي ", enText: "Business Data To"),
            report.businessDateTo,
            fontBold,
          ),

          // Date and Time
          _buildInfoRow(
            translator(arText: "التاريخ", enText: "Date"),
            report.date,
            fontBold,
          ),
          _buildInfoRow(
            translator(arText: "الوقت", enText: "Time"),
            report.time,
            fontBold,
          ),

          // Printed By and Cashier
          _buildInfoRow(
            translator(arText: "طباعه", enText: "Printed By"),
            report.printedBy,
            fontBold,
          ),
          _buildInfoRow(
            translator(arText: "كاشير", enText: "Cashier"),
            report.cashierName,
            fontBold,
          ),

          pw.SizedBox(height: 10),
          pw.Divider(),
          pw.SizedBox(height: 5),

          // Sales Summary
          _buildInfoRow(
            translator(arText: "المبيعات بدون ضريبه", enText: "Total Sales Without VAT"),
            report.totalSalesWithOutVatNo,
            fontBold,
          ),
          _buildInfoRow(
            translator(arText: "الضريبة", enText: "VAT"),
            report.totalTaxes,
            fontBold,
          ),
          _buildInfoRow(
            translator(arText: "المبيعات مع الضريبة ١٥ ٪", enText: "Total Sales With VAT 15%"),
            report.totalSalesWithVatNo,
            fontBold,
          ),

          pw.SizedBox(height: 10),
          pw.Divider(),
          pw.SizedBox(height: 5),

          // Return Invoices
          _buildDetailsTitle(
              translator(arText: "فواتير المرتجعات", enText: "Return Invoices"), fontBold),
          _buildDetailsRow(report.returnInvoices, fontBold),

          pw.SizedBox(height: 5),
          pw.Divider(),
          pw.SizedBox(height: 5),

          // Sale Types
          _buildDetailsTitle(translator(arText: "نوع البيع", enText: "Sale Types"), fontBold),
          ...report.saleTypes.map((e) => _buildDetailsRow(e, fontBold)),

          pw.SizedBox(height: 5),
          pw.Divider(),
          pw.SizedBox(height: 5),
          // promotions
          _buildDetailsTitle(translator(arText: "الخصم", enText: "Discount"), fontBold),
          ...report.promotions.map((e) => _buildDetailsRow(
              ReportDetails(
                nameAr: e.promotionName ?? '',
                nameEn: '',
                qty: e.numbersOfApplies ?? '',
                price: double.tryParse(e.promotionValue ?? '0')?.toStringAsFixed(2) ?? '',
              ),
              fontBold)),

          pw.SizedBox(height: 5),
          pw.Divider(),
          pw.SizedBox(height: 5),

          // Tender Types
          _buildDetailsTitle(translator(arText: "طرق الدفع", enText: "Tender Types"), fontBold),
          ...report.tenderTypes.map((e) => _buildDetailsRow(e, fontBold)),

          // Petty Cash
          _buildInfoRow(
            translator(arText: "Petty Cash", enText: "Petty Cash"),
            report.totalPtCash.toString(),
            fontBold,
          ),

          pw.SizedBox(height: 10),
          pw.Divider(),
          pw.SizedBox(height: 5),

          // Report Footer
          pw.Center(
            child: pw.Text(
              translator(arText: "نهاية التقرير", enText: "End of Report"),
              style: pw.TextStyle(
                color: PdfColors.black,
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                font: fontBold,
              ),
            ),
          ), // Report Footer
          pw.Center(
            child: pw.Text(
              "Powerd By : www.3d-sys.com",
              style: pw.TextStyle(
                color: PdfColors.black,
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                font: fontBold,
              ),
            ),
          ),

          pw.SizedBox(height: 20),
        ],
      ),
    )),
  );
}

pw.Widget _buildInfoRow(String title, String value, pw.Font fontBold) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(vertical: 2),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            color: PdfColors.black,
            fontSize: 7,
            fontWeight: pw.FontWeight.bold,
            font: fontBold,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            color: PdfColors.black,
            fontSize: 7,
            fontWeight: pw.FontWeight.normal,
          ),
        ),
      ],
    ),
  );
}

pw.Widget _buildDetailsRow(ReportDetails details, pw.Font fontBold) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(vertical: 2),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Expanded(
          flex: 3,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Directionality(
                textDirection: pw.TextDirection.rtl,
                child: pw.Text(
                  details.nameAr,
                  style: pw.TextStyle(
                    color: PdfColors.black,
                    fontSize: 7,
                    fontWeight: pw.FontWeight.bold,
                    font: fontBold,
                  ),
                ),
              ),
              pw.Text(
                details.nameEn,
                style: pw.TextStyle(
                  color: PdfColors.black,
                  fontSize: 7,
                  fontWeight: pw.FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        pw.Expanded(
          flex: 1,
          child: pw.Text(
            details.qty,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              color: PdfColors.black,
              fontSize: 7,
              fontWeight: pw.FontWeight.bold,
              font: fontBold,
            ),
          ),
        ),
        pw.Expanded(
          flex: 1,
          child: pw.Text(
            details.price,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              color: PdfColors.black,
              fontSize: 7,
              fontWeight: pw.FontWeight.bold,
              font: fontBold,
            ),
          ),
        ),
      ],
    ),
  );
}

pw.Widget _buildDetailsTitle(String title, pw.Font fontBold) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(vertical: 2),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Expanded(
          flex: 3,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                title,
                style: pw.TextStyle(
                  color: PdfColors.black,
                  fontSize: 7,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        pw.Expanded(
          flex: 1,
          child: pw.Text(
            translator(enText: "Qty", arText: "الكمية"),
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              color: PdfColors.black,
              fontSize: 7,
              fontWeight: pw.FontWeight.bold,
              font: fontBold,
            ),
          ),
        ),
        pw.Expanded(
          flex: 1,
          child: pw.Text(
            translator(enText: "Price", arText: "السعر"),
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              color: PdfColors.black,
              fontSize: 7,
              fontWeight: pw.FontWeight.bold,
              font: fontBold,
            ),
          ),
        ),
      ],
    ),
  );
}
