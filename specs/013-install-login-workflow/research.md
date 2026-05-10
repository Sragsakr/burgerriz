# Research: Installation and Device PIN Login

## Decision 1: Token Persistence Boundary

- **Decision**: Store access token in secure storage semantics (or existing secure token mechanism), while storing non-sensitive identifiers (userId, userName, tenant/store IDs, tenant metadata) in `AppPreferences`.
- **Rationale**: Project constitution explicitly forbids storing sensitive credentials in plain shared preferences; access token is sensitive.
- **Alternatives considered**:
  - Store everything in `AppPreferences` (rejected: security violation).
  - Store everything in SQLite (rejected: unnecessary scope and migration overhead for this feature).

## Decision 2: Environment Dropdown Source

- **Decision**: Use existing environment enum/options as the dropdown source and persist selected environment in one canonical preferences key used by startup/network configuration.
- **Rationale**: Reuses existing app environment model, minimizes drift, and keeps route/API selection deterministic.
- **Alternatives considered**:
  - Hardcoded string dropdown in UI only (rejected: fragile and inconsistent).
  - Server-driven environment list (rejected: out of current feature scope).

## Decision 3: First-Run Behavior Under New Flow Flag

- **Decision**: When new flow is enabled, force one new-install completion before login, then treat saved setup as source of truth until explicitly reinstalled.
- **Rationale**: Matches clarification decision and prevents mixed old/new configuration state.
- **Alternatives considered**:
  - Auto-migrate old setup silently (rejected: risk of stale/partial data).
  - Force install on every app start (rejected: poor UX and unnecessary friction).

## Decision 4: Install Validation Request Shape

- **Decision**: Always submit `tenderTypeId = 0` from the new two-input install flow.
- **Rationale**: Explicitly confirmed in clarification; keeps UI to IP + cluster only.
- **Alternatives considered**:
  - Omit `tenderTypeId` (rejected: less explicit than clarified contract).
  - Add tender input field (rejected: out of requested UX).

## Decision 5: Exact Persistence Map

- **Decision**: Define explicit key mappings in implementation docs/tasks for:
  - Install response: tenant ID, store ID, device type, selected environment.
  - Login response: access token (secure), user ID, user name.
  - Tenant payload from login: tenant ID, tenancy name, tenant display name (new dedicated keys).
- **Rationale**: Removes ambiguity raised in checklist; ensures deterministic reads across startup/login.
- **Alternatives considered**:
  - Reuse older generic keys without mapping table (rejected: ambiguity/conflicts).
  - Persist whole response blob as JSON (rejected: poor maintainability and migration safety).
