# Quickstart: Installation and Device PIN Login

## Prerequisites

- New workflow static flag enabled in app configuration.
- Test environment API reachable.
- Device has network connectivity and detectable IP.
- Known valid cluster ID and PIN for test account.

## Setup Flow Validation

1. Launch app on a device with existing old-flow setup.
2. Confirm app requires one-time new installation step.
3. In install screen:
   - IP is auto-populated and read-only.
   - Cluster ID is editable.
   - Environment dropdown is present and selectable.
4. Submit install request.
5. Verify success path:
   - Install response is accepted only when `isValid=true`.
   - Stored setup includes tenant/store/device info + environment selection.
6. Verify failure path:
   - Error message(s) displayed.
   - Cluster ID remains editable.
   - Setup is not marked complete.

## Login Flow Validation

1. Navigate to new login screen after successful install.
2. Confirm login UI is PIN-only (saved IP/cluster hidden from user).
3. Submit valid PIN:
   - Request uses saved `ipAddress` + `clusterId`.
   - Session values persist: userId, userName, tenantData, device metadata.
   - Access token persists via secure storage mechanism.
4. Submit invalid PIN:
   - User-visible auth error shown.
   - No sensitive/session overwrite occurs.
5. Disconnect network and attempt login:
   - Login fails with online-required behavior (no offline fallback).

## Regression Checks

- With workflow flag disabled, app uses existing install/login flow unchanged.
- Existing cart/checkout and core sales operations are unaffected.
- Arabic and English labels/messages render via localization keys.

## Persistence Key Map

- Install response keys:
  - `installTenantId`, `installStoreId`, `installDeviceType`
  - `clusterId`, `EnvironmentType`, `installCompleted`
- Login response keys:
  - `accessToken` (secure token storage helper)
  - `loginUserId`, `loginUserName`, `deviceStoreId`
  - `tenantDataId`, `tenantDataTenancyName`, `tenantDataName`

## Validation Outcome

- Implementation run confirms new flow routing, install validation integration, and PIN login response persistence wiring are in place.
- Remaining work centers on dedicated tests and localization key expansion for new screens.
