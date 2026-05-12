# Data Model: Install Page — Cluster Validation & Setup

**Feature**: 014-install-cluster-validation  
**Date**: 2026-05-10

## Entities

### InstallRequestModel

The request payload sent to the validation API. Per spec clarification, environment is NOT included — it resolves the base URL client-side only.

| Field | Type | Required | Validation | Description |
|-------|------|----------|------------|-------------|
| `clusterId` | `int` | yes | Must be > 0 | Numeric identifier for the POS cluster |
| `ipAddress` | `String` | conditional | Must be non-empty if environment is LocalHost; optional otherwise | Device IP address, auto-detected or manually entered |

**Notes**:
- `tenderTypeId` defaults to `0` in the API call for backward compatibility, but is NOT exposed in the feature model.
- `fromJson` / `toJson` not needed — this model is only used for constructing the API request, not deserialized from JSON.

### InstallResponseModel

The server response from the validation endpoint.

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `isValid` | `bool` | yes | `false` | Whether the installation info is valid |
| `tenantId` | `int` | yes | `0` | Tenant identifier returned on valid response |
| `storeId` | `int` | yes | `0` | Store identifier returned on valid response |
| `deviceType` | `int` | yes | `0` | Device type identifier returned on valid response |
| `message` | `String` | yes | `''` | Human-readable message (error description or success confirmation) |

**Notes**:
- Deserialized from JSON via `fromJson` factory constructor.
- Follows the existing `ValidateInstallationInfoResponse` field names exactly for API compatibility.

### InstallConfigModel

The persisted configuration stored on-device after successful validation.

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `clusterId` | `int` | yes | — | Validated cluster ID |
| `ipAddress` | `String` | yes | — | Device IP address |
| `environment` | `String` | yes | `'Production'` | Selected environment name |
| `tenantId` | `int` | yes | — | Tenant ID from validation response |
| `storeId` | `int` | yes | — | Store ID from validation response |
| `deviceType` | `int` | yes | — | Device type from validation response |
| `installCompleted` | `bool` | yes | `true` | Flag indicating installation is complete |

**Notes**:
- `fromJson` / `toJson` methods for serialization to/from `SharedPreferences`.
- On load, `installCompleted` defaults to `false` if key is absent.

### InstallOptionModel (Environment)

Reuses the existing `InstallOptionModel` pattern for dropdown options.

| Field | Type | Description |
|-------|------|-------------|
| `name` | `String` | Display name (e.g., "Production") |
| `nameLocalized` | `String` | Arabic display name (e.g., "الإنتاج") |
| `value` | `String` | Enum value string (e.g., "Production") |

**Predefined values** (matching `Environment` enum):

| Value | English Name | Arabic Name | Base URL (POSMena) |
|-------|-------------|-------------|---------------------|
| `Production` | Production | الإنتاج | `https://food-api.posmena.com` |
| `Staging` | Staging | التجريبي | `https://staging.food-api.posmena.com` |
| `Testing` | Testing | الاختبار | `https://uat.food-api.posmena.com` |
| `Developing` | Development | التطوير | `https://devapi.posmena.com` |
| `LocalHost` | LocalHost | المحلي | `{ipAddress}` (dynamic) |

## Relationships

```text
┌─────────────────────┐
│  InstallRequestModel │ ──► sent to API endpoint
│  (clusterId, ipAddress)│
└─────────────────────┘

┌──────────────────────────┐
│  InstallResponseModel      │ ◄── received from API endpoint
│  (isValid, tenantId,       │
│   storeId, deviceType,    │
│   message)                │
└─────────┬────────────────┘
          │ if isValid == true
          ▼
┌──────────────────────────┐
│  InstallConfigModel        │ ──► persisted to InstallStorage
│  (clusterId, ipAddress,   │
│   environment, tenantId,  │
│   storeId, deviceType,    │
│   installCompleted)       │
└──────────────────────────┘
```

## Validation Rules

| Rule | Field | Condition | Error Message (Key) |
|------|-------|-----------|---------------------|
| V-001 | `clusterId` | Must be a positive integer (> 0) | `install_error_cluster_id_positive` |
| V-002 | `ipAddress` | Required when environment is LocalHost | `install_error_ip_required_localhost` |
| V-003 | `ipAddress` | If provided, must be valid IPv4 format | `install_error_ip_invalid` |
| V-004 | `environment` | Must be one of the 5 predefined values | `install_error_environment_invalid` |
| V-005 | (form) | All required fields must be filled before submission | `fillAllData` |

## State Transitions

```text
                    ┌──────────┐
         ┌─────────│  Initial  │──────────────┐
         │         └──────────┘               │
         │              │                     │
    load from        (user fills             │
   InstallStorage    form & taps             │
         │         "Validate & Save")         │
         ▼              │                     │
  ┌──────────────┐      ▼                     │
  │   Loaded      │  ┌──────────┐             │
  │ (pre-filled)  │  │ Loading   │             │
  └──────────────┘  └──────────┘             │
                          │                    │
               ┌──────────┴──────────┐        │
               ▼                     ▼        │
        ┌────────────┐      ┌──────────┐     │
        │   Success   │      │  Error    │     │
        │ (persist &  │      │ (show msg │     │
        │  navigate)  │      │  preserve  │     │
        └────────────┘      │  fields)   │     │
                            └─────┬─────┘     │
                                  │ (retry) ───┘
```

### State: StandaloneInstallState (immutable)

```text
class StandaloneInstallState {
  final bool isLoading;        // true during API call
  final String? errorMessage;   // non-null on error
  final bool isSuccess;         // true after successful validation & persist
  final InstallConfigModel? config;  // non-null after load or success
}
```

- Initial → `isLoading: false, errorMessage: null, isSuccess: false, config: null`
- Loaded → `isLoading: false, errorMessage: null, isSuccess: false, config: InstallConfigModel(...)`
- Loading → `isLoading: true, errorMessage: null, isSuccess: false, config: ...`
- Success → `isLoading: false, errorMessage: null, isSuccess: true, config: InstallConfigModel(...)`
- Error → `isLoading: false, errorMessage: "error text", isSuccess: false, config: ...`