# Tasks: Mobile-Adaptive Customization UI

**Input**: Design documents from `specs/008-mobile-customization-ui/`  
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅, contracts/ ✅, quickstart.md ✅

**Tests**: Not requested in spec — omitted per constitution (pure UI change).

**Organization**: Tasks are grouped by user story to enable independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on other parallel tasks)
- **[Story]**: Which user story this task belongs to ([US1], [US2], [US3])

---

## Phase 1: Setup

**Purpose**: Create the new `mobile-features/customization/` directory structure.

- [ ] T001 Create `lib/features/mobile-features/customization/` directory by adding the first file `mobile_item_customization_sheet.dart` as an empty Dart file (just the library declaration comment)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Read and map the full result-handling call chain so Phases 3 and 4 wire return values correctly. No code changes — analysis only.

**⚠️ CRITICAL**: Complete before implementing any user story.

- [ ] T002 [P] Read `lib/core/helpers/menu_product_tap_handler.dart` lines 138–180 and `lib/features/mobile-features/SellPage/widgets/cart_items_widget.dart` lines 650–700 to fully understand how `showAppDialog<ItemCustomizationResult>` + `ProductCustomizationHost` result is consumed, so the `ProductCustomizationHost.show()` static method wires correctly in T008
- [ ] T003 [P] Read `lib/features/kiosk-features/menu_widget/components/item_customization/widgets/kiosk_style_customization_widgets.dart` in full to inventory all reusable sub-widgets (`KioskStyleCustomizationGroupSection`, `KioskStyleCustomizationOptionTile`, `KioskStyleSectionHeader`, `KioskStyleQtyButton`, `KioskStyleNutritionTag`, `KioskStylePriceBadge`) and confirm their import path for use in the new mobile widgets

**Checkpoint**: Call-flow fully understood. Sub-widget imports confirmed. Ready for user story phases.

---

## Phase 3: User Story 1 — Cashier Customizes a Product on a Phone (Priority: P1) 🎯 MVP

**Goal**: `MobileItemCustomizationSheet` exists and opens correctly in mobile mode for add flow. Existing kiosk flow untouched.

**Independent Test**: Run app in mobile mode, tap any product with variants/modifiers → sheet slides up from bottom at 85% height with drag handle, 2-column UOM grid, single scrollable modifier list, pinned footer with live total and "Add" button.

### Implementation

- [ ] T004 [US1] Read `lib/features/kiosk-features/menu_widget/components/item_customization/item_customization_dialog.dart` in full to extract all state fields, `initState` logic (`_buildVariantGroups`, `_buildAvailableSteps`, `_prePopulateSelections`), pricing methods (`_applyPricingRules`, `_liveTotalPrice`, `_getTotalPrice`), validation methods (`_validateCurrentStep`, `_validateGroups`), and variant toggle/quantity handlers (`_onToggleVariant`, `_onUpdateQuantity`) — these will be replicated verbatim in T005

- [ ] T005 [US1] Create `lib/features/mobile-features/customization/mobile_item_customization_sheet.dart`: define `MobileItemCustomizationSheet extends StatefulWidget` with all constructor parameters from `contracts/mobile-item-customization-sheet.md`; implement `_MobileItemCustomizationSheetState` with state fields (`_selectedUnit`, `_selectedByGroup`, `_validationErrors`, `_quantity`, `_uomShowError`, `_modifierGroups`, `_variantGroups`); copy `initState`, `_buildVariantGroups`, `_prePopulateSelections` (skip `_buildAvailableSteps` — no steps in mobile), all pricing methods, and all variant toggle/quantity handlers verbatim from `ItemCustomizationDialog` (T004)

- [ ] T006 [US1] Implement `build()` in `MobileItemCustomizationSheet` (`lib/features/mobile-features/customization/mobile_item_customization_sheet.dart`): return a `Column` with (1) drag handle pill (`Container`, 40×4 dp, grey.shade300, 10 dp vertical margin), (2) compact product image section (`SizedBox` height 160 using `buildImage`/`buildSyncProductImage` + close button overlay), (3) product name + live SAR total row + optional nutrition chips reusing `KioskStyleNutritionTag`, (4) `Divider`, (5) `Expanded(child: SingleChildScrollView(...))` containing UOM section (2-column `Wrap` using `KioskStyleCustomizationOptionTile`), then all `_modifierGroups` and `_variantGroups` via `KioskStyleCustomizationGroupSection`, (6) pinned footer with `KioskStyleQtyButton` quantity row + `FilledButton` "Add (SAR X)" that calls `_confirm()`; all strings via `translator(arText:, enText:)`

- [ ] T007 [US1] Implement `static Future<ItemCustomizationResult?> show(BuildContext context, {...all params})` on `MobileItemCustomizationSheet` (`lib/features/mobile-features/customization/mobile_item_customization_sheet.dart`): call `showModalBottomSheet<ItemCustomizationResult>(context: context, isScrollControlled: true, enableDrag: true, useSafeArea: true, backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (_) => SizedBox(height: MediaQuery.of(context).size.height * 0.85, child: MobileItemCustomizationSheet(...params)))` ; return its Future result

