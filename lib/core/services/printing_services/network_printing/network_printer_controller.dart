import 'package:drago_pos_printer/utils/esc_pos/capability_profile.dart' as capabilityProfile;
import 'package:drago_pos_printer/utils/esc_pos/enums.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/core/services/printing_services/drago/drago_service.dart';
import 'package:kiosk_point_of_sale/core/services/printing_services/network_printing/network_printer_package.dart';
import 'package:kiosk_point_of_sale/core/services/printing_services/network_printing/network_printing_enum.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_invoice.dart';
import 'package:kiosk_point_of_sale/features/shared-features/admin/reports/cashier_report/cashier_report_view.dart';

class NetworkPrinterController {
  static int paperWidth = PaperSizeWidth.mm80;
  static int charPerLine = PaperSizeMaxPerLine.mm80;
  static Future<List<int>> getInvoicePdf({required SalesInvoice invoice}) async {
    List<int> data = [];
    var profile = await capabilityProfile.CapabilityProfile.load();
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

  static Future<void> printInvoice({required List<int> data, bool withSnac = true}) async {
    try {
      const PaperSize paper = PaperSize.mm80;
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm80, profile);
      // final savedPrinterIp = await AppPreferences().getPrinterIp();
      final savedPrinterIp = "192.168.1.4";

      final printer = NetworkPrinter(paper, profile);
      PosPrintResult result = await printer.connect(
        savedPrinterIp,
        port: 9100,
        timeout: const Duration(seconds: 5),
      );
      dPrint(result.value.toString());

      printer.rawBytes(data);

      printer.cut();
      printer.disconnect();
    } catch (e) {
      dPrint(e.toString());
    }
  }

  static Future<void> printShiftReport({ShiftReportModel? report}) async {
    if (report == null) {
      return;
    }
    try {
      const PaperSize paper = PaperSize.mm80;
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm80, profile);
      final savedPrinterIp = await AppPreferences().getPrinterIp();
      List<int> data = [];
      data = await getShiftReportPdf(report: report);
      final printer = NetworkPrinter(paper, profile);
      PosPrintResult result = await printer.connect(
        savedPrinterIp,
        port: 9100,
        timeout: const Duration(seconds: 5),
      );
      dPrint(result.value.toString());

      printer.rawBytes(data);

      printer.cut();
      printer.disconnect();
    } catch (e) {
      dPrint(e.toString());
    }
  }

  static Future<List<int>> getShiftReportPdf({required ShiftReportModel report}) async {
    List<int> data = [];
    var profile = await capabilityProfile.CapabilityProfile.load();
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
