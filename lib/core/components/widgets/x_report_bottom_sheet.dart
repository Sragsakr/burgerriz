import 'dart:io';
import 'dart:typed_data';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/confirm_back_dialog.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/internationalization.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_dialogs.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/core/helpers/login_helpers.dart';
import 'package:kiosk_point_of_sale/core/services/printing_services/drago/drago_printer_controller.dart';
import 'package:kiosk_point_of_sale/core/services/printing_services/drago/drago_service.dart';
import 'package:kiosk_point_of_sale/core/services/printing_services/kiosk_printing/thermal_printer_service.dart';
import 'package:kiosk_point_of_sale/core/services/printing_services/network_printing/network_printer_controller.dart';
import 'package:kiosk_point_of_sale/core/services/loading_services/enhanced_loading_service.dart';
import 'package:kiosk_point_of_sale/core/services/kiosk_mode_services/kiosk_management_service.dart';
import 'package:kiosk_point_of_sale/data/services/remote_data/service_locator.dart';
import 'package:kiosk_point_of_sale/main.dart';
import 'package:kiosk_point_of_sale/features/shared-features/admin/reports/cashier_report/cashier_report_view.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

class XReportBottomSheet extends ConsumerStatefulWidget {
  final ShiftReportModel? reportModel;
  final String? outletName;
  final String? shiftId;

  const XReportBottomSheet({
    super.key,
    this.reportModel,
    this.outletName,
    this.shiftId,
  });

  @override
  ConsumerState<XReportBottomSheet> createState() => _XReportBottomSheetState();
}

