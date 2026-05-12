# POSMena Install + Login — Complete Standalone Implementation Guide

**Version**: 2.0 | **Date**: 2026-05-10 | **Scope**: Install page (3 fields) + PIN Login + all supporting files

---

## Table of Contents

1. [Overview](#1-overview)
2. [User Stories & Requirements](#2-user-stories--requirements)
3. [Architecture](#3-architecture)
4. [Environment Enum](#4-environment-enum)
5. [API URLs](#5-api-urls)
6. [Data Models](#6-data-models)
7. [API Contract](#7-api-contract)
8. [Base API Service](#8-base-api-service)
9. [API Interface + Service](#9-api-interface--service)
10. [Install Validation Service](#10-install-validation-service)
11. [Device PIN Login Service](#11-device-pin-login-service)
12. [Install Controller + State](#12-install-controller--state)
13. [Login Controller + State](#13-login-controller--state)
14. [UI Components](#14-ui-components)
15. [Install Helper (Dropdown Options)](#15-install-helper-dropdown-options)
16. [AppPreferences (SharedPreferences)](#16-apppreferences-sharedpreferences)
17. [Secure Token Storage](#17-secure-token-storage)
18. [Install Widget (Full Code)](#18-install-widget-full-code)
19. [Login Widget (Full Code)](#19-login-widget-full-code)
20. [Router + Route Registration](#20-router--route-registration)
21. [Localization](#21-localization)
22. [App Assets](#22-app-assets)
23. [Failure Class](#23-failure-class)
24. [Portability Interfaces (Standalone)](#24-portability-interfaces-standalone)
25. [Standalone Repository Implementation](#25-standalone-repository-implementation)
26. [Standalone Widget (3-Field Install)](#26-standalone-widget-3-field-install)
27. [Integration Guide](#27-integration-guide)
28. [Validation Rules](#28-validation-rules)
29. [IP Auto-Detection](#29-ip-auto-detection)
30. [Success Criteria](#30-success-criteria)

---

## 1. Overview

A complete install + login flow for a POS device. The app starts unconfigured → user enters Cluster ID, IP Address, and Environment → API validates → on success, config is persisted → user is directed to PIN login → on login success, token stored → navigate to home.

**Two flows included:**

| Flow | Purpose | Fields |
|------|---------|--------|
| **Install** | First-time device setup | Cluster ID, IP Address, Environment (3 fields) |
| **Login** | PIN-based device authentication | PIN Code (1 field) |

**Key design decisions:**
- Environment is **NOT sent to the API** — resolves base URL client-side only
- API request carries `clusterId` + `ipAddress` (+ `tenderTypeId=0` for backward compat)
- Environment dropdown defaults to **Production** on fresh install
- PIN login reads `clusterId` and `ipAddress` from persisted install config

---

## 2. User Stories & Requirements

### Install Flow

| ID | Requirement |
|----|------------|
| FR-001 | Display exactly 3 fields: Cluster ID (numeric), IP Address (text), Environment (dropdown) |
| FR-002 | Environment dropdown: Production, Staging, Testing, Development, LocalHost. Default = Production |
| FR-003 | Cluster ID validated as positive integer before API submission |
| FR-004 | IP Address auto-detected from device network, remains editable |
| FR-005 | IP required when Environment is LocalHost; optional otherwise |
| FR-006 | "Validate & Save" sends clusterId + ipAddress to API; Environment resolves base URL |
| FR-007 | API returns: isValid, tenantId, storeId, deviceType, message |
| FR-008 | On success: persist clusterId, ipAddress, environment, tenantId, storeId, deviceType, installCompleted=true |
| FR-009 | On failure: show error message, preserve field values |
| FR-010 | Submit button disabled during in-flight request |
| FR-011 | Network errors shown as user-friendly messages |
| FR-012 | Pre-fill fields from stored config if exists |
| FR-013 | Environment determines base URL for API call |
| FR-014 | Feature self-contained — no host-app-specific dependencies |

### Login Flow

| ID | Requirement |
|----|------------|
| LR-001 | Display PIN Code input field with numeric keyboard |
| LR-002 | PIN must not be empty before submission |
| LR-003 | On submit: call `/api/TokenAuth/AuthenticateDeviceByPinCode` with pinCode, ipAddress, clusterId |
| LR-004 | ipAddress and clusterId read from persisted install config |
| LR-005 | If install data missing (no IP or clusterId ≤ 0), show error and redirect to install |
| LR-006 | On success: store accessToken securely, persist userId, userName, deviceStoreId, tenantData |
| LR-007 | On failure: show localized error message |
| LR-008 | PIN field uses secure input (no clipboard) |

---

## 3. Architecture

```
┌────────────────────────────────────────────────────────┐
│                    Presentation                         │
│  NewInstallWidget / StandaloneInstallWidget             │
│  NewLoginWidget                                         │
│  (ConsumerStatefulWidget)                               │
├────────────────────────────────────────────────────────┤
│                    Controllers                          │
│  NewInstallController (ChangeNotifier)                  │
│  NewLoginController (ChangeNotifier)                    │
│  — or Riverpod AsyncNotifier for new code —            │
├────────────────────────────────────────────────────────┤
│                    Services                             │
│  InstallValidationService                               │
│  DevicePinLoginService                                  │
├────────────────────────────────────────────────────────┤
│                    Data Layer                           │
│  TokenAuthApiInterface → TokenAuthApiService (Dio)     │
│  AppPreferences (SharedPreferences singleton)          │
│  SecureTokenStorage                                     │
└────────────────────────────────────────────────────────┘

Flow: Install → persist config → Login → persist token → Home
```

---

## 4. Environment Enum

```dart
enum Environment {
  LocalHost,
  Production,
  Staging,
  Testing,
  Developing,
}

extension EnvironmentExtension on Environment {
  int get value => [0, 0, 1, 2, 3][index];

  String getV1BaseUrl() {
    switch (this) {
      case Environment.LocalHost:
        return ''; // resolved from IP at runtime
      case Environment.Production:
        return 'https://posapi.posmena.com';
      case Environment.Staging:
        return 'https://stagingapi.posmena.com';
      case Environment.Testing:
        return 'https://uatapi.posmena.com';
      case Environment.Developing:
        return 'https://devapi.posmena.com';
    }
  }

  String getV2BaseUrl() {
    switch (this) {
      case Environment.LocalHost:
        return ''; // resolved from IP at runtime
      case Environment.Production:
        return 'https://food-api.posmena.com';
      case Environment.Staging:
        return 'https://staging.food-api.posmena.com';
      case Environment.Testing:
        return 'https://uat.food-api.posmena.com';
      case Environment.Developing:
        return 'https://devapi.posmena.com';
    }
  }

  String get name => toString().split('.').last;
}

Environment getEnvType(String name) {
  return Environment.values.firstWhere(
    (e) => e.name == name,
    orElse: () => Environment.Production,
  );
}
```

---

## 5. API URLs

```dart
class AppUrls {
  // Install & Auth endpoints
  static const String validateInstallationInfoUrl =
      '/api/TokenAuth/ValidateInstallationInfo';
  static const String authenticateDeviceByPinCodeUrl =
      '/api/TokenAuth/AuthenticateDeviceByPinCode';
  static const String authUrl = '/api/TokenAuth/Authenticate';
  static const String authPinCodeUrl = '/api/TokenAuth/AuthenticateByPinCode';

  // Dynamic base URL from environment
  static Future<String> getBaseUrl() async {
    final savedEnv = await AppPreferences().getEnvironmentType();
    final env = getEnvType(savedEnv);
    return env.getV2BaseUrl();
  }
}
```

---

## 6. Data Models

### ValidateInstallationInfoRequest

```dart
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
```

### ValidateInstallationInfoResponse

```dart
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
```

### AuthenticateDeviceByPinRequest

```dart
class AuthenticateDeviceByPinRequest {
  final String pinCode;
  final String ipAddress;
  final int clusterId;

  const AuthenticateDeviceByPinRequest({
    required this.pinCode,
    required this.ipAddress,
    required this.clusterId,
  });

  Map<String, dynamic> toJson() => {
    'pinCode': pinCode,
    'ipAddress': ipAddress,
    'clusterId': clusterId,
  };
}
```

### TenantDataModel

```dart
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
```

### AuthenticateDeviceByPinResponse

```dart
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
```

### InstallConfigModel (for standalone feature)

```dart
class InstallConfigModel {
  final int clusterId;
  final String ipAddress;
  final String environment;
  final int tenantId;
  final int storeId;
  final int deviceType;
  final bool installCompleted;

  const InstallConfigModel({
    required this.clusterId,
    required this.ipAddress,
    required this.environment,
    required this.tenantId,
    required this.storeId,
    required this.deviceType,
    required this.installCompleted,
  });

  InstallConfigModel copyWith({
    int? clusterId, String? ipAddress, String? environment,
    int? tenantId, int? storeId, int? deviceType, bool? installCompleted,
  }) {
    return InstallConfigModel(
      clusterId: clusterId ?? this.clusterId,
      ipAddress: ipAddress ?? this.ipAddress,
      environment: environment ?? this.environment,
      tenantId: tenantId ?? this.tenantId,
      storeId: storeId ?? this.storeId,
      deviceType: deviceType ?? this.deviceType,
      installCompleted: installCompleted ?? this.installCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
    'clusterId': clusterId, 'ipAddress': ipAddress, 'environment': environment,
    'tenantId': tenantId, 'storeId': storeId, 'deviceType': deviceType,
    'installCompleted': installCompleted,
  };

  factory InstallConfigModel.fromJson(Map<String, dynamic> json) {
    return InstallConfigModel(
      clusterId: json['clusterId'] as int? ?? 0,
      ipAddress: json['ipAddress'] as String? ?? '',
      environment: json['environment'] as String? ?? 'Production',
      tenantId: json['tenantId'] as int? ?? 0,
      storeId: json['storeId'] as int? ?? 0,
      deviceType: json['deviceType'] as int? ?? 0,
      installCompleted: json['installCompleted'] as bool? ?? false,
    );
  }
}
```

---

## 7. API Contract

### Validate Installation Info

```
GET {baseUrl}/api/TokenAuth/ValidateInstallationInfo
```

| Query Param | Type | Required | Default |
|-------------|------|----------|---------|
| `ipAddress` | string | yes | — |
| `clusterId` | integer | yes | — |
| `tenderTypeId` | integer | no | `0` |

**Success Response:**
```json
{ "isValid": true, "tenantId": 1, "storeId": 42, "deviceType": 2, "message": "" }
```

**Failure Response:**
```json
{ "isValid": false, "tenantId": 0, "storeId": 0, "deviceType": 0, "message": "Cluster not found" }
```

**Response unwrapping**: API may wrap in `{"result": {...}}` — extract `result` if present.

### Authenticate Device By PIN

```
POST {baseUrl}/api/TokenAuth/AuthenticateDeviceByPinCode
```

**Request Body:**
```json
{ "pinCode": "1234", "ipAddress": "192.168.1.100", "clusterId": 5 }
```

**Success Response:**
```json
{
  "accessToken": "eyJ...",
  "expireInSeconds": 86400,
  "userId": 10,
  "userName": "Cashier1",
  "deviceStoreId": 42,
  "deviceType": 2,
  "tenantData": { "id": 1, "tenancyName": "Default", "name": "My Restaurant" }
}
```

**Tenant ID header**: If `tenantId` is stored, set `abp.tenantId` header on both endpoints.

---

## 8. Base API Service

```dart
import 'package:dio/dio.dart';

abstract class BaseApiInterface {
  Dio get dio;
  String get baseUrl;
  Map<String, String> get defaultHeaders;
  Future<void> initialize();
  Future<void> handleError(DioException error);
  Future<void> addAuthToken(String token);
  Future<void> removeAuthToken();
  Future<Response<T>> get<T>(String path, {
    Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken,
  });
  Future<Response<T>> post<T>(String path, {
    dynamic data, Map<String, dynamic>? queryParameters,
    Options? options, CancelToken? cancelToken,
  });
  Future<Response<T>> put<T>(String path, {
    dynamic data, Map<String, dynamic>? queryParameters,
    Options? options, CancelToken? cancelToken,
  });
  Future<Response<T>> delete<T>(String path, {
    dynamic data, Map<String, dynamic>? queryParameters,
    Options? options, CancelToken? cancelToken,
  });
}

abstract class BaseApiService implements BaseApiInterface {
  late final Dio _dio;
  bool _dioInitialized = false;
  final String _baseUrl;
  final Map<String, String> _defaultHeaders;

  BaseApiService({required String baseUrl, Map<String, String>? defaultHeaders})
      : _baseUrl = baseUrl, _defaultHeaders = defaultHeaders ?? {};

  @override
  Dio get dio => _dio;
  @override
  String get baseUrl => _baseUrl;
  @override
  Map<String, String> get defaultHeaders => _defaultHeaders;

  @override
  Future<void> initialize() async {
    if (_dioInitialized) return;
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      headers: _defaultHeaders,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
    ));
    // Add your interceptors here (logging, error handling, etc.)
    _dioInitialized = true;
  }

  @override
  Future<void> handleError(DioException error) async {
    if (error.response?.statusCode == 401) await removeAuthToken();
  }

  @override
  Future<void> addAuthToken(String token) async {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  @override
  Future<void> removeAuthToken() async {
    _dio.options.headers.remove('Authorization');
  }

  @override
  Future<Response<T>> get<T>(String path, {
    Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken,
  }) => _dio.get<T>(path, queryParameters: queryParameters, options: options, cancelToken: cancelToken);

  @override
  Future<Response<T>> post<T>(String path, {
    dynamic data, Map<String, dynamic>? queryParameters,
    Options? options, CancelToken? cancelToken,
  }) => _dio.post<T>(path, data: data, queryParameters: queryParameters, options: options, cancelToken: cancelToken);

  @override
  Future<Response<T>> put<T>(String path, {
    dynamic data, Map<String, dynamic>? queryParameters,
    Options? options, CancelToken? cancelToken,
  }) => _dio.put<T>(path, data: data, queryParameters: queryParameters, options: options, cancelToken: cancelToken);

  @override
  Future<Response<T>> delete<T>(String path, {
    dynamic data, Map<String, dynamic>? queryParameters,
    Options? options, CancelToken? cancelToken,
  }) => _dio.delete<T>(path, data: data, queryParameters: queryParameters, options: options, cancelToken: cancelToken);
}
```

---

## 9. API Interface + Service

### TokenAuthApiInterface

```dart
abstract class TokenAuthApiInterface {
  Future<void> initialize();

  Future<ValidateInstallationInfoResponse> validateInstallationInfo({
    required ValidateInstallationInfoRequest request,
  });

  Future<AuthenticateDeviceByPinResponse> authenticateDeviceByPinCode({
    required AuthenticateDeviceByPinRequest request,
  });
}
```

### TokenAuthApiService

```dart
class TokenAuthApiService extends BaseApiService implements TokenAuthApiInterface {
  late String _baseUrl;

  TokenAuthApiService()
      : super(baseUrl: '', defaultHeaders: {'Content-Type': 'application/json'});

  @override
  Future<void> initialize() async {
    _baseUrl = await AppUrls.getBaseUrl();
    await super.initialize();
  }

  @override
  Future<ValidateInstallationInfoResponse> validateInstallationInfo({
    required ValidateInstallationInfoRequest request,
  }) async {
    final tenantId = await AppPreferences().getTenant();
    if (tenantId.isNotEmpty) {
      dio.options.headers['abp.tenantId'] = tenantId;
    }
    try {
      final response = await get<Map<String, dynamic>>(
        _baseUrl + AppUrls.validateInstallationInfoUrl,
        queryParameters: {
          'ipAddress': request.ipAddress,
          'clusterId': request.clusterId,
          'tenderTypeId': request.tenderTypeId,
        },
      );
      final body = response.data ?? {};
      final result = (body['result'] as Map<String, dynamic>?) ?? body;
      return ValidateInstallationInfoResponse.fromJson(result);
    } on DioException catch (e) {
      throw Exception('ValidateInstallationInfo failed: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<AuthenticateDeviceByPinResponse> authenticateDeviceByPinCode({
    required AuthenticateDeviceByPinRequest request,
  }) async {
    try {
      final tenantId = await AppPreferences().getTenant();
      if (tenantId.isNotEmpty) {
        dio.options.headers['abp.tenantId'] = tenantId;
      }
      final response = await post<Map<String, dynamic>>(
        _baseUrl + AppUrls.authenticateDeviceByPinCodeUrl,
        data: request.toJson(),
      );
      final body = response.data ?? {};
      final result = (body['result'] as Map<String, dynamic>?) ?? body;
      return AuthenticateDeviceByPinResponse.fromJson(result);
    } on DioException catch (e) {
      throw Exception('AuthenticateDeviceByPinCode failed: ${e.response?.data ?? e.message}');
    }
  }
}
```

---

## 10. Install Validation Service

```dart
class InstallValidationService {
  final TokenAuthApiInterface _tokenAuthApiService;

  InstallValidationService({TokenAuthApiInterface? tokenAuthApiService})
      : _tokenAuthApiService = tokenAuthApiService ?? TokenAuthApiService();

  Future<ValidateInstallationInfoResponse> validateAndPersist({
    required String ipAddress,
    required int clusterId,
    required String environment,
    required String firstLanguageCode,
    required String secondLanguageCode,
    required String syncInterval,
    required String tenderType,
  }) async {
    final pref = AppPreferences();
    await pref.setEnvironmentType(environment);
    await pref.setIp(ipAddress);

    await _tokenAuthApiService.initialize();
    final response = await _tokenAuthApiService.validateInstallationInfo(
      request: ValidateInstallationInfoRequest(
        ipAddress: ipAddress,
        clusterId: clusterId,
        tenderTypeId: int.tryParse(tenderType) ?? 0,
      ),
    );

    if (response.isValid) {
      await pref.setLanguage(firstLanguageCode);
      await pref.setSecLanguage(secondLanguageCode);
      await pref.setSyncInterval(syncInterval);
      await pref.setTenderType(tenderType);
      await pref.setClusterId(clusterId);
      await pref.setInstallTenantId(response.tenantId);
      await pref.setInstallStoreId(response.storeId);
      await pref.setInstallDeviceType(response.deviceType);
      await pref.setInstallCompleted(true);
      await pref.setTenant(response.tenantId.toString());
      await pref.setStore(response.storeId.toString());
    }

    return response;
  }
}
```

---

## 11. Device PIN Login Service

```dart
class DevicePinLoginService {
  final TokenAuthApiService _tokenAuthApiService;
  final SecureTokenStorage _secureTokenStorage;

  DevicePinLoginService({
    TokenAuthApiService? tokenAuthApiService,
    SecureTokenStorage? secureTokenStorage,
  })  : _tokenAuthApiService = tokenAuthApiService ?? TokenAuthApiService(),
        _secureTokenStorage = secureTokenStorage ?? SecureTokenStorage();

  Future<AuthenticateDeviceByPinResponse> authenticate({
    required String pinCode,
  }) async {
    final pref = AppPreferences();
    final ipAddress = await pref.getIp();
    final clusterId = await pref.getClusterId();

    if (ipAddress.isEmpty || clusterId <= 0) {
      throw Exception('Installation data is missing');
    }

    await _tokenAuthApiService.initialize();
    final response = await _tokenAuthApiService.authenticateDeviceByPinCode(
      request: AuthenticateDeviceByPinRequest(
        pinCode: pinCode,
        ipAddress: ipAddress,
        clusterId: clusterId,
      ),
    );

    await _secureTokenStorage.saveAccessToken(response.accessToken);
    await pref.setExpireInSeconds(response.expireInSeconds);
    await pref.setLoginUserId(response.userId);
    await pref.setLoginUserName(response.userName);
    await pref.setUsername(response.userName);
    await pref.setDeviceStoreId(response.deviceStoreId);
    await pref.setInstallDeviceType(response.deviceType);
    await pref.setTenantDataId(response.tenantData.id);
    await pref.setTenantDataTenancyName(response.tenantData.tenancyName);
    await pref.setTenantDataName(response.tenantData.name);
    await pref.setTenant(response.tenantData.id.toString());
    return response;
  }
}
```

---

## 12. Install Controller + State

### NewInstallState

```dart
class NewInstallState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  const NewInstallState({this.isLoading = false, this.errorMessage, this.isSuccess = false});

  NewInstallState copyWith({bool? isLoading, String? errorMessage, bool? isSuccess}) {
    return NewInstallState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}
```

### NewInstallController

```dart
class NewInstallController extends ChangeNotifier {
  final InstallValidationService _installValidationService;

  NewInstallState _state = const NewInstallState();
  NewInstallState get state => _state;

  NewInstallController({InstallValidationService? installValidationService})
      : _installValidationService = installValidationService ?? InstallValidationService();

  Future<bool> submit({
    required String ipAddress,
    required int clusterId,
    required String environment,
    required String firstLanguageCode,
    required String secondLanguageCode,
    required String syncInterval,
    required String tenderType,
    String Function(String key)? localizeKey,
  }) async {
    _state = _state.copyWith(isLoading: true, errorMessage: null);
    notifyListeners();

    try {
      final response = await _installValidationService.validateAndPersist(
        ipAddress: ipAddress,
        clusterId: clusterId,
        environment: environment,
        firstLanguageCode: firstLanguageCode,
        secondLanguageCode: secondLanguageCode,
        syncInterval: syncInterval,
        tenderType: tenderType,
      );

      if (!response.isValid) {
        final fallback = localizeKey?.call('auth_flow_install_validation_failed') ?? 'Installation validation failed';
        _state = _state.copyWith(
          isLoading: false,
          isSuccess: false,
          errorMessage: response.message.isEmpty ? fallback : response.message,
        );
        notifyListeners();
        return false;
      }

      _state = _state.copyWith(isLoading: false, isSuccess: true);
      notifyListeners();
      return true;
    } catch (e) {
      _state = _state.copyWith(isLoading: false, isSuccess: false, errorMessage: e.toString());
      notifyListeners();
      return false;
    }
  }
}
```

---

## 13. Login Controller + State

### NewLoginState

```dart
class NewLoginState {
  final bool isLoading;
  final String? errorMessage;

  const NewLoginState({this.isLoading = false, this.errorMessage});

  NewLoginState copyWith({bool? isLoading, String? errorMessage}) {
    return NewLoginState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}
```

### NewLoginController

```dart
class NewLoginController extends ChangeNotifier {
  final DevicePinLoginService _devicePinLoginService;

  NewLoginState _state = const NewLoginState();
  NewLoginState get state => _state;

  NewLoginController({DevicePinLoginService? devicePinLoginService})
      : _devicePinLoginService = devicePinLoginService ?? DevicePinLoginService();

  Future<bool> login(String pin, String Function(String key) localize) async {
    if (pin.trim().isEmpty) {
      _state = _state.copyWith(errorMessage: localize('auth_flow_error_pin_required'));
      notifyListeners();
      return false;
    }

    _state = _state.copyWith(isLoading: true, errorMessage: null);
    notifyListeners();

    try {
      await _devicePinLoginService.authenticate(pinCode: pin.trim());
      _state = _state.copyWith(isLoading: false, errorMessage: null);
      notifyListeners();
      return true;
    } catch (e) {
      var msg = e.toString();
      if (msg.contains('Online authentication is required')) {
        msg = localize('auth_flow_error_online_required');
      } else if (msg.contains('Installation data is missing')) {
        msg = localize('auth_flow_error_install_missing');
      }
      _state = _state.copyWith(isLoading: false, errorMessage: msg);
      notifyListeners();
      return false;
    }
  }
}
```

---

## 14. UI Components

### FormFieldController

```dart
import 'package:flutter/foundation.dart';

class FormFieldController<T> extends ValueNotifier<T?> {
  FormFieldController(this.initialValue) : super(initialValue);
  final T? initialValue;
  void reset() => value = initialValue;
  void update() => notifyListeners();
}
```

### InstallFormField

```dart
class InstallFormField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? hintText;
  final String? labelText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final bool autofocus;
  final EdgeInsetsGeometry? padding;
  final bool enabled;
  final bool readOnly;

  const InstallFormField({
    super.key,
    required this.controller,
    required this.focusNode,
    this.hintText,
    this.labelText,
    this.keyboardType,
    this.validator,
    this.inputFormatters,
    this.obscureText = false,
    this.autofocus = true,
    this.padding,
    this.enabled = true,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: padding ?? const EdgeInsetsDirectional.fromSTEB(0, 12, 0, 12),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        obscureText: obscureText,
        enabled: enabled,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.35), width: 1.4),
            borderRadius: BorderRadius.circular(16),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colorScheme.error, width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colorScheme.error, width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        keyboardType: keyboardType,
        validator: validator,
        inputFormatters: inputFormatters,
      ),
    );
  }
}

class InstallFormFieldFactory {
  static InstallFormField clusterId({
    required TextEditingController controller,
    required FocusNode focusNode,
    String? Function(String?)? validator,
  }) {
    return InstallFormField(
      controller: controller,
      focusNode: focusNode,
      hintText: translator(arText: 'معرّف العنقود', enText: 'Cluster ID'),
      keyboardType: const TextInputType.numberWithOptions(decimal: false),
      validator: validator,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9]'))],
    );
  }

  static InstallFormField ipAddress({
    required TextEditingController controller,
    required FocusNode focusNode,
    String? Function(String?)? validator,
    bool readOnly = false,
  }) {
    return InstallFormField(
      readOnly: readOnly,
      controller: controller,
      focusNode: focusNode,
      hintText: translator(arText: 'عنوان IP', enText: 'IP Address'),
      keyboardType: TextInputType.url,
      validator: validator,
    );
  }

  static InstallFormField tenderType({
    required TextEditingController controller,
    required FocusNode focusNode,
    String? Function(String?)? validator,
  }) {
    return InstallFormField(
      controller: controller,
      focusNode: focusNode,
      hintText: '0',
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: validator,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9]'))],
    );
  }

  static InstallFormField syncInterval({
    required TextEditingController controller,
    required FocusNode focusNode,
    String? Function(String?)? validator,
  }) {
    return InstallFormField(
      controller: controller,
      focusNode: focusNode,
      hintText: translator(arText: 'المدة', enText: 'Sync Interval'),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: validator,
    );
  }
}
```

### InstallOptionDropdown

```dart
class InstallOptionDropdown extends StatelessWidget {
  final FormFieldController<InstallOptionModel> controller;
  final List<InstallOptionModel> options;
  final String? hintText;
  final Function(InstallOptionModel?)? onChanged;
  final double? width;
  final double height;

  const InstallOptionDropdown({
    super.key,
    required this.controller,
    required this.options,
    this.hintText,
    this.onChanged,
    this.width,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 12, 0, 12),
      child: DropdownButtonFormField<InstallOptionModel>(
        value: controller.value,
        items: options.map((option) => DropdownMenuItem(
          value: option,
          child: Text(translator(arText: option.nameLoalized, enText: option.name)),
        )).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

class InstallOptionDropdownFactory {
  static InstallOptionDropdown environment({
    required FormFieldController<InstallOptionModel> controller,
    required List<InstallOptionModel> options,
    Function(InstallOptionModel?)? onChanged,
    String? hintText,
  }) {
    return InstallOptionDropdown(
      controller: controller,
      options: options,
      onChanged: onChanged,
      hintText: hintText ?? translator(arText: 'اختر البيئة', enText: 'Select Environment'),
    );
  }

  static InstallOptionDropdown language({
    required FormFieldController<InstallOptionModel> controller,
    required List<InstallOptionModel> options,
    Function(InstallOptionModel?)? onChanged,
    String? hintText,
  }) {
    return InstallOptionDropdown(
      controller: controller,
      options: options,
      onChanged: onChanged,
      hintText: hintText ?? translator(arText: 'اختر اللغة', enText: 'Select Language'),
    );
  }
}
```

> **Note**: The original POSMena code uses `FlutterFlowDropDown<InstallOptionModel>` from `dropdown_button2`. The simplified version above uses Flutter's built-in `DropdownButtonFormField`. Use whichever fits your app.

---

## 15. Install Helper (Dropdown Options)

```dart
class InstallOptionModel {
  final String name;
  final String nameLoalized; // "nameLocalized" (typo preserved from original)
  final String value;

  InstallOptionModel({required this.name, required this.nameLoalized, required this.value});
}

List<InstallOptionModel> languageOptions = [
  InstallOptionModel(name: 'Arabic', nameLoalized: 'العربية', value: 'ar'),
  InstallOptionModel(name: 'English', nameLoalized: 'الإنجليزية', value: 'en'),
];

List<InstallOptionModel> naturalOptions = [
  InstallOptionModel(name: 'Local Host', nameLoalized: 'محلي', value: 'LocalHost'),
  InstallOptionModel(name: 'Production', nameLoalized: 'إنتاج', value: 'Production'),
  InstallOptionModel(name: 'Staging', nameLoalized: 'تحضير', value: 'Staging'),
  InstallOptionModel(name: 'Testing', nameLoalized: 'اختبار', value: 'Testing'),
  InstallOptionModel(name: 'Developing', nameLoalized: 'تطوير', value: 'Developing'),
];
```

---

## 16. AppPreferences (SharedPreferences)

```dart
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static final AppPreferences _instance = AppPreferences._internal();
  SharedPreferences? _prefs;

  AppPreferences._internal();
  factory AppPreferences() => _instance;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs => _prefs!;

  Future<void> _setValue<T>(String key, T value) async {
    if (value is String) await _prefs!.setString(key, value);
    if (value is int) await _prefs!.setInt(key, value);
    if (value is double) await _prefs!.setDouble(key, value);
    if (value is bool) await _prefs!.setBool(key, value);
    if (value is List<String>) await _prefs!.setStringList(key, value);
  }

  Future<T> _getValue<T>(String key, T defaultValue) async {
    final value = _prefs!.get(key);
    return (value is T) ? value : defaultValue;
  }

  // ——— Install-related keys ———

  Future<String> getIp() async => _getValue('IP', '');
  Future<void> setIp(String v) async => _setValue('IP', v);

  Future<int> getClusterId() async => _getValue('clusterId', 0);
  Future<void> setClusterId(int v) async => _setValue('clusterId', v);

  Future<String> getEnvironmentType() async => _getValue('EnvironmentType', '');
  Future<void> setEnvironmentType(String v) async => _setValue('EnvironmentType', v);

  Future<bool> getInstallCompleted() async => _getValue('installCompleted', false);
  Future<void> setInstallCompleted(bool v) async => _setValue('installCompleted', v);

  Future<int> getInstallTenantId() async => _getValue('installTenantId', 0);
  Future<void> setInstallTenantId(int v) async => _setValue('installTenantId', v);

  Future<int> getInstallStoreId() async => _getValue('installStoreId', 0);
  Future<void> setInstallStoreId(int v) async => _setValue('installStoreId', v);

  Future<int> getInstallDeviceType() async => _getValue('installDeviceType', 0);
  Future<void> setInstallDeviceType(int v) async => _setValue('installDeviceType', v);

  // ——— Login-related keys ———

  Future<String> getAccessToken() async => _getValue('accessToken', '');
  Future<void> setAccessToken(String v) async => _setValue('accessToken', v);

  Future<int> getExpireInSeconds() async => _getValue('expireInSeconds', 0);
  Future<void> setExpireInSeconds(int v) async => _setValue('expireInSeconds', v);

  Future<int> getLoginUserId() async => _getValue('loginUserId', 0);
  Future<void> setLoginUserId(int v) async => _setValue('loginUserId', v);

  Future<String> getLoginUserName() async => _getValue('loginUserName', '');
  Future<void> setLoginUserName(String v) async => _setValue('loginUserName', v);

  Future<String> getUsername() async => _getValue('username', '');
  Future<void> setUsername(String v) async => _setValue('username', v);

  Future<int> getDeviceStoreId() async => _getValue('deviceStoreId', 0);
  Future<void> setDeviceStoreId(int v) async => _setValue('deviceStoreId', v);

  Future<int> getTenantDataId() async => _getValue('tenantDataId', 0);
  Future<void> setTenantDataId(int v) async => _setValue('tenantDataId', v);

  Future<String> getTenantDataTenancyName() async => _getValue('tenantDataTenancyName', '');
  Future<void> setTenantDataTenancyName(String v) async => _setValue('tenantDataTenancyName', v);

  Future<String> getTenantDataName() async => _getValue('tenantDataName', '');
  Future<void> setTenantDataName(String v) async => _setValue('tenantDataName', v);

  Future<String> getTenant() async => _getValue('tenant', '');
  Future<void> setTenant(String v) async => _setValue('tenant', v);

  Future<String> getStore() async => _getValue('store', '');
  Future<void> setStore(String v) async => _setValue('store', v);

  Future<String> getLanguage() async => _getValue('language', 'en');
  Future<void> setLanguage(String v) async => _setValue('language', v);

  Future<String> getSecLanguage() async => _getValue('Seclanguage', '');
  Future<void> setSecLanguage(String v) async => _setValue('Seclanguage', v);

  Future<String> getSyncInterval() async => _getValue('syncInterval', '0');
  Future<void> setSyncInterval(String v) async => _setValue('syncInterval', v);

  Future<String> getTenderType() async => _getValue('tenderType', '');
  Future<void> setTenderType(String v) async => _setValue('tenderType', v);

  Future<int> getCurrentInvoice() async => _getValue('currentInvoice', 0);
  Future<void> setCurrentInvoice(int v) async => _setValue('currentInvoice', v);

  Future<int> getCashierId() async => _getValue('cashierId', 0);
  Future<void> setCashierId(int v) async => _setValue('cashierId', v);
}
```

---

## 17. Secure Token Storage

```dart
class SecureTokenStorage {
  Future<void> saveAccessToken(String token) async {
    await AppPreferences().setAccessToken(token);
  }

  Future<String> getAccessToken() async {
    return AppPreferences().getAccessToken();
  }

  Future<void> clearAccessToken() async {
    await AppPreferences().setAccessToken('');
  }
}
```

---

## 18. Install Widget (Full Code)

```dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class NewInstallWidget extends ConsumerStatefulWidget {
  static const routeName = 'NewInstall';
  static const routePath = '/install-v2';

  final NewInstallController? controller;

  const NewInstallWidget({super.key, this.controller});

  @override
  ConsumerState<NewInstallWidget> createState() => _NewInstallWidgetState();
}

class _NewInstallWidgetState extends ConsumerState<NewInstallWidget> {
  late final NewInstallController _controller;
  late final bool _ownsController;
  final _formKey = GlobalKey<FormState>();

  final _ipController = TextEditingController();
  final _ipFocusNode = FocusNode();
  final _clusterController = TextEditingController();
  final _clusterFocusNode = FocusNode();
  final _tenderTypeController = TextEditingController();
  final _tenderTypeFocusNode = FocusNode();
  final _syncController = TextEditingController();
  final _syncFocusNode = FocusNode();

  late final FormFieldController<InstallOptionModel> _firstLangController;
  late final FormFieldController<InstallOptionModel> _secondLangController;
  late final FormFieldController<InstallOptionModel> _environmentController;

  bool _ipLookupDone = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
      _ownsController = false;
    } else {
      _controller = NewInstallController();
      _ownsController = true;
    }

    _firstLangController = FormFieldController<InstallOptionModel>(
      languageOptions.firstWhere((o) => o.value == 'en', orElse: () => languageOptions.first),
    );
    _secondLangController = FormFieldController<InstallOptionModel>(
      languageOptions.firstWhere((o) => o.value == 'ar', orElse: () => languageOptions.last),
    );
    _environmentController = FormFieldController<InstallOptionModel>(
      naturalOptions.firstWhere((o) => o.value == 'Production', orElse: () => naturalOptions.first),
    );
    _syncController.text = '0';

    WidgetsBinding.instance.addPostFrameCallback((_) => _hydrateFromPrefs());
    _loadIp();
  }

  Future<void> _hydrateFromPrefs() async {
    final p = AppPreferences();
    final lang = await p.getLanguage();
    final sec = await p.getSecLanguage();
    final sync = await p.getSyncInterval();
    final tenderType = await p.getTenderType();
    final env = await p.getEnvironmentType();
    final clusterId = await p.getClusterId();

    if (!mounted) return;
    setState(() {
      _firstLangController.value = languageOptions.firstWhere(
        (e) => e.value == lang, orElse: () => languageOptions.first,
      );
      if (sec.isNotEmpty) {
        _secondLangController.value = languageOptions.firstWhere(
          (e) => e.value == sec, orElse: () => languageOptions.last,
        );
      }
      if (sync.isNotEmpty) _syncController.text = sync;
      if (tenderType.isNotEmpty) _tenderTypeController.text = tenderType;
      if (env.isNotEmpty) {
        _environmentController.value = naturalOptions.firstWhere(
          (e) => e.value == env, orElse: () => naturalOptions.first,
        );
      }
      if (clusterId > 0) _clusterController.text = clusterId.toString();
    });
  }

  Future<void> _loadIp() async {
    String ip = '';
    try {
      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.IPv4,
      );
      ip = interfaces
          .expand((e) => e.addresses)
          .map((e) => e.address)
          .firstWhere((e) => e.isNotEmpty, orElse: () => '');
    } catch (_) {
      ip = '';
    }
    if (!mounted) return;
    setState(() {
      _ipLookupDone = true;
      _ipController.text = ip;
    });
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    _firstLangController.dispose();
    _secondLangController.dispose();
    _environmentController.dispose();
    _ipController.dispose();
    _ipFocusNode.dispose();
    _clusterController.dispose();
    _clusterFocusNode.dispose();
    _tenderTypeController.dispose();
    _tenderTypeFocusNode.dispose();
    _syncController.dispose();
    _syncFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        translator(arText: 'تثبيت الجهاز', enText: 'Install Device'),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 24),

                      // Cluster ID
                      InstallFormFieldFactory.clusterId(
                        controller: _clusterController,
                        focusNode: _clusterFocusNode,
                        validator: (v) {
                          final id = int.tryParse(v ?? '') ?? 0;
                          if (id <= 0) return translator(arText: 'يجب ملء جميع البيانات', enText: 'All fields are required');
                          return null;
                        },
                      ),

                      // IP Address
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: InstallFormFieldFactory.ipAddress(
                              controller: _ipController,
                              focusNode: _ipFocusNode,
                              readOnly: true,
                              validator: (v) {
                                if ((v ?? '').trim().isEmpty) {
                                  return translator(arText: 'تعذّر اكتشاف عنوان IP', enText: 'Could not detect IP');
                                }
                                return null;
                              },
                            ),
                          ),
                          if (!_ipLookupDone)
                            Padding(
                              padding: const EdgeInsets.only(left: 8, top: 24),
                              child: SizedBox(
                                width: 22, height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                        ],
                      ),

                      // Sync Interval
                      InstallFormFieldFactory.syncInterval(
                        controller: _syncController,
                        focusNode: _syncFocusNode,
                        validator: (v) {
                          final s = (v ?? '').trim();
                          if (s.isEmpty || int.tryParse(s) == null) {
                            return translator(arText: 'يجب ملء جميع البيانات', enText: 'All fields are required');
                          }
                          return null;
                        },
                      ),

                      // Tender Type
                      InstallFormFieldFactory.tenderType(
                        controller: _tenderTypeController,
                        focusNode: _tenderTypeFocusNode,
                        validator: (v) {
                          final t = (v ?? '').trim();
                          if (t.isEmpty || int.tryParse(t) == null) {
                            return translator(arText: 'يجب ملء جميع البيانات', enText: 'All fields are required');
                          }
                          return null;
                        },
                      ),

                      // Environment
                      InstallOptionDropdownFactory.environment(
                        controller: _environmentController,
                        options: naturalOptions,
                        onChanged: (_) => setState(() {}),
                      ),

                      // Languages
                      InstallOptionDropdownFactory.language(
                        controller: _firstLangController,
                        options: languageOptions,
                        onChanged: (_) => setState(() {}),
                      ),
                      InstallOptionDropdownFactory.language(
                        controller: _secondLangController,
                        options: languageOptions,
                        onChanged: (_) => setState(() {}),
                      ),

                      // Error
                      if (_controller.state.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _controller.state.errorMessage!,
                            style: TextStyle(color: Theme.of(context).colorScheme.error),
                          ),
                        ),

                      const SizedBox(height: 24),

                      // Submit
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _controller.state.isLoading ? null : () async {
                            if (!(_formKey.currentState?.validate() ?? false)) return;
                            final ok = await _controller.submit(
                              ipAddress: _ipController.text.trim(),
                              clusterId: int.tryParse(_clusterController.text.trim()) ?? 0,
                              environment: _environmentController.value?.value ?? 'Production',
                              firstLanguageCode: _firstLangController.value?.value ?? 'en',
                              secondLanguageCode: _secondLangController.value?.value ?? 'ar',
                              syncInterval: _syncController.text.trim(),
                              tenderType: _tenderTypeController.text.trim(),
                            );
                            if (ok && context.mounted) {
                              context.go(NewLoginWidget.routePath);
                            }
                          },
                          child: _controller.state.isLoading
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : Text(translator(arText: 'تحقق ومتابعة', enText: 'Validate & Continue')),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
```

---

## 19. Login Widget (Full Code)

```dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class NewLoginWidget extends ConsumerStatefulWidget {
  static const routeName = 'NewLogin';
  static const routePath = '/login-v2';

  final NewLoginController? controller;

  const NewLoginWidget({super.key, this.controller});

  @override
  ConsumerState<NewLoginWidget> createState() => _NewLoginWidgetState();
}

class _NewLoginWidgetState extends ConsumerState<NewLoginWidget> {
  late final NewLoginController _controller;
  late final bool _ownsController;
  final _pinFocusNode = FocusNode();
  final _pinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
      _ownsController = false;
    } else {
      _controller = NewLoginController();
      _ownsController = true;
    }
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    _pinFocusNode.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    FocusScope.of(context).unfocus();
    final ok = await _controller.login(_pinController.text, (key) {
      // Simple localization lookup — replace with your app's mechanism
      switch (key) {
        case 'auth_flow_error_pin_required': return translator(arText: 'رمز PIN مطلوب', enText: 'PIN is required');
        case 'auth_flow_error_online_required': return translator(arText: 'يلزم الاتصال بالإنترنت', enText: 'Online authentication is required');
        case 'auth_flow_error_install_missing': return translator(arText: 'بيانات التثبيت غير متوفرة', enText: 'Installation data is missing');
        default: return key;
      }
    });

    if (!context.mounted) return;
    if (!ok) {
      final msg = _controller.state.errorMessage;
      if (msg != null && msg.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
      return;
    }

    // Navigate to home after successful login
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Scaffold(
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        translator(arText: 'مرحباً', enText: 'Welcome'),
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      Text(
                        translator(arText: 'إلى نقطة البيع', enText: 'To POINT OF SALE'),
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        translator(arText: 'أدخل رمز PIN أو اضغط خروج', enText: 'Enter the agent pincode or Use Exit'),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: TextFormField(
                          controller: _pinController,
                          focusNode: _pinFocusNode,
                          autofocus: true,
                          obscureText: false,
                          decoration: InputDecoration(
                            labelText: translator(arText: 'رمز PIN', enText: 'Agent PIN Code...'),
                            suffixIcon: const Icon(Icons.calculate),
                            border: UnderlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.outline,
                                width: 2,
                              ),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9]'))],
                          onFieldSubmitted: (_) => _submitLogin(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (_controller.state.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            _controller.state.errorMessage!,
                            style: TextStyle(color: Theme.of(context).colorScheme.error),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _controller.state.isLoading ? null : _submitLogin,
                          child: _controller.state.isLoading
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : Text(translator(arText: 'تسجيل الدخول', enText: 'Login')),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => exit(0),
                        child: Text(translator(arText: 'خروج', enText: 'Exit')),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
```

---

## 20. Router + Route Registration

### AppRoutes

```dart
abstract final class AppRoutes {
  static const String install = '/install-kiosk';
  static const String installV2 = '/install-v2';
  static const String login = '/login';
  static const String loginV2 = '/login-v2';
  static const String home = '/home';
  // ... add more routes as needed
}
```

### Router Setup (GoRouter)

```dart
import 'package:go_router/go_router.dart';

final router = GoRouter(
  initialLocation: AppRoutes.installV2,
  routes: [
    GoRoute(
      path: NewInstallWidget.routePath,        // '/install-v2'
      name: NewInstallWidget.routeName,         // 'NewInstall'
      builder: (context, state) => PopScope(
        canPop: false,
        child: NewInstallWidget(),
      ),
    ),
    GoRoute(
      path: NewLoginWidget.routePath,           // '/login-v2'
      name: NewLoginWidget.routeName,            // 'NewLogin'
      builder: (context, state) => PopScope(
        canPop: false,
        child: NewLoginWidget(),
      ),
    ),
    GoRoute(
      path: AppRoutes.home,
      name: 'Home',
      builder: (context, state) => const HomeWidget(), // your home widget
    ),
  ],
  redirect: (context, state) async {
    final installCompleted = await AppPreferences().getInstallCompleted();
    final isLoginRoute = state.matchedLocation == NewLoginWidget.routePath;
    final isInstallRoute = state.matchedLocation == NewInstallWidget.routePath;

    if (!installCompleted && !isInstallRoute) return NewInstallWidget.routePath;
    if (installCompleted && isInstallRoute) return NewLoginWidget.routePath;
    return null;
  },
);
```

---

## 21. Localization

### Translation Helper

```dart
String translator({required String arText, required String enText}) {
  final isEnglish = Localizations.localeOf(navKey.currentState!.context).languageCode == 'en';
  return isEnglish ? enText : arText;
}

bool isAr() {
  return Localizations.localeOf(navKey.currentState!.context).languageCode == 'ar';
}
```

### All Localization Keys

| Key | English | Arabic |
|-----|---------|-------|
| `auth_flow_install_title` | Install Device | تثبيت الجهاز |
| `auth_flow_install_ip_address` | IP Address | عنوان IP |
| `auth_flow_install_ip_missing` | Could not detect this device IP address. Connect to Wi‑Fi or Ethernet and try again. | تعذّر اكتشاف عنوان IP للجهاز. تأكد من الاتصال بالواي فاي أو الشبكة السلكية ثم أعد المحاولة. |
| `auth_flow_install_cluster_id` | Cluster ID | معرّف العنقود |
| `auth_flow_install_environment` | Environment | البيئة |
| `auth_flow_install_validate_continue` | Validate & Continue | تحقق ومتابعة |
| `auth_flow_install_validation_failed` | Installation validation failed | فشل التحقق من التثبيت |
| `auth_flow_login_title` | Device Login | تسجيل دخول الجهاز |
| `auth_flow_login_pin_code` | PIN Code | رمز PIN |
| `auth_flow_login_submit` | Login | تسجيل الدخول |
| `auth_flow_error_pin_required` | PIN is required | رمز PIN مطلوب |
| `auth_flow_error_online_required` | Online authentication is required | يلزم الاتصال بالإنترنت للمصادقة |
| `auth_flow_error_install_missing` | Installation data is missing | بيانات التثبيت غير متوفرة |
| `fillAllData` | All fields are required | يجب ملء جميع البيانات |

---

## 22. App Assets

```dart
class AppAssets {
  AppAssets._();
  static const String newLogo = 'assets/global/new_logo.png';
  // Add your own logo asset path
}
```

---

## 23. Failure Class

```dart
class Failure {
  int code;
  String message;
  Failure(this.code, this.message);
}
```

Used with `Either<Failure, T>` from `package:eitherx`:

```dart
// Success
return Right(data);

// Error
return Left(Failure(400, 'error message'));
```

---

## 24. Portability Interfaces (Standalone)

If you want the **3-field standalone** version (not the full POSMena flow), use these interfaces:

```dart
abstract class InstallStorage {
  Future<InstallConfigModel?> loadConfig();
  Future<void> saveConfig(InstallConfigModel config);
  Future<void> clearConfig();
}

abstract class EnvironmentConfig {
  String baseUrlFor(String environmentName);
}
```

**3 injection points** for the host app:
1. `InstallStorage` — persistence implementation
2. `EnvironmentConfig` — URL mapping
3. `void onInstallComplete(InstallConfigModel)` — navigation callback

---

## 25. Standalone Repository Implementation

```dart
class InstallRepository {
  final InstallValidationApiInterface _apiService;
  final InstallStorage _storage;
  final EnvironmentConfig _environmentConfig;

  InstallRepository({
    required InstallValidationApiInterface apiService,
    required InstallStorage storage,
    required EnvironmentConfig environmentConfig,
  });

  Future<Either<Failure, InstallConfigModel>> validateAndSave({
    required int clusterId,
    required String ipAddress,
    required String environment,
  }) async {
    try {
      final request = InstallRequestModel(clusterId: clusterId, ipAddress: ipAddress);
      // Set environment on API service before calling
      await _apiService.initialize();
      final response = await _apiService.validateInstallation(request: request);

      if (response.isValid) {
        final config = InstallConfigModel(
          clusterId: clusterId, ipAddress: ipAddress, environment: environment,
          tenantId: response.tenantId, storeId: response.storeId,
          deviceType: response.deviceType, installCompleted: true,
        );
        await _storage.saveConfig(config);
        return Right(config);
      } else {
        return Left(Failure(400, response.message.isNotEmpty ? response.message : 'Validation failed'));
      }
    } on DioException catch (e) {
      return Left(_mapDioException(e));
    } catch (e) {
      return Left(Failure(500, e.toString()));
    }
  }

  Failure _mapDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Failure(408, 'install_error_timeout');
      case DioExceptionType.connectionError:
        return Failure(503, 'install_error_no_connection');
      default:
        return Failure(500, 'install_error_server');
    }
  }
}
```

---

## 26. Standalone Widget (3-Field Install)

If you want **only 3 fields** (Cluster ID, IP Address, Environment) without tender type, sync interval, languages:

```dart
class StandaloneInstallWidget extends ConsumerStatefulWidget {
  static const routeName = 'StandaloneInstall';
  static const routePath = '/install-standalone';

  final void Function(InstallConfigModel config) onInstallComplete;

  const StandaloneInstallWidget({super.key, required this.onInstallComplete});

  @override
  ConsumerState<StandaloneInstallWidget> createState() =>
      _StandaloneInstallWidgetState();
}

class _StandaloneInstallWidgetState
    extends ConsumerState<StandaloneInstallWidget> {
  final _formKey = GlobalKey<FormState>();
  final _clusterIdController = TextEditingController();
  final _clusterIdFocusNode = FocusNode();
  final _ipController = TextEditingController();
  final _ipFocusNode = FocusNode();
  late FormFieldController<InstallOptionModel> _environmentController;
  bool _ipLookupDone = false;

  @override
  void initState() {
    super.initState();
    _environmentController = FormFieldController<InstallOptionModel>(
      naturalOptions.firstWhere((o) => o.value == 'Production', orElse: () => naturalOptions.first),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _hydrateFromPrefs());
    _loadIp();
  }

  Future<void> _hydrateFromPrefs() async {
    final config = await ref.read(installRepositoryProvider).loadConfig();
    if (!mounted) return;
    if (config != null) {
      setState(() {
        _clusterIdController.text = config.clusterId.toString();
        _ipController.text = config.ipAddress;
        _environmentController.value = naturalOptions.firstWhere(
          (o) => o.value == config.environment, orElse: () => naturalOptions.first,
        );
      });
    }
  }

  Future<void> _loadIp() async {
    final ip = await _detectDeviceIp();
    if (!mounted) return;
    setState(() { _ipLookupDone = true; _ipController.text = ip; });
  }

  Future<String> _detectDeviceIp() async {
    try {
      final interfaces = await NetworkInterface.list(includeLoopback: false, type: InternetAddressType.IPv4);
      for (final iface in interfaces) {
        if (iface.name == 'wlan0' || iface.name == 'eth0') {
          for (final addr in iface.addresses) {
            if (!addr.isLoopback && !addr.address.startsWith('169.254.')) return addr.address;
          }
        }
      }
      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          if (!addr.isLoopback && !addr.address.startsWith('169.254.')) return addr.address;
        }
      }
      return '';
    } catch (_) { return ''; }
  }

  @override
  void dispose() {
    _clusterIdController.dispose(); _clusterIdFocusNode.dispose();
    _ipController.dispose(); _ipFocusNode.dispose();
    _environmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(installControllerProvider);

    ref.listen<StandaloneInstallState>(installControllerProvider, (prev, next) {
      if (next.isSuccess && next.config != null) widget.onInstallComplete(next.config!);
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(translator(arText: 'إعداد الجهاز', enText: 'Device Setup'),
                    style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 32),

                  InstallFormFieldFactory.clusterId(
                    controller: _clusterIdController,
                    focusNode: _clusterIdFocusNode,
                    validator: (v) {
                      if (v == null || v.isEmpty) return translator(arText: 'يجب ملء جميع البيانات', enText: 'All fields are required');
                      final parsed = int.tryParse(v);
                      if (parsed == null || parsed <= 0) return translator(arText: 'يجب أن يكون رقم المجموعة رقماً موجباً', enText: 'Cluster ID must be a positive number');
                      return null;
                    },
                  ),

                  InstallFormFieldFactory.ipAddress(
                    controller: _ipController,
                    focusNode: _ipFocusNode,
                    validator: (v) {
                      final env = _environmentController.value?.value ?? 'Production';
                      if (env == 'LocalHost' && (v == null || v.isEmpty)) {
                        return translator(arText: 'عنوان IP مطلوب لبيئة المحلي', enText: 'IP Address is required for LocalHost environment');
                      }
                      if (v != null && v.isNotEmpty) {
                        if (!RegExp(r'^(\d{1,3}\.){3}\d{1,3}$').hasMatch(v)) {
                          return translator(arText: 'صيغة عنوان IP غير صالحة', enText: 'Invalid IP address format');
                        }
                      }
                      return null;
                    },
                  ),
                  if (!_ipLookupDone)
                    Text(translator(arText: 'جارٍ اكتشاف عنوان IP...', enText: 'Detecting IP address...'),
                      style: Theme.of(context).textTheme.bodySmall),

                  InstallOptionDropdownFactory.environment(
                    controller: _environmentController,
                    options: naturalOptions,
                    onChanged: (_) => setState(() {}),
                  ),

                  if (state.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(state.errorMessage!,
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                        textAlign: TextAlign.center),
                    ),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state.isLoading ? null : () {
                        if (!_formKey.currentState!.validate()) return;
                        ref.read(installControllerProvider.notifier).submit(
                          clusterId: int.parse(_clusterIdController.text),
                          ipAddress: _ipController.text,
                          environment: _environmentController.value?.value ?? 'Production',
                        );
                      },
                      child: state.isLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(translator(arText: 'تحقق وحفظ', enText: 'Validate & Save')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## 27. Integration Guide

### Option A: Full POSMena-style flow (Install + Login)

1. Add all model files to `lib/data/models/auth/`
2. Add `Environment` enum to `lib/core/enums/`
3. Add `AppUrls` to `lib/core/constants/`
4. Add `AppPreferences` to `lib/core/helpers/`
5. Add `SecureTokenStorage` to `lib/core/helpers/`
6. Add `BaseApiService` + `BaseApiInterface` to `lib/data/services/remote_data/`
7. Add `TokenAuthApiInterface` + `TokenAuthApiService` to `lib/data/services/remote_data/`
8. Add `InstallValidationService` + `DevicePinLoginService` to `lib/core/services/auth/`
9. Add `NewInstallController` + `NewLoginController` + states
10. Add `NewInstallWidget` + `NewLoginWidget` to `lib/features/`
11. Add UI components (`InstallFormField`, `InstallOptionDropdown`, `FormFieldController`)
12. Add `install_helper.dart` with `InstallOptionModel` + option lists
13. Register routes in GoRouter

**pubspec.yaml dependencies:**
```yaml
dependencies:
  flutter_riverpod: ^2.6.1
  dio: ^5.7.0
  shared_preferences: ^2.3.3
  go_router: ^16.0.0
  eitherx: ^2.0.1
  dropdown_button2: ^2.3.1  # if using FlutterFlowDropDown
```

### Option B: Standalone 3-field Install only

1. Use `InstallConfigModel`, `InstallStorage`, `EnvironmentConfig` interfaces
2. Use `StandaloneInstallWidget` (section 26)
3. Implement `InstallStorage` + `EnvironmentConfig` in your app
4. Override Riverpod providers

---

## 28. Validation Rules

| ID | Field | Condition | Error Key |
|----|-------|-----------|-----------|
| V-001 | clusterId | Must be positive integer > 0 | `install_error_cluster_id_positive` |
| V-002 | ipAddress | Required when environment = LocalHost | `install_error_ip_required_localhost` |
| V-003 | ipAddress | Valid IPv4 format if provided | `install_error_ip_invalid` |
| V-004 | environment | Must be one of 5 predefined values | `install_error_environment_invalid` |
| V-005 | pin | Must not be empty | `auth_flow_error_pin_required` |

---

## 29. IP Auto-Detection

```dart
Future<String> detectDeviceIp() async {
  try {
    final interfaces = await NetworkInterface.list(
      includeLoopback: false,
      type: InternetAddressType.IPv4,
    );
    // Prefer Wi-Fi/ethernet interfaces
    for (final iface in interfaces) {
      if (iface.name == 'wlan0' || iface.name == 'eth0' || iface.name == 'wlp2s0') {
        for (final addr in iface.addresses) {
          if (!addr.isLoopback && !addr.address.startsWith('169.254.')) {
            return addr.address;
          }
        }
      }
    }
    // Fallback: first non-loopback, non-link-local IPv4
    for (final iface in interfaces) {
      for (final addr in iface.addresses) {
        if (!addr.isLoopback && !addr.address.startsWith('169.254.')) {
          return addr.address;
        }
      }
    }
    return '';
  } catch (_) {
    return '';
  }
}
```

---

## 30. Success Criteria

| ID | Criterion |
|----|-----------|
| SC-001 | New user completes device installation in under 30 seconds |
| SC-002 | 100% of mandatory fields validated client-side before API submission |
| SC-003 | On validation failure, error message shown within 1 second, field values preserved |
| SC-004 | After success, all persisted config values retrievable on next launch |
| SC-005 | Standalone version portable — integrate with storage, URL mapping, navigation callback only |
| SC-006 | PIN login reads install data from persistence — no re-entry needed |
| SC-007 | Access token stored securely after login |