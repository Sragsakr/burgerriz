import 'package:kiosk_point_of_sale/data/models/customer/customer_model.dart';
import 'package:kiosk_point_of_sale/data/models/customer/customer_address_model.dart';
import 'package:kiosk_point_of_sale/data/models/customer/customer_response_model.dart';
import 'customer_table.dart';
import 'customer_address_table.dart';

class CustomerService {
  CustomerService._();

  static Future<void> createTables() async {
    await CustomerTable.create();
    await CustomerAddressTable.create();
  }

  static Future<void> saveCustomerWithAddresses(CustomerModel customer) async {
    // Save customer first
    await CustomerTable.insertAndUpdateIfExist(customer);

    // Save all addresses for this customer
    if (customer.customerAddress.isNotEmpty) {
      await CustomerAddressTable.insertMultiple(customer.customerAddress);
    }
  }

  static Future<void> saveCustomersFromResponse(
      CustomerResponseModel response) async {
    for (var customer in response.result) {
      await saveCustomerWithAddresses(customer);
    }
  }

  static Future<CustomerModel?> getCustomerWithAddresses(
      String customerId) async {
    // Get customer
    var customer = await CustomerTable.getById(customerId);
    if (customer == null) return null;

    // Get addresses for this customer
    var addresses = await CustomerAddressTable.getByCustomerId(customerId);

    // Return customer with addresses
    return customer.copyWith(customerAddress: addresses);
  }

  static Future<List<CustomerModel>> getAllCustomersWithAddresses() async {
    // Get all customers
    var customers = await CustomerTable.getAll();
    var customersWithAddresses = <CustomerModel>[];

    // Get addresses for each customer
    for (var customer in customers) {
      var addresses = await CustomerAddressTable.getByCustomerId(customer.id);
      customersWithAddresses.add(customer.copyWith(customerAddress: addresses));
    }

    return customersWithAddresses;
  }

  /// Get all customers with valid date ranges (current date is within fromDate and toDate)
  static Future<List<CustomerModel>> getValidCustomersWithAddresses() async {
    var allCustomers = await getAllCustomersWithAddresses();
    return allCustomers
        .where((customer) => customer.isDateRangeValid())
        .toList();
  }

  /// Get customers with valid date ranges for a specific date
  static Future<List<CustomerModel>> getValidCustomersForDate(
      DateTime date) async {
    var allCustomers = await getAllCustomersWithAddresses();
    return allCustomers
        .where((customer) => customer.isDateRangeValidForDate(date))
        .toList();
  }

  /// Check if a specific customer is valid (has valid date range)
  static Future<bool> isCustomerValid(String customerId) async {
    var customer = await getCustomerWithAddresses(customerId);
    return customer?.isDateRangeValid() ?? false;
  }

  /// Check if a specific customer is valid for a specific date
  static Future<bool> isCustomerValidForDate(
      String customerId, DateTime date) async {
    var customer = await getCustomerWithAddresses(customerId);
    return customer?.isDateRangeValidForDate(date) ?? false;
  }

  static Future<CustomerModel?> getCustomerByCode(String code) async {
    var customer = await CustomerTable.getByCode(code);
    if (customer == null) return null;

    var addresses = await CustomerAddressTable.getByCustomerId(customer.id);
    return customer.copyWith(customerAddress: addresses);
  }

  static Future<CustomerModel?> getCustomerByPhone(String phone) async {
    var customer = await CustomerTable.getByPhone(phone);
    if (customer == null) return null;

    var addresses = await CustomerAddressTable.getByCustomerId(customer.id);
    return customer.copyWith(customerAddress: addresses);
  }

  static Future<CustomerAddressModel?> getSelectedAddress(
      String customerId) async {
    return await CustomerAddressTable.getSelectedAddressByCustomerId(
        customerId);
  }

  static Future<void> deleteCustomerAndAddresses(String customerId) async {
    await CustomerAddressTable.deleteByCustomerId(customerId);
    await CustomerTable.deleteByCustomerId(customerId);
  }

  static Future<void> clearAllData() async {
    await CustomerAddressTable.deleteTable();
    await CustomerTable.deleteTable();
  }
}
