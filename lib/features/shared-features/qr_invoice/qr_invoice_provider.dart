import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiosk_point_of_sale/core/helpers/logger.dart';
import 'package:kiosk_point_of_sale/data/models/invoice/qr_invoice_state.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_invoice.dart';
import 'package:kiosk_point_of_sale/features/shared-features/qr_invoice/qr_invoice_mapper.dart';
import 'package:kiosk_point_of_sale/core/services/qr_invoice_service/feedmena_service.dart';
import 'package:kiosk_point_of_sale/core/services/qr_invoice_service/qr_generator_service.dart';
import 'package:kiosk_point_of_sale/core/services/qr_invoice_service/zigs_service.dart';

const _tag = 'QrInvoiceProvider';

final feedmenaServiceProvider = Provider<FeedmenaService>((ref) {
  return FeedmenaService();
});

final zigsServiceProvider = Provider<ZigsService>((ref) {
  return ZigsService();
});

final qrGeneratorServiceProvider = Provider<QrGeneratorService>((ref) {
  return QrGeneratorService();
});

final qrInvoiceProvider =
    StateNotifierProvider<QrInvoiceNotifier, QrInvoiceState>((ref) {
  return QrInvoiceNotifier(ref);
});

class QrInvoiceNotifier extends StateNotifier<QrInvoiceState> {
  final Ref _ref;

  QrInvoiceNotifier(this._ref) : super(const QrInvoiceState.initial());

  Future<void> generateQrCode({
    required SalesInvoice invoice,
    String? branchId,
    String? shiftId,
  }) async {
    if (state.isLoading) return;

    AppLogger.info(_tag,
        'Starting QR code generation for order: ${invoice.salesOrderModel.receiptNumber}');
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Step 1: Request feedback URL from Feedmena
      final feedmenaService = _ref.read(feedmenaServiceProvider);
      final feedbackUrl = await feedmenaService.requestFeedbackUrl(
        branchId: branchId,
        shiftId: shiftId,
      );

      if (feedbackUrl == null) {
        AppLogger.warning(_tag, 'Failed to get feedback URL, continuing without it');
      }

      state = state.copyWith(feedbackUrl: feedbackUrl);

      // Step 2: Build invoice payload from SalesInvoice
      final invoicePayload = QrInvoiceMapper.buildPayload(invoice);

      // Step 3: Request invoice URL from Zigs
      final zigsService = _ref.read(zigsServiceProvider);
      final invoiceUrl = await zigsService.generateInvoiceUrl(invoicePayload);

      if (invoiceUrl == null) {
        AppLogger.warning(_tag, 'Failed to get invoice URL, continuing without it');
      }

      state = state.copyWith(invoiceUrl: invoiceUrl);

      // Step 4: Generate final QR URL
      final qrGenerator = _ref.read(qrGeneratorServiceProvider);
      final finalQrUrl = qrGenerator.buildQrUrl(
        invoiceUrl: invoiceUrl,
        feedbackUrl: feedbackUrl,
      );

      state = state.copyWith(
        finalQrUrl: finalQrUrl,
        isLoading: false,
      );

      AppLogger.info(_tag, 'QR code generation completed: $finalQrUrl');
    } catch (e, st) {
      AppLogger.error(_tag, 'QR code generation failed', e, st);
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to generate QR code: $e',
      );
    }
  }

  void clear() {
    state = const QrInvoiceState.initial();
  }
}
