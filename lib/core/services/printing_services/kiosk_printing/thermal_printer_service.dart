// lib/core/framework/printing_services/usb_serial/thermal_printer_service.dart
//
// Posiflex PP-7600 · 576-dot head  (≈ 72 mm printable width)
//
//   1) Build a PDF exactly as wide as the print-head
//   2) Raster to 1-bit 576 px PNG stripes
//   3) Stream GS v 0 raster stripes over USB / Bluetooth
//
// Public API
// ─────────────────────────────────────────────────────────────
//   await ThermalPrinterService.printInvoiceFinal(invoice: myInvoice);
// ------------------------------------------------------------------

import 'dart:developer';

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:collection/collection.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:kiosk_point_of_sale/core/assets/app_assets.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/core/helpers/zatca_qr_helper.dart';
import 'package:kiosk_point_of_sale/core/services/printing_services/kiosk_printing/pdf_isolate.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_invoice.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/device/device_info_table.dart';
import 'package:kiosk_point_of_sale/features/shared-features/admin/reports/cashier_report/cashier_report_view.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:usb_serial/usb_serial.dart';

class ThermalPrinterService {
  /* ── printer head resolution (change to 384 for 58 mm paper) ───────── */
  static const int _headDots = 528;

  // static const int _headDots = 576;

  // static const int _headDots = 384;

  /// ---------------------------------------------------------------------------
  /// MAIN ENTRY POINT  – now fully instrumented
  /// ---------------------------------------------------------------------------

