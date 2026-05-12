# Feature Specification: Install Page — Cluster Validation & Setup

**Feature Branch**: `014-install-cluster-validation`  
**Created**: 2026-05-10  
**Status**: Draft  
**Input**: User description: "Create a standalone install page with three inputs (Cluster ID, IP Address, Environment) and its API service for validating and saving the response. The spec must be standalone and portable to another app."

## Overview

A minimal, standalone installation/setup page that collects three configuration inputs — **Cluster ID**, **IP Address**, and **Environment** — validates them against a remote API, persists the validated response, and enables the app to proceed to the next flow (typically login). The entire feature (UI, controller, service, models) must be self-contained and portable across apps without coupling to any host-app-specific logic.

## Clarifications

### Session 2026-05-10

- Q: Is the `environment` value sent to the validation API as a request parameter, or is it only used client-side to resolve which server URL to call? → A: Environment is **only used client-side** to resolve the base URL for the API call; the API request body contains only `clusterId` and `ipAddress`.
- Q: What should the Environment dropdown show by default on a fresh install? → A: Pre-select **Production** as the default environment option.

## User Scenarios & Testing *(mandatory)*

### User Story 1 — First-Time Device Setup (Priority: P1)

A user unboxes a new POS device and launches the app for the first time. The app has no stored configuration. The user is presented with the Install page containing three fields: Cluster ID (numeric), IP Address, and Environment (dropdown). The user enters the Cluster ID provided by their administrator, the IP address auto-detects but remains editable, and they select an Environment from the list. On tapping "Validate & Save", the system calls the validation API. If the API confirms the configuration is valid, the response data (tenant ID, store ID, device type) is persisted locally and the user is directed to the login screen.

**Why this priority**: This is the core flow — without a successful install validation the device cannot proceed to any other functionality. It represents the minimum viable product.

**Independent Test**: Can be fully tested by entering valid Cluster ID, IP, and Environment, submitting, and verifying that persisted data exists after the API returns a successful validation response.

**Acceptance Scenarios**:

1. **Given** a fresh device with no stored config, **When** the user opens the app, **Then** the Install page is displayed with three empty fields (Cluster ID, IP Address, Environment dropdown)
2. **Given** all three fields are populated with valid values, **When** the user taps "Validate & Save", **Then** a loading indicator appears, the validation API is called with clusterId and ipAddress (environment resolves the base URL client-side), and on success the response data is saved locally
3. **Given** the API returns `isValid: true` with `tenantId`, `storeId`, and `deviceType`, **When** the response is processed, **Then** these values plus the original inputs (clusterId, IP, environment) are persisted and the user navigates to the next screen

---

### User Story 2 — Validation Failure Handling (Priority: P2)

A user enters an invalid Cluster ID or the wrong Environment/IP combination. The validation API returns `isValid: false` with an error message. The user sees a clear error message on the form and can correct their input and retry without losing the values they entered.

**Why this priority**: Error handling is essential for user experience but depends on the happy-path submission being functional first.

**Independent Test**: Can be tested by submitting invalid combinations and verifying error messages appear while field values are preserved.

**Acceptance Scenarios**:

1. **Given** the user submits with an unrecognized Cluster ID, **When** the API returns `isValid: false` with message "Cluster not found", **Then** an error message is displayed and all field values are preserved
2. **Given** the API call fails due to network connectivity, **When** no response is received within the timeout period, **Then** a user-friendly network error message is shown and the form remains editable

---

### User Story 3 — Re-Configuration of an Already Installed Device (Priority: P3)

An administrator needs to reconfigure a device that has already been set up (e.g., moved to a different store or cluster). They access the Install page and see the previously stored values pre-filled. They update the Cluster ID and/or Environment, re-validate, and the new configuration replaces the old one.

**Why this priority**: Re-configuration is important but less frequent than initial setup; the feature must support it but it's not the primary flow.

**Independent Test**: Can be tested by completing Story 1 first, then navigating back to the Install page and verifying fields are pre-filled with saved values, then changing values and re-submitting.

**Acceptance Scenarios**:

1. **Given** a device with stored configuration, **When** the user navigates to the Install page, **Then** all three fields are pre-filled with the previously saved values
2. **Given** pre-filled fields, **When** the user changes the Cluster ID and re-validates successfully, **Then** the new configuration replaces the old one in persistent storage

---

### Edge Cases

