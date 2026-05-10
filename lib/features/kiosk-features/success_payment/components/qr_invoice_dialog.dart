import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiosk_point_of_sale/core/extentions/app_extentions.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_invoice.dart';
import 'package:kiosk_point_of_sale/features/shared-features/qr_invoice/qr_invoice_provider.dart';
import 'package:kiosk_point_of_sale/main.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/entry_widget/entry_widget.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrInvoiceDialog extends ConsumerStatefulWidget {
  final SalesInvoice salesInvoice;

  const QrInvoiceDialog({super.key, required this.salesInvoice});

  @override
  ConsumerState<QrInvoiceDialog> createState() => _QrInvoiceDialogState();
}

class _QrInvoiceDialogState extends ConsumerState<QrInvoiceDialog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(qrInvoiceProvider.notifier).generateQrCode(invoice: widget.salesInvoice);
    });
  }

  @override
  void dispose() {
    ref.read(qrInvoiceProvider.notifier).clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final qrState = ref.watch(qrInvoiceProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              translator(
                arText: 'الفاتورة الرقمية',
                enText: 'Digital Invoice',
              ),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              translator(
                arText: 'امسح الرمز للوصول إلى فاتورتك',
                enText: 'Scan to access your invoice',
              ),
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildContent(qrState),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  navKey.currentState!.context.pushReplacementNamed(EntryWidget.routeName);
                },
                child: Text(
                  translator(arText: 'إغلاق', enText: 'Close'),
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(qrState) {
    if (qrState.isLoading) {
      return const SizedBox(
        height: 216,
        width: 216,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Generating QR...', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    if (qrState.hasError) {
      return SizedBox(
        height: 216,
        width: 216,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 8),
              Text(
                translator(
                  arText: 'فشل في إنشاء الرمز',
                  enText: 'Failed to generate QR',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      );
    }

    if (qrState.hasQrUrl) {
      return QrImageView(
        data: qrState.finalQrUrl!,
        version: QrVersions.auto,
        size: 216,
        errorCorrectionLevel: QrErrorCorrectLevel.M,
      );
    }

    return const SizedBox(height: 216, width: 216);
  }
}
