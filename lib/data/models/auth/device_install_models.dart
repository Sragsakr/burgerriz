class ValidateInstallationInfoRequest {
  final String ipAddress;
  final int clusterId;
  final int tenderTypeId;

  const ValidateInstallationInfoRequest({
    required this.ipAddress,
    required this.clusterId,
    this.tenderTypeId = 0,
  });
}

class ValidateInstallationInfoResponse {
  final bool isValid;
  final int tenantId;
  final int storeId;
  final int deviceType;
  final String message;

  const ValidateInstallationInfoResponse({
    required this.isValid,
    required this.tenantId,
    required this.storeId,
    required this.deviceType,
    required this.message,
  });

  factory ValidateInstallationInfoResponse.fromJson(Map<String, dynamic> json) {
    return ValidateInstallationInfoResponse(
      isValid: json['isValid'] as bool? ?? false,
      tenantId: json['tenantId'] as int? ?? 0,
      storeId: json['storeId'] as int? ?? 0,
      deviceType: json['deviceType'] as int? ?? 0,
      message: json['message'] as String? ?? '',
    );
  }
}
