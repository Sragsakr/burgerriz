# Research: Mobile-Adaptive Customization UI

**Phase 0 output** | Branch: `008-mobile-customization-ui` | Date: 2026-04-07

---

## Finding 1: Current call-site architecture

**Decision**: Both new mobile widgets are wired in at existing switch points — no new routing or deep call-site changes needed.

**Rationale**:
- `ProductCustomizationHost` (`lib/features/shared-features/customization/product_customization_host.dart`) already branches on `AppModeSession.useCustomizationWizard` (which is `true` when `AppConfig.isMobile`). The mobile branch currently returns `ItemCustomizationDialog`; it will be updated to return `MobileItemCustomizationSheet` wrapped in a `showModalBottomSheet` call, or the host widget itself becomes a bottom-sheet launcher.
- `showComboMealDialog` (`lib/features/shared-features/customization/combo_meal_dialog.dart`) is the single call site for all combo meal dialogs. A mode check (`AppConfig.isMobile`) is added here to branch between `showAppDialog` (kiosk) and `showModalBottomSheet` (mobile).

**Alternatives considered**:
- Adding `AppConfig.isMobile` checks directly in `ProductTapHandler` — rejected; the host files are the established switch layer.
- Adding a `static show()` factory on each new widget — viable, but the host pattern is already in use and should be kept consistent.

---

## Finding 2: Bottom sheet presentation

**Decision**: Use Flutter's `showModalBottomSheet` with `isScrollControlled: true` and a `SizedBox` constrained to `MediaQuery.of(context).size.height * 0.85`.

**Rationale**:
- `isScrollControlled: true` allows the sheet to go beyond 50% of screen height (required for 85% target).
- The sheet is not `DraggableScrollableSheet` — fixed height was chosen (clarification Q2). A fixed `SizedBox` height achieves this simply.
- `showModalBottomSheet` natively supports swipe-to-dismiss via `enableDrag: true` (default). A visible drag handle is added manually as a `Container` with a rounded grey pill at the top of the sheet.
- `useSafeArea: true` on `showModalBottomSheet` handles the Android bottom safe-area automatically in Flutter 3.x.

**Alternatives considered**:
- `DraggableScrollableSheet` — rejected in clarification; adds complexity without cashier benefit.
- `showGeneralDialog` with slide-up transition (like `showAppDialog`) — rejected; does not provide native swipe-dismiss gesture.

---

## Finding 3: Reusable sub-widgets from kiosk layer

**Decision**: The mobile sheets reuse the following existing sub-widgets from `kiosk_style_customization_widgets.dart` and related files without modification:

| Widget | Reuse in mobile |
|---|---|
| `KioskStyleNutritionTag` | Product header nutrition chips |
| `KioskStyleSectionHeader` | Group title + required/count badge |
| `KioskStyleCustomizationGroupSection` | Full modifier/variant group rendering |
| `KioskStyleCustomizationOptionTile` | Individual option tile (width passed as parameter) |
| `KioskStyleQtyButton` | Quantity +/- buttons in footer |
| `KioskStylePriceBadge` | Price display on tiles |
| `VariantGroupData` / `VariantValueOption` (models) | Group data model |
| `ComboMealPackageSelector` | Package item selector in combo flow |

**Rationale**: These widgets already accept layout parameters (e.g., `tileWidth`) making them screen-size-agnostic. Reusing them ensures visual consistency and avoids duplication.

**Differences in mobile usage**:
- UOM grid: `cols = 2` instead of `cols = 4` → smaller `tileWidth` computed from `constraints.maxWidth`.
- All groups (UOM + modifiers + variants) rendered in one `Column` instead of paginated steps.

---

## Finding 4: Pricing, validation, and cart logic

**Decision**: All business logic (pricing rules, variant validation, cart insertion) is copied verbatim from `ItemCustomizationDialog`/`ComboMealWidget` state classes into the new mobile widget state classes. No extraction into a shared mixin is done (clarification Q1: separate widgets, not shared base).

**Rationale**:
- Keeps kiosk code completely untouched.
- Logic is well-contained in `State` methods (`_applyPricingRules`, `_validateCurrentStep`, `_getTotalPrice`, `_liveTotalPrice`, `_onToggleVariant`, `_onUpdateQuantity`) — easy to copy and own independently.
- Future consolidation into a shared service/mixin is a separate refactor concern.

---

## Finding 5: Bilingual and RTL compliance

**Decision**: All new user-facing strings use the existing `translator(arText:, enText:)` helper. No hard-coded strings. `Directionality` is automatic via `MaterialApp` locale propagation.

**Strings needed** (all have existing AR equivalents from current widgets):
- "Size" / "اختر الحجم"
- "Modifiers" / "الإضافات"
- "Options" / "الخيارات"
- "Add" / "إضافة"
- "Update" / "تحديث"
- "Add To Cart" / "أضف إلى السلة"
- "Complete your selections" / "أكمل اختياراتك"
- "Please select a size." / "يرجى اختيار الحجم"
- "Please select at least N item(s)." / handled inline

**RTL note**: `showModalBottomSheet` respects the active `TextDirection`. The drag handle and internal layout use standard Flutter `Row`/`Column` with `CrossAxisAlignment` — they flip correctly under RTL automatically.

---

## Finding 6: `ProductCustomizationHost` — launch mechanism

**Decision**: `ProductCustomizationHost` is changed from a `StatelessWidget` that *returns* a widget to a function that *launches* a bottom sheet for mobile mode.

**Current**: `ProductCustomizationHost.build()` returns either `ItemCustomizationDialog` or `KioskProductCustomizationSheet` — both are `Dialog` widgets shown by the caller via `showAppDialog`.

**New approach**: The existing callers of `ProductCustomizationHost` use `showAppDialog(builder: (_) => ProductCustomizationHost(...))`. The host's `build` method will still return either `MobileItemCustomizationSheet` (for mobile) or `KioskProductCustomizationSheet` (for kiosk). However, `MobileItemCustomizationSheet` will be a standard widget that is wrapped by the caller in `showModalBottomSheet` instead of `showAppDialog`.

**Practical implementation**: Add a static `show()` method to `MobileItemCustomizationSheet` that calls `showModalBottomSheet`. Update `ProductCustomizationHost` to call `MobileItemCustomizationSheet.show(context, ...)` in the mobile branch and return a `SizedBox.shrink()`, matching the pattern already used in the kiosk branch. Similarly, update `showComboMealDialog` to call `MobileComboMealSheet.show(context, ...)` in mobile mode.
