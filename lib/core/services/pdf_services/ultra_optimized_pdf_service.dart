import 'package:flutter/services.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_invoice.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/device/device_info_table.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class UltraOptimizedPdfService {
  static final UltraOptimizedPdfService _instance =
      UltraOptimizedPdfService._internal();
  factory UltraOptimizedPdfService() => _instance;
  UltraOptimizedPdfService._internal();

  // Static cache for maximum performance
  static pw.Font? _cachedFont;
  static pw.Widget? _cachedLogo;
  static DateTime? _lastCacheTime;
  static const Duration _cacheExpiry = Duration(minutes: 10);

  /// Initialize with pre-loaded resources
  static Future<void> initialize() async {
    try {
      // Pre-load font once
      if (_cachedFont == null) {
        _cachedFont = pw.Font.ttf(
            await rootBundle.load("assets/fonts/ar/Almarai-Bold.ttf"));
        dPrint("✅ Font pre-loaded for ultra-optimized PDF");
      }

      // Pre-load simple logo
      await _preloadSimpleLogo();

      _lastCacheTime = DateTime.now();
      dPrint("✅ UltraOptimizedPdfService initialized");
    } catch (e) {
      dPrint("❌ Error initializing UltraOptimizedPdfService: $e");
    }
  }

  /// Pre-load a simple logo widget
  static Future<void> _preloadSimpleLogo() async {
    try {
      _cachedLogo = pw.Container(
        height: 50,
        width: 80,
        alignment: pw.Alignment.center,
        child: pw.Text(
          'LOGO',
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      );
    } catch (e) {
      dPrint("⚠️ Could not pre-load logo: $e");
    }
  }

  /// Check cache validity
  static bool _isCacheValid() {
    if (_lastCacheTime == null) return false;
    return DateTime.now().difference(_lastCacheTime!) < _cacheExpiry;
  }

  /// Ultra-optimized PDF generation with minimal processing
  static Future<Uint8List> generateUltraOptimizedPdf(
      SalesInvoice invoice) async {
    final stopwatch = Stopwatch()..start();

    try {
      // Ensure font is loaded
      final font = _cachedFont ??
          pw.Font.ttf(
              await rootBundle.load("assets/fonts/ar/Almarai-Bold.ttf"));

      // Get minimal device info
      final deviceInfo = await DeviceConfigTable.getDeviceInfo();

      // Get printer mode
      final selectedMode = await AppPreferences().getPrinterMode();
      final isNetwork = selectedMode == "network";

      // Simplified page format
      const double mm = 72.0 / 25.4;
      final pageFormat = isNetwork
          ? PdfPageFormat(125 * mm, double.infinity, marginAll: 0 * mm)
          : PdfPageFormat(105 * mm, double.infinity, marginAll: 0 * mm);

      // Create minimal document
      final doc = pw.Document(
        version: PdfVersion.pdf_1_5,
        compress: true,
        theme: pw.ThemeData.withFont(base: font, bold: font),
      );

      // Add simplified page
      doc.addPage(
        pw.Page(
          pageFormat: pageFormat,
          build: (context) {
            return _buildSimplifiedInvoice(invoice, deviceInfo);
          },
        ),
      );

      final pdfBytes = await doc.save();

      stopwatch.stop();
      dPrint(
          "🚀 Ultra-optimized PDF generated in: ${stopwatch.elapsedMilliseconds}ms");

      return pdfBytes;
    } catch (e) {
      stopwatch.stop();
      dPrint("❌ Error generating ultra-optimized PDF: $e");
      rethrow;
    }
  }

  /// Build simplified invoice content
  static pw.Widget _buildSimplifiedInvoice(
      SalesInvoice invoice, dynamic deviceInfo) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Header
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              deviceInfo?.name ?? 'Store',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              'Invoice #${invoice.salesOrderModel.receiptNumber}',
              style: pw.TextStyle(fontSize: 12),
            ),
          ],
        ),

        pw.SizedBox(height: 10),

        // Date
        pw.Text(
          'Date: ${DateTime.parse(invoice.salesOrderModel.createdAt).toString().substring(0, 19)}',
          style: pw.TextStyle(fontSize: 10),
        ),

        pw.SizedBox(height: 10),

        // Items header
        pw.Row(
          children: [
            pw.Expanded(
                flex: 3,
                child: pw.Text('Item',
                    style: pw.TextStyle(
                        fontSize: 10, fontWeight: pw.FontWeight.bold))),
            pw.Expanded(
                flex: 1,
                child: pw.Text('Qty',
                    style: pw.TextStyle(
                        fontSize: 10, fontWeight: pw.FontWeight.bold))),
            pw.Expanded(
                flex: 1,
                child: pw.Text('Price',
                    style: pw.TextStyle(
                        fontSize: 10, fontWeight: pw.FontWeight.bold))),
            pw.Expanded(
                flex: 1,
                child: pw.Text('Total',
                    style: pw.TextStyle(
                        fontSize: 10, fontWeight: pw.FontWeight.bold))),
          ],
        ),

        pw.Divider(),

        // Items
        ...invoice.salesOrderItems.map((item) => pw.Row(
              children: [
                pw.Expanded(
                  flex: 3,
                  child: pw.Text(
                    item.productNameEn.length > 20
                        ? '${item.productNameEn.substring(0, 20)}...'
                        : item.productNameEn,
                    style: pw.TextStyle(fontSize: 9),
                  ),
                ),
                pw.Expanded(
                    flex: 1,
                    child: pw.Text(item.quantity,
                        style: pw.TextStyle(fontSize: 9))),
                pw.Expanded(
                    flex: 1,
                    child:
                        pw.Text(item.price, style: pw.TextStyle(fontSize: 9))),
                pw.Expanded(
                    flex: 1,
                    child:
                        pw.Text(item.total, style: pw.TextStyle(fontSize: 9))),
              ],
            )),

        pw.Divider(),

        // Totals
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Subtotal:',
                style:
                    pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
            pw.Text(invoice.salesOrderModel.subTotal,
                style: pw.TextStyle(fontSize: 10)),
          ],
        ),

        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Tax:',
                style:
                    pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
            pw.Text(invoice.salesOrderModel.tax,
                style: pw.TextStyle(fontSize: 10)),
          ],
        ),

        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Total:',
                style:
                    pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            pw.Text(invoice.salesOrderModel.totalAmount,
                style:
                    pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
          ],
        ),

        pw.SizedBox(height: 10),

        // Payment methods
        pw.Text('Payment Methods:',
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
        ...invoice.salesOrderPayMethods.map((payment) => pw.Text(
              '${payment.nameEn}: ${payment.amount.toStringAsFixed(2)}',
              style: pw.TextStyle(fontSize: 9),
            )),

        pw.SizedBox(height: 10),

        // Footer
        pw.Center(
          child: pw.Text(
            'Thank you for your purchase!',
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
        ),
      ],
    );
  }

  /// Clear cache
  static void clearCache() {
    _cachedFont = null;
    _cachedLogo = null;
    _lastCacheTime = null;
    dPrint("🗑️ Ultra-optimized PDF cache cleared");
  }

  /// Get cache status
  static Map<String, dynamic> getCacheStatus() {
    return {
      'fontCached': _cachedFont != null,
      'logoCached': _cachedLogo != null,
      'lastCacheTime': _lastCacheTime?.toIso8601String(),
      'cacheValid': _isCacheValid(),
    };
  }
}

// Global instance
final ultraOptimizedPdfService = UltraOptimizedPdfService();
