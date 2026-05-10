import 'package:kiosk_point_of_sale/data/models/customer/customer_response_model.dart';

/// Interface for customer-related API operations
abstract class CustomerApiInterface {
  Future<CustomerResponseModel> getAllCustomersWithAddresses();
}