  static Future<void> printInvoiceFinal(
      {required List<Uint8List> frames}) async {
    try {
      /* 2. باقى خطوات الطباعة كما هى — الكتابة فى الـ UI-isolate */
      final port = await setupPrinter(isBluetooth: false);
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm80, profile)..reset();

      await writeImagesToPort(frames, generator, port, isBluetooth: false);
      await feedAndCut(port, generator, isBluetooth: false);
    } catch (err, st) {
      log('Printer error: $err\n$st',
          name: 'ThermalPrinterService', error: true);
      rethrow;
    }
  }

  static Future<void> printShiftFinal({required List<Uint8List> frames}) async {
    try {
      /* 2. باقى خطوات الطباعة كما هى — الكتابة فى الـ UI-isolate */
      final port = await setupPrinter(isBluetooth: false);
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm80, profile)..reset();

      await writeImagesToPort(frames, generator, port, isBluetooth: false);
      await feedAndCut(port, generator, isBluetooth: false);
    } catch (err, st) {
      log('Printer error: $err\n$st',
          name: 'ThermalPrinterService', error: true);
      rethrow;
    }
  }

  static Future<List<Uint8List>> buildInvoicePdf(
    SalesInvoice invoice,
    String logoAssetPath,
  ) async {
    final fontReg =
        (await rootBundle.load('assets/fonts/ar/Almarai-Regular.ttf'))
            .buffer
            .asUint8List();
    final fontBold = (await rootBundle.load('assets/fonts/ar/Almarai-Bold.ttf'))
        .buffer
        .asUint8List();
    final sar = (await rootBundle.load(AppAssets.sarIcon)).buffer.asUint8List();
    final logo =
        (await rootBundle.load(logoAssetPath)).buffer.asUint8List();

    final RootIsolateToken rootToken = RootIsolateToken.instance!;
    final pw.Widget zatcaQrCode = buildZatcaQrCode(invoice);
    final zatcaDeviceInfo = await DeviceConfigTable.getDeviceInfo();
    /* 1. شغّل isolate لخَلق الإطارات */
    final frames = await compute<InvoicePayload, List<Uint8List>>(
      buildInvoiceFrames,
      InvoicePayload(
        invoice: invoice,
        fontReg: fontReg,
        fontBold: fontBold,
        sar: sar,
        logo: logo,
        // badge: badge,
        headDots: _headDots,
        rootToken: rootToken,
        zatcaQrCode: zatcaQrCode,
        zatcaDeviceInfo: zatcaDeviceInfo!,
      ),
    );
    return frames;
  }

  static Future<List<Uint8List>> buildShiftPdf(ShiftReportModel report) async {
    final fontReg =
        (await rootBundle.load('assets/fonts/ar/Almarai-Regular.ttf'))
            .buffer
            .asUint8List();
    final fontBold = (await rootBundle.load('assets/fonts/ar/Almarai-Bold.ttf'))
        .buffer
        .asUint8List();
    final sar = (await rootBundle.load(AppAssets.sarIcon)).buffer.asUint8List();
    final logo =
        (await rootBundle.load("assets/images/logo.png")).buffer.asUint8List();
    final isEnglish = await AppPreferences().getLanguage() == "en";
    final RootIsolateToken rootToken = RootIsolateToken.instance!;
    /* 1. شغّل isolate لخَلق الإطارات */
    final frames = await compute<ShiftPayload, List<Uint8List>>(
      buildShiftFrames,
      ShiftPayload(
        report: report,
        fontReg: fontReg,
        fontBold: fontBold,
        sar: sar,
        logo: logo,
        // badge: badge,
        headDots: _headDots,
        rootToken: rootToken,
        isEnglish: isEnglish,
      ),
    );
    return frames;
  }

  /*──────────────────────────────────────────────────────────────────────*/
  /*  STEP 3 – stream GS v 0 stripes                                      */
  static Future<void> writeImagesToPort(
    List<Uint8List> frames,
    Generator gen,
    dynamic port, {
    isBluetooth = false,
    int chunk = 512,
    Duration pause = const Duration(milliseconds: 6),
  }) async {
    // if isBluetooth then port is BlueThermalPrinter else port is UsbPort
    if (isBluetooth) {
      port is BlueThermalPrinter;
      if (port == null) {
        throw Exception('Bluetooth printer not connected');
      }
    } else {
      port is UsbPort;
    }
    for (final imgBytes in frames) {
      final raster = img.decodeImage(imgBytes);
      if (raster == null) continue;

      final cmd = gen.imageRaster(raster, align: PosAlign.center);

      for (var i = 0; i < cmd.length; i += chunk) {
        final slice = Uint8List.fromList(
            cmd.sublist(i, (i + chunk).clamp(0, cmd.length)));

        if (isBluetooth) {
          await port.writeBytes(slice);
        } else {
          await port.write(slice);
        }
        await Future.delayed(pause); // give the printer time to drain
      }
    }
  }

  /*──────────────────────────────────────────────────────────────────────*/

  static Future<dynamic> setupPrinter({bool isBluetooth = false}) async {
    if (isBluetooth) {
      final printer = BlueThermalPrinter.instance;

      final devices = await printer.getBondedDevices();
      if (devices.isEmpty) throw Exception('No paired BT printers found');

      final target = devices.first; // or pick by name / MAC
      if (await printer.isConnected != true) {
        await printer.connect(target);
      }
      return printer;
    } else {
      final devices = await UsbSerial.listDevices();
      if (devices.isEmpty) {
        throw Exception('No compatible thermal printer found');
      }

      dPrint('devices: ${devices.map((e) => e.productName).toList()}');

      final thermalPrinter = devices.firstWhereOrNull(
        (device) =>
            (device.manufacturerName?.contains('POSIFLEX') ?? false) ||
            (device.productName?.startsWith('PP') ?? false) ||
            (device.productName?.contains('Thermal') ?? false),
      );

      if (thermalPrinter == null) {
        throw Exception('No compatible thermal printer found');
      }

      final port = await thermalPrinter.create();
      if (port == null || !await port.open()) {
        throw Exception('Failed to open printer port');
      }

      await port.setDTR(true);
      await port.setRTS(true);

      port.setPortParameters(
        9600,
        UsbPort.DATABITS_8,
        UsbPort.STOPBITS_1,
        UsbPort.PARITY_NONE,
      );
      return port;
    }
  }

  static Future<void> feedAndCut(port, Generator gen,
      {required bool isBluetooth}) async {
    if (isBluetooth) {
      port is BlueThermalPrinter;
      if (port == null) {
        throw Exception('Bluetooth printer not connected');
      }
    } else {
      port is UsbPort;
    }
    // feed & cut
    if (isBluetooth) {
      port.writeBytes(Uint8List.fromList(gen.feed(3)));
      port.writeBytes(Uint8List.fromList(gen.cut()));
    } else {
      port.write(Uint8List.fromList(gen.feed(3)));
      port.write(Uint8List.fromList(gen.cut()));
    }

    await Future.delayed(
        const Duration(milliseconds: 200)); // let the knife finish
    gen.reset();
  }

  /*──────────────────────────────────────────────────────────────────────*/

  static Future<Generator> _prepareGenerator() async {
    const PaperSize paper = PaperSize.mm80;
    final profile = await CapabilityProfile.load();
    return Generator(paper, profile);
  }
}
