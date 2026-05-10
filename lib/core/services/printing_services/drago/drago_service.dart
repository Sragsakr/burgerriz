import 'dart:io';
// import 'package:qr_flutter/qr_flutter.dart';
import 'dart:math' as math;

import 'package:drago_pos_printer/drago_pos_printer.dart';
import 'package:flutter/material.dart' as ma;
import 'package:flutter/services.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';
import 'package:kiosk_point_of_sale/core/helpers/login_helpers.dart';
import 'package:kiosk_point_of_sale/core/services/printing_services/invoice_pdf_content.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_invoice.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/device/device_info_table.dart';
import 'package:kiosk_point_of_sale/main.dart';
import 'package:kiosk_point_of_sale/features/shared-features/Cashier/cashier_widget.dart';
import 'package:kiosk_point_of_sale/features/shared-features/admin/reports/cashier_report/cashier_report_view.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart' as pf;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';

import '../../../helpers/helper_functions.dart';

Font? enFont;
Future<void> initFont() async {
  try {
    // arFont = Font.ttf(await rootBundle.load("assets/fonts/ar/bank_Bold.ttf"));
    // enFont =
    //     Font.ttf(await rootBundle.load("assets/fonts/ar/Cairo-Regular.ttf"));
    enFont =
        Font.ttf(await rootBundle.load("assets/fonts/ar/Almarai-Bold.ttf"));
    dPrint('Fonts loaded successfully.');
  } catch (e) {
    dPrint('Error loading fonts: $e');
  }
}

class ESCPrinterService {
  final Uint8List? receipt;
  List<int>? _bytes;
  late Font arFont;
  // late Font enFont;
  var dpi;

  List<int>? get bytes => _bytes;
  int? _paperSizeWidthMM;
  int? _maxPerLine;
  CapabilityProfile? _profile;

  ESCPrinterService(this.receipt);

  Future<List<int>> getBytes({
    int paperSizeWidthMM = PaperSizeWidth.mm80,
    int maxPerLine = PaperSizeMaxPerLine.mm80,
    CapabilityProfile? profile,
    String name = "default",
  }) async {
    List<int> bytes = [];
    _profile = profile ?? (await CapabilityProfile.load(name: name));
    print(_profile!.name);
    _paperSizeWidthMM = paperSizeWidthMM;
    _maxPerLine = maxPerLine;
    assert(receipt != null);
    assert(_profile != null);
    EscGenerator generator =
        EscGenerator(_paperSizeWidthMM!, _maxPerLine!, _profile!);
    var decodeImage = img.decodeImage(receipt!);
    if (decodeImage == null) throw Exception('decoded image is null');
    final img.Image resize =
        img.copyResize(decodeImage, width: _paperSizeWidthMM);

    String dir = (await getTemporaryDirectory()).path;
    String fullPath = '$dir/abc.png';
    print("local file full path $fullPath");
    File file = File(fullPath);

    await file.writeAsBytes(img.encodePng(decodeImage));

    // OpenFile.open(fullPath);

    bytes += generator.image(resize);
    bytes += generator.feed(2);
    bytes += generator.cut();
    return bytes;
  }