- [ ] T008 [US1] Update `lib/features/shared-features/customization/product_customization_host.dart`: add `static Future<ItemCustomizationResult?> show(BuildContext context, {...all params})` that (a) when `AppConfig.isMobile` calls `MobileItemCustomizationSheet.show(context, ...)`, (b) otherwise calls `showAppDialog<ItemCustomizationResult>(builder: (_) => KioskProductCustomizationSheet(...))` — then update the two existing `showAppDialog`+`ProductCustomizationHost` call sites in `lib/core/helpers/menu_product_tap_handler.dart` (line ~150) and `lib/features/mobile-features/SellPage/widgets/cart_items_widget.dart` (line ~667) to call `ProductCustomizationHost.show(context, ...)` instead; the kiosk call site in `lib/features/kiosk-features/cart/kiosk_cart_line_item.dart` is NOT changed (kiosk code untouched)

**Checkpoint**: US1 complete. Open a product with modifiers in mobile mode → bottom sheet appears, UOM grid is 2-col, all groups in one scroll, "Add" inserts item into cart. Kiosk mode unchanged.

---

## Phase 4: User Story 2 — Cashier Builds a Combo Meal on a Phone (Priority: P1)

**Goal**: `MobileComboMealSheet` exists and opens correctly in mobile mode. All packages scroll in one list. Kiosk combo flow untouched.

**Independent Test**: Run app in mobile mode, tap any combo meal product → sheet slides up with package list in one scroll, spinner while loading, "Add To Cart" button enabled only when all packages complete, combo added to cart correctly.

### Implementation

- [ ] T009 [US2] Read `lib/features/kiosk-features/menu_widget/components/combo_meal/combo_meal_widget.dart` in full to extract the `_addToCart` method logic (ComboMealItem mapping, CartItem construction, cartProvider interaction, comboMealProvider reset) which will be copied verbatim in T010

- [ ] T010 [P] [US2] Create `lib/features/mobile-features/customization/mobile_combo_meal_sheet.dart`: define `MobileComboMealSheet extends ConsumerStatefulWidget` with constructor params (`product`, `basePrice`, `initialQuantity`) per `contracts/mobile-combo-meal-sheet.md`; implement state with `_quantity` field, `_scrollController`, `initState`/`dispose`; copy `_addToCart` verbatim from `ComboMealWidget` (T009)

- [ ] T011 [US2] Implement `build()` in `MobileComboMealSheet` (`lib/features/mobile-features/customization/mobile_combo_meal_sheet.dart`): return `Column` with (1) drag handle pill, (2) compact image section max 160 px using `buildSyncProductImage` + close icon that calls `ref.read(comboMealProvider.notifier).reset()` then `Navigator.pop()`, (3) product name + total row + nutrition chips, (4) `Divider`, (5) `Expanded(child: body)` where body shows `CircularProgressIndicator` when `state.isLoading`, error widget when `state.error != null`, or `SingleChildScrollView` with all `state.comboMeal!.packages.map((p) => ComboMealPackageSelector(...))` in sequence, (6) pinned footer with quantity row + `FilledButton` that is disabled (grey) when `!state.isComplete` with label "Complete your selections" and enabled (themeColor) when complete with label "Add To Cart (SAR X)" calling `_addToCart`; all strings via `translator(arText:, enText:)`

- [ ] T012 [US2] Implement `static Future<void> show(BuildContext context, {required SyncProduct product, required double basePrice, required int initialQuantity})` on `MobileComboMealSheet` (`lib/features/mobile-features/customization/mobile_combo_meal_sheet.dart`): call `showModalBottomSheet<void>(context: context, isScrollControlled: true, enableDrag: true, useSafeArea: true, backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (_) => SizedBox(height: MediaQuery.of(context).size.height * 0.85, child: MobileComboMealSheet(product: product, basePrice: basePrice, initialQuantity: initialQuantity)))`

- [ ] T013 [US2] Update `lib/features/shared-features/customization/combo_meal_dialog.dart`: add `import 'package:kiosk_point_of_sale/core/config/app_config.dart'` and `import` for `MobileComboMealSheet`; wrap existing `showAppDialog` call in `else` branch; add `if (AppConfig.isMobile) { await MobileComboMealSheet.show(context, product: product, basePrice: basePrice, initialQuantity: initialQuantity); return; }` before the existing kiosk path

**Checkpoint**: US2 complete. Tap a combo in mobile mode → sheet opens, packages scroll, add to cart works. Kiosk combo unchanged.

---

## Phase 5: User Story 3 — Edit Mode on a Phone (Priority: P2)

**Goal**: Tapping a customizable item in the mobile cart opens `MobileItemCustomizationSheet` pre-populated with previous selections and shows "Update" instead of "Add".

**Independent Test**: Add a customizable product to cart in mobile mode, tap it to edit → mobile sheet opens with all previous selections already checked, "Update" button visible, changing a selection and tapping "Update" updates the cart item correctly.

### Implementation

