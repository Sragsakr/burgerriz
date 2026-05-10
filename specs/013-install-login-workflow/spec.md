# Feature Specification: Installation and Device PIN Login

**Feature Branch**: `013-install-login-workflow`  
**Created**: 2026-05-07  
**Status**: Draft  
**Input**: User description: "Create new installation page and new login page with app-config switch, new installation validation flow, and device PIN authentication using saved installation values."

## Clarifications

### Session 2026-05-07

- Q: When the new workflow flag is enabled, should devices be forced through the new installation step even if setup data already exists? → A: Force all devices to run the new installation step once when the new workflow flag is enabled.
- Q: Should login support offline fallback when the authentication API is unreachable? → A: Always require online PIN authentication with no offline login fallback.
- Q: After a failed installation validation, should the cluster ID remain editable? → A: Keep cluster ID editable until installation validation succeeds.
- Q: Should the login screen display saved IP and cluster values to users? → A: Login screen shows PIN field only; saved IP and cluster are hidden.
- Q: How should tender type be handled in installation validation for the two-input installation UI? → A: Always send tenderTypeId = 0.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Validate Installation Before Use (Priority: P1)

As a store operator, I can open a new installation page, review the detected device IP address, enter a cluster identifier, and validate the installation so the device can be authorized before login.

**Why this priority**: Device installation validation is the entry gate for the full workflow. Without successful validation, login cannot proceed.

**Independent Test**: Can be fully tested by entering a cluster identifier on a clean device and validating installation info. The feature delivers value by confirming whether the device has an active license and valid setup.

**Acceptance Scenarios**:

1. **Given** a new device with no saved installation data, **When** the operator opens installation and submits cluster ID with the auto-detected IP, **Then** the system validates the installation and stores returned tenant, store, and device metadata when valid.
2. **Given** installation validation fails, **When** the system receives one or more error messages, **Then** it shows the failure reasons to the operator and does not mark setup as complete.

---

### User Story 2 - Authenticate Using PIN After Installation (Priority: P2)

As a cashier, I can open a new login page that uses the previously saved installation IP and cluster values and authenticate with a PIN code to start a session.

**Why this priority**: Authentication is required for daily operations but depends on successful installation setup.

**Independent Test**: Can be fully tested by using previously saved installation values and submitting a valid PIN. The feature delivers value by enabling authorized staff access without re-entering device setup information.

**Acceptance Scenarios**:

1. **Given** valid saved installation data, **When** the cashier submits a correct PIN, **Then** the system creates a user session and stores authentication response data required for authorized app use.
2. **Given** valid saved installation data, **When** the cashier submits an invalid PIN, **Then** the system shows the corresponding authentication error and keeps the user on login.

---

### User Story 3 - Switch Between Old and New Auth Flow (Priority: P3)

As an administrator, I can enable or disable the new installation/login workflow through a static app configuration key so rollout can be controlled safely.

**Why this priority**: Controlled rollout reduces operational risk and allows fallback to existing screens.

**Independent Test**: Can be fully tested by toggling the configuration key and confirming the app starts with the expected installation/login flow in each mode.

**Acceptance Scenarios**:

1. **Given** the new-flow switch is enabled, **When** the app starts in an unconfigured state, **Then** it presents the new installation and new login sequence.
2. **Given** the new-flow switch is enabled for the first time on a configured device, **When** the app starts, **Then** it requires one fresh pass through the new installation flow before allowing new login.
3. **Given** the new-flow switch is disabled, **When** the app starts, **Then** it uses the existing installation and login workflow without behavior changes.

### Edge Cases

- Installation validation returns multiple failure reasons in one response message.
- Cluster identifier is missing, zero, or non-numeric at submission time.
- Device IP cannot be detected at runtime; installation must not continue silently.
- Authentication is attempted before installation data has been saved.
- Authentication fails because device is inactive, unregistered, or cluster is not found.
- Installation is valid when tender type is omitted or provided as zero.
- Authentication API is unreachable; login must fail with an online-required message.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST provide a new installation page that includes exactly two installation fields: a device IP value and a cluster identifier.
- **FR-002**: System MUST auto-populate the device IP on the installation page and MUST prevent the user from editing it.
- **FR-003**: System MUST allow the user to enter and submit the cluster identifier from the installation page and keep it editable until installation validation succeeds.
- **FR-004**: System MUST validate installation data against the installation-validation endpoint using device IP and cluster identifier, and MUST always send tender type as 0.
- **FR-005**: System MUST treat installation as successful only when validation response indicates success and MUST store the returned tenant, store, and device metadata.
- **FR-006**: System MUST show a clear failure result when installation validation fails, including all returned validation error messages.
- **FR-007**: System MUST persist installation data and validation result data so it is available to the login workflow across app restarts.
- **FR-008**: System MUST provide a new login page that keeps the same visual layout as the current login experience while using the new authentication workflow, with PIN entry only.
- **FR-009**: System MUST authenticate login using PIN code together with the saved installation IP and cluster identifier.
- **FR-010**: System MUST block login submission when required installation data is missing and direct the user to complete installation first.
- **FR-011**: System MUST store successful authentication response data required for an active user session, including access token, token expiry, user identity, roles, tenant info, and device metadata.
- **FR-012**: System MUST show user-facing authentication errors for invalid cluster, unregistered device, inactive device, and invalid PIN outcomes.
- **FR-013**: System MUST include a static app configuration switch that controls whether the app uses the new installation/login workflow or the existing workflow.
- **FR-014**: System MUST apply the workflow switch consistently from app start so users do not see mixed old/new installation-login flows in the same session.
- **FR-015**: System MUST require a one-time completion of the new installation step for each device when the new workflow is enabled, even if prior setup data exists from the old workflow.
- **FR-016**: System MUST require online PIN authentication for every login attempt and MUST not allow offline login when the authentication service is unreachable.

### Key Entities *(include if feature involves data)*

- **Installation Input**: User-provided and system-provided installation values, including auto-detected device IP and entered cluster identifier.
- **Installation Validation Result**: Validation outcome containing status, message(s), tenant ID, store ID, and device type.
- **Saved Device Setup**: Persisted installation context reused by login, including device IP, cluster identifier, tenant/store/device metadata, and setup completion status.
- **Device Login Request**: PIN-based login payload that combines entered PIN with saved installation values.
- **Authenticated Session**: Persisted login result containing token, expiry, user identity, role list, tenant details, and device/store context.
- **Workflow Mode Flag**: Static configuration value that selects either the new or existing installation/login flow.

## Assumptions

- The installation screen captures cluster identifier as the second input; tender type is not user-entered and is always sent as 0 during validation.
- IP auto-detection happens before installation submission and is available for display in normal network conditions.
- Existing workflow remains unchanged when the new-flow configuration switch is disabled.
- Authentication token lifetime and refresh behavior remain aligned with existing app session behavior.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 95% of newly provisioned devices complete installation validation in a single attempt when correct cluster data is entered.
- **SC-002**: 100% of successful PIN logins use saved installation values without requiring users to re-enter IP or cluster information.
- **SC-003**: In user acceptance testing, 90% of operators can complete installation and first login in under 2 minutes on a configured network.
- **SC-004**: 100% of known authentication failure types produce a distinct, user-visible error outcome that maps to the returned server error category.
- **SC-005**: Toggling the workflow mode flag changes startup flow deterministically for all test devices, with no mixed-flow sessions observed during validation.