  Future<img.Image?> generateLabel(int width, int height, int labelWidth,
      double horizontalGap, int column) async {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: pf.PdfPageFormat(
            width * pf.PdfPageFormat.mm, height * pf.PdfPageFormat.mm),
        build: (pw.Context context) => pw.Row(children: [
          for (int i = 0; i < column; i++)
            pw.Expanded(
                child: pw.Center(
                    child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                  pw.SizedBox(height: 5),
                  pw.Text('Bodi ananatham department',
                      style: pw.TextStyle(fontSize: 6),
                      overflow: pw.TextOverflow.clip),
                  pw.SizedBox(height: 1),
                  //barcode
                  pw.BarcodeWidget(
                      width: 90,
                      height: 28,
                      data: '324324',
                      barcode: pw.Barcode.code39()),
                  //qr code
                  pw.Row(children: [
                    pw.Container(
                      width: 3,
                      child: pw.Transform.rotateBox(
                        angle: math.pi / 180,
                        child: pw.Text(
                          '13232',
                          style: pw.TextStyle(fontSize: 5),
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 2),
                    pw.BarcodeWidget(
                        width: 26,
                        height: 26,
                        data: '324324',
                        barcode: pw.Barcode.qrCode()),
                    pw.SizedBox(width: 5),
                    pw.Expanded(
                        child: pw.Column(children: [
                      pw.Row(children: [
                        pw.Expanded(
                            child: pw.Text('Rate',
                                style: pw.TextStyle(fontSize: 6))),
                        pw.Expanded(
                            child: pw.Text('0.52',
                                style: pw.TextStyle(fontSize: 6))),
                      ]),
                      pw.Row(children: [
                        pw.Expanded(
                            child: pw.Text('MRP',
                                style: pw.TextStyle(fontSize: 6))),
                        pw.Expanded(
                            child: pw.Text('0.52',
                                style: pw.TextStyle(fontSize: 6))),
                      ]),
                      pw.Row(children: [
                        pw.Expanded(
                            child: pw.Text('Mfd',
                                style: pw.TextStyle(fontSize: 6))),
                        pw.Expanded(
                            child: pw.Text('02/20/23',
                                style: pw.TextStyle(fontSize: 6))),
                      ]),
                      pw.Row(children: [
                        pw.Expanded(
                            child: pw.Text('Expiry',
                                style: pw.TextStyle(fontSize: 6))),
                        pw.Expanded(
                            child: pw.Text('02/20/23',
                                style: pw.TextStyle(fontSize: 6))),
                      ]),
                    ])),
                    pw.SizedBox(width: 3),
                  ]),
                  pw.SizedBox(height: 1.5),
                  pw.Text('200g Horlicks Choclate flavor [iyj fdgdfgdf dfgdfg]',
                      style: pw.TextStyle(fontSize: 6)),
                ])))
        ]),
      ),
    );

    await for (var page in Printing.raster(await doc.save(), dpi: 203)) {
      return page.asImage();
    }
    return null;
  }

  Future<Uint8List> _generatePdf(SalesInvoice invoice) async {
    final deviceInfo = await DeviceConfigTable.getDeviceInfo();
    SaleType? saleType;
    final saleTypes = await generateSaleTypeList();
    saleType = saleTypes.firstWhere(
        (element) => element.saleTypeId == invoice.salesOrderModel.saleTypeId,
        orElse: () =>
            SaleType(saleTypeId: 0, nameAr: '', nameEn: '', saleNature: 0));

    final isEnglish =
        ma.Localizations.localeOf(navKey.currentState!.context).languageCode ==
            'en';
    const double point = 1.0;
    const double inch = 72.0;
    const double cm = inch / 2.54;
    const double mm = inch / 25.4;
    String selectedMode = await AppPreferences().getPrinterMode();
    bool isNetwork = selectedMode == "network";
    final pageFormat58 =
        pf.PdfPageFormat(105 * mm, double.infinity, marginAll: 0 * mm);
    final pageFormat80 =
        pf.PdfPageFormat(125 * mm, double.infinity, marginAll: 0 * mm);
    final doc = Document(
      version: pf.PdfVersion.pdf_1_5,
      compress: false,
      pageMode: pf.PdfPageMode.fullscreen,
      theme: ThemeData.withFont(base: enFont, bold: enFont),
    );
    imageWidget = await buildNetworkImageWidget();
    doc.addPage(
      Page(
        textDirection: TextDirection.rtl,
        pageFormat: isNetwork ? pageFormat80 : pageFormat58,
        build: (context) {
          return getInvoicePdf(
            invoice: invoice,
            deviceConfigModel: deviceInfo,
            saleType: saleType!,
            logo: imageWidget,
          );
        },
      ),
    );
    // final doc = pw.Document();
    // doc.addPage(
    //   pw.Page(
    //     pageFormat: pf.PdfPageFormat.roll57,
    //     build: (pw.Context context) => pw.SizedBox(
    //       height: 10 * pf.PdfPageFormat.mm,
    //       child: pw.Center(
    //         child: pw.Text('Hello World', style: pw.TextStyle(fontSize: ResponsiveHelper.getResponsiveFontSize(context, 20))),
    //       ),
    //     ),
    //   ),
    // );

    return doc.save();
  }

  Future<List<int>> getPdfBytes({
    int paperSizeWidthMM = PaperSizeMaxPerLine.mm80,
    int maxPerLine = PaperSizeMaxPerLine.mm80,
    CapabilityProfile? profile,
    String name = "default",
    required SalesInvoice invoice,
  }) async {
    // await initFont();
    List<int> bytes = [];
    dPrint("${DateTime.now().second}");
    _profile = profile ?? (await CapabilityProfile.load(name: name));
    dPrint("${DateTime.now().second}");
    _paperSizeWidthMM = paperSizeWidthMM;
    _maxPerLine = maxPerLine;

    EscGenerator generator =
        EscGenerator(_paperSizeWidthMM!, _maxPerLine!, _profile!);

    await for (var page
        in Printing.raster(await _generatePdf(invoice), dpi: 96)) {
      final image = page.asImage();
      String selectedMode = await AppPreferences().getPrinterMode();
      bool isNetwork = selectedMode == "network";
      if (isNetwork) {
        bytes += generator.imageRaster(image);
      } else {
        bytes += generator.image(image);
      }

      bytes += generator.reset();
      bytes += generator.cut();
    }
    dPrint(DateTime.now().toIso8601String());
    return bytes;
  }

  Future<List<int>> getSamplePosBytes({
    int paperSizeWidthMM = PaperSizeMaxPerLine.mm80,
    int maxPerLine = PaperSizeMaxPerLine.mm80,
    CapabilityProfile? profile,
    String name = "default",
  }) async {
    List<int> bytes = [];
    _profile = profile ?? (await CapabilityProfile.load(name: name));
    print(_profile!.name);
    _paperSizeWidthMM = paperSizeWidthMM;
    _maxPerLine = maxPerLine;
    EscGenerator ticket =
        EscGenerator(_paperSizeWidthMM!, _maxPerLine!, _profile!);
    bytes += ticket.reset();
    //Print image
    // final ByteData data = await rootBundle.load('assets/logo.png');
    // final Uint8List imageBytes = data.buffer.asUint8List();
    // final img.Image? image = img.decodeImage(imageBytes);
    // if (image != null) {
    //   img.Image thumbnail = img.copyResize(image, width: 400);
    //   bytes += ticket.image(thumbnail);
    //   bytes += ticket.reset();
    // }

    // bytes += ticket.text(
    //     'Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ');
    // bytes += ticket.text('Special 1: ', styles: PosStyles(codeTable: 'CP1252'));
    // bytes += ticket.text('Special 2: blåbærgrød',
    //     styles: PosStyles(codeTable: 'CP1252'));

    // bytes += ticket.text('Bold text', styles: PosStyles(bold: true));
    // bytes += ticket.text('Reverse text', styles: PosStyles(reverse: true));
    // bytes += ticket.text('Underlined text',
    //     styles: PosStyles(underline: true), linesAfter: 1);
    // bytes += ticket.text('Align left', styles: PosStyles(align: PosAlign.left));
    // bytes +=
    //     ticket.text('Align center', styles: PosStyles(align: PosAlign.center));
    // bytes += ticket.text('Align right',
    //     styles: PosStyles(align: PosAlign.right), linesAfter: 1);

    // bytes += ticket.text('SKS DEPARTMENT STORE',
    //     styles: PosStyles(
    //       align: PosAlign.center,
    //       height: PosTextSize.size1,
    //       width: PosTextSize.size1,
    //     ));

    // bytes += ticket.text('889  Watson Lane',
    //     styles: PosStyles(align: PosAlign.center));
    // bytes += ticket.text('New Braunfels, TX',
    //     styles: PosStyles(align: PosAlign.center));
    // bytes += ticket.text('Tel: 830-221-1234',
    //     styles: PosStyles(align: PosAlign.center));
    // bytes +=
    //     ticket.text('Web: .com', styles: PosStyles(align: PosAlign.center));

    // bytes += ticket.hr();
    // bytes += ticket.row([
    //   PosColumn(text: 'Qty', width: 1),
    //   PosColumn(text: 'Item', width: 5),
    //   PosColumn(
    //       text: 'Price', width: 3, styles: PosStyles(align: PosAlign.right)),
    //   PosColumn(
    //       text: 'Total ', width: 3, styles: PosStyles(align: PosAlign.right)),
    // ]);
    // bytes += ticket.hr();

    // bytes += ticket.row([
    //   PosColumn(text: '2', width: 1),
    //   PosColumn(text: 'ONION RINGS ONION RINGS ONION', width: 5),
    //   PosColumn(
    //       text: '0.99', width: 3, styles: PosStyles(align: PosAlign.right)),
    //   PosColumn(
    //       text: '1.98', width: 3, styles: PosStyles(align: PosAlign.right)),
    // ]);
    // bytes += ticket.row([
    //   PosColumn(text: '1', width: 1),
    //   PosColumn(text: 'PIZZA', width: 7),
    //   PosColumn(
    //       text: '3.45', width: 2, styles: PosStyles(align: PosAlign.right)),
    //   PosColumn(
    //       text: '3.45', width: 2, styles: PosStyles(align: PosAlign.right)),
    // ]);
    // bytes += ticket.row([
    //   PosColumn(text: '1', width: 1),
    //   PosColumn(text: 'SPRING ROLLS', width: 7),
    //   PosColumn(
    //       text: '2.99', width: 2, styles: PosStyles(align: PosAlign.right)),
    //   PosColumn(
    //       text: '2.99', width: 2, styles: PosStyles(align: PosAlign.right)),
    // ]);
    // bytes += ticket.row([
    //   PosColumn(text: '3', width: 1),
    //   PosColumn(text: 'CRUNCHY STICKS', width: 7),
    //   PosColumn(
    //       text: '0.85', width: 2, styles: PosStyles(align: PosAlign.right)),
    //   PosColumn(
    //       text: '2.55', width: 2, styles: PosStyles(align: PosAlign.right)),
    // ]);
    // bytes += ticket.hr();

    // bytes += ticket.row([
    //   PosColumn(
    //       text: 'TOTAL',
    //       width: 6,
    //       styles: PosStyles(
    //         height: PosTextSize.size2,
    //         width: PosTextSize.size2,
    //       )),
    //   PosColumn(
    //       text: '\$10.97',
    //       width: 6,
    //       styles: PosStyles(
    //         align: PosAlign.right,
    //         height: PosTextSize.size2,
    //         width: PosTextSize.size2,
    //       )),
    // ]);

    // bytes += ticket.hr(ch: '=', linesAfter: 1);

    // bytes += ticket.row([
    //   PosColumn(
    //       text: 'CASH',
    //       width: 7,
    //       styles: PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
    //   PosColumn(
    //       text: '\$15.00',
    //       width: 5,
    //       styles: PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
    // ]);
    // bytes += ticket.row([
    //   PosColumn(
    //       text: 'CHANGE',
    //       width: 7,
    //       styles: PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
    //   PosColumn(
    //       text: '\$4.03',
    //       width: 5,
    //       styles: PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
    // ]);

    // bytes += ticket.feed(1);
    bytes += ticket.text('Thank you!',
        styles: PosStyles(align: PosAlign.center, bold: true));

    // final now = DateTime.now();
    // final formatter = DateFormat('MM/dd/yyyy H:m');
    // final String timestamp = formatter.format(now);
    // bytes += ticket.text(timestamp,
    //     styles: PosStyles(align: PosAlign.center), linesAfter: 2);

    //Print QR Code from image
    // try {
    //   const String qrData = 'example.com';
    //   const double qrSize = 100;
    //   final uiImg = await QrPainter(
    //     data: qrData,
    //     version: QrVersions.auto,
    //     gapless: false,
    //   ).toImageData(qrSize);
    //   final dir = await getTemporaryDirectory();
    //   final pathName = '${dir.path}/qr_tmp.png';
    //   final qrFile = File(pathName);
    //   final imgFile = await qrFile.writeAsBytes(uiImg!.buffer.asUint8List());
    //   final image = img.decodeImage(imgFile.readAsBytesSync());

    //   bytes += ticket.image(image!);
    // } catch (e) {
    //   print(e);
    // }

    // Print QR Code using native function
    // bytes += ticket.qrcode('example.com');

    bytes += ticket.feed(1);
    bytes += ticket.cut();

    return bytes;
  }

  Future<List<int>> getShiftReportPdfBytes({
    required ShiftReportModel report,
    int paperSizeWidthMM = PaperSizeWidth.mm80,
    int maxPerLine = PaperSizeMaxPerLine.mm80,
    CapabilityProfile? profile,
    String name = "default",
  }) async {
    List<int> bytes = [];
    _profile = profile ?? (await CapabilityProfile.load(name: name));
    print(_profile!.name);
    _paperSizeWidthMM = paperSizeWidthMM;
    _maxPerLine = maxPerLine;
    assert(_profile != null);

    // await initFont();
    final isEnglish = await AppPreferences().getLanguage() == "en";
    final doc = Document(
      version: pf.PdfVersion.pdf_1_5,
      compress: false,
      pageMode: pf.PdfPageMode.fullscreen,
      theme: ThemeData.withFont(base: enFont, bold: enFont),
    );
    const double point = 1.0;
    const double inch = 72.0;
    const double cm = inch / 2.54;
    const double mm = inch / 25.4;
    String selectedMode = await AppPreferences().getPrinterMode();
    bool isNetwork = selectedMode == "network";

    final pageFormat58 =
        pf.PdfPageFormat(105 * mm, double.infinity, marginAll: 0 * mm);
    final pageFormat80 =
        pf.PdfPageFormat(125 * mm, double.infinity, marginAll: 0 * mm);
    doc.addPage(
      Page(
        textDirection: isEnglish ? TextDirection.ltr : TextDirection.rtl,
        pageFormat: !isNetwork ? pageFormat58 : pageFormat80,
        build: (context) {
          return getShiftReportPdf(
            report: report,
            isEnglish: isEnglish,
          );
        },
      ),
    );

    final pdfBytes = await doc.save();

    // Convert PDF to image for thermal printing
    await for (var page in Printing.raster(pdfBytes, dpi: 96)) {
      final image = page.asImage();
      EscGenerator generator =
          EscGenerator(_paperSizeWidthMM!, _maxPerLine!, _profile!);

      if (isNetwork) {
        bytes += generator.imageRaster(image);
      } else {
        bytes += generator.image(image);
      }
      // bytes += generator.feed(2);
      bytes += generator.cut();
      break; // Only process first page
    }

    return bytes;
  }

  pw.Widget getShiftReportPdf({
    required ShiftReportModel report,
    bool isEnglish = true,
  }) {
    return pw.Directionality(
      textDirection: isEnglish ? pw.TextDirection.ltr : pw.TextDirection.rtl,
      child: pw.Container(
          child: pw.Padding(
        padding: pw.EdgeInsetsDirectional.only(start: 10),
        child: pw.Column(
          children: [
            // Logo if available
            // if (report.appConfig != null && report.appConfig!.logo != null)
            //   pw.Container(
            //     color: PdfColors.white,
            //     width: 400,
            //     height: 70,
            //     child: pw.Center(
            //       child: pw.Text(
            //         'LOGO',
            //         style: pw.TextStyle(
            //           color: PdfColors.black,
            //           fontSize: 12,
            //           fontWeight: pw.FontWeight.bold,
            //         ),
            //       ),
            //     ),
            //   ),

            // Report Title
            pw.Container(
              color: PdfColors.white,
              child: pw.Center(
                child: pw.Text(
                  translator(arText: 'تقرير الكاشير', enText: 'Cashier Report'),
                  style: pw.TextStyle(
                    color: PdfColors.black,
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
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
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    report.appConfig?.storeNumber ?? '',
                    style: pw.TextStyle(
                      color: PdfColors.black,
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  if (report.appConfig?.companyName != null)
                    pw.Text(
                      "  -  ",
                      style: pw.TextStyle(
                        color: PdfColors.black,
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  pw.Text(
                    report.appConfig?.companyName ?? '',
                    style: pw.TextStyle(
                      color: PdfColors.black,
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
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
              translator(
                  arText: "تاريخ العمل من ", enText: "Business Data From"),
              report.businessDateFrom,
            ),
            _buildInfoRow(
              translator(
                  arText: "تاريخ العمل الي ", enText: "Business Data To"),
              report.businessDateTo,
            ),

            // Date and Time
            _buildInfoRow(
              translator(arText: "التاريخ", enText: "Date"),
              report.date,
            ),
            _buildInfoRow(
              translator(arText: "الوقت", enText: "Time"),
              report.time,
            ),

            // Printed By and Cashier
            _buildInfoRow(
              translator(arText: "طباعه", enText: "Printed By"),
              report.printedBy,
            ),
            _buildInfoRow(
              translator(arText: "كاشير", enText: "Cashier"),
              report.cashierName,
            ),

            pw.SizedBox(height: 10),
            pw.Divider(),
            pw.SizedBox(height: 5),

            // Sales Summary
            _buildInfoRow(
              translator(
                  arText: "المبيعات بدون ضريبه",
                  enText: "Total Sales Without VAT"),
              report.totalSalesWithOutVatNo,
            ),
            _buildInfoRow(
              translator(arText: "الضريبة", enText: "VAT"),
              report.totalTaxes,
            ),
            _buildInfoRow(
              translator(
                  arText: "المبيعات مع الضريبة ١٥ ٪",
                  enText: "Total Sales With VAT 15%"),
              report.totalSalesWithVatNo,
            ),

            pw.SizedBox(height: 10),
            pw.Divider(),
            pw.SizedBox(height: 5),

            // Return Invoices
            _buildDetailsTitle(translator(
                arText: "فواتير المرتجعات", enText: "Return Invoices")),
            _buildDetailsRow(report.returnInvoices),

            pw.SizedBox(height: 5),
            pw.Divider(),
            pw.SizedBox(height: 5),

            // Sale Types
            _buildDetailsTitle(
                translator(arText: "نوع البيع", enText: "Sale Types")),
            ...report.saleTypes.map((e) => _buildDetailsRow(e)),

            pw.SizedBox(height: 5),
            pw.Divider(),
            pw.SizedBox(height: 5),
            // promotions
            _buildDetailsTitle(translator(arText: "الخصم", enText: "Discount")),
            ...report.promotions.map((e) => _buildDetailsRow(ReportDetails(
                  nameAr: e.promotionName ?? '',
                  nameEn: '',
                  qty: e.numbersOfApplies ?? '',
                  price: double.tryParse(e.promotionValue ?? '0')
                          ?.toStringAsFixed(2) ??
                      '',
                ))),

            pw.SizedBox(height: 5),
            pw.Divider(),
            pw.SizedBox(height: 5),

            // Tender Types
            _buildDetailsTitle(
                translator(arText: "طرق الدفع", enText: "Tender Types")),
            ...report.tenderTypes.map((e) => _buildDetailsRow(e)),

            // Petty Cash
            _buildInfoRow(
              translator(arText: "Petty Cash", enText: "Petty Cash"),
              report.totalPtCash.toString(),
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
                ),
              ),
            ),

            pw.SizedBox(height: 20),
          ],
        ),
      )),
    );
  }

  pw.Widget _buildInfoRow(String title, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              color: PdfColors.black,
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              color: PdfColors.black,
              fontSize: 12,
              fontWeight: pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildDetailsRow(ReportDetails details) {
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
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.Text(
                  details.nameEn,
                  style: pw.TextStyle(
                    color: PdfColors.black,
                    fontSize: 12,
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
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
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
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildDetailsTitle(String title) {
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
                    fontSize: 12,
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
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
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
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
