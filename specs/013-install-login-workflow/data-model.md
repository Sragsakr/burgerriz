# Data Model: Installation and Device PIN Login

## Entity: InstallationInput

- **Fields**
  - `ipAddress` (string, required, read-only in UI, auto-detected)
  - `clusterId` (int, required, user-entered, editable until validation success)
  - `tenderTypeId` (int, required by contract in this flow as constant `0`)
  - `environment` (enum/string, required, selected from dropdown)

- **Validation Rules**
  - `ipAddress` must be non-empty and in valid IP format.
  - `clusterId` must be positive integer.
  - `tenderTypeId` must equal `0` for this workflow.
  - `environment` must match one supported app environment value.

## Entity: InstallationValidationResult

- **Fields**
  - `isValid` (bool)
  - `tenantId` (int)
  - `storeId` (int)
  - `deviceType` (int enum)
  - `message` (string; may contain newline-separated errors)

- **State Semantics**
  - Success state: `isValid=true` and setup may be persisted as completed.
  - Failure state: `isValid=false`; setup completion must remain false.

## Entity: SavedDeviceSetup

- **Fields**
  - `ipAddress` (string)
  - `clusterId` (int/string representation)
  - `environment` (string/enum key)
  - `tenantId` (int)
  - `storeId` (int)
  - `deviceType` (int)
  - `installationCompleted` (bool)

- **Lifecycle**
  - Created/overwritten on successful install validation.
  - Read during login request composition.
  - Cleared or replaced on reinstall when new flow is enabled.

## Entity: DeviceLoginRequest

- **Fields**
  - `pinCode` (string, required)
  - `ipAddress` (string, required, from SavedDeviceSetup)
  - `clusterId` (int, required, from SavedDeviceSetup)

## Entity: DeviceLoginResponse

- **Fields**
  - `accessToken` (string, sensitive)
  - `expireInSeconds` (int)
  - `userId` (int)
  - `userName` (string)
  - `deviceStoreId` (int)
  - `deviceType` (int)
  - `tenantData.id` (int)
  - `tenantData.tenancyName` (string)
  - `tenantData.name` (string)
  - `roles[]` (list of `{roleId, roleName}`)

- **Persistence Split**
  - Sensitive: `accessToken` in secure storage.
  - Non-sensitive identity/context: `userId`, `userName`, `tenantData.*`, `deviceStoreId`, `deviceType` in app preferences.

## State Transitions

1. `Unconfigured` -> `InstallPending` when new flow starts.
2. `InstallPending` -> `InstallValidated` on valid install response.
3. `InstallPending` -> `InstallError` on failed validation.
4. `InstallValidated` -> `LoginPending` when PIN submitted.
5. `LoginPending` -> `Authenticated` on valid login response.
6. `LoginPending` -> `LoginError` on auth failure.
7. `Authenticated` -> `Unconfigured` only on explicit reset/reinstall/logout policy.
