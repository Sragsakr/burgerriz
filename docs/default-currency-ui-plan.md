# Plan: Default Currency UI – Hard Remove currencyId

## Overview
Enforce that currencyId is never passed from call sites to CurrencyDisplayWidget. Centralize default currency selection inside CurrencyDisplayWidget / CurrencyDisplayHelper, using the first non-deleted currency from the local CurrencyTable as the default when currencyId is not provided.

## Goals
- Ensure currencyId is not used outside CurrencyDisplayWidget.
- Always default to the first currency in the local CurrencyTable when currencyId is omitted.
- Preserve SAR rendering (image) and non-SAR rendering (text).
- Remove public API surface for currencyId from CurrencyDisplayWidget.

## Assumptions
- CurrencyTable is the single source of truth for currencies.
- The order by currencyId defines the deterministic first currency.
- SAR rendering via image assets and non-SAR rendering via text remains correct.

## Scope
- Code touched (conceptual):
  - lib/core/components/widgets/currency_display_widget.dart
  - lib/core/helpers/currency_display_helper.dart
  - lib/data/models/store/currency_model.dart
  - lib/data/services/local_data/currency/currency_table.dart
- All call sites that instantiate CurrencyDisplayWidget with currencyId.

## Build Context
### What will change in the codebase
- Phase 1: API cleanup
  - Remove the `currencyId` parameter from the public CurrencyDisplayWidget constructor.
  - Ensure CurrencyDisplayWidget always resolves currencyId internally (pass null to the resolver) so the first currency from CurrencyTable is used by default.
- Phase 2: Call-site cleanup
  - Remove currencyId usage from all 26+ call sites across kiosk/mobile UI layers.
  - Replace calls like `CurrencyDisplayWidget(..., currencyId: someId)` with `CurrencyDisplayWidget(...)` without changing UX beyond the default currency rule.
- Phase 3: Testing
  - Add unit tests for default currency selection when currencyId is null.
  - Add integration/UI tests to verify SAR vs non-SAR rendering with the first currency and locale fallbacks.
- Phase 4: Guards and docs
  - Add a development-only guard to warn if currencyId is used again outside CurrencyDisplayWidget.
  - Update internal docs to reflect the new single-source default currency flow.

## Phases & Key Activities
### Phase 1 — API surface cleanup
- Change: CurrencyDisplayWidget no longer accepts currencyId.
- Change: Constructor signature reduces to variant, width, height, fit, textStyle.
- Change: Build path always resolves with currencyId = null.

### Phase 2 — Call-site cleanup
- Change: Remove currencyId: ... arguments from all 26+ call sites.
- Change: Ensure rendering outcome remains the same for existing UX paths.
- Change: Batch edits to minimize risk (one patch/PR).

### Phase 3 — Testing
- Unit tests:
  - CurrencyDisplayHelper.resolveFromCurrencies with currencyId null selects activeCurrencies.first.
- SAR path remains image-based when first currency is SAR.
- Fallback when no currencies exist.
- Integration/UI tests:
  - CurrencyDisplayWidget renders correctly in representative screens across AR/EN locales without currencyId.
- Regression tests:
  - Verify SAR vs non-SAR visuals remain correct in common flows.

### Phase 4 — Guards, docs, rollout
- Guard: Implement a development-only check to warn if currencyId is used again in UI paths.
- Documentation: Update design/docs to indicate default currency is derived from local CurrencyTable and CurrencyDisplayWidget is the sole source for default rendering.

## Migration Plan
1. Create PR/branch: feature/default-currency-ui-hard-remove
2. Patch 1: CurrencyDisplayWidget API removal
   - Remove `currencyId` from the public constructor.
   - Update internal call path to always pass null to the resolver.
3. Patch 2: Call-site cleanup
   - Update all identified call sites to drop `currencyId: ...` usages.
   - Validate that UI still renders with a default currency (first in CurrencyTable).
4. Patch 3: Tests
   - Add unit/integration tests for default behavior; add UI/integration tests if feasible.
5. Patch 4: Guard & docs
   - Add development-only assertion/warn if currencyId is detected in UI call sites.
6. Run: flutter analyze, flutter test, and a full app build to validate visual correctness.

## Call-Site Mapping (to be updated in patch)
- lib/features/kiosk-features/pay_widget/pay_now_widget.dart
- lib/features/kiosk-features/menu_widget/components/...  (all 26+ occurrences)
- lib/features/mobile-features/... (all identified occurrences)

> Note: Actual patch will enumerate exact lines and replace instances; this plan lists files for traceability.

## Testing Plan
- Unit tests will exercise CurrencyDisplayHelper and CurrencyDisplayWidget behavior with currencyId omitted.
- Integration/UI tests to validate visuals across locales AR/EN and the SAR/non-SAR branches.

## Guarding & CI
- Development-only guard to warn if currencyId is detected in UI call sites.
- Optional: a lint rule could be added later to forbid currencyId usage in UI constructors; currently a runtime warn is sufficient.

## Documentation & Nightly Checks
- Update internal docs to reflect the rule and default behavior.
- Ensure we have a quick verification script to scan for currencyId usage in UI constructors for quick audits.

## Acceptance Criteria
- CurrencyDisplayWidget constructor no longer accepts currencyId.
- All call sites render using the first currency from CurrencyTable when currencyId is not provided.
- SAR rendering remains via image when default currency is SAR; non-SAR uses text.
- Tests reflect default-selection behavior and locale fallbacks.
- A development guard exists to catch future currencyId usage outside CurrencyDisplayWidget.

## Risks & Mitigations
- Risk: Edge-case UX relies on providing a specific currency at some call sites.
  - Mitigation: Ensure UX review during the patch; if needed, adjust UX to align with default-first rule.
- Risk: Test suites require updates to reflect new default logic.
  - Mitigation: Add/adjust tests to explicitly validate default currency behavior.

## Plan for Next Steps
- Review and approve the plan in docs.
- Create a dedicated branch and implement patches in this order:
  1) currency_display_widget.dart API removal
  2) call-site cleanup across all identified files
  3) add unit/integration tests
  4) add development guard and docs updates
- Run: flutter analyze, flutter test, and a full app build to verify.

## Build Context Details
- Runtime behavior after the changes:
  - CurrencyDisplayWidget will always resolve the currency internally using the local CurrencyTable when no currencyId is provided.
  - The first non-deleted CurrencyModel in CurrencyTable (ordered by currencyId) becomes the default currency.
  - If the default currency is SAR, an image asset is displayed; otherwise the currency name text is shown.
- Localization: AR uses Arabic name; EN uses English name as provided by CurrencyModel data; both rely on CurrencyDisplayHelper logic.

## Documentation
- This plan is stored at: docs/plans/default-currency-ui-plan.md
- The plan describes the concrete changes, migration steps, tests, guardrails, and rollout expectations.
