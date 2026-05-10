import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/data/models/customer/customer_address_model.dart';
import 'package:kiosk_point_of_sale/data/models/customer/customer_model.dart';
import 'package:kiosk_point_of_sale/data/models/customer/customer_response_model.dart';
import 'package:kiosk_point_of_sale/data/services/local_data/customer_tables/customer_service.dart';
import 'package:kiosk_point_of_sale/data/services/remote_data/interfaces/customer_api_interface.dart';

class CustomerRepository {
  final CustomerApiInterface _customerApiService;

  CustomerRepository(this._customerApiService);

  /// Sync customers from API and save to local database
  Future<CustomerResponseModel> syncCustomers() async {
    try {
      // Fetch customers from API
      final response = await _customerApiService.getAllCustomersWithAddresses();

      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Get all customers from local database
  Future<List<CustomerModel>> getAllCustomers() async {
    try {
      final customers = await CustomerService.getAllCustomersWithAddresses();
      final walkingCustomer = CustomerModel(
          id: '-1',
          fullName: 'Walking Customer',
          cellPhone: ' ',
          code: '',
          customerAddress: [],
          fromDate: null,
          toDate: null);
      dPrint(
          "customers: ${customers.map((e) => e.toMap()).toList().toString()}");
      return [walkingCustomer, ...customers];
    } catch (e) {
      rethrow;
    }
  }

  /// Get all valid customers from local database (with valid date ranges)
  Future<List<CustomerModel>> getValidCustomers() async {
    try {
      final customers = await CustomerService.getValidCustomersWithAddresses();
      final walkingCustomer = CustomerModel(
          id: '-1',
          fullName: 'Walking Customer',
          cellPhone: ' ',
          code: '',
          customerAddress: [],
          fromDate: null,
          toDate: null);
      dPrint(
          "valid customers: ${customers.map((e) => e.toMap()).toList().toString()}");
      return [walkingCustomer, ...customers];
    } catch (e) {
      rethrow;
    }
  }

  /// Get valid customers for a specific date
  Future<List<CustomerModel>> getValidCustomersForDate(DateTime date) async {
    try {
      final customers = await CustomerService.getValidCustomersForDate(date);
      final walkingCustomer = CustomerModel(
          id: '-1',
          fullName: 'Walking Customer',
          cellPhone: ' ',
          code: '',
          customerAddress: [],
          fromDate: null,
          toDate: null);
      dPrint(
          "valid customers for date ${date.toString()}: ${customers.map((e) => e.toMap()).toList().toString()}");
      return [walkingCustomer, ...customers];
    } catch (e) {
      rethrow;
    }
  }

  /// Check if a customer is valid (has valid date range)
  Future<bool> isCustomerValid(String customerId) async {
    try {
      return await CustomerService.isCustomerValid(customerId);
    } catch (e) {
      rethrow;
    }
  }

  /// Check if a customer is valid for a specific date
  Future<bool> isCustomerValidForDate(String customerId, DateTime date) async {
    try {
      return await CustomerService.isCustomerValidForDate(customerId, date);
    } catch (e) {
      rethrow;
    }
  }

  /// Get customer by ID from local database
  Future<CustomerModel?> getCustomerById(String customerId) async {
    try {
      return await CustomerService.getCustomerWithAddresses(customerId);
    } catch (e) {
      rethrow;
    }
  }

  /// Get customer by code from local database
  Future<CustomerModel?> getCustomerByCode(String code) async {
    try {
      return await CustomerService.getCustomerByCode(code);
    } catch (e) {
      rethrow;
    }
  }

  /// Get customer by phone from local database
  Future<CustomerModel?> getCustomerByPhone(String phone) async {
    try {
      return await CustomerService.getCustomerByPhone(phone);
    } catch (e) {
      rethrow;
    }
  }

  /// Get selected address for a customer
  Future<CustomerAddressModel?> getSelectedAddress(String customerId) async {
    try {
      return await CustomerService.getSelectedAddress(customerId);
    } catch (e) {
      rethrow;
    }
  }

  /// Save customer to local database
  Future<void> saveCustomer(CustomerModel customer) async {
    try {
      await CustomerService.saveCustomerWithAddresses(customer);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete customer and addresses from local database
  Future<void> deleteCustomer(String customerId) async {
    try {
      await CustomerService.deleteCustomerAndAddresses(customerId);
    } catch (e) {
      rethrow;
    }
  }

  /// Clear all customer data from local database
  Future<void> clearAllData() async {
    try {
      await CustomerService.clearAllData();
    } catch (e) {
      rethrow;
    }
  }
}
