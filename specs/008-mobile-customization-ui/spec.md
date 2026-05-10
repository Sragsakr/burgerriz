# Feature Specification: Mobile-Adaptive Customization UI

**Feature Branch**: `008-mobile-customization-ui`  
**Created**: 2026-04-07  
**Status**: Draft  
**Input**: User description: "create plan for update ui for ItemCustomizationDialog and ComboMealWidget if app mode is mobile to be more adaptive to mobile apps ui ux"

## Overview

The product customization dialog (`ItemCustomizationDialog`) and the combo meal builder (`ComboMealWidget`) are currently designed for large-screen kiosk touchscreens. When the app runs in **handheld/mobile mode** (cashier device), both screens appear as full-screen-filling dialogs that feel out of place on a phone: the hero image is oversized, UOM option tiles are arranged in a 4-column kiosk grid, and the layout wastes vertical space on a smaller display.

This feature adapts both screens — conditioned on mobile app mode — to follow standard mobile UX patterns: a bottom sheet presentation, compact image header, scrollable single-page content, appropriate column counts, and proper safe-area handling. The kiosk experience is left completely unchanged.

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Cashier Customizes a Product on a Phone (Priority: P1)

A cashier taps a product card on their handheld device. The customization screen slides up from the bottom as a sheet — familiar, thumb-reachable, and dismissible with a swipe. They pick a size, select modifiers, and confirm — all without the screen feeling like a shrunken kiosk.

**Why this priority**: This is the primary daily interaction for handheld cashiers. A poorly adapted UI directly slows down order taking.

**Independent Test**: Can be fully tested by opening a customizable product in mobile mode and confirming the sheet looks and behaves like a native mobile bottom sheet.

**Acceptance Scenarios**:

1. **Given** the app is in mobile mode and a cashier taps a customizable product, **When** the customization screen appears, **Then** it slides in from the bottom as a modal sheet — not as a centered dialog.
2. **Given** the customization sheet is open, **When** the cashier swipes downward on the sheet handle, **Then** the sheet dismisses and returns a cancelled result.
3. **Given** the sheet is open with UOM options, **When** the cashier views the size selection grid, **Then** options are shown in 2 columns (not 4), making each tile comfortably tappable with a thumb.
4. **Given** the sheet is open, **When** the cashier scrolls down through modifiers, **Then** all content is reachable in a single scrollable area without pagination steps.
5. **Given** the cashier is ready to confirm and taps "Add", **When** all required selections are made, **Then** the item is added to the cart and the sheet closes with a success result.

---

### User Story 2 — Cashier Builds a Combo Meal on a Phone (Priority: P1)

A cashier taps a combo meal product. The combo meal builder opens as a mobile bottom sheet. Each combo package is listed in a scrollable single-page layout. The cashier selects items per package, sees the running total, and adds the combo to the cart.

**Why this priority**: Combo meals are a high-frequency order type; usability problems here affect throughput directly.

**Independent Test**: Can be fully tested by opening a combo product in mobile mode and verifying the sheet presentation and scrollable package layout.

**Acceptance Scenarios**:

1. **Given** the app is in mobile mode and a cashier taps a combo meal product, **When** the combo builder appears, **Then** it opens as a bottom sheet with a compact header and scrollable package list.
2. **Given** the combo sheet is open, **When** the cashier scrolls through packages, **Then** all packages are visible in a single continuous scroll — no pagination or separate steps.
3. **Given** not all required package items have been selected, **When** the cashier views the action button, **Then** the button clearly communicates what is still incomplete and is disabled.
4. **Given** all packages are complete, **When** the cashier taps "Add to Cart", **Then** the combo is added and the sheet closes.

---

### User Story 3 — Cashier Edits an Existing Cart Item on a Phone (Priority: P2)

A cashier opens an item already in the cart to modify its variants. The edit flow opens the same mobile-adapted customization sheet with previous selections pre-populated. The cashier changes a modifier and taps "Update".

**Why this priority**: Edit flow reuses the same component; the adaptation must work in both add and edit modes.

**Independent Test**: Can be fully tested by adding a customizable product to cart, tapping it to edit, verifying the sheet opens with pre-filled selections and "Update" completes correctly.

**Acceptance Scenarios**:

1. **Given** a customizable item is in the cart and the cashier opens it for editing, **When** the mobile customization sheet appears, **Then** all previously selected options are pre-filled.
2. **Given** the cashier changes a selection and taps "Update", **When** all validations pass, **Then** the cart item is updated and the sheet closes.

---

### Edge Cases

