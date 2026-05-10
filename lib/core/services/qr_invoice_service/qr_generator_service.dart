import 'dart:convert';
import 'package:kiosk_point_of_sale/core/constants/qr_invoice_constants.dart';
import 'package:kiosk_point_of_sale/core/helpers/logger.dart';

const _tag = 'QrGeneratorService';

class QrGeneratorService {
  String buildQrUrl({
    required String? invoiceUrl,
    required String? feedbackUrl,
  }) {
    final combined = <String, dynamic>{};

    if (invoiceUrl != null && invoiceUrl.isNotEmpty) {
      combined['invoice_url'] = invoiceUrl;
    }
    if (feedbackUrl != null && feedbackUrl.isNotEmpty) {
      combined['feedback_url'] = feedbackUrl;
    }

    if (combined.isEmpty) {
      AppLogger.warning(_tag, 'No URLs provided for QR generation');
      return '';
    }

    final jsonString = jsonEncode(combined);
    final base64Token = base64UrlEncode(utf8.encode(jsonString));

    final finalUrl = '${QrInvoiceConstants.qrBaseUrl}?q=$base64Token';
    AppLogger.info(_tag, 'Generated QR URL: $finalUrl');

    return finalUrl;
  }
}
