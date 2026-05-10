# Feature Specification: Remove Multi-Store ReportGroup Feature from Kiosk Mode

**Feature Branch**: `009-kiosk-single-store`  
**Created**: 2026-04-07  
**Status**: Draft  

## Overview

Kiosk mode currently supports multi-store operation via the ReportGroup feature, allowing operators to switch between different store/brand variants within a single session. This feature will be removed to simplify kiosk operation to single-store mode (parity with handheld/mobile mode). The kiosk flow will be streamlined from multi-store selection at entry to direct menu browsing after sale-type selection.

## User Scenarios & Testing

### User Story 1 - Remove Store Selection UI from Kiosk Entry (Priority: P1)

When kiosk starts, operators should no longer see the store/ReportGroup selector screen. Instead, the system automatically initializes with the default store configuration and proceeds directly to the main menu entry point.

**Why this priority**: Removes confusing multi-store UI from kiosk, simplifies entry flow. This is the primary user-facing change and must work correctly for the feature to be viable.

**Independent Test**: Boot kiosk in kiosk mode → system skips store selector screen → entry screen displays with menu categories → operator can immediately start selecting sale type and products.

**Acceptance Scenarios**:

1. **Given** kiosk app launches in kiosk mode, **When** initialization completes, **Then** entry screen displays directly without store selector.
2. **Given** entry screen is active, **When** operator selects a sale type, **Then** menu loads with single store's products (no store-specific filtering).
3. **Given** after completing a sale, **When** "finish" button is pressed, **Then** system redirects to entry screen with Posmena logo (ready for next customer).

---

### User Story 2 - Remove ReportGroup Database Tables and Clean Data References (Priority: P2)

All database tables, columns, and references related to ReportGroup store filtering must be removed or deprecated safely. Data structures should no longer track store associations.

**Why this priority**: Technical cleanup is necessary to remove unused code paths and data. While not directly visible to users, it prevents confusion and reduces maintenance burden.

**Independent Test**: After cleanup, kiosk app launches successfully without ReportGroup lookups → all product queries return full catalog without filtering → no errors in database initialization.

**Acceptance Scenarios**:

1. **Given** database is initialized, **When** querying menu items, **Then** no ReportGroup filtering is applied.
2. **Given** sales data is created, **When** saved to database, **Then** no store/ReportGroup association is stored.

---

### User Story 3 - Simplify Store Initialization and Session Management (Priority: P3)

Kiosk initialization should no longer require ReportGroup selection or store-specific configuration. Session defaults to single-store mode automatically.

**Why this priority**: Eliminates conditional logic paths related to store selection, making code more maintainable.

**Independent Test**: App initialization completes without ReportGroup selection dialog → kiosk operates with unified product catalog.

**Acceptance Scenarios**:

1. **Given** app starts, **When** initialization runs, **Then** no store selection prompt appears.
2. **Given** menu products load, **When** displayed to operator, **Then** all products show (unfiltered by store).

---

### Edge Cases

- What happens if legacy ReportGroup data exists in the database? (Should be cleared or migrated during app startup)
- What if a sale partially references ReportGroup IDs? (Sales should continue to work; ReportGroup references can be nullified safely)
- Should multi-store configuration option be removed from installation/settings? (Yes, completely remove from settings UI)

---

## Requirements

### Functional Requirements

- **FR-001**: Kiosk mode MUST skip the store/ReportGroup selector screen on startup and proceed directly to entry screen.
- **FR-002**: Kiosk mode MUST operate with a single unified product catalog (no per-store filtering).
- **FR-003**: Menu loading MUST not filter products based on ReportGroup ID; all products for the selected price-list are displayed.
- **FR-004**: Sales data creation MUST NOT require or reference ReportGroup ID.
- **FR-005**: After-sale routing MUST return to entry screen with Posmena logo display, ready for next customer (existing behavior preserved).
- **FR-006**: Database initialization MUST clean up any orphaned ReportGroup references; app MUST not attempt to load store selectors.
- **FR-007**: Settings/installation UI MUST remove all multi-store configuration options (no ReportGroup selection).
- **FR-008**: App session MUST default to a single "default store" mode, eliminating store-switching code paths.

### Key Entities

- **ReportGroup Table**: Will be deprecated/unused. Safe to delete or leave empty.
- **Product Filtering**: Currently filtered by `reportGroupId` → will be unified to single catalog.
- **Session State**: `reportGroupThemeProvider` and related store-switching logic → will be simplified or removed.

---

## Success Criteria

### Measurable Outcomes

- **SC-001**: Kiosk app launches and displays entry screen within 2 seconds (same as current), without store selector.
- **SC-002**: Operator can complete a full transaction (select sale type → browse menu → add items → checkout) without encountering ReportGroup selection or switching.
- **SC-003**: Menu product count displayed matches full unified catalog (100% of products, not filtered subset).
- **SC-004**: 100% of existing test scenarios pass after ReportGroup removal (no regressions in flow).
- **SC-005**: Database initialization succeeds on fresh install and on upgrade from prior version (backward-compatible).

---

## Assumptions

1. **Single default store configuration**: System will operate with a single "default" ReportGroup equivalent or no grouping at all.
2. **Legacy data cleanup**: Any existing ReportGroup data in database can be safely cleared on app startup if needed.
3. **Existing kiosk flow preserved**: Entry → Cashier → Sell Page → Sale Type Selection → Menu → Checkout → Entry (this flow remains unchanged).
4. **Mobile mode unaffected**: Handheld/mobile mode already operates single-store; no changes needed.
5. **No customer-facing store selection**: Operators will not have option to switch stores during a session.

---

## Implementation Scope

### In Scope (Must Remove)
- ReportGroup selector screen (SplitStoresScreen)
- Store-switching UI components and navigation
- ReportGroup filter logic in menu product loading
- ReportGroup-specific theme/configuration selection
- Multi-store configuration in installation/settings

### Out of Scope (Keep As-Is)
- Existing kiosk flow structure (entry → cashier → sell → checkout → entry)
- Product variant selection and customization
- Pricing and promotion logic
- Payment processing
- Receipt printing
- Mobile/handheld mode

---

## Related Documentation

- See CLAUDE.md for current dual-UI architecture and ReportGroup usage patterns
- Existing ProductTapHandler and MenuCatalogPreloadHelper will require updates to remove ReportGroup filtering
