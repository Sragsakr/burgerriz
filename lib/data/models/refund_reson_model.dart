class RefundResonModel {
  int? tableId;
  final int id;
  final String code;
  final String description;

  RefundResonModel({
    this.tableId,
    required this.id,
    required this.code,
    required this.description,
  });

  // Factory method to create a RefundResonModel object from JSON
  factory RefundResonModel.fromMap(Map<String, dynamic> json) {
    return RefundResonModel(
      tableId: json['tableId'],
      id: json['id'],
      code: json['code'],
      description: json['description'],
    );
  }

  // Method to convert a RefundResonModel object to JSON
  Map<String, dynamic> toMap() {
    return {
      if (tableId != null) 'tableId': tableId,
      'id': id,
      'code': code,
      'description': description,
    };
  }
}

class RefundResonResponseModel {
  final List<RefundResonModel> result;
  final String? targetUrl;
  final bool success;
  final dynamic error;
  final bool unAuthorizedRequest;
  final bool abp;

  RefundResonResponseModel({
    required this.result,
    this.targetUrl,
    required this.success,
    this.error,
    required this.unAuthorizedRequest,
    required this.abp,
  });

  factory RefundResonResponseModel.fromMap(Map<String, dynamic> json) {
    return RefundResonResponseModel(
      result: (json['result'] as List)
          .map((item) => RefundResonModel.fromMap(item))
          .toList(),
      targetUrl: json['targetUrl'],
      success: json['success'],
      error: json['error'],
      unAuthorizedRequest: json['unAuthorizedRequest'],
      abp: json['__abp'],
    );
  }
}