class _XReportBottomSheetState extends ConsumerState<XReportBottomSheet> {
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isOffline = connectivityResult == ConnectivityResult.none;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  FFLocalizations.of(context).getText('xReport.title'),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (widget.outletName != null && widget.shiftId != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${widget.outletName} — ${widget.shiftId}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
                // Offline badge
                if (_isOffline) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.cloud_off,
                          size: 16,
                          color: Colors.orange[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          translator(
                            arText: "غير متصل (يشمل البيانات غير المزامنة)",
                            enText: "Offline (includes unsynced)",
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // Preview button
                _buildActionButton(
                  context: context,
                  icon: Icons.preview,
                  title: FFLocalizations.of(context).getText('xReport.preview'),
                  onTap: () {
                    Navigator.pop(context);
                    _showPreview(context);
                  },
                ),

                const SizedBox(height: 12),

                // Print button
                _buildActionButton(
                  context: context,
                  icon: Icons.print,
                  title: FFLocalizations.of(context).getText('xReport.print'),
                  onTap: () {
                    Navigator.pop(context);
                    _handlePrint(context);
                  },
                ),

                const SizedBox(height: 12),

                // Share PDF button
                _buildActionButton(
                  context: context,
                  icon: Icons.share,
                  title: FFLocalizations.of(context).getText('xReport.sharePdf'),
                  onTap: () async {
                    try {
                      // Stop kiosk mode

                      // Close bottom sheet first
                      Navigator.pop(context);

                      // Handle PDF sharing with proper waiting
                      await _handleSharePdfWithKioskControl(context);
                    } catch (e) {
                      dPrint("Error in share PDF: $e");
                      // Ensure kiosk mode is restarted even if sharing fails
                      try {
                        final kioskService = KioskManagementService();
                        if (kioskService.isKioskModeActive) {
                          await kioskService.startKiosk();
                        }
                      } catch (kioskError) {
                        dPrint("Failed to restart kiosk: $kioskError");
                      }
                    }
                  },
                ),

                const SizedBox(height: 12),

                // Close Shift button
                _buildActionButton(
                  context: context,
                  icon: Icons.close,
                  title: translator(
                    arText: "إغلاق الوردية",
                    enText: "Close Shift",
                  ),
                  onTap: () => _handleCloseShift(context),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFAF2A26),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3.0,
        ),
      ),
    );
  }

  void _showPreview(BuildContext context) {
    if (widget.reportModel == null) {
      _showNoOpenShiftDialog(context);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CashierReportView(
          reportModel: widget.reportModel!,
          // outletName: widget.outletName,
          // shiftId: widget.shiftId,
          // isOffline: _isOffline,
        ),
      ),
    );
  }

  void _handlePrint(BuildContext context) {
    if (widget.reportModel == null) {
      _showNoOpenShiftDialog(context);
      return;
    }

    _printXReport(context, widget.reportModel!);
  }

  Future<void> _printXReport(BuildContext context, ShiftReportModel report) async {
    try {
      // Show loading indicator
      enhancedLoadingService.showEnhancedLoading(
        context,
        message: translator(
          arText: "جاري طباعة تقرير X",
          enText: "Printing X Report",
        ),
        isLottie: true,
      );
      List<Uint8List> frames = [];
      await enhancedLoadingService.processPrinting(
        operationType: translator(
          arText: "تقرير X",
          enText: "X Report",
        ),
        // generateInvoice: () async {
        //   return report;
        // },
        generatePdf: () async {
          frames = await ThermalPrinterService.buildShiftPdf(report);
          return frames; // X-Report doesn't return PDF data
        },
        // saveOrder: () async {
        //   return;
        // },
        sendInvoice: null,
        printInvoice: () async {
          await ThermalPrinterService.printShiftFinal(
            frames: frames,
          );
        }, // Already handled in generatePdf
      );
      navKey.currentState!.context.pop();

      // Show success message

      ScaffoldMessenger.of(navKey.currentState!.context).showSnackBar(
        SnackBar(
          content: Text(
            translator(
              arText: "تم طباعة تقرير X بنجاح",
              enText: "X Report printed successfully",
            ),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      navKey.currentState!.context.pop();

      ScaffoldMessenger.of(navKey.currentState!.context).showSnackBar(
        SnackBar(
          content: Text(
            translator(
              arText: "خطأ في طباعة تقرير X: $e",
              enText: "Error printing X Report: $e",
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleSharePdf(BuildContext context) async {
    if (widget.reportModel == null) {
      _showNoOpenShiftDialog(context);
      return;
    }

    await _generateAndSharePdf(context, widget.reportModel!);
  }

  Future<void> _handleSharePdfWithKioskControl(BuildContext context) async {
    if (widget.reportModel == null) {
      _showNoOpenShiftDialog(context);
      return;
    }

    try {
      // Show loading indicator
      enhancedLoadingService.showEnhancedLoading(
        context,
        message: translator(
          arText: "جاري إنشاء ملف PDF...",
          enText: "Generating PDF...",
        ),
        isLottie: true,
      );

      // Generate PDF with same layout as preview
      final pdfBytes = await _generateXReportPdf(widget.reportModel!);

      if (pdfBytes != null) {
        // Save PDF to temporary file for sharing
        final directory = await getApplicationDocumentsDirectory();
        final downloadsPath = '${directory.path}/downloads';
        await Directory(downloadsPath).create(recursive: true);

        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = 'X_Report_$timestamp.pdf';
        final file = File('$downloadsPath/$fileName');
        await file.writeAsBytes(pdfBytes);

        enhancedLoadingService.hideLoading();
        navKey.currentState!.context.pop();

        final kioskService = KioskManagementService();
        if (kioskService.isKioskModeActive) {
          await KioskManagementService().stopKiosk();
        }
        final result = await SharePlus.instance.share(
          ShareParams(
            files: [XFile(file.path)],
            text: translator(
              arText: "تقرير X - ${widget.outletName ?? 'Outlet'}",
              enText: "X Report - ${widget.outletName ?? 'Outlet'}",
            ),
          ),
        );

        // Check if sharing was successful
        if (result.status == ShareResultStatus.success) {
          dPrint('PDF shared successfully!');
        } else if (result.status == ShareResultStatus.dismissed) {
          dPrint('Sharing was dismissed by user');
        } else {
          dPrint('Sharing failed or was cancelled');
        }

        // Show contextual message based on sharing result
        String message;
        Color backgroundColor;

        if (result.status == ShareResultStatus.success) {
          message = translator(
            arText: "تم مشاركة ملف PDF بنجاح",
            enText: "PDF shared successfully",
          );
          backgroundColor = Colors.green;
        } else if (result.status == ShareResultStatus.dismissed) {
          message = translator(
            arText: "تم إلغاء مشاركة الملف",
            enText: "File sharing cancelled",
          );
          backgroundColor = Colors.orange;
        } else {
          message = translator(
            arText: "فشل في مشاركة الملف",
            enText: "Failed to share file",
          );
          backgroundColor = Colors.red;
        }

        ScaffoldMessenger.of(navKey.currentState!.context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: backgroundColor,
          ),
        );

        // Clean up temporary file
        try {
          if (await file.exists()) {
            await file.delete();
            dPrint('Temporary PDF file deleted: ${file.path}');
          }
        } catch (e) {
          dPrint('Error deleting temporary file: $e');
        }

        // Now restart kiosk mode after sharing is complete
        await Future.delayed(const Duration(seconds: 1));
        if (kioskService.isKioskModeActive) {
          await KioskManagementService().startKiosk();
        }
      } else {
        enhancedLoadingService.hideLoading();
        throw Exception('Failed to generate PDF');
      }
    } catch (e) {
      enhancedLoadingService.hideLoading();

      // Show error message
      ScaffoldMessenger.of(navKey.currentState!.context).showSnackBar(
        SnackBar(
          content: Text(
            translator(
              arText: "خطأ في مشاركة ملف PDF: $e",
              enText: "Error sharing PDF: $e",
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );

      // Restart kiosk mode even on error
      await Future.delayed(const Duration(seconds: 1));
      final kioskService = KioskManagementService();
      if (kioskService.isKioskModeActive) {
        await KioskManagementService().startKiosk();
      }
    }
  }

  Future<void> _generateAndSharePdf(BuildContext context, ShiftReportModel report) async {
    try {
      // Show loading indicator
      enhancedLoadingService.showEnhancedLoading(
        context,
        message: translator(
          arText: "جاري إنشاء ملف PDF...",
          enText: "Generating PDF...",
        ),
        isLottie: true,
      );

      // Generate PDF with same layout as preview
      final pdfBytes = await _generateXReportPdf(report);

      if (pdfBytes != null) {
        // Save PDF to file
        final directory = await getApplicationDocumentsDirectory();
        final downloadsPath = '${directory.path}/downloads';
        await Directory(downloadsPath).create(recursive: true);

        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = 'X_Report_$timestamp.pdf';
        final file = File('$downloadsPath/$fileName');
        await file.writeAsBytes(pdfBytes);
        navKey.currentState!.context.pop();
        // enhancedLoadingService.hideLoading();

        // Share the PDF file using system share
        await Printing.sharePdf(
          bytes: pdfBytes,
          filename: fileName,
        );
        // dPrint("share pdf fibished");
        // await Future.delayed(Duration(seconds: 5));
        // await KioskManagementService().startKiosk();
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                translator(
                  arText: "تم مشاركة ملف PDF بنجاح",
                  enText: "PDF shared successfully",
                ),
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
        navKey.currentState!.context.pop();
      } else {
        enhancedLoadingService.hideLoading();
        throw Exception('Failed to generate PDF');
      }
    } catch (e) {
      enhancedLoadingService.hideLoading();

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              translator(
                arText: "خطأ في مشاركة ملف PDF: $e",
                enText: "Error sharing PDF: $e",
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<Uint8List?> _generateXReportPdf(ShiftReportModel report) async {
    try {
      final isEnglish = await AppPreferences().getLanguage() == "en";

      final pdf = pw.Document(
        version: PdfVersion.pdf_1_5,
        compress: false,
        pageMode: PdfPageMode.fullscreen,
        theme: pw.ThemeData.withFont(base: enFont, bold: enFont),
      );

      pdf.addPage(
        pw.Page(
          textDirection: isEnglish ? pw.TextDirection.ltr : pw.TextDirection.rtl,
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return ESCPrinterService(null).getShiftReportPdf(report: report, isEnglish: isEnglish);
          },
        ),
      );

      return await pdf.save();
    } catch (e) {
      dPrint('Error generating X-Report PDF: $e');
      return null;
    }
  }

  pw.Widget _buildXReportPdfContent(ShiftReportModel report, bool isEnglish) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Header
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            children: [
              pw.Text(
                translator(
                  arText: "تقرير X",
                  enText: "X Report",
                ),
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              if (widget.outletName != null && widget.shiftId != null) ...[
                pw.SizedBox(height: 8),
                pw.Text(
                  '${widget.outletName} — ${widget.shiftId}',
                  style: pw.TextStyle(
                    fontSize: 14,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            ],
          ),
        ),

        pw.SizedBox(height: 16),

        // Report Information
        _buildPdfSection(
          title: translator(
            arText: "معلومات التقرير",
            enText: "Report Information",
          ),
          children: [
            _buildPdfInfoRow(
              translator(
                arText: "المنفذ",
                enText: "Outlet",
              ),
              widget.outletName ?? report.appConfig?.companyName ?? "N/A",
            ),
            _buildPdfInfoRow(
              translator(
                arText: "الجهاز",
                enText: "Device",
              ),
              report.appConfig?.deviceNumber ?? "N/A",
            ),
            _buildPdfInfoRow(
              translator(
                arText: "أمين الصندوق",
                enText: "Cashier",
              ),
              report.cashierName,
            ),
            _buildPdfInfoRow(
              translator(
                arText: "الوردية الحالية",
                enText: "Current Shift",
              ),
              widget.shiftId ?? "N/A",
            ),
            _buildPdfInfoRow(
              translator(
                arText: "فتحت في",
                enText: "Opened at",
              ),
              "${report.date} ${report.businessDateFrom}",
            ),
            _buildPdfInfoRow(
              translator(
                arText: "تم الإنشاء في",
                enText: "Generated at",
              ),
              "${report.date} ${report.time}",
            ),
          ],
        ),

        pw.SizedBox(height: 16),

        // Totals
        _buildPdfSection(
          title: translator(
            arText: "المجاميع",
            enText: "Totals",
          ),
          children: [
            _buildPdfTotalRow(
              translator(
                arText: "إجمالي المبيعات",
                enText: "Gross Sales",
              ),
              report.totalSalesWithVatNo,
              PdfColors.green,
            ),
            _buildPdfTotalRow(
              translator(
                arText: "الخصومات",
                enText: "Discounts",
              ),
              report.totalDiscount,
              PdfColors.orange,
            ),
            _buildPdfTotalRow(
              translator(
                arText: "المرتجعات/الإلغاءات",
                enText: "Returns/Voids",
              ),
              report.returnInvoices.price,
              PdfColors.red,
            ),
            _buildPdfTotalRow(
              translator(
                arText: "الضريبة/ضريبة القيمة المضافة",
                enText: "Tax/VAT",
              ),
              report.totalTaxes,
              PdfColors.blue,
            ),
            _buildPdfTotalRow(
              translator(
                arText: "صافي المبيعات",
                enText: "Net Sales",
              ),
              report.totalSalesWithOutVatNo,
              PdfColors.purple,
            ),
            _buildPdfTotalRow(
              translator(
                arText: "النقدية الإضافية",
                enText: "Additional Cash",
              ),
              report.totalPtCash,
              PdfColors.teal,
            ),
          ],
        ),

        pw.SizedBox(height: 16),

        // Payment Breakdown
        if (report.tenderTypes.isNotEmpty)
          _buildPdfSection(
            title: translator(
              arText: "تفصيل المدفوعات",
              enText: "Payment Breakdown",
            ),
            children: report.tenderTypes
                .map(
                  (tender) => _buildPdfInfoRow(
                    isEnglish ? tender.nameEn : tender.nameAr,
                    "${tender.qty} × ${tender.price}",
                  ),
                )
                .toList(),
          ),

        pw.SizedBox(height: 16),

        // Promotions
        if (report.promotions.isNotEmpty)
          _buildPdfSection(
            title: translator(
              arText: "العروض والخصومات",
              enText: "Promotions & Discounts",
            ),
            children: report.promotions
                .map(
                  (promotion) => _buildPdfInfoRow(
                    promotion.promotionName ?? "N/A",
                    "${promotion.numbersOfApplies} × ${promotion.promotionValue}",
                  ),
                )
                .toList(),
          ),

        pw.SizedBox(height: 16),

        // Sale Types
        if (report.saleTypes.isNotEmpty)
          _buildPdfSection(
            title: translator(
              arText: "أنواع المبيعات",
              enText: "Sale Types",
            ),
            children: report.saleTypes
                .map(
                  (saleType) => _buildPdfInfoRow(
                    isEnglish ? saleType.nameEn : saleType.nameAr,
                    "${saleType.qty} × ${saleType.price}",
                  ),
                )
                .toList(),
          ),

        pw.SizedBox(height: 24),

        // Footer
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Center(
            child: pw.Text(
              translator(
                arText: "تقرير X لا يغلق أو يعيد تعيين الوردية.",
                enText: "X-Report does not close or reset the shift.",
              ),
              style: pw.TextStyle(
                fontSize: 12,
                fontStyle: pw.FontStyle.italic,
                color: PdfColors.grey600,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildPdfSection({
    required String title,
    required List<pw.Widget> children,
  }) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  pw.Widget _buildPdfInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(
            child: pw.Text(
              label,
              style: const pw.TextStyle(fontSize: 12),
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfTotalRow(String label, String value, PdfColor color) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.normal,
            ),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNoOpenShiftDialog(BuildContext context) {
    showAppDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          FFLocalizations.of(context).getText('xReport.title'),
        ),
        content: Text(
          FFLocalizations.of(context).getText('xReport.noOpenShift'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              translator(
                arText: "موافق",
                enText: "OK",
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleCloseShift(BuildContext context) {
    showAppDialog(
      context: context,
      builder: (context1) => ConfirmBackDialog(
        arMsg: 'هل انت متأكد من اغلاق الوردية؟',
        enMsg: 'Are you sure you want to close the shift?',
        onAccept: () async {
          // Navigator.pop(context1);
          Navigator.pop(context); // Close the bottom sheet
          await _closeShift(context);
        },
      ),
    );
  }

  Future<void> _closeShift(BuildContext context) async {
    try {
      // Show loading
      enhancedLoadingService.showEnhancedLoading(
        navKey.currentState!.context,
        message: translator(
          arText: "جاري إغلاق الوردية...",
          enText: "Closing shift...",
        ),
        isLottie: true,
      );

      // Sync orders first
      await syncOrders(ref);

      // Get shift report and close shift
      final xReportService = ref.watch(xReportApiServiceProvider);
      try {
        final shift = await xReportService.xReport();

        // Print shift report
        enhancedLoadingService.showEnhancedLoading(
          navKey.currentState!.context,
          message: translator(
            arText: "جاري طباعة تقرير الوردية",
            enText: "Printing Shift Report",
          ),
          isLottie: true,
        );

        await enhancedLoadingService.processPrinting(
          operationType: translator(
            arText: "تقرير الوردية",
            enText: "Shift Report",
          ),
          // generateInvoice: () async {
          //   return shift;
          // },
          generatePdf: () async {
            String selectedMode = await AppPreferences().getPrinterMode();
            if (selectedMode == 'network') {
              await NetworkPrinterController.printShiftReport(report: shift);
            } else {
              await DragoPrinterController.printShiftReportPdf(report: shift);
            }
            return null;
          },
          // saveOrder: () async {
          //   return;
          // },
          sendInvoice: null,
          printInvoice: null,
        );

        navKey.currentState!.context.pop();

        // Show shift report and navigate to login
        // await showAppDialog(
        //   context: context,
        //   builder: (context1) => CashierReportView(reportModel: shift),
        // );

        context.go('/login');
      } catch (e) {
        navKey.currentState!.context.pop();
        ScaffoldMessenger.of(navKey.currentState!.context).showSnackBar(
          SnackBar(
            content: Text(
              translator(
                arText: "فشل في إغلاق الوردية",
                enText: "Failed to close shift",
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    } catch (e) {
      navKey.currentState!.context.pop();
      ScaffoldMessenger.of(navKey.currentState!.context).showSnackBar(
        SnackBar(
          content: Text(
            translator(
              arText: "خطأ في إغلاق الوردية: $e",
              enText: "Error closing shift: $e",
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
