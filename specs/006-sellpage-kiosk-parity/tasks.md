# Tasks: Handheld and kiosk ordering parity

**Input**: Design documents from `/specs/006-sellpage-kiosk-parity/`  
**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/navigation-handheld.md](./contracts/navigation-handheld.md)

**Tests**: Not requested in spec — no automated test tasks. Validation via [quickstart.md](./quickstart.md) + `flutter analyze`.

**Organization**: Phases follow user story priorities from spec.md (US1 P1 → US2–US4 P2/P3). Foundational work blocks all stories.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no unmet dependencies)
- **[Story]**: User story label for story phases only

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Trace current code paths before edits.

- [X] T001 Map `GoRoute` definitions and `/sell-page` entry in `lib/core/routers/router.dart` against `specs/006-sellpage-kiosk-parity/contracts/navigation-handheld.md`
- [X] T002 [P] Trace handheld chain from `lib/views/Cashier/cashier_widget.dart` through `lib/views/sale_typs/sale_type_widget.dart` to `context.go('/sell-page')` in `lib/views/customers/customers_widget.dart` and `lib/views/customers/customers_table_widget.dart`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Shared prefs and **one** catalog preload implementation used by kiosk and handheld.

**⚠️ CRITICAL**: No user story work until this phase completes.

- [X] T003 Add getters/setters (or equivalent) for `show_split_store_handheld` and `default_report_group_id_handheld` in `lib/core/helpers/app_pref.dart` per `specs/006-sellpage-kiosk-parity/data-model.md`
- [X] T004 Extract shared menu preload logic from `lib/views/kiosk/menu_widget/components/menu_category_and_sale_type_bar.dart` (`_loadFilteredMenu`) into a reusable API (e.g. new `lib/repository/menu_catalog_preload_helper.dart` or methods on `lib/repository/menu_item_sync_repository.dart`) that accepts `WidgetRef`, `SaleType`, and optional `reportGroupId` / filter flag
- [X] T005 Refactor `lib/views/kiosk/menu_widget/components/menu_category_and_sale_type_bar.dart` to call the shared preload helper without changing kiosk behavior
- [X] T006 [P] Refactor `lib/views/kiosk/sale_type_kiosk/kiosk_sale_type_screen.dart` (`_loadFilteredMenu`) to call the same shared preload helper without changing kiosk behavior

**Checkpoint**: Kiosk flows unchanged; helper ready for `SaleTypesWidget`.

**Dependencies**: T005 and T006 depend on **T004**. T003 can run in parallel with **T004** ([P] pair: T003 + T004 start together; T005/T006 after T004).

---

## Phase 3: User Story 1 — Right entry for the device (Priority: P1) 🎯 MVP

**Goal**: Handheld follows **Home → Cashier → Sale type → Customer → [Split store if setting on] → Sell page**; kiosk entry unchanged.

**Independent Test**: Phone profile: complete chain and land on `SellpageWidget` without kiosk `EntryWidget`. Tablet/kiosk: still lands on kiosk entry. See [quickstart.md](./quickstart.md).

### Implementation for User Story 1

- [X] T007 [US1] Adjust `lib/core/routers/router.dart` and/or `lib/core/helpers/find_first_path.dart` so **handheld** post-login / post-install initial route targets the Cashier → sale-type path (not kiosk `EntryWidget` / `SplitStoreScreen` unless spec’d)
- [X] T008 [US1] After customer selection in `lib/views/customers/customers_widget.dart` and `lib/views/customers/customers_table_widget.dart`, branch: if `show_split_store_handheld` and multi-store applies, `context.go(SplitStoreScreen.routePath)` (from `lib/views/kiosk/splite-stores/splite-store-screen.dart`); else `context.go('/sell-page')` (or equivalent named route)
- [X] T009 [US1] On `lib/views/kiosk/splite-stores/splite-store-screen.dart` completion for handheld, navigate to `/sell-page` (reuse existing `selectedReportGroupIdProvider` / `selectedStoreInfoProvider` updates already performed on store tap)

**Checkpoint**: US1 testable on device class matrix.

---

## Phase 4: User Story 2 — Same catalog rules (Priority: P2)

**Goal**: Handheld `SellpageWidget` catalog uses **effective** `reportGroupId` and same preload rules as kiosk.

**Independent Test**: Same store + sale type: product IDs match kiosk categories. Setting off: default scope applied. See [quickstart.md](./quickstart.md).

### Implementation for User Story 2

- [X] T010 [US2] In `lib/views/sale_typs/sale_type_widget.dart` (`_preloadData`), call shared preload helper with `selectedReportGroupIdProvider` when set, or `default_report_group_id_handheld` when split-store setting is off, mirroring `MenuCategoryAndSaleTypeBar` / `KioskSaleTypeScreen` filtering rules
- [X] T011 [US2] When split-store is skipped, set `selectedReportGroupIdProvider` (and `selectedStoreInfoProvider` if needed for accents) from `default_report_group_id_handheld` **before** first catalog fill used by Sell page — in `lib/views/sale_typs/sale_type_widget.dart` and/or `lib/views/SellPage/sellpage_widget.dart` as appropriate (FR-007)

**Checkpoint**: SC-002 / SC-003 smoke on multi-store data.

