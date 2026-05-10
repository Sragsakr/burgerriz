import 'package:kiosk_point_of_sale/core/constants/app_urls.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/data/models/customer/customer_response_model.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/customer_tables/customer_service.dart';

import '../interfaces/customer_api_interface.dart';
import 'base_api_service.dart';

class CustomerApiService extends BaseApiService
    implements CustomerApiInterface {
  late String _baseUrl;

  CustomerApiService()
      : super(
          baseUrl: '', // Will be set in initialize()
          defaultHeaders: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );

  @override
  Future<void> initialize() async {
    _baseUrl = await AppUrls.getBaseUrl();

    await super.initialize();
  }

  @override
  Future<CustomerResponseModel> getAllCustomersWithAddresses() async {
    try {
      final token = await AppPreferences().getAccessToken();
      final tenantId = await AppPreferences().getTenant();

      // Set tenant ID header
      dio.options.headers.addAll({
        "abp.tenantid": tenantId,
        "Authorization": "Bearer $token",
      });

      final response = await get<Map<String, dynamic>>(
        _baseUrl + AppUrls.syncCustomers,
      );

      if (response.statusCode == 200) {
        await CustomerService.clearAllData();
        dPrint('Customer API Response received successfully');
        final customerResponse = CustomerResponseModel.fromMap(response.data!);

        dPrint('Starting customer database sync...');
        await CustomerService.saveCustomersFromResponse(customerResponse);

        dPrint('Customer database sync completed');
        return customerResponse;
      } else {
        throw Exception(
            'Customer API request failed with status code ${response.statusCode}');
      }
    } catch (e) {
      dPrint('Error during customer operation: $e');
      rethrow;
    }
  }
}
