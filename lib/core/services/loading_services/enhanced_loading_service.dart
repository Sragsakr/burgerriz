import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/enhanced_loading_popup.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_dialogs.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/core/services/printing_services/optimized_printer_controller.dart';
import 'package:kiosk_point_of_sale/core/services/loading_services/performance_monitor.dart';

class EnhancedLoadingService {
  static final EnhancedLoadingService _instance =
      EnhancedLoadingService._internal();
  factory EnhancedLoadingService() => _instance;
  EnhancedLoadingService._internal();

  ValueNotifier<double>? _progressNotifier;
  ValueNotifier<String>? _stepNotifier;
  Timer? _progressTimer;
  BuildContext? _context;
  bool _isLoading = false;

  // Step definitions for invoice printing
  static const Map<String, String> _printingSteps = {
    'preparing': 'preparing_invoice',
    'generating': 'generating_pdf',
    'saving': 'saving_order',
    'sending': 'sending_invoice',
    'printing': 'printing_invoice',
    'complete': 'complete',
  };

  /// Show enhanced loading dialog
  void showEnhancedLoading(
    BuildContext context, {
    String? message,
    bool isLottie = false,
    VoidCallback? onComplete,
  }) {
    if (_isLoading) return;

    _context = context;
    _isLoading = true;
    _progressNotifier = ValueNotifier(0.0);
    _stepNotifier = ValueNotifier('');

    showAppDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return EnhancedLoadingPopup(
          isLottie: isLottie,
          message: message,
          progressNotifier: _progressNotifier,
          stepNotifier: _stepNotifier,
          onComplete: onComplete,
        );
      },
    );
  }

  /// Update progress (0.0 to 1.0)
  void updateProgress(double progress) {
    _progressNotifier?.value = progress.clamp(0.0, 1.0);
  }

  /// Update current step
  void updateStep(String stepKey) {
    final stepText = _getStepText(stepKey);
    _stepNotifier?.value = stepText;
  }

  /// Simulate progress for a specific step
  Future<void> simulateStepProgress(String stepKey,
      {Duration? duration}) async {
    updateStep(stepKey);
    final stepDuration = duration ?? const Duration(milliseconds: 600);
    final steps = 15;
    final increment = 1.0 / steps;

    for (int i = 0; i < steps; i++) {
      await Future.delayed(stepDuration ~/ steps);
      updateProgress((i + 1) * increment);
    }
  }

  /// Real-time progress tracking for PDF generation
  Future<void> trackPdfGenerationProgress(
    Future<dynamic> Function() pdfGenerationTask,
  ) async {
    updateStep('generating');

    // Start with 10% progress
    updateProgress(0.1);

    // Create a completer to track when PDF generation actually completes
    final completer = Completer<void>();

    // Start PDF generation in background
    pdfGenerationTask().then((_) {
      completer.complete();
    }).catchError((error) {
      completer.completeError(error);
    });

    // Simulate progress while PDF is actually generating
    int progressStep = 1;
    const maxSteps = 20;

    while (!completer.isCompleted && progressStep <= maxSteps) {
      await Future.delayed(const Duration(milliseconds: 200));
      final progress = 0.1 + (0.8 * progressStep / maxSteps); // 10% to 90%
      updateProgress(progress);
      progressStep++;
    }

    // Wait for actual completion
    await completer.future;

    // Complete to 100%
    updateProgress(1.0);
  }

  /// Complete the loading process
  void complete() {
    _progressNotifier?.value = 1.0;
    updateStep('complete');

    // Add a small delay to show completion
    Future.delayed(const Duration(milliseconds: 500), () {
      hideLoading();
    });
  }

  /// Hide loading dialog
  void hideLoading() {
    if (!_isLoading) return;

    _isLoading = false;
    _progressTimer?.cancel();
    _progressNotifier?.dispose();
    _stepNotifier?.dispose();

    if (_context != null && _context!.mounted) {
      if (Navigator.canPop(_context!)) {
        Navigator.of(_context!).pop();
      }
    }

    _context = null;
    _progressNotifier = null;
    _stepNotifier = null;
  }

  /// Get localized step text
  String _getStepText(String stepKey) {
    // Handle operation-specific step keys
    if (stepKey.startsWith('preparing_')) {
      final operation = stepKey.split('_')[1];
      switch (operation) {
        case 'invoice':
          return translator(
            arText: "جاري إعداد الفاتورة",
            enText: "Preparing Invoice",
          );
        case 'shift_report':
          return translator(
            arText: "جاري إعداد تقرير الوردية",
            enText: "Preparing Shift Report",
          );
        case 'order':
          return translator(
            arText: "جاري إعداد الطلب",
            enText: "Preparing Order",
          );
        default:
          return translator(
            arText: "جاري الإعداد",
            enText: "Preparing",
          );
      }
    }

    if (stepKey.startsWith('saving_')) {
      final operation = stepKey.split('_')[1];
      switch (operation) {
        case 'invoice':
          return translator(
            arText: "جاري حفظ الطلب",
            enText: "Saving Order",
          );
        case 'shift_report':
          return translator(
            arText: "جاري حفظ التقرير",
            enText: "Saving Report",
          );
        case 'order':
          return translator(
            arText: "جاري حفظ الطلب",
            enText: "Saving Order",
          );
        default:
          return translator(
            arText: "جاري الحفظ",
            enText: "Saving",
          );
      }
    }

    if (stepKey.startsWith('sending_')) {
      final operation = stepKey.split('_')[1];
      switch (operation) {
        case 'invoice':
          return translator(
            arText: "جاري إرسال الفاتورة",
            enText: "Sending Invoice",
          );
        case 'shift_report':
          return translator(
            arText: "جاري إرسال التقرير",
            enText: "Sending Report",
          );
        case 'order':
          return translator(
            arText: "جاري إرسال الطلب",
            enText: "Sending Order",
          );
        default:
          return translator(
            arText: "جاري الإرسال",
            enText: "Sending",
          );
      }
    }

    if (stepKey.startsWith('printing_')) {
      final operation = stepKey.split('_')[1];
      switch (operation) {
        case 'invoice':
          return translator(
            arText: "جاري طباعة الفاتورة",
            enText: "Printing Invoice",
          );
        case 'shift_report':
          return translator(
            arText: "جاري طباعة التقرير",
            enText: "Printing Report",
          );
        case 'order':
          return translator(
            arText: "جاري طباعة الطلب",
            enText: "Printing Order",
          );
        default:
          return translator(
            arText: "جاري الطباعة",
            enText: "Printing",
          );
      }
    }

    // Handle general step keys
    switch (stepKey) {
      case 'generating':
        return translator(
          arText: "جاري إنشاء PDF",
          enText: "Generating PDF",
        );
      case 'complete':
        return translator(
          arText: "تم الإنجاز",
          enText: "Complete",
        );
      default:
        return translator(
          arText: "جاري التحميل",
          enText: "Loading...",
        );
    }
  }

  /// Optimized printing process with progress tracking
  Future<void> processPrinting({
      Future<dynamic> Function()? generateInvoice,
    required Future<dynamic> Function()? generatePdf,
      Future<dynamic> Function()? saveOrder,
    required Future<dynamic> Function()? sendInvoice,
    required Future<dynamic> Function()? printInvoice,
    String operationType = 'invoice', // 'invoice', 'shift_report', 'order'
  }) async {
    /// Backward compatibility method for invoice printing
    Future<void> processInvoicePrinting({
          Future<dynamic> Function()? generateInvoice,
      required Future<dynamic> Function()? generatePdf,
      required Future<dynamic> Function()? saveOrder,
      required Future<dynamic> Function()? sendInvoice,
      required Future<dynamic> Function()? printInvoice,
    }) async {
      return processPrinting(
        generateInvoice: generateInvoice,
        generatePdf: generatePdf,
        saveOrder: saveOrder,
        sendInvoice: sendInvoice,
        printInvoice: printInvoice,
        operationType: operationType,
      );
    }

    try {
      // Initialize optimized services if not already done
      await _ensureOptimizedServicesInitialized();

      // // Step 1: Preparing
      performanceMonitor.startTimer('preparation');
      await simulateStepProgress('preparing_$operationType');
      if (generateInvoice != null) {
        await generateInvoice();
      }
      performanceMonitor.endTimer('preparation');
      if (generatePdf != null) {
        // Step 2: Generating PDF (Optimized) with real-time progress
        performanceMonitor.startTimer('pdf_generation');
        await trackPdfGenerationProgress(() async {
          await generatePdf();
        });
        performanceMonitor.endTimer('pdf_generation');
      }
      // // Step 3: Saving
      performanceMonitor.startTimer('saving');
      await simulateStepProgress('saving_$operationType');
      if (saveOrder != null) {
        await saveOrder();
      }
      performanceMonitor.endTimer('saving');

      // Step 4: Sending (if applicable)
      try {
        if (sendInvoice != null) {
          performanceMonitor.startTimer('sending');
          await simulateStepProgress('sending_$operationType');
          await sendInvoice();
          performanceMonitor.endTimer('sending');
        }
      } catch (e) {
        dPrint(e.toString());
      }

      // Step 5: Printing (if applicable)
      if (printInvoice != null) {
        performanceMonitor.startTimer('printing');
        await simulateStepProgress('printing_$operationType');
        await printInvoice();
        performanceMonitor.endTimer('printing');
      }

      // Complete
      complete();

      // Log performance summary
      final summary = performanceMonitor.getPerformanceSummary();
      dPrint("📊 Performance Summary: $summary");

      // Log cache status for debugging
      final cacheStatus = OptimizedPrinterController.getCacheStatus();
      dPrint("📋 Cache Status: $cacheStatus");
    } catch (e) {
      // Handle error and hide loading
      hideLoading();
      rethrow;
    }
  }

  /// Ensure optimized services are initialized
  Future<void> _ensureOptimizedServicesInitialized() async {
    try {
      await OptimizedPrinterController.initialize();
    } catch (e) {
      dPrint("⚠️ Could not initialize optimized services: $e");
      // Continue without optimization if initialization fails
    }
  }
}

// Global instance
final enhancedLoadingService = EnhancedLoadingService();