**Dependencies**: Requires **Phase 2** (T004–T006). Best after **US1** (T007–T009) so routing sets scope before preload.

---

## Phase 5: User Story 3 — Same add-to-cart from grid (Priority: P2)

**Goal**: `ProductGrid` taps use `MenuProductTapHandler` like kiosk cards.

**Independent Test**: Tap simple / variant / combo products from Sell page grid; no dead taps. See [quickstart.md](./quickstart.md).

### Implementation for User Story 3

- [X] T012 [US3] Replace empty `onTap` in `lib/components/widgets/SellPage/product_grid.dart` with `MenuProductTapHandler.handleProductTap(context, ref, product, isEnglish, false)` (import `lib/views/kiosk/menu_widget/components/menu_product_tap_handler.dart`)

**Checkpoint**: FR-004 satisfied for grid.

**Dependencies**: **Phase 2** complete (optional: works even if US2 incomplete but catalog may be wrong until US2 done).

---

## Phase 6: User Story 4 — Barcode parity (Priority: P3)

**Goal**: Handheld barcode paths match kiosk (`MenuProductTapHandler` after lookup).

**Independent Test**: Scan matrix products; same dialogs as grid. See [quickstart.md](./quickstart.md).

### Implementation for User Story 4

- [X] T013 [US4] In `lib/views/SellPage/sellpage_widget.dart` (`onBarcodeScanned`), after `getProductByBarcode`, call `MenuProductTapHandler.handleProductTap` instead of branching to `ProductUnitDialog` / direct `addItem` when parity is required
- [X] T014 [US4] Apply the same barcode handling in `lib/views/SellPage/sell_page_custom_nav_bar.dart` (`scanBarcodeManually`)

**Checkpoint**: FR-006 satisfied for handheld barcode.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Settings UI, docs, validation.

- [X] T015 [P] Add operator UI for **show split store on handheld** and **default report group** in `lib/views/settings/settings_screen.dart` (persist via `lib/core/helpers/app_pref.dart`)
- [X] T016 [P] Update `docs/menu_items_readme.md` (SellPage vs kiosk section) to describe new handheld filtering, grid tap, and barcode behavior
- [X] T017 Run `flutter analyze` and execute scenarios in `specs/006-sellpage-kiosk-parity/quickstart.md` on phone and kiosk profiles

---

## Dependencies & Execution Order

### Phase dependencies

```text
Phase 1 (T001–T002) → Phase 2 (T003–T006) → US1 (T007–T009) → US2 (T010–T011) → US3 (T012) → US4 (T013–T014) → Polish (T015–T017)
```

- **US2** should follow **US1** so store scope is resolved before relying on preload at sale-type time (if preload runs at sale type, ensure order matches product decision: scope may need to be set before `_preloadData` when using default — align with plan).

### User story dependencies

| Story | Depends on |
|-------|------------|
| US1 | Phase 2 only (T003 for prefs on T008) |
| US2 | Phase 2; recommended after US1 |
| US3 | Phase 2 (soft); catalog accuracy best after US2 |
| US4 | US3 recommended (same handler assumptions) |

### Parallel opportunities

- **T003** ∥ **T004** (after T001–T002 done)
- **T006** ∥ **T005** after **T004**
- **T015** ∥ **T016** in Polish
- **US3** (T012) and **US4** (T013–T014) can run in parallel **if** different developers (touch different files); sequential avoids merge conflicts on `sellpage_widget.dart` vs `sell_page_custom_nav_bar.dart` — prefer **T012 → T013 → T014** single-threaded on SellPage files

### Parallel example: Phase 2 (after T004)

```text
T005 Refactor menu_category_and_sale_type_bar.dart
T006 [P] Refactor kiosk_sale_type_screen.dart
```

### Parallel example: Polish

```text
T015 settings_screen.dart
T016 [P] docs/menu_items_readme.md
```

---

## Implementation Strategy

### MVP first (User Story 1 only)

1. Complete Phase 1–2 (T001–T006)
2. Complete US1 (T007–T009)
3. **STOP**: Validate navigation contract on a phone emulator
4. Then add US2 for catalog parity

### Incremental delivery

1. Foundation → US1 → demo routing MVP  
2. + US2 → demo correct catalog  
3. + US3 → demo grid adds  
4. + US4 → demo barcode parity  
5. Polish → settings + docs + analyze  

### Task counts

| Phase | Tasks | Notes |
|-------|-------|--------|
| Setup | 2 | T001–T002 |
| Foundational | 4 | T003–T006 |
| US1 | 3 | T007–T009 |
| US2 | 2 | T010–T011 |
| US3 | 1 | T012 |
| US4 | 2 | T013–T014 |
| Polish | 3 | T015–T017 |
| **Total** | **17** | |

---

## Format validation

- All tasks use `- [ ] TNNN` checklist prefix  
- All user-story tasks include `[US#]` and **file paths** in the description  
- `[P]` only where parallel execution is safe per notes above  

---

## Notes

- If `find_first_path` / install flow conflicts with US1, document exception in plan and add a follow-up task.  
- `MenuProductTapHandler` uses `ref.read(selectedReportGroupIdProvider)!` in places — ensure non-null after US2 or guard for handheld default scope.  
