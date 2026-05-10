import 'package:dio/dio.dart';
import 'package:kiosk_point_of_sale/core/constants/qr_invoice_constants.dart';
import 'package:kiosk_point_of_sale/core/helpers/logger.dart';
import 'package:kiosk_point_of_sale/data/models/invoice/invoice_payload.dart';
import 'package:kiosk_point_of_sale/core/services/qr_invoice_service/qr_network_service.dart';

const _tag = 'ZigsService';

class ZigsService {
  final Dio _dio;

  ZigsService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: QrInvoiceConstants.zigsBaseUrl,
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
            ));

  Future<String?> generateInvoiceUrl(InvoicePayload payload) async {
    final hasNetwork = await NetworkService.hasInternetConnection();
    if (!hasNetwork) {
      AppLogger.warning(
          _tag, 'No internet connection, cannot generate invoice');
      throw const NetworkException(
          'No internet connection. Please check your network and try again.');
    }

    try {
      final response = await _dio.post(
        QrInvoiceConstants.zigsEndpoint,
        options: Options(
          headers: {
            'X-Account-ID': QrInvoiceConstants.zigsAccountId,
            'X-Auth-Key': QrInvoiceConstants.zigsAuthKey,
            'Content-Type': 'application/json',
          },
        ),
        data: payload.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final invoiceUrl = response.data['invoice_url'] as String?;
        AppLogger.info(_tag, 'Invoice URL received: $invoiceUrl');
        return invoiceUrl;
      }

      AppLogger.warning(_tag, 'Zigs returned status ${response.statusCode}');
      return null;
    } on DioException catch (e) {
      AppLogger.error(_tag, 'Zigs request failed', e);
      return null;
    } catch (e, st) {
      AppLogger.error(_tag, 'Unexpected error in Zigs request', e, st);
      return null;
    }
  }
}
