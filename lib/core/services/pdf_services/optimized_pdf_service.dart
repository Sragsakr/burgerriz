import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as ma;
import 'package:flutter/services.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/core/helpers/login_helpers.dart';
import 'package:kiosk_point_of_sale/core/services/printing_services/invoice_pdf_content.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_invoice.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/device/device_info_table.dart';
import 'package:kiosk_point_of_sale/main.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;


Future<Uint8List> generatePdf(pw.Document doc) async {
  return compute((pw.Document d) async => await d.save(), doc);
}

class OptimizedPdfService {
  static final OptimizedPdfService _instance = OptimizedPdfService._internal();
  factory OptimizedPdfService() => _instance;
  OptimizedPdfService._internal();

  // Cache for frequently accessed data
  static pw.Widget? _cachedLogoWidget;
  static pw.Font? _cachedFont;
  static final Map<int, pw.Widget> _cachedSaleTypeWidgets = {};
  static List<dynamic>? _cachedSaleTypes;
  static DateTime? _lastCacheTime;
  static const Duration _cacheExpiry = Duration(minutes: 5);

  /// Initialize the service with pre-loaded data
  static Future<void> initialize() async {
    try {
      // Pre-load font
      _cachedFont = pw.Font.ttf(
          await rootBundle.load("assets/fonts/ar/Almarai-Bold.ttf"));

      // Pre-load logo
      await _preloadLogo();

      // Pre-load sale types
      _cachedSaleTypes = await generateSaleTypeList();

      _lastCacheTime = DateTime.now();
      dPrint("✅ OptimizedPdfService initialized successfully");
    } catch (e) {
      dPrint("❌ Error initializing OptimizedPdfService: $e");
    }
  }

  /// Pre-load logo widget to avoid network calls during PDF generation
  static Future<void> _preloadLogo() async {
    try {
      final deviceInfo = await DeviceConfigTable.getDeviceInfo();
      if (deviceInfo?.logo != null && deviceInfo!.logo!.isNotEmpty) {
        final path = "https://zatca.posmena.com.tr";
        final imageUrl = deviceInfo.logo!;

        final response = await http.get(Uri.parse(path + imageUrl));
        if (response.statusCode == 200) {
          final imageBytes = response.bodyBytes;
          _cachedLogoWidget = pw.Container(
            color: PdfColors.white,
            alignment: pw.Alignment.center,
            height: 70,
            width: 100,
            child: pw.Image(pw.MemoryImage(imageBytes)),
          );
          dPrint("✅ Logo pre-loaded successfully");
        }
      }
    } catch (e) {
      dPrint("⚠️ Could not pre-load logo: $e");
      // Fallback to default logo
      _cachedLogoWidget = await _getDefaultLogo();
    }
  }

  /// Get default logo from assets
  static Future<pw.Widget> _getDefaultLogo() async {
    try {
      final img = await rootBundle.load('assets/images/logo.jpg');
      final imageBytes = img.buffer.asUint8List();
      return pw.Container(
        color: PdfColors.white,
        alignment: pw.Alignment.center,
        height: 70,
        width: 100,
        child: pw.Image(pw.MemoryImage(imageBytes)),
      );
    } catch (e) {
      dPrint("❌ Error loading default logo: $e");
      return pw.Container(height: 70, width: 100);
    }
  }

  /// Check if cache is still valid
  static bool _isCacheValid() {
    if (_lastCacheTime == null) return false;
    return DateTime.now().difference(_lastCacheTime!) < _cacheExpiry;
  }

  /// Get cached logo or load it
  static Future<pw.Widget> getLogoWidget() async {
    if (_cachedLogoWidget != null && _isCacheValid()) {
      return _cachedLogoWidget!;
    }

    // Refresh cache
    await _preloadLogo();
    return _cachedLogoWidget ?? await _getDefaultLogo();
  }

  /// Optimized PDF generation with caching
  static Future<Uint8List> generateOptimizedPdf(SalesInvoice invoice) async {
    final stopwatch = Stopwatch()..start();

    try {
      dPrint("⚡ Start generated in: ${stopwatch.elapsedMilliseconds}ms");

      // Get cached data
      final logo = await getLogoWidget();
      final font = _cachedFont ??
          pw.Font.ttf(
              await rootBundle.load("assets/fonts/ar/Almarai-Bold.ttf"));

      // Get device info (cached if possible)
      final deviceInfo = await DeviceConfigTable.getDeviceInfo();

      // Get sale type (cached if possible)
      final saleTypes = _cachedSaleTypes ?? await generateSaleTypeList();
      final saleType = saleTypes.firstWhere(
            (element) => element.saleTypeId == invoice.salesOrderModel.saleTypeId,
        orElse: () =>
            SaleType(saleTypeId: 0, nameAr: '', nameEn: '', saleNature: 0),
      );

      // Determine language
      final isEnglish = ma.Localizations.localeOf(navKey.currentState!.context)
          .languageCode ==
          'en';

      // Get printer mode
      final selectedMode = await AppPreferences().getPrinterMode();
      final isNetwork = selectedMode == "network";

      // Page format constants
      const double point = 1.0;
      const double inch = 72.0;
      const double mm = inch / 25.4;

      final pageFormat = isNetwork
          ? PdfPageFormat(125 * mm, double.infinity, marginAll: 0 * mm)
          : PdfPageFormat(105 * mm, double.infinity, marginAll: 0 * mm);
      dPrint("⚡ Config generated in: ${stopwatch.elapsedMilliseconds}ms");

      // Create optimized document
      final doc = pw.Document(
        version: PdfVersion.pdf_1_5,
        compress: true, // Enable compression for faster processing
        pageMode: PdfPageMode.fullscreen,
        theme: pw.ThemeData.withFont(base: font, bold: font),
      );

      // Add page with optimized content
      doc.addPage(
        pw.Page(
          textDirection:
          isEnglish ? pw.TextDirection.ltr : pw.TextDirection.rtl,
          pageFormat: pageFormat,
          build: (context) {
            return getInvoicePdf(
              invoice: invoice,
              deviceConfigModel: deviceInfo,
              saleType: saleType,
              logo: logo,
            );
          },
        ),
      );
      dPrint("⚡ Doc generated in: ${stopwatch.elapsedMilliseconds}ms");
      final pdfBytes = await doc.save();

      stopwatch.stop();
      dPrint(
          "⚡ Optimized PDF generated in: ${stopwatch.elapsedMilliseconds}ms");

      return pdfBytes;
    } catch (e) {
      stopwatch.stop();
      dPrint("❌ Error generating optimized PDF: $e");
      rethrow;
    }
  }

  /// Clear cache when needed
  static void clearCache() {
    _cachedLogoWidget = null;
    _cachedSaleTypeWidgets.clear();
    _cachedSaleTypes = null;
    _lastCacheTime = null;
    dPrint("🗑️ PDF service cache cleared");
  }

  /// Get cache status
  static Map<String, dynamic> getCacheStatus() {
    return {
      'logoCached': _cachedLogoWidget != null,
      'fontCached': _cachedFont != null,
      'saleTypeCacheSize': _cachedSaleTypeWidgets.length,
      'saleTypesCached': _cachedSaleTypes != null,
      'lastCacheTime': _lastCacheTime?.toIso8601String(),
      'cacheValid': _isCacheValid(),
    };
  }
}

// Global instance
final optimizedPdfService = OptimizedPdfService();
