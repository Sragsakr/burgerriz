class AuthenticateDeviceByPinRequest {
  final String pinCode;
  final String ipAddress;
  final int clusterId;

  const AuthenticateDeviceByPinRequest({
    required this.pinCode,
    required this.ipAddress,
    required this.clusterId,
  });

  Map<String, dynamic> toJson() {
    return {
      'pinCode': pinCode,
      'ipAddress': ipAddress,
      'clusterId': clusterId,
    };
  }
}

class TenantDataModel {
  final int id;
  final String tenancyName;
  final String name;

  const TenantDataModel({
    required this.id,
    required this.tenancyName,
    required this.name,
  });

  factory TenantDataModel.fromJson(Map<String, dynamic> json) {
    return TenantDataModel(
      id: json['id'] as int? ?? 0,
      tenancyName: json['tenancyName'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }
}

class AuthenticateDeviceByPinResponse {
  final String accessToken;
  final int expireInSeconds;
  final int userId;
  final String userName;
  final int deviceStoreId;
  final int deviceType;
  final TenantDataModel tenantData;

  const AuthenticateDeviceByPinResponse({
    required this.accessToken,
    required this.expireInSeconds,
    required this.userId,
    required this.userName,
    required this.deviceStoreId,
    required this.deviceType,
    required this.tenantData,
  });

  factory AuthenticateDeviceByPinResponse.fromJson(Map<String, dynamic> json) {
    return AuthenticateDeviceByPinResponse(
      accessToken: json['accessToken'] as String? ?? '',
      expireInSeconds: json['expireInSeconds'] as int? ?? 0,
      userId: json['userId'] as int? ?? 0,
      userName: json['userName'] as String? ?? '',
      deviceStoreId: json['deviceStoreId'] as int? ?? 0,
      deviceType: json['deviceType'] as int? ?? 0,
      tenantData: TenantDataModel.fromJson(
        (json['tenantData'] as Map<String, dynamic>?) ?? {},
      ),
    );
  }
}