- [ ] T014 [US3] Verify `MobileItemCustomizationSheet` edit mode end-to-end: confirm that `_prePopulateSelections()` (copied in T005) correctly restores `_selectedByGroup` from `initialSelectedVariants` when `isEditMode: true`, and that `_confirm()` calls `Navigator.of(context).pop(ItemCustomizationResult(..., wasCancelled: false))` correctly; confirm the "Update" label in the footer `FilledButton` reads `translator(arText: 'تحديث', enText: 'Update')` when `widget.isEditMode == true` — if any of these are missing from T005/T006, add them now in `lib/features/mobile-features/customization/mobile_item_customization_sheet.dart`

- [ ] T015 [US3] Add the edit-mode/customize-mode badge chip to `MobileItemCustomizationSheet` header (`lib/features/mobile-features/customization/mobile_item_customization_sheet.dart`): below the product name row, add a small `Container` chip showing `translator(arText: 'تعديل', enText: 'Edit')` (orange chip) when `widget.isEditMode == true`, or `translator(arText: 'تخصيص', enText: 'Customize')` (green chip) when false — mirrors `ItemCustomizationDialog._buildStepChipsRow()`

**Checkpoint**: US3 complete. Edit an existing cart item in mobile mode → mobile sheet opens pre-populated, badge shows "Edit", Update saves correctly.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Bilingual compliance, RTL verification, kiosk regression, full manual checklist.

- [ ] T016 [P] Audit all user-facing `Text(...)` widgets in `lib/features/mobile-features/customization/mobile_item_customization_sheet.dart` and `lib/features/mobile-features/customization/mobile_combo_meal_sheet.dart` — every string must use `translator(arText:, enText:)`; replace any hardcoded English strings found

- [ ] T017 [P] Audit `lib/features/shared-features/customization/product_customization_host.dart` and `lib/features/shared-features/customization/combo_meal_dialog.dart` for any unintentional changes that could affect the kiosk path — confirm `KioskProductCustomizationSheet` and `ComboMealWidget` are still returned/called unchanged in the kiosk branch

- [ ] T018 Run the full manual testing checklist from `specs/008-mobile-customization-ui/quickstart.md` covering: sheet bottom presentation, swipe-dismiss returns cancelled, 2-col UOM tiles, single scroll (no pagination), live total updates, inline validation errors, edit mode pre-population, combo spinner → packages → add, kiosk mode completely unchanged, Arabic RTL layout, 360 dp phone no overflow

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies — start immediately
- **Phase 2 (Foundational)**: Depends on Phase 1 — BLOCKS Phase 3 and 4
- **Phase 3 (US1)** and **Phase 4 (US2)**: Both depend on Phase 2; can run in parallel on separate files
- **Phase 5 (US3)**: Depends on Phase 3 (US1) completing — edit mode is inside `MobileItemCustomizationSheet`
- **Phase 6 (Polish)**: Depends on Phases 3, 4, 5

### User Story Dependencies

- **US1 (P1)**: Can start after Phase 2 — independent
- **US2 (P1)**: Can start after Phase 2 — fully independent of US1 (different files)
- **US3 (P2)**: Depends on US1 (edits `MobileItemCustomizationSheet` from US1)

### Within Each Story

- T004/T009 (read existing code) → T005/T010 (create new widget) → T006/T011 (implement build) → T007/T012 (add static show) → T008/T013 (update call sites)

---

## Parallel Execution Examples

### US1 and US2 together (after Phase 2)

```
Developer A: T004 → T005 → T006 → T007 → T008  (MobileItemCustomizationSheet)
Developer B: T009 → T010 → T011 → T012 → T013  (MobileComboMealSheet)
```

Both work in completely different files — zero conflicts.

### Phase 2 (parallel reads)

```
T002: Read menu_product_tap_handler.dart + cart_items_widget.dart call chain
T003: Read kiosk_style_customization_widgets.dart sub-widget inventory
```

### Phase 6 (parallel audits)

```
T016: Bilingual string audit (mobile widget files)
T017: Kiosk regression audit (host files)
```

---

## Implementation Strategy

### MVP First (US1 Only)

1. Complete Phase 1: Setup (T001)
2. Complete Phase 2: Foundational (T002, T003)
3. Complete Phase 3: US1 (T004 → T005 → T006 → T007 → T008)
4. **STOP and VALIDATE**: Add a product with variants in mobile mode → sheet works end-to-end
5. Demo/merge if approved

### Incremental Delivery

1. Phase 1 + 2 → Foundation ready
2. Phase 3 (US1) → Mobile customization sheet working → demo/merge
3. Phase 4 (US2) → Mobile combo sheet working → demo/merge
4. Phase 5 (US3) → Edit mode on phone → demo/merge
5. Phase 6 → Polish + full regression → PR ready

---

## Notes

- [P] tasks = different files, no dependency on each other
- [Story] label traces each task to its user story for independent delivery
- No test tasks generated (pure UI change, constitution allows omission)
- kiosk code must be verifiably unchanged after every phase — check `KioskProductCustomizationSheet`, `ItemCustomizationDialog`, `ComboMealWidget` are not modified
- Commit after T008 (US1 complete) and T013 (US2 complete) at minimum