- What happens when a product has no UOM options, no modifiers, and no variants? The sheet confirms immediately with no content shown.
- What happens when the cashier dismisses the sheet by swiping before making required selections? Treated as a cancel — no item is added or updated.
- What happens when the product image fails to load? The compact image header degrades gracefully (placeholder or collapsed gap).
- What happens when there are many modifier groups and the content is very long? The sheet is scrollable and does not clip content.
- What happens if the sheet is opened in landscape orientation on a phone? The sheet height adapts without overflow.
- What appears while combo packages are loading? A centered spinner is shown inside the sheet body until data is ready.

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: When app mode is handheld/mobile, `ItemCustomizationDialog` MUST open as a modal bottom sheet instead of a centered dialog.
- **FR-002**: When app mode is handheld/mobile, `ComboMealWidget` MUST open as a modal bottom sheet instead of a centered dialog.
- **FR-003**: The mobile bottom sheet MUST be fixed at 85% of screen height with a visible drag handle at the top; content that exceeds the available area scrolls inside the sheet.
- **FR-004**: The product image header in mobile mode MUST be compact (maximum 160 px tall), leaving more vertical space for selections.
- **FR-005**: UOM size options in mobile mode MUST be arranged in a 2-column grid with each tile meeting a minimum 48 dp touch target height.
- **FR-006**: All customization content (UOM, modifiers, variants) in mobile mode MUST appear in a single scrollable page — no multi-step/paginated wizard flow.
- **FR-007**: The bottom action bar (quantity controls + confirm button) MUST be pinned to the sheet bottom and respect the device safe-area inset.
- **FR-008**: The kiosk-mode presentation and layout of both components MUST remain completely unchanged. The mobile experience is delivered via two new dedicated widgets (`MobileItemCustomizationSheet`, `MobileComboMealSheet`); the existing `ItemCustomizationDialog` and `ComboMealWidget` files MUST NOT be modified.
- **FR-009**: The mobile sheet MUST display a live running total that updates immediately after each selection change.
- **FR-010**: Required selection groups MUST show their minimum requirement label and display an inline error when confirmation is attempted without satisfying it.
- **FR-011**: Edit mode MUST pre-populate all previously selected options when the sheet opens.
- **FR-012**: The combo meal mobile sheet MUST display all packages in one continuous scrollable list without step-based navigation.

### Key Entities

- **ItemCustomizationDialog**: Wizard-style customization screen for UOM, modifiers, and variants; adapted to a single-scroll bottom sheet in mobile mode.
- **ComboMealWidget**: Multi-package combo meal builder; adapted to a single-scroll bottom sheet in mobile mode.
- **AppMode**: Enum (`handheld` / `kiosk`) that gates which presentation is used; mobile adaptations activate only when mode is `handheld`.
- **ItemCustomizationResult**: Return value from the customization flow; unchanged — both sheet and dialog return the same data structure.

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A cashier can open, complete, and confirm a customizable product in mobile mode in under 20 seconds for a product with 2 modifier groups.
- **SC-002**: All interactive touch targets in the mobile sheet meet the 48×48 dp minimum size standard.
- **SC-003**: The mobile sheet opens in under 300 ms from the moment the cashier taps a product (excluding menu-loading network time).
- **SC-004**: 100% of test scenarios pass for both add and edit flows in mobile mode with zero regressions in kiosk mode.
- **SC-005**: The sheet (fixed at 85% screen height) displays without layout overflow or clipping on screen sizes from 360×640 dp to 430×932 dp (common Android phone range), with internal content scrolling when needed.
- **SC-006**: The live running total updates within one rendered frame after each selection change.

---

## Clarifications

### Session 2026-04-07

- Q: Should the mobile adaptation use in-place conditional branches inside existing widgets, or separate mobile-specific widget classes? → A: Separate new widget classes (`MobileItemCustomizationSheet` and `MobileComboMealSheet`); existing kiosk widget files remain unchanged.
- Q: Should the mobile bottom sheet have a fixed height or be draggable/resizable? → A: Fixed height at 85% of screen height; content scrolls inside if it overflows.
- Q: What should appear while combo meal packages are loading inside the mobile sheet? → A: Centered loading spinner inside the sheet body (consistent with existing kiosk loading state).

---

## Assumptions

- Mobile mode is detected via `AppConfig.isMobile` (globally available); no new configuration is required.
- The existing `ItemCustomizationResult` return type is reused unchanged — callers do not need modification.
- The app targets Android only; iOS safe-area handling is out of scope.
- `ComboMealWidget` and `ItemCustomizationDialog` are currently launched via `showDialog`; the mobile adaptation conditions the launch call to use `showModalBottomSheet` when `AppConfig.isMobile` is true. This condition lives at the call site (via `ProductTapHandler` and related helpers) or inside a static `show()` helper on each widget.
- No design token changes are needed; existing accent colors, fonts, and spacing values carry over.
- Content accessibility (screen readers, font scaling) is out of scope for this feature.
