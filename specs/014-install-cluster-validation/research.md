# Research: Install Page — Cluster Validation & Setup

**Feature**: 014-install-cluster-validation  
**Date**: 2026-05-10

## Research Tasks & Decisions

### 1. State Management Approach for New Install Feature

**Decision**: Use Riverpod `AsyncNotifier` with an immutable state class.

**Rationale**: Constitution Principle I mandates that all **new** code MUST use Riverpod. The existing `NewInstallController` uses the legacy `ChangeNotifier` pattern which the constitution explicitly says "do not extend." The new standalone install feature should use `AsyncNotifier<StandaloneInstallState>` (Riverpod 2.x) mounted via `@riverpod` annotation or manual `NotifierProvider`. This gives:
- Compile-time safety for state transitions (loading → success → error)
- Built-in async handling via `AsyncValue` pattern
- Easy testability with provider overrides
- No coupling to legacy `ChangeNotifier` or `provider` package

**Alternatives considered**:
- **ChangeNotifier** (existing pattern): Rejected — constitution explicitly forbids extending legacy patterns for new code
- **Bloc/Cubit**: Rejected — not used anywhere in the codebase; adds a new paradigm for no benefit
- **Simple StatefulWidget with setState**: Rejected — does not separate presentation from state per constitution

### 2. Persistence Layer — AppPreferences vs. Abstract Storage Interface

**Decision**: Create an abstract `InstallStorage` interface that wraps persistence, with a default `SharedPreferencesInstallStorage` implementation.

**Rationale**: The spec requires FR-014 (self-containment and portability). Direct `AppPreferences` usage would couple the feature to POSMena's singleton. Instead, define:
```dart
abstract class InstallStorage {
  Future<InstallConfig?> loadConfig();
  Future<void> saveConfig(InstallConfig config);
  Future<void> clearConfig();
}
```
The `SharedPreferencesInstallStorage` implementation maps to `AppPreferences` internally for the POSMena deployment, but another app can provide its own implementation (e.g., using `shared_preferences` directly, Hive, or secure storage).

**Alternatives considered**:
- **Direct AppPreferences calls**: Rejected — violates FR-014 (portability); couples to POSMena's singleton
- **SQLite via AppDB**: Rejected — install config is simple key-value data with 7 fields; SQLite is overkill and contradicts the existing pattern where install data lives in SharedPreferences

### 3. API Service — Interface Pattern

**Decision**: Follow the existing codebase pattern: abstract interface + Dio implementation.

**Rationale**: The project already uses `TokenAuthApiInterface` (abstract) → `TokenAuthApiService` (Dio implementation). The new standalone feature should mirror this:
```dart
abstract class InstallValidationApiInterface {
  Future<InstallResponseModel> validateInstallation(InstallRequestModel request);
}
```
```dart
class InstallValidationApiService extends BaseApiService implements InstallValidationApiInterface {
  // Uses Dio with environment-derived base URL
}
```
This follows constitution Principle I (data layer owns API contracts only) and enables unit testing with mock implementations.

**Alternatives considered**:
- **Direct Dio calls in repository**: Rejected — violates layered architecture; repository should orchestrate, not make HTTP calls directly
- **Retrofit/Chopper code generation**: Rejected — not used in the codebase; adds unnecessary complexity for a single endpoint

### 4. IP Auto-Detection Strategy

**Decision**: Use `dart:io` `NetworkInterface.list()` filtered to IPv4, preferring Wi-Fi/ethernet interfaces, with manual override.

**Rationale**: The existing `NewInstallWidget._loadIp()` already uses `NetworkInterface.list()` and filters for `InternetAddressType.IPv4`. This is the standard Flutter approach for local IP detection on Android. The standalone feature will replicate this pattern in a pure Dart utility function within the feature (not in a shared util) to maintain portability.

**Filtering logic** (from existing code + improvements):
1. List all network interfaces
2. Filter to IPv4 addresses
3. Exclude loopback (127.x.x.x) and link-local (169.254.x.x)
4. Prefer interfaces named `wlan0`, `eth0`, `wlp2s0` (Wi-Fi/ethernet)
5. Fallback to first non-loopback IPv4 address
6. If detection fails, leave IP field empty (user must type manually)

