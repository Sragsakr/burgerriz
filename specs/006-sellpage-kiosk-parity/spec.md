# Feature Specification: Handheld and kiosk ordering parity

**Feature Branch**: `006-sellpage-kiosk-parity`  
**Created**: 2026-04-05  
**Status**: Draft  
**Input**: User description: "Read and analyze menu items readme and kiosk logic; align SellPage-vs-kiosk divergences so SellPage is the entry on mobile devices and kiosk is the entry on kiosk devices, with matched behavior."

## Clarifications

### Session 2026-04-05

- Q: When multi-store is enabled, how should handheld establish store scope before showing the category catalog? → A: Match kiosk **when a settings flag is on** (show split-store / brand selection). When the flag is **off**, **skip** the split-store screen. Normal **handheld staff flow**: **Home → Cashier → Sale type → Customer selection → Sell page** (catalog and cart on Sell page).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Right entry for the device (Priority: P1)

A staff member or customer opens the ordering experience on a **handheld (mobile) device** and follows the **handheld path**: **Home → Cashier → Sale type → Customer selection → Sell page** (the handheld sell/catalog experience). On a **kiosk-class device**, they land on the kiosk ordering flow. They do not have to guess which surface to use based on device.

**Why this priority**: Wrong entry causes confusion, training cost, and inconsistent catalog or pricing context.

**Independent Test**: Configure or emulate each device class, launch ordering, and confirm the initial screen matches the device class without manual navigation to the other flow. On handheld, verify the ordered steps through Sell page.

**Acceptance Scenarios**:

1. **Given** a device classified as handheld/mobile, **When** a staff user runs the normal ordering path, **Then** they pass through **Home → Cashier → Sale type → Customer selection** and arrive at **Sell page** (not the kiosk storefront entry).
2. **Given** a device classified as kiosk, **When** the user starts ordering from the normal app entry, **Then** they arrive at the kiosk ordering experience (store choice, sale type, and menu as designed for kiosk).
3. **Given** a device whose class is ambiguous or misconfigured, **When** ordering starts, **Then** the application applies a documented default and the user still reaches a usable ordering flow (no blank or broken route).

---

### User Story 2 - Same catalog rules in both modes (Priority: P2)

When the business operates **more than one store or menu scope** (e.g. different brands on one deployment), the **same products** appear in handheld and kiosk for the **same active store context and sale type**, subject to the **split-store settings flag** (see FR-009). Handheld no longer shows a broader catalog than kiosk when a store scope is active under the same settings and fallback rules.

**Why this priority**: Prevents selling items that should not appear for the selected store and removes mismatch between what kiosk and handheld staff see.

**Independent Test**: Select a store (or equivalent scope) and sale type on kiosk, note visible products per category; repeat on handheld with the same context and the **same** split-store setting; lists match for every category in the test matrix.

**Acceptance Scenarios**:

1. **Given** an active store scope and a chosen sale type, **When** the user browses categories on kiosk, **Then** only products allowed for that store scope appear.
2. **Given** split-store selection is **enabled** in settings and multi-store applies, **When** the user completes the same store choice and sale type on handheld as on kiosk, **Then** the same set of products appears per category on handheld as on kiosk (no extra items from other scopes).
3. **Given** split-store selection is **disabled** in settings, **When** the user reaches Sell page on handheld, **Then** the catalog follows the **documented deployment fallback** (e.g. configured default store scope or full-menu policy) and remains testable for parity against that policy on kiosk when kiosk uses the same fallback.
4. **Given** a deployment with a **single** store scope (no multi-store split), **When** users order on either surface, **Then** catalog behavior remains consistent and predictable (documented as “full menu” or equivalent).

---

### User Story 3 - Same add-to-cart behavior from the grid (Priority: P2)

On handheld, tapping a product in the category grid starts the **same** addition path as on kiosk: simple items add directly; items needing size or options open the **same style** of customization; combo definitions open the combo builder. Grid taps are not inert.

**Why this priority**: Today handheld grid taps may do nothing while kiosk adds items; parity removes training exceptions and failed taps.

**Independent Test**: For a matrix of products (simple, multi-size, with modifiers, combo), tap from handheld grid and from kiosk grid; observe the same sequence of prompts and the same resulting cart line attributes (where the UX is intentionally shared).

**Acceptance Scenarios**:

1. **Given** a product with a single size and no options, **When** the user taps it on the handheld grid, **Then** it is added to the cart with correct quantity and price without an unnecessary extra dialog.
2. **Given** a product with multiple sizes or required options, **When** the user taps it on the handheld grid, **Then** the user completes the same decision steps as on kiosk before the line appears in the cart.
3. **Given** a combo product, **When** the user taps it on the handheld grid, **Then** the combo selection experience matches kiosk (package steps, completion, cart representation).

---

### User Story 4 - Barcode matches catalog selection rules (Priority: P3)

Scanning a barcode (or manual code entry) on handheld applies the **same** rules as choosing that product from the catalog: if choices are required, the user gets the appropriate flow; pricing and eligibility match the active sale type and store scope.

**Why this priority**: Barcode is a common cashier path; divergence causes wrong lines or inconsistent modifiers.

**Independent Test**: Scan products that mirror Story 3 matrix; compare outcomes to kiosk barcode behavior for the same product and session context.

