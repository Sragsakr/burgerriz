import 'customer_model.dart';

class CustomerResponseModel {
  final List<CustomerModel> result;
  final String? targetUrl;
  final bool success;
  final String? error;
  final bool unAuthorizedRequest;
  final bool abp;

  CustomerResponseModel({
    required this.result,
    this.targetUrl,
    required this.success,
    this.error,
    required this.unAuthorizedRequest,
    required this.abp,
  });

  // Factory method to create a CustomerResponseModel object from JSON
  factory CustomerResponseModel.fromMap(Map<String, dynamic> json) {
    return CustomerResponseModel(
      result: (json['result'] as List<dynamic>?)
              ?.map((customer) => CustomerModel.fromMap(customer))
              .toList() ??
          [],
      targetUrl: json['targetUrl'],
      success: json['success'] ?? false,
      error: json['error'],
      unAuthorizedRequest: json['unAuthorizedRequest'] ?? false,
      abp: json['__abp'] ?? false,
    );
  }

  // Method to convert a CustomerResponseModel object to JSON
  Map<String, dynamic> toMap() {
    return {
      'result': result.map((customer) => customer.toMap()).toList(),
      'targetUrl': targetUrl,
      'success': success,
      'error': error,
      'unAuthorizedRequest': unAuthorizedRequest,
      '__abp': abp,
    };
  }

  CustomerResponseModel copyWith({
    List<CustomerModel>? result,
    String? targetUrl,
    bool? success,
    String? error,
    bool? unAuthorizedRequest,
    bool? abp,
  }) {
    return CustomerResponseModel(
      result: result ?? this.result,
      targetUrl: targetUrl ?? this.targetUrl,
      success: success ?? this.success,
      error: error ?? this.error,
      unAuthorizedRequest: unAuthorizedRequest ?? this.unAuthorizedRequest,
      abp: abp ?? this.abp,
    );
  }
} 