**Alternatives considered**:
- **Platform channels for Android NetworkInfo**: Rejected — adds native code dependency, breaks portability
- **Hardcoded IP / no detection**: Rejected — poor UX; auto-detection is expected per FR-004

### 5. Environment-to-URL Mapping — Configurable Abstraction

**Decision**: Define an `EnvironmentConfig` interface that maps environment names to base URLs, injectable at app startup.

**Rationale**: FR-014 requires portability. Each deploying app provides its own URL mapping. The POSMena deployment will use the existing `Environment` enum's `getV2BaseUrl()` methods:

```dart
class PosmenaEnvironmentConfig implements EnvironmentConfig {
  @override
  String baseUrlFor(String environmentName) {
    return getEnvType(environmentName).getV2BaseUrl();
  }
}
```

Other apps provide their own implementation. The default `EnvironmentConfig` in the feature returns empty strings (forcing the app to inject a real one).

**Alternatives considered**:
- **Hardcoded URLs in the feature**: Rejected — violates portability (FR-014)
- **Read URLs from environment variables**: Rejected — not a Flutter pattern; no .env on Android POS devices

### 6. Validation API Endpoint

**Decision**: The existing POSMena API endpoint is `GET /api/TokenAuth/ValidateInstallationInfo` with query params `ipAddress`, `clusterId`, `tenderTypeId`. The standalone feature will use the same endpoint but with `tenderTypeId=0` (default), since the feature spec only requires Cluster ID and IP Address.

**Rationale**: The spec clarifies that the API request carries only `clusterId` and `ipAddress` (environment is client-side only). The existing API also accepts `tenderTypeId` which defaults to `0`. The `InstallValidationApiService` will send `tenderTypeId=0` to maintain API compatibility while the feature only exposes the two required fields.

**Alternatives considered**:
- **New API endpoint**: Rejected — the existing endpoint already validates cluster and IP; creating a new endpoint is out of scope for a UI feature
- **Remove tenderTypeId entirely**: Rejected — would break API compatibility; defaulting to 0 is safer

### 7. Portability Strategy — Feature Self-Containment

**Decision**: All new files for this feature will live under a cohesive `install/` namespace and be importable as a group. The feature requires exactly 3 injections from the host app:
1. `InstallStorage` — persistence implementation
2. `EnvironmentConfig` — URL mapping
3. `void onInstallComplete(InstallConfig)` — navigation callback

The `StandaloneInstallWidget` accepts these via constructor or Riverpod provider overrides. No import of `AppPreferences`, `AppConfig`, `AuthFlowConfig`, or any other POSMena-specific module from within the feature's core logic.

**Rationale**: Directly from FR-014 and the spec's Success Criterion SC-005.

**Alternatives considered**:
- **Package/pub sub-module**: Rejected — premature; the feature can be extracted into a package later after validation. Folder-level cohesion is sufficient.
- **Callback-only (no interface injection)**: Rejected — would require the feature to directly use SharedPreferences, breaking portability

### 8. Localization Strategy

**Decision**: Use Flutter's `AppLocalizations` pattern with AR + EN keys for all user-facing strings in the standalone feature.

**Rationale**: Constitution Principle V mandates bilingual support. The existing codebase uses `.arb` files with `AppLocalizations.of(context)!.keyName` pattern. New keys for this feature will be added to both `app_en.arb` and `app_ar.arb`.

**Alternatives considered**:
- **Hard-coded strings with a Map**: Rejected — violates constitution Principle V
- **Separate localization bundle for the feature**: Rejected — adds complexity; the app's existing ARB system is sufficient

### 9. Form Validation Pattern

**Decision**: Use Flutter's `Form` + `TextFormField` with `validator` callbacks, matching the existing `InstallFormField` pattern.

**Rationale**: The existing install page uses `Form` with `GlobalKey<FormState>` and per-field `validator` functions. The new standalone feature should mirror this pattern for consistency. Validation rules per FR-003 (Cluster ID positive integer) and FR-005 (IP required for LocalHost) will be pure Dart functions for testability.

**Alternatives considered**:
- **Riverpod-based validation (separate validator providers)**: Rejected — over-engineering for a 3-field form
- **Third-party form library (formz, reactive_forms)**: Rejected — not in the codebase; adds dependency for minimal value