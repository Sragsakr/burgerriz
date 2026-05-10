# Tasks: Installation and Device PIN Login

**Input**: Design documents from `/specs/013-install-login-workflow/`  
**Prerequisites**: `plan.md`, `spec.md`, `research.md`, `data-model.md`, `contracts/token-auth-install-login.yaml`, `quickstart.md`

**Tests**: Test tasks are included because constitution quality gates require coverage for critical login flow changes.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Every task includes an exact file path

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Prepare shared constants, models, and storage contracts for the new install/login workflow.

- [X] T001 Add new flow toggle and environment defaults in `lib/core/config/app_config.dart`
- [X] T002 Define installation/login endpoint constants in `lib/core/constants/app_urls.dart`
- [X] T003 [P] Add install/login DTO models for contract payloads in `lib/data/models/auth/device_install_models.dart`
- [X] T004 [P] Add device auth response DTO model in `lib/data/models/auth/device_auth_models.dart`
- [X] T005 Add secure token persistence helper abstraction in `lib/core/helpers/secure_token_storage.dart`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Build foundational routing, preference key mapping, and service interfaces required by all stories.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [X] T006 Add explicit preference keys/getters/setters for tenant/store/environment/session fields in `lib/core/helpers/app_pref.dart`
- [X] T007 Create token-auth API interface for install validation and PIN login in `lib/data/services/remote_data/interfaces/token_auth_api_interface.dart`
- [X] T008 Implement token-auth API service methods using Dio in `lib/data/services/remote_data/implementations/token_auth_api_service.dart`
- [X] T009 Wire new install/login route paths and names in `lib/core/routers/app_routes.dart`
- [X] T010 Update startup/router branching for old/new workflow toggle in `lib/core/routers/router.dart`
- [X] T011 Add localization keys for new install/login states and errors in `lib/core/internationalization/en.arb`
- [X] T012 [P] Add Arabic localization for new install/login states and errors in `lib/core/internationalization/ar.arb`

**Checkpoint**: Foundation ready — user story implementation can begin.

---

## Phase 3: User Story 1 - Validate Installation Before Use (Priority: P1) 🎯 MVP

**Goal**: Deliver the new forced installation screen that validates IP + cluster (+ tenderTypeId=0), supports environment selection, and persists setup metadata.

**Independent Test**: From a device with old setup and new flow enabled, app forces new install, IP is read-only, cluster is editable until success, environment is selectable, validation success persists tenant/store/device setup.

### Tests for User Story 1

- [X] T013 [P] [US1] Add install validation service unit tests in `test/unit/core/services/token_auth_install_service_test.dart`
- [X] T014 [P] [US1] Add install widget interaction test (read-only IP, editable cluster, environment dropdown) in `test/widget/features/install/new_install_widget_test.dart`

### Implementation for User Story 1

- [X] T015 [US1] Create install flow coordinator service for validation and persistence in `lib/core/services/auth/install_validation_service.dart`
- [X] T016 [US1] Implement install success/failure state model in `lib/features/shared-features/Install/new_install_state.dart`
- [X] T017 [US1] Build new installation screen UI with IP + cluster + environment dropdown in `lib/features/shared-features/Install/new_install_widget.dart`
- [X] T018 [US1] Integrate install submit action with token-auth validation API in `lib/features/shared-features/Install/new_install_controller.dart`
- [X] T019 [US1] Persist install response fields (tenantId, storeId, deviceType, environment, installCompleted) in `lib/core/helpers/app_pref.dart`
- [X] T020 [US1] Enforce one-time forced reinstall when new flow is enabled in `lib/core/helpers/install_functions.dart`
- [X] T021 [US1] Route post-install success to new login flow in `lib/core/routers/router.dart`

**Checkpoint**: User Story 1 is independently functional and testable (MVP ready).

---

## Phase 4: User Story 2 - Authenticate Using PIN After Installation (Priority: P2)

**Goal**: Deliver PIN-only login UI that authenticates using saved install context and persists session/tenant fields with secure token handling.

**Independent Test**: After successful install, login accepts PIN, uses saved IP+cluster in request, persists user/session/tenant fields, rejects offline login and invalid credentials with mapped errors.

### Tests for User Story 2

- [X] T022 [P] [US2] Add PIN login service unit tests for success/failure/error mapping in `test/unit/core/services/device_pin_login_service_test.dart`
- [X] T023 [P] [US2] Add login widget test for PIN-only UI and online-required error state in `test/widget/features/login/new_login_widget_test.dart`

### Implementation for User Story 2