**Acceptance Scenarios**:

1. **Given** a scannable product that needs options, **When** the user scans it on handheld, **Then** they are not given a simplified path that skips required options compared to kiosk.
2. **Given** active store scope filtering, **When** the user scans a code for a product **not** in scope, **Then** the system responds consistently with kiosk (clear message, no silent add).

---

### Edge Cases

- User switches sale type mid-session on handheld: cart policy (clear vs keep) matches kiosk expectations and is confirmed when needed.
- **Split-store setting off** while multiple brands exist in data: catalog MUST use a **documented fallback** (e.g. default reporting group / store in configuration) so eligibility is never undefined; QA MUST verify fallback matches business policy.
- **Split-store setting on**: handheld MUST present store (brand) selection **before** Sell page catalog when multi-store is enabled, consistent with kiosk’s split-store step.
- Product exists in data but has no price for current sale type: behavior matches documented rules (e.g. allow zero-price line with warning, or block) consistently on both surfaces.
- Very fast repeated taps on a product: no duplicate unintended lines beyond defined merge rules.

## Requirements *(mandatory)*

### Assumptions

- The product already has or will have a **reliable way to classify** the device as handheld vs kiosk (configuration flag, install profile, or hardware profile). This specification does not mandate how that classification is detected.
- **Store scope** (multi-brand / reporting group) is optional per deployment; when absent, “full menu” behavior applies consistently on both surfaces.
- Operators can **turn split-store selection on or off** in settings; when off, handheld skips the split-store screen and relies on a **documented fallback** for catalog scope (see FR-009).
- The team maintains an internal parity description of current kiosk vs handheld behavior; delivery MUST be validated against that reference so gaps are closed deliberately.

### Functional Requirements

- **FR-001**: The system MUST present the **handheld ordering entry** as the default ordering start when the device is classified as mobile/handheld.
- **FR-002**: The system MUST present the **kiosk ordering entry** as the default ordering start when the device is classified as kiosk.
- **FR-003**: When a store scope applies (after any split-store step **or** the documented fallback when split-store is skipped), the system MUST restrict the handheld category catalog to the **same product eligibility** as kiosk for that **effective** scope and the **currently selected sale type**.
- **FR-004**: The system MUST make **category grid product tiles** on handheld respond to tap with the **same branching** as kiosk: direct add for simple lines; customization or combo flow when required.
- **FR-005**: The system MUST use **one consistent customization and pricing outcome** for the same product, options, and quantities on handheld and kiosk (no alternate legacy path that produces different line totals for identical choices).
- **FR-006**: Barcode (and manual code entry where offered) on handheld MUST respect the **same** option/combo requirements and **same** store-scope eligibility as catalog selection on kiosk under the same session context.
- **FR-007**: Session context (at minimum: sale type; and store scope when multi-store is enabled) MUST be **consistent** between surfaces so that visual branding (e.g. store colors) does not imply a different catalog than the one loaded.
- **FR-008**: Where handheld and kiosk intentionally differ only in **layout** (e.g. sidebar vs tabs), the specification of **which products appear** and **how lines are built** MUST still satisfy FR-003 through FR-006.
- **FR-009**: The system MUST provide a **settings (or configuration) control** for “show split store selection” (or equivalent). When **Yes** and multi-store is enabled, handheld MUST show the split-store (brand) step **before** Sell page, matching kiosk’s store-selection behavior. When **No**, handheld MUST **skip** the split-store screen; catalog scope MUST follow a **documented deployment fallback** (e.g. default store / reporting group) and MUST NOT leave eligibility undefined.
- **FR-010**: On handheld, the **normal staff ordering sequence** MUST be: **Home → Cashier → Sale type → Customer selection → Sell page** (Sell page hosts the handheld category catalog and cart interaction for this flow).

### Key Entities

- **App / operator settings**: Includes the split-store visibility flag and any default store scope used when split-store is skipped.
- **Ordering session**: Active device class, sale type, customer context, optional store scope (explicit or fallback), loaded catalog snapshot, cart contents.
- **Product catalog (per session)**: Categories and products visible under current rules; must be comparable across handheld and kiosk for the same session inputs.
- **Cart line**: Product identity, quantity, unit/size, selected options, combo children if applicable, price shown to the user; merge rules when identical lines are added again.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: For a defined QA matrix of at least 20 products across simple, multi-unit, modifier, and combo types, **100%** of cases produce **matching** cart line attributes (unit, options, quantity, and displayed line price) on handheld and kiosk when the same choices are made.
- **SC-002**: For deployments with multi-store scope, **100%** of categories in the QA matrix show **identical** product membership on handheld and kiosk for the same **effective** store scope, sale type, and **split-store setting** (and, when the setting is off, the same documented fallback).
- **SC-003**: **Zero** handheld-only catalog items (items visible on handheld but not on kiosk for the same store and sale type) are found in QA sign-off for scoped deployments.
- **SC-004**: **95%** of handheld users in usability or pilot testing complete “add this product from the grid” on first try without reporting that “nothing happened” or that the wrong dialog appeared (measured against a short task script).
- **SC-005**: Support or operations logs show **no new** class of tickets citing “handheld menu different from kiosk for same store” within 30 days of release (baseline agreed with product owner).
