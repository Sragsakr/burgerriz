import 'package:dio/dio.dart';
import 'package:kiosk_point_of_sale/core/constants/qr_invoice_constants.dart';
import 'package:kiosk_point_of_sale/core/helpers/logger.dart';
import 'package:kiosk_point_of_sale/core/services/qr_invoice_service/qr_network_service.dart';

const _tag = 'FeedmenaService';

class FeedmenaService {
  final Dio _dio;

  FeedmenaService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: QrInvoiceConstants.feedmenaBaseUrl,
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
            ));

  Future<String?> requestFeedbackUrl({
    String? branchId,
    String? shiftId,
    String? responseChannel,
  }) async {
    final hasNetwork = await NetworkService.hasInternetConnection();
    if (!hasNetwork) {
      AppLogger.warning(
          _tag, 'No internet connection, cannot request feedback URL');
      throw const NetworkException(
          'No internet connection. Please check your network and try again.');
    }

    try {
      final response = await _dio.post(
        QrInvoiceConstants.feedmenaEndpoint,
        options: Options(
          headers: {
            'X-Account-ID': QrInvoiceConstants.feedmenaAccountId,
            'X-Auth-Key': QrInvoiceConstants.feedmenaAuthKey,
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'branch_id': branchId ?? QrInvoiceConstants.defaultBranchId,
          'shift_id': shiftId ?? QrInvoiceConstants.defaultShiftId,
          'response_channel':
              responseChannel ?? QrInvoiceConstants.defaultResponseChannel,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final link = response.data['link'] as String?;
        AppLogger.info(_tag, 'Feedback URL received: $link');
        return link;
      }

      AppLogger.warning(
          _tag, 'Feedmena returned status ${response.statusCode}');
      return null;
    } on DioException catch (e) {
      AppLogger.error(_tag, 'Feedmena request failed', e);
      return null;
    } catch (e, st) {
      AppLogger.error(_tag, 'Unexpected error in Feedmena request', e, st);
      return null;
    }
  }
}
