# Implementation Plan: Installation and Device PIN Login

**Branch**: `013-install-login-workflow` | **Date**: 2026-05-07 | **Spec**: `/Volumes/Storage/projects/posmena/posmena-pos/specs/013-install-login-workflow/spec.md`  
**Input**: Feature specification from `/specs/013-install-login-workflow/spec.md`

## Summary

Implement a new gated install/login workflow behind a static config flag: a forced one-time installation step validates device context by IP + cluster and stores setup metadata, followed by PIN-based login using saved setup values. Extend requirements to include environment selection during install and explicit persistence mapping for tenant/store and login session/tenant payload fields.

## Technical Context

**Language/Version**: Dart 3.x (Flutter 3.32.8 stable)  
**Primary Dependencies**: `flutter_riverpod`, `go_router`, `dio` services via existing remote_data services, `shared_preferences` (`AppPreferences`)  
**Storage**: SQLite (`AppDB` tables) + SharedPreferences (`AppPreferences`) + secure storage for auth token material  
**Testing**: `flutter test` (unit/widget), `flutter analyze`  
**Target Platform**: Android POS handheld/kiosk devices  
**Project Type**: Mobile app (Flutter, feature-first)  
**Performance Goals**: Install validation and login submission should complete user-visible flow in under 2 minutes for first-time setup (per spec SC-003)  
**Constraints**: New UI must preserve existing login layout style; PIN-only login UI; online authentication mandatory; bilingual readiness (AR/EN)  
**Scale/Scope**: 2 new screens/flows (install + login variants), app-config switch routing, preferences persistence updates, token/session persistence integration

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **I. Layered Architecture**: PASS — plan keeps UI in `features/*`, state/orchestration in providers/helpers/services, remote calls through existing service interfaces.
- **II. Offline-First Core Operations**: PASS — this feature is configuration/auth entry flow; no core sales flow regression; explicit online login requirement is allowed for auth boundary.
- **III. ZATCA Compliance**: PASS — feature does not alter invoicing/tax/receipt generation.
- **IV. Hardware Abstraction**: PASS — no direct hardware SDK additions.
- **V. Full Bilingual Support**: PASS — new UI copy must use localization keys.
- **Payment & Security Standards**: PASS WITH CONSTRAINT — PIN must not be logged; access token persistence must use secure storage semantics (not plaintext prefs), while non-sensitive IDs/names can use existing preference keys.

## Project Structure

### Documentation (this feature)

```text
specs/013-install-login-workflow/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── token-auth-install-login.yaml
└── tasks.md
```

### Source Code (repository root)

```text
lib/
├── core/
│   ├── config/
│   │   └── app_config.dart
│   ├── constants/
│   │   └── app_urls.dart
│   ├── helpers/
│   │   ├── app_pref.dart
│   │   ├── install_functions.dart
│   │   └── login_helpers.dart
│   └── routers/
│       └── router.dart
├── data/
│   └── services/remote_data/
│       ├── interfaces/
│       └── implementations/
└── features/shared-features/
    ├── Install/
    └── Login/

test/
├── unit/
└── widget/
```

**Structure Decision**: Keep existing feature-first Flutter structure; implement new install/login behavior in shared feature screens and helpers, with routing switch in core router/config and API wiring in existing remote service layer.

## Phase 0: Research Plan

1. Confirm persistence boundary: what must stay in SharedPreferences vs secure storage under project security standards.
2. Define environment dropdown source and mapping strategy to API base URLs without breaking existing environment enum usage.
3. Define deterministic migration/reset behavior for first-time forced new installation when prior old-flow preferences exist.
4. Define exact persistence key schema for installation response and login response fields to remove checklist ambiguity.

## Phase 1: Design Plan

1. Model entities and state transitions for install validation, saved setup, and authenticated session.
2. Produce API contracts for `ValidateInstallationInfo` and `AuthenticateDeviceByPinCode`, including error mapping.
3. Author quickstart validation steps for manual QA and regression checks.
4. Update agent context to include current feature technologies and constraints.

## Post-Design Constitution Re-Check

- **Architecture gate**: PASS — design keeps orchestration out of widgets and uses existing helper/provider boundaries.
- **Security gate**: PASS — token persistence explicitly constrained to secure storage semantics; PIN never persisted from login input.
- **Localization gate**: PASS — design includes localization requirement for all new strings.
- **No unjustified violations detected**.

## Complexity Tracking

No constitution violations requiring justification.
