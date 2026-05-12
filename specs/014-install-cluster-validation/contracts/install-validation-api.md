# API Contract: Install Validation Endpoint

**Feature**: 014-install-cluster-validation  
**Date**: 2026-05-10

## Endpoint

### Validate Installation Info

Validates the provided Cluster ID and IP Address against the POSMena backend and returns tenant/store/device information if valid.

```
GET /api/TokenAuth/ValidateInstallationInfo
```

### Request

**Method**: `GET`  
**Base URL**: Determined by the selected Environment via `EnvironmentConfig.baseUrlFor(environmentName)`  
**Authentication**: None required (public endpoint — device is not yet authenticated)

**Query Parameters**:

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `ipAddress` | `string` | yes | — | Device IP address (auto-detected or manually entered) |
| `clusterId` | `integer` | yes | — | POS cluster numeric identifier |
| `tenderTypeId` | `integer` | no | `0` | Tender type (always sent as `0` by this feature) |

**Example Request**:
```
GET https://food-api.posmena.com/api/TokenAuth/ValidateInstallationInfo?ipAddress=192.168.1.100&clusterId=5&tenderTypeId=0
```

### Response

**Content-Type**: `application/json`

#### Success Response (valid installation)

```json
{
  "isValid": true,
  "tenantId": 1,
  "storeId": 42,
  "deviceType": 2,
  "message": ""
}
```

#### Failure Response (invalid installation)

```json
{
  "isValid": false,
  "tenantId": 0,
  "storeId": 0,
  "deviceType": 0,
  "message": "Cluster not found"
}
```

#### Field Specifications

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| `isValid` | `boolean` | no | Whether the installation info is valid |
| `tenantId` | `integer` | no | Tenant identifier (0 if invalid) |
| `storeId` | `integer` | no | Store identifier (0 if invalid) |
| `deviceType` | `integer` | no | Device type identifier (0 if invalid) |
| `message` | `string` | no | Human-readable message describing the result |

### Error Responses

| HTTP Status | Condition | Body |
|-------------|-----------|------|
| `400` | Missing required parameters | `{ "message": "Bad Request" }` |
| `404` | Cluster ID not found | `{ "isValid": false, "message": "Cluster not found" }` |
| `500` | Server error | `{ "message": "Internal Server Error" }` |

### Error Handling Rules

1. **Network timeout** (> 30 seconds): Display "Connection timed out. Please check your network and try again." (localization key: `install_error_timeout`)
2. **No connectivity**: Display "No internet connection. Please check your network settings." (localization key: `install_error_no_connection`)
3. **HTTP 4xx/5xx**: Display the `message` field from the response body if available; otherwise display a generic error (localization key: `install_error_server`)
4. **Malformed response**: Display "Unexpected response from server. Please try again." (localization key: `install_error_parse`)

## Interface Contract (Dart)

```dart
abstract class InstallValidationApiInterface {
  /// Validates installation info against the backend.
  /// The base URL is determined by the environment passed to the service.
  Future<InstallResponseModel> validateInstallation(InstallRequestModel request);
}
```

```dart
abstract class InstallStorage {
  /// Loads previously saved install configuration.
  /// Returns null if no configuration has been saved.
  Future<InstallConfigModel?> loadConfig();

  /// Persists install configuration after successful validation.
  Future<void> saveConfig(InstallConfigModel config);

  /// Clears the stored configuration (for re-configuration or reset).
  Future<void> clearConfig();
}
```

```dart
abstract class EnvironmentConfig {
  /// Returns the base API URL for the given environment name.
  /// Environment names: 'Production', 'Staging', 'Testing', 'Developing', 'LocalHost'
  String baseUrlFor(String environmentName);
}
```