- What happens when the user enters a non-numeric value in the Cluster ID field? → Client-side validation rejects it with "Cluster ID must be a positive number"
- What happens when IP Address is left empty and Environment is NOT LocalHost? → IP Address field remains editable; an empty IP is still sent to the API for validation (the server decides)
- What happens when Environment is LocalHost and IP Address is empty? → Show "IP Address is required for LocalHost environment" before submission
- What happens when the API call times out? → Display "Connection timed out. Please check your network and try again."
- What happens when the user rapidly taps "Validate & Save" multiple times? → The button is disabled during the in-flight request to prevent duplicate submissions
- What happens if the app is killed mid-save before persistence completes? → On next launch, the install page appears with empty/default values; the user must re-enter and re-validate

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The Install page MUST display exactly three input fields: Cluster ID (numeric), IP Address (text), and Environment (dropdown selection)
- **FR-002**: The Environment dropdown MUST offer the following options: Production, Staging, Testing, Development, LocalHost. On a fresh install (no stored configuration), the dropdown MUST default to **Production**
- **FR-003**: Cluster ID MUST be validated client-side as a positive integer before API submission
- **FR-004**: IP Address MUST be auto-detected from the device's network interfaces and pre-filled, but MUST remain editable by the user
- **FR-005**: IP Address MUST be required when Environment is set to LocalHost; for other environments it is optional
- **FR-006**: The page MUST provide a "Validate & Save" action that sends Cluster ID and IP Address to the validation API endpoint; Environment is used only client-side to determine the base URL for the API call
- **FR-007**: The validation API MUST accept Cluster ID (integer) and IP Address (string) and return a response indicating validity, tenant ID, store ID, device type, and an optional message
- **FR-008**: Upon successful validation (`isValid: true`), the system MUST persist the following data locally: clusterId, ipAddress, environment, tenantId, storeId, deviceType, and a flag indicating installation is complete
- **FR-009**: Upon failed validation (`isValid: false`), the system MUST display the API-returned error message (or a fallback message) and preserve all field values
- **FR-010**: The "Validate & Save" button MUST be disabled while a validation request is in-flight to prevent duplicate submissions
- **FR-011**: Network errors (timeout, no connectivity) MUST be caught and shown as user-friendly messages without exposing technical details
- **FR-012**: If previously stored configuration exists, the Install page MUST pre-fill all three fields with the stored values on load
- **FR-013**: The selected Environment MUST determine the base URL used for the validation API call (each environment maps to a distinct server endpoint)
- **FR-014**: The entire feature (UI, controller, service, models) MUST be self-contained and not depend on host-app-specific modules, services, or state management outside its own scope

### Key Entities

- **InstallRequest**: Carries the two inputs sent to the validation endpoint — clusterId (integer) and ipAddress (string). Environment is NOT included in the request; it resolves the base URL client-side.
- **InstallValidationResponse**: Carries the server response — isValid (boolean), tenantId (integer), storeId (integer), deviceType (integer), message (string) — returned from the validation endpoint
- **InstallConfig**: The persisted configuration — clusterId, ipAddress, environment, tenantId, storeId, deviceType, installCompleted (boolean) — stored on-device after successful validation
- **EnvironmentOption**: An enumeration of available environments — Production, Staging, Testing, Development, LocalHost — each mapping to a specific API base URL

## Assumptions

- The validation endpoint accepts a GET or POST request with clusterId and ipAddress as parameters; environment is not sent to the server
- This is a standalone/portable spec; any app implementing it will provide its own navigation mechanism after install completion
- The auto-detected IP uses the device's active network interface (Wi-Fi/ethernet) and is a best-effort detection that the user can override
- "Validate & Save" is the primary action; there is no separate "Save without validating" flow
- The API endpoint path and exact parameter names are implementation details; the contract is defined by the request/response shapes in the Key Entities
- Environment-to-base-URL mapping is configurable per implementing app; the spec defines the five supported environment names but not their URLs

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A new user can complete device installation in under 30 seconds (3 fields + 1 tap), assuming a stable network connection
- **SC-002**: 100% of mandatory fields are validated client-side before submission, preventing unnecessary API calls for malformed input
- **SC-003**: On validation failure, the user sees a clear error message within 1 second of the API response, and all entered field values are preserved
- **SC-004**: After successful validation, all 7 persisted config values are retrievable on next app launch, and the install-complete flag prevents re-showing the install page
- **SC-005**: The feature can be extracted as a standalone module and integrated into a different app by providing only: (a) local storage interface, (b) navigation callback, (c) environment-to-URL mapping — with zero modifications to the feature's internal code