<!--
SYNC IMPACT REPORT
==================
Version change: 1.0.0 → 1.1.0
Modified principles: I (Layered Architecture), IV (Hardware Abstraction — wording only)
Rationale: Align constitution with repository reality — Riverpod + feature-first layout per
  `.cursorrules` / `CLAUDE.md`; remove incorrect mandate for `lib/viewModels/` and ViewModel-only state.
Templates requiring updates:
  - .specify/templates/plan-template.md ✅ (Constitution Check section remains generic)
Follow-up TODOs:
  - TODO(RATIFICATION_DATE): Confirm exact project inception date if different from 2026-03-23.
  - TODO(TEAM_APPROVERS): Define amendment approval quorum when team grows.
-->

# Posmena POS Constitution

## Core Principles

### I. Layered Architecture (Riverpod + Clean boundaries)

The project MUST preserve a strict dependency direction for new work:
**presentation (widgets) → application state (Riverpod) → repository → data**
(models, `local_data/`, `remote_data/`).

- **State management**: All **new** code MUST use **Riverpod** (`Provider`, `Notifier`,
  `AsyncNotifier`, etc.) under `lib/providers/` or colocated `*_provider.dart` files next to
  the feature. Legacy `ChangeNotifier` / `provider` package usage MAY remain only in
  explicitly legacy modules until migrated.
- **Widgets / screens** (`lib/features/`, `lib/views/` where used) MUST NOT embed business
  rules or call repositories, API services, or SQLite directly; they read Riverpod providers
  and delegate orchestration to notifiers or repositories as appropriate.
- **Riverpod notifiers and provider modules** MUST NOT import Flutter **widget** libraries
  for UI composition (no `material.dart` / `widgets.dart` in state classes). They may use
  `flutter_riverpod` and pure Dart.
- **Repository** layer owns domain orchestration and combines local + remote sources; the
  **data** layer owns persistence schemas and API client contracts only.
- **New features** MUST live under `lib/features/` (kiosk, mobile, or shared subtrees per
  `AppConfig` / `.cursorrules`), with supporting providers under `lib/providers/` when shared,
  plus `lib/repository/` and `lib/data/` as needed — no collapsing of layers for convenience.

**Rationale**: The codebase is feature-first with Riverpod (see `.cursorrules`, `CLAUDE.md`);
mandating a separate `viewModels/` layer would contradict established patterns and mislead
contributors.

### II. Offline-First Core Operations

All primary POS operations — cart management, price/tax calculation, order creation, and
receipt printing — MUST function without network connectivity.

- Remote sync (back-office API) MUST be non-blocking and handled asynchronously.
- Local SQLite (sqflite) is the authoritative store for menus, orders, and device config.
- If a remote call fails, the app MUST queue the operation and retry; it MUST NOT block
  the cashier or kiosk user.

**Rationale**: POS terminals operate in environments with unreliable internet; a dropped
connection MUST NOT halt a sale.

### III. ZATCA Compliance (NON-NEGOTIABLE)

Every completed sale transaction MUST produce a ZATCA Phase 2-compliant e-invoice QR code
and structured XML payload before the receipt is printed.

- The `zatca_2_invoice_generator` SDK integration MUST NOT be bypassed or mocked in
  production builds.
- Invoice serial numbers and cryptographic signing MUST follow ZATCA specifications exactly.
- Any change to tax calculation logic REQUIRES an explicit ZATCA compliance review note in
  the PR description.

**Rationale**: ZATCA non-compliance carries legal and financial penalties for the merchant.
This principle has zero tolerance for exceptions in production.

### IV. Hardware Abstraction

All hardware interactions — thermal printers (Bluetooth/USB/network), NFC reader, barcode
scanner, and payment terminal (NearPay) — MUST be accessed exclusively through the
abstraction interfaces in `lib/core/` or `lib/sdks/`.

- Widgets and Riverpod notifier/provider implementations MUST NOT call hardware SDKs directly.
- Adding a new hardware integration REQUIRES a new interface/adapter in `lib/core/` or
  `lib/sdks/` before wiring to UI.
- Hardware errors MUST surface to the user as actionable messages, not raw SDK exceptions.

**Rationale**: Multiple printer/payment types are supported; abstraction prevents combinatorial
complexity and allows swapping hardware without touching business logic.

### V. Full Bilingual Support (AR + EN, RTL/LTR)

All user-facing strings MUST be provided in both Arabic and English via
`flutter_localizations`.

- No hard-coded user-facing strings in widget trees; all text MUST use localization keys.
- Layouts MUST be validated in both RTL (Arabic) and LTR (English) orientations.
- Arabic fonts (Almarai, Cairo, bank) MUST be used for Arabic locale; Latin fonts (Rubik)
  for English.
- Date, number, and currency formatting MUST use `intl` with the active locale.

**Rationale**: The primary market is Saudi Arabia where operators and customers expect
native Arabic UI; English is required for non-Arabic-speaking staff.

## Payment & Security Standards

- NearPay SDK MUST be the sole integration for card/NFC payment processing; raw PAN or
  card track data MUST never be stored locally or transmitted to the back-office API.
- Shift open/close and cashier authentication flows MUST be enforced server-side; the app
  MUST validate session state on startup.
- PIN-based login MUST use secure input (no clipboard access, no logging of PIN values).
- Shared preferences MUST NOT store sensitive credentials; use platform secure storage for
  tokens and device secrets.

## Testing & Quality Gates

- Widget tests MUST cover all critical UI flows: login, cart add/remove, checkout, and
  payment confirmation dialogs.
- ZATCA invoice generation MUST have unit tests covering tax rounding, QR encoding, and
  serial number sequencing.
- Integration tests MUST verify offline-to-sync round-trips for order creation.
- A PR that modifies payment, ZATCA, or sync logic MUST include or update relevant tests.
- Tests are otherwise OPTIONAL for pure UI changes unless the feature spec requests them.

## Governance

This constitution supersedes all other practices, conventions, and informal agreements.

- **Amendments**: Any amendment requires a PR with a `constitution:` commit prefix,
  a version bump following semantic versioning (MAJOR/MINOR/PATCH as defined in the
  version policy below), and approval from at least one other contributor.
- **Version policy**:
  - MAJOR — principle removed, redefined, or governance restructured incompatibly.
  - MINOR — new principle or section added, or existing section materially expanded.
  - PATCH — wording clarification, typo fix, or non-semantic refinement.
- **Compliance review**: Every PR description MUST include a one-line "Constitution Check"
  noting which principles are touched or confirming "no impact".
- **Complexity justification**: Any deliberate violation of a principle (e.g., inline
  business logic in a view for a time-critical hotfix) MUST be documented in the PR with
  a follow-up issue to restore compliance.
- **Runtime guidance**: See `.specify/templates/` for spec, plan, and task templates that
  operationalize these principles in day-to-day feature work.

**Version**: 1.1.0 | **Ratified**: 2026-03-23 | **Last Amended**: 2026-04-19
