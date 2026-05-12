# Quickstart: Install Page — Cluster Validation & Setup

**Feature**: 014-install-cluster-validation  
**Date**: 2026-05-10

## Overview

This feature provides a standalone, portable installation page that collects Cluster ID, IP Address, and Environment, validates them against a remote API, and persists the result. It is designed to be extracted and integrated into any Flutter app with minimal coupling.

## Architecture

```text
┌──────────────────────────────────────────┐
│          Presentation Layer               │
│  StandaloneInstallWidget                  │
│  (ConsumerStatefulWidget + Form)          │
├──────────────────────────────────────────┤
│          State Layer (Riverpod)           │
│  installControllerProvider                │
│  (AsyncNotifier<StandaloneInstallState>) │
├──────────────────────────────────────────┤
│          Repository Layer                 │
│  InstallRepository                        │
│  (orchestrates local + remote)            │
├──────────────────┬───────────────────────┤
│   Data - Remote  │   Data - Local         │
│  InstallValid-   │  InstallStorage         │
│  ationApiService │  (interface, injected)  │
│  (Dio + env URL) │                         │
└──────────────────┴───────────────────────┘
```

**Dependency direction**: Presentation → State (Riverpod) → Repository → Data (API + Storage)  
Constitution Principle I compliant: no layer skips.

## Integration (Host App)

To integrate this feature into a Flutter app, provide three injections:

### 1. InstallStorage implementation

```dart
// Example: POSMena implementation using AppPreferences
class PosmenaInstallStorage implements InstallStorage {
  final AppPreferences _prefs = AppPreferences();

  @override
  Future<InstallConfigModel?> loadConfig() async {
    final completed = await _prefs.getInstallCompleted();
    if (!completed) return null;
    return InstallConfigModel(
      clusterId: await _prefs.getClusterId(),
      ipAddress: await _prefs.getIp(),
      environment: (await _prefs.getEnvironmentType()).isNotEmpty
          ? await _prefs.getEnvironmentType()
          : 'Production',
      tenantId: await _prefs.getInstallTenantId(),
      storeId: await _prefs.getInstallStoreId(),
      deviceType: await _prefs.getInstallDeviceType(),
      installCompleted: completed,
    );
  }

  @override
  Future<void> saveConfig(InstallConfigModel config) async {
    await _prefs.setClusterId(config.clusterId);
    await _prefs.setIp(config.ipAddress);
    await _prefs.setEnvironmentType(config.environment);
    await _prefs.setInstallTenantId(config.tenantId);
    await _prefs.setInstallStoreId(config.storeId);
    await _prefs.setInstallDeviceType(config.deviceType);
    await _prefs.setInstallCompleted(config.installCompleted);
  }

  @override
  Future<void> clearConfig() async {
    await _prefs.setInstallCompleted(false);
  }
}
```

### 2. EnvironmentConfig implementation

```dart
// Example: POSMena implementation
class PosmenaEnvironmentConfig implements EnvironmentConfig {
  @override
  String baseUrlFor(String environmentName) {
    return getEnvType(environmentName).getV2BaseUrl();
  }
}
```

### 3. Navigation callback

```dart
// In route configuration or scaffold
void onInstallComplete(InstallConfigModel config) {
  context.goNamed(NewLoginWidget.routeName);
  // Or any post-install route
}
```

### 4. Wire up Riverpod providers

```dart
// In your ProviderScope overrides:
ProviderScope(
  overrides: [
    installStorageProvider.overrideWithValue(PosmenaInstallStorage()),
    environmentConfigProvider.overrideWithValue(PosmenaEnvironmentConfig()),
  ],
  child: MyApp(),
)
```

### 5. Use the widget

```dart
StandaloneInstallWidget(
  onInstallComplete: (config) {
    context.goNamed('Login');
  },
)
```

## File Manifest

| # | File Path | Type | Description |
|---|-----------|------|-------------|
| 1 | `lib/data/models/install/install_request_model.dart` | Model | Request payload (clusterId, ipAddress) |
| 2 | `lib/data/models/install/install_response_model.dart` | Model | API response (isValid, tenantId, storeId, deviceType, message) |
| 3 | `lib/data/models/install/install_config_model.dart` | Model | Persisted config (all 7 fields) |
| 4 | `lib/data/services/remote_data/interfaces/install_validation_api_interface.dart` | Interface | Abstract API contract |
| 5 | `lib/data/services/remote_data/implementations/install_validation_api_service.dart` | Service | Dio-based API implementation |
| 6 | `lib/data/services/local_data/install_config_repository.dart` | Storage | Abstract InstallStorage + default SharedPreferences impl |
| 7 | `lib/repository/install_repository.dart` | Repository | Domain orchestration (validate + persist) |
| 8 | `lib/providers/install_provider.dart` | Provider | Riverpod providers (state, storage, env config) |
| 9 | `lib/features/shared-features/Install/standalone_install_widget.dart` | Widget | Portable UI (3 fields + validate button) |
| 10 | `lib/core/routers/app_routes.dart` | Routes | MODIFY: add route constant |
| 11 | `lib/core/routers/router.dart` | Routes | MODIFY: add route entry |

## Localization Keys Required

| Key | English | Arabic |
|-----|---------|-------|
| `install_title` | "Device Setup" | "إعداد الجهاز" |
| `install_cluster_id` | "Cluster ID" | "رقم المجموعة" |
| `install_ip_address` | "IP Address" | "عنوان IP" |
| `install_environment` | "Environment" | "البيئة" |
| `install_validate_save` | "Validate & Save" | "تحقق وحفظ" |
| `install_error_cluster_id_positive` | "Cluster ID must be a positive number" | "يجب أن يكون رقم المجموعة رقماً موجباً" |
| `install_error_ip_required_localhost` | "IP Address is required for LocalHost environment" | "عنوان IP مطلوب لبيئة المحلي" |
| `install_error_ip_invalid` | "Invalid IP address format" | "صيغة عنوان IP غير صالحة" |
| `install_error_timeout` | "Connection timed out. Please check your network and try again." | "انتهت مهلة الاتصال. تحقق من الشبكة وحاول مرة أخرى." |
| `install_error_no_connection` | "No internet connection. Please check your network settings." | "لا يوجد اتصال بالإنترنت. تحقق من إعدادات الشبكة." |
| `install_error_server` | "Server error. Please try again later." | "خطأ في الخادم. حاول مرة أخرى لاحقاً." |
| `install_error_parse` | "Unexpected response from server. Please try again." | "استجابة غير متوقعة من الخادم. حاول مرة أخرى." |
| `install_detecting_ip` | "Detecting IP address..." | "جارٍ اكتشاف عنوان IP..." |

## Testing Strategy

### Unit Tests

| Test | Target | Verifies |
|------|--------|----------|
| `install_request_model_test.dart` | `InstallRequestModel` | Field assignment, equality |
| `install_response_model_test.dart` | `InstallResponseModel` | `fromJson` parsing, default values for null fields |
| `install_repository_test.dart` | `InstallRepository` | Happy path (save on valid), error path (don't save on invalid), network error propagation |
| `install_validation_service_test.dart` | Validation logic | Cluster ID > 0, IP required for LocalHost, IPv4 format |

### Widget Tests

| Test | Target | Verifies |
|------|--------|----------|
| `standalone_install_widget_test.dart` | Full widget | Form renders 3 fields, Environment defaults to Production, submission flow, error display, field preservation on error |

### Integration Tests (deferred)

- End-to-end validation with mock API server
- Offline → online recovery flow