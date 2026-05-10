import 'dart:typed_data';

import 'package:kiosk_point_of_sale/data/models/sales_models/sales_invoice.dart';

class ReceiptPreRenderService {
  ReceiptPreRenderService._();

  static final _singleton = ReceiptPreRenderService._();

  factory ReceiptPreRenderService() => _singleton;

  List<Uint8List>? _cachedFrames; // المتاح لشاشة Grab
  Uint8List? _cachedPdf;

  List<Uint8List>? get frames => _cachedFrames;

  Uint8List? get pdf => _cachedPdf;

  Future<void> prepare(SalesInvoice invoice) async {
    // 1️⃣  Build PDF — main-isolate (لا خطأ Binding)
    // _cachedPdf = await ThermalPrinterService.buildReceiptPdf(invoice);
    // 2️⃣  Raster PDF → PNG — أجرِها هنا أيضًا (pdfx يستخدم Channels)
    // _cachedFrames = await ThermalPrinterService.pdfToPngFrames(_cachedPdf!);
  }

  void clear() {
    _cachedFrames = null;
    _cachedPdf = null;
  }
}
