// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/material.dart' as ma;
import 'package:flutter/services.dart'; // import 'package:flutter/material.dart';
import 'package:kiosk_point_of_sale/core/services/printing_services/invoice_pdf_content.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/device/device_info_table.dart';
import 'package:kiosk_point_of_sale/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';

import '../../data/models/sales_models/sales_invoice.dart';
import 'helper_functions.dart';
import 'login_helpers.dart';

class InvoicePdf {
  InvoicePdf();

  late Font arFont;
  late Font enFont;

  Future<Uint8List?> convertPdfToImage(Uint8List pdfBytes) async {
    try {
      // Convert the PDF to images (Rasterized)
      final Stream<PdfRaster> pdfRasterStream =
          Printing.raster(pdfBytes, dpi: 150);

      // Get the first page as image
      await for (final PdfRaster raster in pdfRasterStream) {
        return raster.toPng(); // Convert to PNG
      }
    } catch (e) {
      print("Error converting PDF to image: $e");
    }
    return null; // Return null if conversion fails
  }

  Future<Uint8List?> createInvoicePdf(
    SalesInvoice invoice,
    double dpi,
  ) async {
    await initFont();
    final deviceInfo = await DeviceConfigTable.getDeviceInfo();
    SaleType? saleType;
    final saleTypes = await generateSaleTypeList();
    saleType = saleTypes.firstWhere(
        (element) => element.saleTypeId == invoice.salesOrderModel.saleTypeId,
        orElse: () =>
            SaleType(saleTypeId: 0, nameAr: '', nameEn: '', saleNature: 0));
    try {
      final isEnglish = ma.Localizations.localeOf(navKey.currentState!.context)
              .languageCode ==
          'en';

      final pdf = Document(
        version: PdfVersion.pdf_1_5,
        compress: true,
        pageMode: PdfPageMode.fullscreen,
        theme: ThemeData.withFont(base: enFont),
      );

      pdf.addPage(
        Page(
          textDirection: TextDirection.rtl,
          pageFormat: PdfPageFormat.roll80,
          build: (context) {
            return getInvoicePdf(
                invoice: invoice,
                deviceConfigModel: deviceInfo,
                saleType: saleType!);
          },
        ),
      );

      // PDF saving code
      Directory directory = await getApplicationDocumentsDirectory();

      String downloadsPath = '${directory.path}/downloads';
      await Directory(downloadsPath).create(recursive: true);
      final outputFile = File('$downloadsPath/cashier_report.pdf');
      final pdfData = await pdf.save();
      await outputFile.writeAsBytes(pdfData);
      return pdfData;
    } catch (e) {
      print('Error creating receipt PDF: $e');
      return null;
      // return Uint8List(0); // Return empty list in case of error
    }
  }

  Future<void> getAvailablePrinters() async {
    List<Printer> printers = await Printing.listPrinters();

    for (var printer in printers) {
      print("Found Printer: ${printer.name} - ${printer.url}");
    }
  }

  Future<void> directPrintPdf(String pdfPath) async {
    try {
      // Load the PDF file as bytes
      final File pdfFile = File(pdfPath);
      final Uint8List pdfBytes = await pdfFile.readAsBytes();
      Printer? pri =
          await Printing.pickPrinter(context: navKey.currentState!.context);
      dPrint("printer is ${pri?.name}");
      if (pri != null) {
        // Directly send the PDF to the default printer
        await Printing.directPrintPdf(
          printer: pri,
          onLayout: (format) async => pdfBytes,
        );
      }

      print("PDF sent to printer successfully!");
    } catch (e) {
      print("Error printing PDF: $e");
    }
  }

  Future<void> printPdf(String pdfPath) async {
    try {
      // Load the PDF file as bytes
      final File pdfFile = File(pdfPath);
      final Uint8List pdfBytes = await pdfFile.readAsBytes();

      // Print the PDF
      await Printing.layoutPdf(
        onLayout: (format) async => pdfBytes,
      );

      print("Printing started...");
    } catch (e) {
      print("Error printing PDF: $e");
    }
  }

  Future<void> initFont() async {
    try {
      // arFont = Font.ttf(await rootBundle.load("assets/fonts/ar/bank_Bold.ttf"));
      // enFont =
      //     Font.ttf(await rootBundle.load("assets/fonts/ar/Cairo-Regular.ttf"));
      enFont = Font.ttf(
          await rootBundle.load("assets/fonts/ar/Almarai-Regular.ttf"));
      print('Fonts loaded successfully.');
    } catch (e) {
      print('Error loading fonts: $e');
    }
  }
}

class TextFont {
  final Font font;
  final String text;
  double? fontSize;

  TextFont({required this.font, required this.text, this.fontSize});
}
