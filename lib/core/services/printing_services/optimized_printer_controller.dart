import 'package:drago_pos_printer/drago_pos_printer.dart';
import 'package:flutter/foundation.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/core/services/pdf_services/optimized_pdf_service.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_invoice.dart';
import 'package:printing/printing.dart';


class OptimizedPrinterController {
  static final OptimizedPrinterController _instance =
  OptimizedPrinterController._internal();
  factory OptimizedPrinterController() => _instance;
  OptimizedPrinterController._internal();

  // Cache for capability profiles
  static CapabilityProfile? _cachedProfile;
  static DateTime? _profileCacheTime;
  static const Duration _profileCacheExpiry = Duration(minutes: 10);

  /// Get cached capability profile or load it
  static Future<CapabilityProfile> _getCachedProfile() async {
    if (_cachedProfile != null && _profileCacheTime != null) {
      final timeDiff = DateTime.now().difference(_profileCacheTime!);
      if (timeDiff < _profileCacheExpiry) {
        return _cachedProfile!;
      }
    }

    // Load and cache new profile
    _cachedProfile = await CapabilityProfile.load();
    _profileCacheTime = DateTime.now();
    dPrint("✅ Capability profile cached");
    return _cachedProfile!;
  }

  /// Ultra-fast direct thermal generation for Drago printer
  static Future<List<int>> getOptimizedInvoicePdf({
    required SalesInvoice invoice,
    int? paperSizeWidthMM,
    int? maxPerLine,
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      // Use optimized PDF generation for Drago printer
      final pdfBytes = await OptimizedPdfService.generateOptimizedPdf(invoice);
      dPrint("⚡ pdfBytes  generated in: ${stopwatch.elapsedMilliseconds}ms");
      // Convert PDF to printer bytes
      final List<int> bytes = [];
      final width = paperSizeWidthMM ?? PaperSizeWidth.mm58;
      final maxLine = maxPerLine ?? PaperSizeMaxPerLine.mm58;
      final profile = await _getCachedProfile();
      final generator = EscGenerator(width, maxLine, profile);

      // Process PDF pages with lower DPI for faster processing
      await for (var page in Printing.raster(pdfBytes, dpi: 96)) {
        final image = page.asImage();
        bytes.addAll(generator.image(image));
        // bytes.addAll(generator.reset());
        bytes.addAll(generator.cut());
        break; // Only process first page
      }
      dPrint(
          "⚡ Printing.raster generated in: ${stopwatch.elapsedMilliseconds}ms");
      stopwatch.stop();
      dPrint(
          "⚡ Optimized Drago PDF generated in: ${stopwatch.elapsedMilliseconds}ms");

      return bytes;
    } catch (e, t) {
      stopwatch.stop();
      dPrint("❌ Error generating optimized Drago PDF: $e");
      dPrint("Stack trace: $t");
      rethrow;
    }
  }

  /// Optimized PDF generation for Network printer
  static Future<List<int>> getOptimizedNetworkInvoicePdf({
    required SalesInvoice invoice,
    int? paperSizeWidthMM,
    int? maxPerLine,
  }) async {
    final width = paperSizeWidthMM ?? PaperSizeWidth.mm80;
    final maxLine = maxPerLine ?? PaperSizeMaxPerLine.mm80;
    final stopwatch = Stopwatch()..start();

    try {
      // Get cached profile
      final profile = await _getCachedProfile();

      // Generate optimized PDF with original design
      final pdfBytes = await OptimizedPdfService.generateOptimizedPdf(invoice);

      // Convert PDF to printer bytes
      final List<int> bytes = [];
      final generator = EscGenerator(width, maxLine, profile);

      // Process PDF pages with lower DPI for faster processing
      await for (var page in Printing.raster(pdfBytes, dpi: 72)) {
        final image = page.asImage();
        bytes.addAll(generator
            .imageRaster(image)); // Use imageRaster for network printers
        bytes.addAll(generator.reset());
        bytes.addAll(generator.cut());
        break; // Only process first page
      }

      stopwatch.stop();
      dPrint(
          "⚡ Optimized Network PDF generated in: ${stopwatch.elapsedMilliseconds}ms");

      return bytes;
    } catch (e, t) {
      stopwatch.stop();
      dPrint("❌ Error generating optimized Network PDF: $e");
      dPrint("Stack trace: $t");
      rethrow;
    }
  }

  /// Get optimized PDF based on printer mode
  static Future<List<int>> getOptimizedInvoicePdfByMode({
    required SalesInvoice invoice,
  }) async {
    final selectedMode = await AppPreferences().getPrinterMode();

    if (selectedMode == 'network') {
      return getOptimizedNetworkInvoicePdf(invoice: invoice);
    } else {
      return getOptimizedInvoicePdf(invoice: invoice);
    }
  }

  /// Clear all caches
  static void clearCaches() {
    _cachedProfile = null;
    _profileCacheTime = null;
    OptimizedPdfService.clearCache();
    dPrint("🗑️ All printer caches cleared");
  }

  /// Get cache status
  static Map<String, dynamic> getCacheStatus() {
    return {
      'profileCached': _cachedProfile != null,
      'profileCacheTime': _profileCacheTime?.toIso8601String(),
      'profileCacheValid': _profileCacheTime != null &&
          DateTime.now().difference(_profileCacheTime!) < _profileCacheExpiry,
      'pdfServiceStatus': OptimizedPdfService.getCacheStatus(),
    };
  }

  /// Initialize the optimized printer service
  static Future<void> initialize() async {
    try {
      // Pre-load capability profile
      await _getCachedProfile();

      // Initialize optimized PDF service
      await OptimizedPdfService.initialize();

      dPrint("✅ OptimizedPrinterController initialized successfully");
    } catch (e) {
      dPrint("❌ Error initializing OptimizedPrinterController: $e");
    }
  }
}

// Global instance
final optimizedPrinterController = OptimizedPrinterController();