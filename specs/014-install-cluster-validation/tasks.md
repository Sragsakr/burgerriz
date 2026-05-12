# Tasks: Install Page — Cluster Validation & Setup

**Input**: Design documents from `/specs/014-install-cluster-validation/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, contracts/

**Tests**: Not explicitly requested in the feature specification. Test tasks are omitted per template guidelines.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project directory structure and localization keys

- [x] T001 Create model directory `lib/data/models/install/` and all three model files: `install_request_model.dart`, `install_response_model.dart`, `install_config_model.dart` with field definitions, constructors, `fromJson`/`toJson` (where applicable), and `Equatable` equality per plan.md architecture
- [x] T002 [P] Add all 13 localization keys from quickstart.md to `lib/l10n/app_en.arb` and `lib/l10n/app_ar.arb`: `install_title`, `install_cluster_id`, `install_ip_address`, `install_environment`, `install_validate_save`, `install_error_cluster_id_positive`, `install_error_ip_required_localhost`, `install_error_ip_invalid`, `install_error_timeout`, `install_error_no_connection`, `install_error_server`, `install_error_parse`, `install_detecting_ip`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core data and service layer that ALL user stories depend on

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [ ] T003 Create `InstallValidationApiInterface` abstract class in `lib/data/services/remote_data/interfaces/install_validation_api_interface.dart` with `Future<InstallResponseModel> validateInstallation(InstallRequestModel request)` method per contracts/install-validation-api.md
- [ ] T004 Create `InstallStorage` abstract class in `lib/data/services/local_data/install_config_repository.dart` with `loadConfig()`, `saveConfig()`, `clearConfig()` methods plus `SharedPreferencesInstallStorage` default implementation per quickstart.md
- [ ] T005 Create `EnvironmentConfig` abstract class in `lib/data/services/local_data/install_config_repository.dart` (same file as T004) with `String baseUrlFor(String environmentName)` method per contracts/install-validation-api.md
- [ ] T006 [P] Create `InstallValidationApiService` extending `BaseApiService` implementing `InstallValidationApiInterface` in `lib/data/services/remote_data/implementations/install_validation_api_service.dart` — GET to `/api/TokenAuth/ValidateInstallationInfo` with query params `ipAddress`, `clusterId`, `tenderTypeId=0`; base URL from `EnvironmentConfig`; parse response via `InstallResponseModel.fromJson`
- [ ] T007 Create `InstallRepository` in `lib/repository/install_repository.dart` — orchestrates validation flow: accepts `InstallValidationApiInterface` + `InstallStorage` + `EnvironmentConfig` dependencies; `validateAndSave(clusterId, ipAddress, environment)` calls API, on success persists via storage, on failure returns error; uses `Either<Failure, InstallConfigModel>` return type per constitution error handling pattern
- [ ] T008 Create Riverpod providers in `lib/providers/install_provider.dart` — `installStorageProvider`, `environmentConfigProvider`, `installApiProvider`, `installRepositoryProvider`, and `installControllerProvider` (AsyncNotifier<StandaloneInstallState>) with `submit()` and `loadConfig()` methods per research.md decision #1
- [ ] T009 Create `StandaloneInstallState` immutable class in `lib/providers/install_provider.dart` (same file as T008) with fields: `isLoading`, `errorMessage`, `isSuccess`, `config` (InstallConfigModel?) and `copyWith` method per data-model.md state definition

**Checkpoint**: Foundation ready — data models, interfaces, services, repository, providers all exist. User story implementation can now begin.

---

## Phase 3: User Story 1 — First-Time Device Setup (Priority: P1) 🎯 MVP

**Goal**: A user can enter Cluster ID, IP Address, and Environment; submit; and have the validated configuration persisted locally.

**Independent Test**: Enter valid Cluster ID (e.g., 5), an IP address, select Production, tap Validate & Save → verify persisted data in SharedPreferences and navigation occurs.

### Implementation for User Story 1

- [ ] T010 [US1] Create `StandaloneInstallWidget` in `lib/features/shared-features/Install/standalone_install_widget.dart` as `ConsumerStatefulWidget` — 3-field form (Cluster ID numeric, IP Address text, Environment dropdown), defaults: Environment=Production, IP auto-detected; `Form` with `GlobalKey<FormState>`; consumer of `installControllerProvider`
- [ ] T011 [US1] Implement IP auto-detection in `standalone_install_widget.dart` — use `NetworkInterface.list()` from `dart:io`, filter IPv4, exclude loopback/link-local, prefer `wlan0`/`eth0`, fallback to first non-loopback IPv4; set detected IP on widget init; show "Detecting IP..." localization key during detection per research.md decision #4
- [ ] T012 [US1] Implement form validation in `standalone_install_widget.dart` — Cluster ID validator: positive int > 0 (V-001); IP validator: required if Environment is LocalHost (V-002), valid IPv4 format (V-003); Environment dropdown with 5 options (V-004); general "fill all data" check (V-005) per data-model.md validation rules
- [ ] T013 [US1] Implement submit flow in `standalone_install_widget.dart` — on "Validate & Save" tap: validate form; disable button during API call (FR-010); call `installControllerProvider.submit(clusterId, ipAddress, environment)`; show loading indicator; on success call `onInstallComplete` callback with `InstallConfigModel`; on error show `errorMessage` from state; preserve field values on failure per FR-009
- [ ] T014 [US1] Implement `installControllerProvider.submit()` in `lib/providers/install_provider.dart` — set loading state → call `InstallRepository.validateAndSave()` → on success persist via `InstallStorage.saveConfig()` and set success state → on failure set error state with message → use `EnvironmentConfig.baseUrlFor()` to determine API target before calling service
- [ ] T015 [US1] Add route registration in `lib/core/routers/app_routes.dart` (add `static const String standaloneInstall = '/install-standalone';`) and `lib/core/routers/router.dart` (add `GoRoute` for `StandaloneInstallWidget` with `popScopeWidget` wrapper)

**Checkpoint**: At this point, User Story 1 should be fully functional — a fresh device can complete installation via the standalone install page.

---

## Phase 4: User Story 2 — Validation Failure Handling (Priority: P2)

**Goal**: Invalid input and network errors display clear messages; field values are preserved on failure; button is disabled during in-flight requests.

**Independent Test**: Submit with an invalid Cluster ID → verify error message appears and form values remain. Disconnect network → submit → verify timeout/connection error message.

### Implementation for User Story 2

- [ ] T016 [US2] Implement error state display in `standalone_install_widget.dart` — show `errorMessage` from `StandaloneInstallState` as a `SnackBar` or inline error widget; map `DioException` types (timeout, connection error) to localized keys `install_error_timeout`, `install_error_no_connection`, `install_error_server`, `install_error_parse` per contracts/install-validation-api.md error handling rules
- [ ] T017 [US2] Implement field preservation on error in `standalone_install_widget.dart` — `TextEditingController` values are never cleared on error; on error state, restore focus to first invalid field; ensure Environment dropdown retains selection per FR-009
- [ ] T018 [US2] Implement duplicate-submission prevention in `standalone_install_widget.dart` — `StandaloneInstallState.isLoading` disables the "Validate & Save" button; button visual state changes to loading spinner or disabled color; no side-effect on rapid taps per FR-010 and edge case "rapidly taps multiple times"
- [ ] T019 [US2] Implement `InstallRepository` error mapping in `lib/repository/install_repository.dart` — catch `DioException` and return mapped `Failure` with localized error key for timeout, no-connection, server-error, and parse-error cases; catch `isValid: false` response and return `Failure` with API `message` field or fallback key

**Checkpoint**: At this point, User Stories 1 AND 2 should both work — happy path + error handling are functional.

---

## Phase 5: User Story 3 — Re-Configuration of an Already Installed Device (Priority: P3)

**Goal**: When returning to the Install page with stored config, all fields are pre-filled. Re-validation replaces the stored config.

**Independent Test**: Complete Story 1 first → navigate back to Install page → verify fields are pre-filled with saved values → change Cluster ID → re-validate → verify new config replaces old in storage.

### Implementation for User Story 3

- [ ] T020 [US3] Implement `loadConfig()` in `installControllerProvider` (in `lib/providers/install_provider.dart`) — on widget init, call `InstallStorage.loadConfig()`; if non-null, populate `TextEditingController`s and Environment dropdown with stored values; set state to `Loaded` with `config` per FR-012
- [ ] T021 [US3] Implement pre-fill logic in `standalone_install_widget.dart` — in `initState` or `didChangeDependencies`, trigger `loadConfig()`; populate `clusterIdController.text`, `ipAddressController.text` from `config.clusterId.toString()`, `config.ipAddress`; set Environment dropdown to `config.environment` value; if config is null, set Environment dropdown to "Production" per FR-002 default
- [ ] T022 [US3] Implement config replacement in `installControllerProvider.submit()` — on successful validation, call `InstallStorage.saveConfig()` which overwrites previous values (not merge); the `installCompleted` flag remains `true` per FR-008

**Checkpoint**: All three user stories are independently functional. Full install flow: fresh setup, error recovery, and re-configuration all work.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Integration, localization QA, and final wiring

- [ ] T023 [P] Implement POSMena-specific `PosmenaInstallStorage` in `lib/data/services/local_data/install_config_repository.dart` (or separate file) — maps `AppPreferences` calls to `InstallStorage` interface per quickstart.md integration example
- [ ] T024 [P] Implement POSMena-specific `PosmenaEnvironmentConfig` — maps `Environment` enum `getV2BaseUrl()` to `EnvironmentConfig.baseUrlFor()` per quickstart.md integration example
- [ ] T025 Wire up Riverpod provider overrides in `lib/main.dart` or app initialization — register `PosmenaInstallStorage` and `PosmenaEnvironmentConfig` as overrides for `installStorageProvider` and `environmentConfigProvider`
- [ ] T026 [P] Verify RTL/LTR layout for all 3 form fields — Cluster ID label, IP Address label, Environment dropdown, Validate & Save button must render correctly in Arabic locale per constitution Principle V
- [ ] T027 Run `flutter analyze` and fix all issues in new files; ensure no `print()` statements (use `dPrint()` or `AppLogger` per AGENTS.md rules); ensure no direct `AppPreferences` imports in `standalone_install_widget.dart` or `install_provider.dart` (portability per FR-014)
- [ ] T028 Validate quickstart.md integration — create a temporary test that instantiates `StandaloneInstallWidget` with mock `InstallStorage`, `EnvironmentConfig`, and `onInstallComplete` callback; verify the 3 injection points work without any POSMena-specific imports per SC-005

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion — BLOCKS all user stories
- **User Stories (Phase 3-5)**: All depend on Foundational phase completion
  - US1 (Phase 3) must complete before US2 (Phase 4) can test error handling
  - US2 (Phase 4) must complete before US3 (Phase 5) can test re-configuration
  - Or: US2 and US3 CAN be developed in parallel if US1 is complete
- **Polish (Phase 6)**: Depends on all user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) — no dependencies on other stories
- **User Story 2 (P2)**: Extends US1 with error handling — builds on the same widget but adds error states independently
- **User Story 3 (P3)**: Extends US1 with pre-fill — builds on the same widget but adds load/persist independently

### Within Each User Story

- Models before services (but models are in foundational phase)
- Services before repository
- Repository before providers
- Providers before widget
- Widget before route wiring

### Parallel Opportunities

- T001 and T002 can run in parallel (different file types: models vs ARB)
- T004 and T005 can run in parallel (same file but different classes)
- T006 and T004/T005 can run in parallel (different files)
- T010-T012 can partially parallelize (different sections of the same widget file)
- T023, T024, T026 can all run in parallel (different files/concerns)

---

## Parallel Example: Foundational Phase

```bash
# Launch these foundational tasks in parallel (different files):
Task T003: "Create InstallValidationApiInterface in lib/data/services/remote_data/interfaces/"
Task T004: "Create InstallStorage + EnvironmentConfig in lib/data/services/local_data/"
Task T006: "Create InstallValidationApiService in lib/data/services/remote_data/implementations/"
```

## Parallel Example: User Story 1

```bash
# After foundational phase, launch these in sequence (same widget file):
Task T010: "Create StandaloneInstallWidget scaffold"
Task T011: "Add IP auto-detection"
Task T012: "Add form validation"
Task T013: "Wire submit flow"
Task T014: "Implement controller submit logic"
Task T015: "Register route"
```

## Parallel Example: Polish Phase

```bash
# Launch these polish tasks in parallel (different files):
Task T023: "Implement PosmenaInstallStorage"
Task T024: "Implement PosmenaEnvironmentConfig"
Task T026: "Verify RTL/LTR layout"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001-T002)
2. Complete Phase 2: Foundational (T003-T009) — **CRITICAL BLOCKER**
3. Complete Phase 3: User Story 1 (T010-T015)
4. **STOP and VALIDATE**: Test US1 independently — fresh install flow works end-to-end
5. Optionally deploy/demo

### Incremental Delivery

1. Setup + Foundational → Foundation ready
2. Add User Story 1 → Test independently → Deploy/Demo (MVP!)
3. Add User Story 2 → Test error handling independently → Deploy/Demo
4. Add User Story 3 → Test re-configuration independently → Deploy/Demo
5. Polish → POSMena integration, RTL QA, analyze → Final release

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- The standalone feature MUST NOT import `AppPreferences`, `AppConfig`, `AuthFlowConfig`, or any POSMena-specific module directly — only through the `InstallStorage` and `EnvironmentConfig` interfaces (FR-014)
- `tenderTypeId=0` is sent in the API call but NOT exposed in the UI (backward compat)
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Avoid: vague tasks, same file conflicts, cross-story dependencies that break independence