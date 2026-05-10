import 'dart:async';
import 'dart:ui' as ui;

import 'package:drago_pos_printer/drago_pos_printer.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/core/services/printing_services/drago/drago_service.dart';
import 'package:kiosk_point_of_sale/core/services/printing_services/invoice_content.dart';
import 'package:kiosk_point_of_sale/main.dart';
import 'package:kiosk_point_of_sale/features/shared-features/admin/reports/cashier_report/cashier_report_view.dart';

import '../../../../data/models/sales_models/sales_invoice.dart';
import '../printer_helpers.dart';

class DragoPrinterController {
  static BuildContext get context => navKey.currentState!.context;
  static bool _isLoading = false;
  static List<BluetoothPrinter> _printers = [];

  static BluetoothPrinter? selectedPrinter;

  static int paperWidth = PaperSizeWidth.mm58;
  static int charPerLine = PaperSizeMaxPerLine.mm58;

  static Future<void> scan() async {
    print("scan");

    _isLoading = true;
    _printers = [];

    BluetoothPrinterManager.discover().then((val) {
      print(val);

      _isLoading = false;
      _printers = val;
      selectedPrinter = _printers.isNotEmpty ? _printers.first : null;
    }).catchError((err) {
      var snackBar = SnackBar(
        content: Text(err.toString()),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
  }

  static Future<void> printInvoicePdf({required SalesInvoice invoice}) async {
    Stopwatch stopwatch = Stopwatch()..start();
    dPrint("Start Printing Invoice");

    if (selectedPrinter == null) {
      var snackBar = SnackBar(
        content: Text("No Printers Found"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      stopwatch.stop();
      dPrint(
          "Printing Invoice aborted - No printer found. Time taken: ${stopwatch.elapsedMilliseconds} ms");
      return;
    }
    var snackBar = SnackBar(
      duration: Duration(seconds: 7),
      backgroundColor: Colors.green,
      content: Center(child: Text(translator(arText: "جاري الطباعه", enText: "Printing Loading"))),
    );
    var manager = BluetoothPrinterManager(selectedPrinter!);

    await manager.connect();

    List<int> data = [];
    data = await getInvoicePdf(invoice: invoice);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    dPrint("Printing Invoice  Time taken: ${stopwatch.elapsedMilliseconds} ms");
    await manager.writeBytes(data).then((val) {}).catchError((err) {
      var snackBar = SnackBar(
        content: Text(err.toString()),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }).whenComplete(() {
      stopwatch.stop();
      dPrint("End Printing Invoice - Time taken: ${stopwatch.elapsedMilliseconds} ms");
    });
  }

  static Future<void> printInvoiceData({required List<int> data, bool withSnac = true}) async {
    Stopwatch stopwatch = Stopwatch()..start();
    dPrint("Start Printing Invoice");
    if (selectedPrinter == null) {
      var snackBar = SnackBar(
        content: Text("No Printers Found"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      stopwatch.stop();
      dPrint(
          "Printing Invoice aborted - No printer found. Time taken: ${stopwatch.elapsedMilliseconds} ms");
      return;
    }
    if (withSnac) {
      var snackBar = SnackBar(
        duration: Duration(seconds: 7),
        backgroundColor: Colors.green,
        content:
            Center(child: Text(translator(arText: "جاري الطباعه", enText: "Printing Loading"))),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    var manager = BluetoothPrinterManager(selectedPrinter!);
    await manager.connect();

    dPrint("Printing Invoice  Time taken: ${stopwatch.elapsedMilliseconds} ms");
    await manager.writeBytes(data).then((val) {}).catchError((err) {
      var snackBar = SnackBar(
        content: Text(err.toString()),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }).whenComplete(() {
      stopwatch.stop();
      dPrint("End Printing Invoice - Time taken: ${stopwatch.elapsedMilliseconds} ms");
    });
  }

  static Future<List<int>> getInvoicePdf({required SalesInvoice invoice}) async {
    List<int> data = [];
    var profile = await CapabilityProfile.load();
    dPrint("Data length: ${data.length}");
    try {
      data = await ESCPrinterService(null).getPdfBytes(
          invoice: invoice,
          paperSizeWidthMM: paperWidth,
          maxPerLine: charPerLine,
          profile: profile);
    } catch (e, t) {
      dPrint("Data length Error: ${e.toString()}");
      dPrint("Data length Trace: ${t.toString()}");
    }
    dPrint("Data length: ${data.length}");
    return data;
  }

  static Future<void> printTest({required img.Image image}) async {
    var profile = await CapabilityProfile.load();
    var manager = BluetoothPrinterManager(selectedPrinter!);
    EscGenerator generator = EscGenerator(paperWidth, charPerLine, profile);

    await manager.connect();
    await manager.writeBytes(generator.imageRaster(image));
  }

  static Future<void> printInvoiceImages({required SalesInvoice invoice}) async {
    Stopwatch stopwatch = Stopwatch()..start();
    dPrint("Start Printing Invoice");

    var snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: 9),
      shape: const StadiumBorder(),
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * .9, left: 10, right: 10),
      backgroundColor: Colors.green,
      content: Center(child: Text(translator(arText: "جاري الطباعه", enText: "Printing Loading"))),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    if (selectedPrinter == null) {
      var snackBar = SnackBar(
        content: Text("No Printers Found"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      stopwatch.stop();
      dPrint(
          "Printing Invoice aborted - No printer found. Time taken: ${stopwatch.elapsedMilliseconds} ms");
      return;
    }

    var profile = await CapabilityProfile.load();
    var manager = BluetoothPrinterManager(selectedPrinter!);
    await manager.connect();
    dPrint("Printing Invoice  Time taken: ${stopwatch.elapsedMilliseconds} ms");

    List<Widget> content = await InvoiceContent.getInvoiceWidgetsContent(invoice);
    EscGenerator generator = EscGenerator(paperWidth, charPerLine, profile);
    List<img.Image> images = [];
    for (var co in content) {
      final image = await createUIAndPrint(widget: co, manager: manager);
      images.add(image);
    }
    for (var image in images) {
      await manager.writeBytes(generator.image(image));
    }
    stopwatch.stop();
    dPrint("End Printing Invoice - Time taken: ${stopwatch.elapsedMilliseconds} ms");
  }

  static Future<img.Image> createUIAndPrint({
    required Widget widget,
    required BluetoothPrinterManager manager,
  }) async {
    ui.Image? printTimeImage = await PrinterHelpers.createImageFromWidget(widget);
    var resultImage = await PrinterHelpers.convertFlutterUiToImage(printTimeImage);
    return resultImage;
  }

  static Future<void> printShiftReportPdf({ShiftReportModel? report}) async {
    if (report == null) {
      return;
    }
    Stopwatch stopwatch = Stopwatch()..start();
    dPrint("Start Printing Shift Report");
    if (selectedPrinter == null) {
      var snackBar = SnackBar(
        content: Text("No Printers Found"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      stopwatch.stop();
      dPrint(
          "Printing Shift Report aborted - No printer found. Time taken: ${stopwatch.elapsedMilliseconds} ms");
      return;
    }
    // var snackBar = SnackBar(
    //   duration: Duration(seconds: 7),
    //   backgroundColor: Colors.green,
    //   content: Center(
    //       child: Text(
    //           translator(arText: "جاري الطباعه", enText: "Printing Loading"))),
    // );
    var manager = BluetoothPrinterManager(selectedPrinter!);
    await manager.connect();

    List<int> data = [];
    data = await getShiftReportPdf(report: report);
    // ScaffoldMessenger.of(context).showSnackBar(snackBar);
    dPrint("Printing Shift Report Time taken: ${stopwatch.elapsedMilliseconds} ms");
    await manager.writeBytes(data).then((val) {}).catchError((err) {
      var snackBar = SnackBar(
        content: Text(err.toString()),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }).whenComplete(() {
      stopwatch.stop();
      dPrint("End Printing Shift Report - Time taken: ${stopwatch.elapsedMilliseconds} ms");
    });
  }

  static Future<List<int>> getShiftReportPdf({required ShiftReportModel report}) async {
    List<int> data = [];
    var profile = await CapabilityProfile.load();
    dPrint("Data length: ${data.length}");
    try {
      data = await ESCPrinterService(null).getShiftReportPdfBytes(
          report: report, paperSizeWidthMM: paperWidth, maxPerLine: charPerLine, profile: profile);
    } catch (e, t) {
      dPrint("Data length Error: ${e.toString()}");
      dPrint("Data length Trace: ${t.toString()}");
    }
    dPrint("Data length: ${data.length}");
    return data;
  }
}
