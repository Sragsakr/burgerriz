import 'customer_address_model.dart';

class CustomerModel {
  int? tableId;
  final String id;
  final String fullName;
  final String cellPhone;
  final String code;
  final double? discountPrcnt;
  final List<CustomerAddressModel> customerAddress;
  final String? fromDate;
  final String? toDate;

  CustomerModel({
    this.tableId,
    required this.id,
    required this.fullName,
    required this.cellPhone,
    required this.code,
    this.discountPrcnt,
    required this.customerAddress,
    this.fromDate,
    this.toDate,
  });

  // Factory method to create a CustomerModel object from JSON
  factory CustomerModel.fromMap(Map<String, dynamic> json) {
    return CustomerModel(
      tableId: json['tableId'],
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      cellPhone: json['cellPhone'] ?? '',
      code: json['code'] ?? '',
      discountPrcnt: json['discountPrcnt']?.toDouble(),
      customerAddress: (json['customerAddress'] as List<dynamic>?)
              ?.map((address) => CustomerAddressModel.fromMap(address))
              .toList() ??
          [],
      fromDate: json['fromDate'],
      toDate: json['toDate'],
    );
  }

  // Method to convert a CustomerModel object to JSON
  Map<String, dynamic> toMap() {
    return {
      if (tableId != null) 'tableId': tableId,
      'id': id,
      'fullName': fullName,
      'cellPhone': cellPhone,
      'code': code,
      'discountPrcnt': discountPrcnt,
      'customerAddress': customerAddress.map((address) => address.toMap()).toList(),
      'fromDate': fromDate,
      'toDate': toDate,
    };
  }

  // Method to convert to map for database operations (without nested objects)
  Map<String, dynamic> toDbMap() {
    return {
      if (tableId != null) 'tableId': tableId,
      'id': id,
      'fullName': fullName,
      'cellPhone': cellPhone,
      'code': code,
      'discountPrcnt': discountPrcnt,
      'fromDate': fromDate,
      'toDate': toDate,
    };
  }

  // Factory method to create from database map
  factory CustomerModel.fromDbMap(Map<String, dynamic> json) {
    return CustomerModel(
      tableId: json['tableId'],
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      cellPhone: json['cellPhone'] ?? '',
      code: json['code'] ?? '',
      discountPrcnt: json['discountPrcnt']?.toDouble(),
      customerAddress: [], // Addresses will be loaded separately
      fromDate: json['fromDate'],
      toDate: json['toDate'],
    );
  }

  /// Check if the customer's date range is valid (current date is within fromDate and toDate)
  bool isDateRangeValid() {
    // If no date range is set, consider it valid
    if (fromDate == null && toDate == null) {
      return true;
    }

    try {
      final now = DateTime.now();
      
      // Check fromDate
      if (fromDate != null) {
        final fromDateTime = DateTime.parse(fromDate!);
        if (now.isBefore(fromDateTime)) {
          return false;
        }
      }
      
      // Check toDate
      if (toDate != null) {
        final toDateTime = DateTime.parse(toDate!);
        if (now.isAfter(toDateTime)) {
          return false;
        }
      }
      
      return true;
    } catch (e) {
      // If date parsing fails, consider it invalid
      return false;
    }
  }

  /// Check if the customer's date range is valid for a specific date
  bool isDateRangeValidForDate(DateTime date) {
    // If no date range is set, consider it valid
    if (fromDate == null && toDate == null) {
      return true;
    }

    try {
      // Check fromDate
      if (fromDate != null) {
        final fromDateTime = DateTime.parse(fromDate!);
        if (date.isBefore(fromDateTime)) {
          return false;
        }
      }
      
      // Check toDate
      if (toDate != null) {
        final toDateTime = DateTime.parse(toDate!);
        if (date.isAfter(toDateTime)) {
          return false;
        }
      }
      
      return true;
    } catch (e) {
      // If date parsing fails, consider it invalid
      return false;
    }
  }

  CustomerModel copyWith({
    int? tableId,
    String? id,
    String? fullName,
    String? cellPhone,
    String? code,
    double? discountPrcnt,
    List<CustomerAddressModel>? customerAddress,
    String? fromDate,
    String? toDate,
  }) {
    return CustomerModel(
      tableId: tableId ?? this.tableId,
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      cellPhone: cellPhone ?? this.cellPhone,
      code: code ?? this.code,
      discountPrcnt: discountPrcnt ?? this.discountPrcnt,
      customerAddress: customerAddress ?? this.customerAddress,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
    );
  }
} 