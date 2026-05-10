import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:kiosk_point_of_sale/core/constants/app_urls.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/device/device_info_table.dart';
import 'package:kiosk_point_of_sale/data/services/remote_data/implementations/base_api_service.dart';

import '../interfaces/feedback_api_interface.dart';

class FeedbackApiService extends BaseApiService
    implements FeedbackApiInterface {
  late String _baseUrl;

  FeedbackApiService()
      : super(
          baseUrl: '', // Will be set in initialize()
          defaultHeaders: {
            // 'Content-Type': 'application/json',
            // 'X-VS-Key':
            //     "bEJRPHo\$HSDeimd5ss4nm@!!tkNMQFg85!4oE9MdSYGdTsYT44MK7c@4smoMBXy",
          },
        );

  @override
  Future<void> initialize() async {
    _baseUrl = await AppUrls.getBaseUrl();
    await super.initialize();
  }

  @override
  Future<String?> sendFeedbackRequest({
    required String phoneNumber,
  }) async {
    final deviceInfo = await DeviceConfigTable.getDeviceInfo();

    try {
      // Create a new Dio instance for this specific request to avoid header conflicts

      final headers = {
        'X-Account-ID': deviceInfo?.feedmenaAccountId ?? '',
        'X-Auth-Key': deviceInfo?.feedmenaAuthKey ?? '',
        // 'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      // Create form data
      final formData = FormData.fromMap({
        'phone_number': phoneNumber,
        'branch_id': deviceInfo?.storeCode ?? '',
        'shift_id': '01',
        'response_channel': 'Whatsapp',
      });

      final response = await dio.request(
        'https://api.feedmena.com/api/v1/feedback-requests/',
        options: Options(
          method: 'POST',
          headers: headers,
          contentType: 'multipart/form-data',
        ),
        data: formData,
      );

      log("feedback-requests: ${response.statusCode}");

      if (response.statusCode == 200) {
        return response.data.toString();
      } else {
        log('Feedback request failed: ${response.statusMessage}');
        return null;
      }
    } on DioException catch (e) {
      log('Error sending feedback request: $e');
      return null;
    } catch (e, stackTrace) {
      log('Unexpected error sending feedback request: $e $stackTrace');
      return null;
    }
  }
}
