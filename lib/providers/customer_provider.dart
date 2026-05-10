import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiosk_point_of_sale/data/models/customer/customer_address_model.dart';
import 'package:kiosk_point_of_sale/data/models/customer/customer_model.dart';
import 'package:kiosk_point_of_sale/data/models/customer/customer_response_model.dart';
import 'package:kiosk_point_of_sale/data/services/remote_data/service_locator.dart';
import 'package:kiosk_point_of_sale/repository/customer_repository.dart';

// Provider for CustomerRepository
final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  final customerApiService = ref.watch(customerApiServiceProvider);
  return CustomerRepository(customerApiService);
});

// Provider for customer response state
final customerResponseProvider =
    StateProvider<CustomerResponseModel?>((ref) => null);

// Provider for all customers state
final allCustomersProvider = StateProvider<List<CustomerModel>>((ref) => []);

// Provider for selected customer state
final selectedCustomerProvider = StateProvider<CustomerModel?>((ref) => null);

// Provider for selected address state
final selectedAddressProvider =
    StateProvider<CustomerAddressModel?>((ref) => null);

// Provider for customer loading state
final customerLoadingProvider = StateProvider<bool>((ref) => false);

// Provider for customer sync success state
final customerSyncSuccessProvider = StateProvider<bool>((ref) => false);

// Notifier for customer operations
class CustomerNotifier extends StateNotifier<List<CustomerModel>> {
  final CustomerRepository _customerRepository;
  final Ref _ref;

  CustomerNotifier(this._customerRepository, this._ref) : super([]);

  /// Sync customers from API
  Future<void> syncCustomers({
    required String tenantId,
    required String token,
  }) async {
    try {
      _ref.read(customerLoadingProvider.notifier).state = true;
      _ref.read(customerSyncSuccessProvider.notifier).state = false;

      final response = await _customerRepository.syncCustomers();

      _ref.read(customerResponseProvider.notifier).state = response;
      _ref.read(customerSyncSuccessProvider.notifier).state = true;

      // Load all customers from local database
      await loadAllCustomers();
    } catch (e) {
      _ref.read(customerSyncSuccessProvider.notifier).state = false;
      // Keep existing state on error
    } finally {
      _ref.read(customerLoadingProvider.notifier).state = false;
    }
  }

  /// Load all customers from local database
  Future<void> loadAllCustomers() async {
    try {
      final customers = await _customerRepository.getAllCustomers();
      state = customers;
      _ref.read(allCustomersProvider.notifier).state = customers;
    } catch (e) {
      // Keep existing state on error
    }
  }

  /// Get customer by ID
  Future<CustomerModel?> getCustomerById(String customerId) async {
    try {
      return await _customerRepository.getCustomerById(customerId);
    } catch (e) {
      return null;
    }
  }

  /// Get customer by code
  Future<CustomerModel?> getCustomerByCode(String code) async {
    try {
      return await _customerRepository.getCustomerByCode(code);
    } catch (e) {
      return null;
    }
  }

  /// Get customer by phone
  Future<CustomerModel?> getCustomerByPhone(String phone) async {
    try {
      return await _customerRepository.getCustomerByPhone(phone);
    } catch (e) {
      return null;
    }
  }

  /// Get selected address for a customer
  Future<CustomerAddressModel?> getSelectedAddress(String customerId) async {
    try {
      return await _customerRepository.getSelectedAddress(customerId);
    } catch (e) {
      return null;
    }
  }

  /// Save customer to local database
  Future<void> saveCustomer(CustomerModel customer) async {
    try {
      await _customerRepository.saveCustomer(customer);
      // Reload all customers
      await loadAllCustomers();
    } catch (e) {
      rethrow;
    }
  }

  /// Delete customer from local database
  Future<void> deleteCustomer(String customerId) async {
    try {
      await _customerRepository.deleteCustomer(customerId);
      // Reload all customers
      await loadAllCustomers();
    } catch (e) {
      rethrow;
    }
  }

  /// Clear all customer data
  Future<void> clearAllData() async {
    try {
      await _customerRepository.clearAllData();
      state = [];
      _ref.read(allCustomersProvider.notifier).state = [];
      _ref.read(customerResponseProvider.notifier).state = null;
      _ref.read(selectedCustomerProvider.notifier).state = null;
      _ref.read(selectedAddressProvider.notifier).state = null;
    } catch (e) {
      rethrow;
    }
  }
}

// Provider for CustomerNotifier
final customerNotifierProvider =
    StateNotifierProvider<CustomerNotifier, List<CustomerModel>>((ref) {
  final customerRepository = ref.watch(customerRepositoryProvider);
  return CustomerNotifier(customerRepository, ref);
});