- [X] T024 [US2] Create device PIN login orchestration service using saved setup values in `lib/core/services/auth/device_pin_login_service.dart`
- [X] T025 [US2] Implement new login state model for loading/success/error transitions in `lib/features/shared-features/Login/new_login_state.dart`
- [X] T026 [US2] Build new PIN-only login screen in `lib/features/shared-features/Login/new_login_widget.dart`
- [X] T027 [US2] Integrate login submit flow with `AuthenticateDeviceByPinCode` in `lib/features/shared-features/Login/new_login_controller.dart`
- [X] T028 [US2] Persist userId, userName, device metadata, and tenantData keys from login response in `lib/core/helpers/app_pref.dart`
- [X] T029 [US2] Persist `accessToken` via secure storage helper and remove plaintext token writes in `lib/core/helpers/login_helpers.dart`
- [X] T030 [US2] Implement explicit online-required behavior when login API is unreachable in `lib/core/helpers/login_helpers.dart`

**Checkpoint**: User Stories 1 and 2 are independently functional.

---

## Phase 5: User Story 3 - Switch Between Old and New Auth Flow (Priority: P3)

**Goal**: Control rollout by static app config flag while preserving old behavior when disabled.

**Independent Test**: Toggling the static key deterministically selects the old or new install/login flow at startup without mixed session behavior.

### Tests for User Story 3

- [X] T031 [P] [US3] Add router branch selection unit test for new-flow toggle in `test/unit/core/routers/auth_flow_toggle_test.dart`

### Implementation for User Story 3

- [X] T032 [US3] Add centralized helper to read workflow toggle and first-run status in `lib/core/config/auth_flow_config.dart`
- [X] T033 [US3] Wire toggle logic into startup path selection in `lib/core/helpers/find_first_path.dart`
- [X] T034 [US3] Ensure legacy install/login screens remain unchanged when toggle is disabled in `lib/features/shared-features/Login/login_widget.dart`
- [X] T035 [US3] Add safeguard to prevent mixed old/new flow in one app session in `lib/core/routers/router.dart`

**Checkpoint**: All user stories are independently functional.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Finalize quality, documentation, and cross-story consistency.

- [X] T036 [P] Resolve duplicated requirement ID references and align requirement wording in `specs/013-install-login-workflow/spec.md`
- [X] T037 Add implementation notes for exact persisted key names in `specs/013-install-login-workflow/quickstart.md`
- [X] T038 [P] Run lints and fix issues for touched files under `lib/` and `test/` using `flutter analyze`
- [X] T039 Execute targeted test suites for new install/login flow using `flutter test test/unit test/widget`
- [X] T040 Perform end-to-end quickstart validation and update outcomes in `specs/013-install-login-workflow/quickstart.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies.
- **Phase 2 (Foundational)**: Depends on Phase 1 and blocks all user stories.
- **Phase 3 (US1)**: Depends on Phase 2.
- **Phase 4 (US2)**: Depends on Phase 2 and reuses US1 persisted setup outputs.
- **Phase 5 (US3)**: Depends on Phase 2 and integrates with US1/US2 routing.
- **Phase 6 (Polish)**: Depends on all implemented stories.

### User Story Dependencies

- **US1 (P1)**: No dependency on other user stories; true MVP.
- **US2 (P2)**: Depends on US1 persistence contract (saved install context).
- **US3 (P3)**: Depends on foundational routing setup and validates integration with US1/US2.

### Within Each User Story

- Tests first, then state/service, then UI/controller wiring, then persistence/error-path hardening.

### Parallel Opportunities

- T003 and T004 can run in parallel.
- T011 and T012 can run in parallel.
- US1 test tasks (T013, T014) can run in parallel.
- US2 test tasks (T022, T023) can run in parallel.
- Spec/doc polish tasks T036 and T038 can run in parallel.

---

## Parallel Example: User Story 1

```bash
# Run US1 test authoring in parallel
Task: "T013 [US1] Add install validation service unit tests in test/unit/core/services/token_auth_install_service_test.dart"
Task: "T014 [US1] Add install widget interaction test in test/widget/features/install/new_install_widget_test.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 and Phase 2.
2. Complete all US1 tasks (T013-T021).
3. Validate US1 independent test criteria.
4. Demo/ship MVP install validation flow.

### Incremental Delivery

1. Add US1 (forced new install + persistence).
2. Add US2 (PIN auth + secure token/session persistence).
3. Add US3 (toggle rollout safety).
4. Finish with Polish phase quality gates.

### Parallel Team Strategy

1. Team completes Setup + Foundational phases together.
2. Then split:
   - Dev A: US1 implementation
   - Dev B: US2 implementation
   - Dev C: US3 routing/toggle integration
3. Rejoin for Phase 6 polish and final verification.

---

## Notes

- All tasks follow the required checklist format with IDs and file paths.
- `[P]` markers are only used where file-level independence exists.
- Story labels are used only in user story phases.
