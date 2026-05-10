# Implementation Tasks: Remove Multi-Store ReportGroup Feature from Kiosk Mode

**Feature**: 009-kiosk-single-store  
**Specification**: [spec.md](spec.md)  
**Plan**: [plan.md](plan.md)  
**Created**: 2026-04-07  

---

## Phase 1: Setup & Codebase Audit

*Goal*: Understand the full extent of ReportGroup usage across the codebase before removal.

### Independent Test Criteria
- All ReportGroup usages identified and documented
- No ReportGroup code is removed yet
- Audit report created for reference during implementation

---

- [ ] T001 Audit entire codebase for ReportGroup references and document findings in `REPORTGROUP_AUDIT.md` (search: grep -r "ReportGroup\|reportGroup\|selectedReportGroupId\|effectiveCatalog" lib/ --include="*.dart")

---

## Phase 2: Foundational (Blocking Prerequisites)

*Goal*: Create blocking prerequisites that P1, P2, P3 user story tasks can execute in parallel.

### Independent Test Criteria
- Database cleanup logic implemented and tested offline
- All ReportGroup dependencies listed and safe to remove
- No app crashes on startup with empty ReportGroup data

---

- [ ] T002 Create database migration: add cleanup logic in `lib/data/services/local_data/db/app_db.dart` to nullify all ReportGroup references on app startup

- [ ] T003 Update `lib/core/config/app_mode_session.dart` to return null for `effectiveCatalogReportGroupId()` when in kiosk mode (simplification before removal)

---

## Phase 3: User Story 1 - Remove Store Selection UI from Kiosk Entry (P1)

*Goal*: Remove the ReportGroup selector screen from kiosk entry flow so operators proceed directly to menu.

### Independent Test Criteria
- Kiosk app launches without SplitStoresScreen
- Entry screen displays immediately after login
- Operator can select sale type and browse menu
- After-sale flow returns to entry with Posmena logo

---

- [ ] T004 [US1] Remove `lib/features/kiosk-features/splite-stores/` directory entirely (delete splite-store-screen.dart and all related files)

- [ ] T005 [P] [US1] Remove SplitStoresScreen route from `lib/core/routers/router.dart` (search for "splite-stores" or "SplitStoresScreen" route definition)

- [ ] T006 [P] [US1] Update entry widget navigation in `lib/features/kiosk-features/entry_widget/entry_widget.dart` to skip store selector and navigate directly to menu/cashier (remove context.go to SplitStoresScreen)

- [ ] T007 [P] [US1] Remove store selector from `lib/features/shared-features/Install/install_widget_kiosk.dart` if present (search for store selection in installation flow)

- [ ] T008 [P] [US1] Remove `selectedReportGroupIdProvider` from `lib/providers/` or stub it to return null (find file defining selectedReportGroupIdProvider)

- [ ] T009 [P] [US1] Simplify or remove `reportGroupThemeProvider` in `lib/providers/` by using default theme for kiosk (return single default theme, not store-specific)

- [ ] T010 [US1] Test kiosk flow: Boot app → Login → Entry screen displays → Select sale type → Verify menu loads (integration test or manual)

---

## Phase 4: User Story 2 - Remove ReportGroup Database Tables and Clean Data References (P2)

*Goal*: Eliminate ReportGroup filtering from all product loading and menu initialization queries.

### Independent Test Criteria
- All product queries return full catalog (not filtered by store)
- Database initialization succeeds without ReportGroup errors
- Sales data can be created without store association
- Legacy ReportGroup data is cleaned on startup

---

- [ ] T011 [P] [US2] Update `lib/repository/menu_item_sync_repository.dart` to remove `getProductsByCategoryFilteredByItems()` method or convert to unfiltered version (remove reportGroupId parameter and filtering logic)

- [ ] T012 [P] [US2] Update `lib/repository/menu_catalog_preload_helper.dart` `loadCatalogForSaleType()` to remove ReportGroup filtering branch (simplify lines 44-76, always call `getAllProducts()`)

- [ ] T013 [P] [US2] Update `lib/core/services/order_services/product_tap_menu_loader.dart` to remove ReportGroup parameter from menu loading calls (call `MenuItemSyncRepository.getAllProducts(priceListId)` without filtering)

- [ ] T014 [P] [US2] Remove or deprecate ReportGroup-related data models: check `lib/data/models/store/` and remove ReportGroup entity files if present

- [ ] T015 [P] [US2] Update `lib/core/theme/report_group_theme.dart` to remove store-specific theme logic or deprecate (use single default theme for kiosk)

- [ ] T016 [US2] Verify database initialization: Run app on fresh install → check that all tables create successfully → verify no ReportGroup lookups in logs

---

## Phase 5: User Story 3 - Simplify Store Initialization and Session Management (P3)

*Goal*: Remove store selection logic from app initialization so kiosk defaults to single-store mode.

### Independent Test Criteria
- App starts without ReportGroup selection dialog
- Initialization completes within 2 seconds
- Menu products load without store filtering
- Offline operation works correctly (no network calls for store selection)

---

- [ ] T017 [P] [US3] Update app initialization in `lib/main.dart` to skip ReportGroup selection (remove any store selector initialization logic, proceed directly to entry screen)

- [ ] T018 [P] [US3] Ensure `AppConfig.isMobile` check skips store selection in kiosk mode (verify kiosk-specific initialization in app_config.dart)

- [ ] T019 [P] [US3] Verify menu loading works offline: disable network → login to kiosk → browse menu categories → confirm all products display without filtering

- [ ] T020 [US3] Test full kiosk flow end-to-end: Launch → Login → Entry → Sale Type → Menu → Add Items → Checkout → Finish → Return to Entry (integration or manual test)

---

## Phase 6: Polish & Cross-Cutting Concerns

*Goal*: Verify the removal is complete, test regressions, and ensure ZATCA compliance is maintained.

### Independent Test Criteria
- 100% of existing test scenarios pass
- No errors in app logs related to ReportGroup
- ZATCA invoice generation still works correctly
- Bilingual support (AR/EN) still functions
- All removed code is confirmed unused

---

- [ ] T021 [P] Run `flutter analyze` to ensure no broken imports or references to removed ReportGroup code

- [ ] T022 [P] Search codebase for any remaining "ReportGroup" references that should have been removed: grep -r "ReportGroup\|reportGroup\|selectedReportGroup" lib/ --include="*.dart"

- [ ] T023 Run flutter tests to verify no regressions: `flutter test` (if widget/integration tests exist for kiosk flow)

- [ ] T024 Verify ZATCA invoice generation: Complete a transaction → Check receipt QR code generation → Confirm invoice serial numbering still works

- [ ] T025 Manual test bilingual flow: Switch app locale to AR → Verify entry screen renders correctly (no missing store selector strings) → Switch to EN → Verify layout

- [ ] T026 Create summary report: document all removed files/methods, verify flow matches specification acceptance scenarios

---

## Dependency Graph

```
T001 (Audit)
  ├─→ T002 (Setup cleanup)
  │    ├─→ T004-T010 [US1] (Remove UI)
  │    │    └─→ T010 (Test US1)
  │    ├─→ T011-T016 [US2] (Remove filtering)
  │    │    └─→ T016 (Test US2)
  │    └─→ T017-T020 [US3] (Simplify init)
  │         └─→ T020 (Test US3)
  └─→ T021-T025 (Polish & Validation)
```

**Parallel Opportunities**:
- T004-T009 can run in parallel (different files, same user story)
- T011-T015 can run in parallel (different files, same user story)
- T017-T019 can run in parallel (different initialization concerns, same user story)
- T004-T009, T011-T015, T017-T019 can run in parallel across user stories (different files, no cross-dependencies)
- T021-T024 can run in parallel (independent verification tasks)

---

## User Story Execution Order & MVP Scope

### Recommended Implementation Order (Sequential)
1. **Phase 1**: T001 (Audit)
2. **Phase 2**: T002, T003 (Foundational setup)
3. **Phase 3**: T004-T010 (US1 - Remove UI) — **MVP Scope** ✓ Delivers user-visible value
4. **Phase 4**: T011-T016 (US2 - Remove filtering) — Enables full functionality
5. **Phase 5**: T017-T020 (US3 - Simplify init) — Completes technical cleanup
6. **Phase 6**: T021-T025 (Polish & Validation)

### MVP Scope
- **Minimal Viable Product**: Complete T001-T010 (Phases 1-3, US1 only)
- **Delivers**: Kiosk entry screen without store selector, menu loads (but may still have ReportGroup filtering)
- **Time Estimate**: ~4-6 hours
- **Next Phase**: Add T011-T016 (full filtering removal) for production-ready code

### Full Implementation Scope
- **Complete Feature**: T001-T025 (all phases, all user stories)
- **Delivers**: Fully cleaned codebase, no ReportGroup references, simplified initialization
- **Time Estimate**: ~8-12 hours
- **Quality Gate**: All tests pass, ZATCA compliant, zero regressions

---

## Implementation Strategy

### Remove vs. Deprecate
- **Remove**: SplitStoresScreen UI directory (not used elsewhere)
- **Remove**: ReportGroup filtering logic (replaced with null/unfiltered queries)
- **Deprecate**: ReportGroup database tables (leave schema for backward compatibility)
- **Simplify**: reportGroupThemeProvider (use single default theme)

### Testing Strategy
- **Per-Story Integration Tests**: Test each user story end-to-end
  - US1: Entry → Menu without store selector
  - US2: Menu loading without ReportGroup filtering
  - US3: App initialization without store selection dialog
- **Cross-Story Regression Tests**: Full kiosk flow (T020, T023, T024)
- **No Unit Tests Required** (unless user requests)

### Risk Mitigation
- **Backward Compatibility**: Database tables left intact (no migration needed)
- **ZATCA Verification**: Explicit test for invoice generation (T023)
- **Rollback Path**: If issues found, feature branch can be reverted (only file removals/modifications, no data loss)

---

## Task Summary

| Metric | Count |
|--------|-------|
| **Total Tasks** | 26 |
| **Phase 1 (Setup)** | 1 |
| **Phase 2 (Foundational)** | 2 |
| **Phase 3 (US1 - Remove UI)** | 7 |
| **Phase 4 (US2 - Remove Filtering)** | 6 |
| **Phase 5 (US3 - Simplify Init)** | 4 |
| **Phase 6 (Polish)** | 6 |
| **Parallelizable Tasks [P]** | 16 |
| **Sequential Tasks** | 10 |

**MVP Scope**: T001-T010 (10 tasks, ~4-6 hours) — Delivers user-visible value  
**Full Scope**: T001-T026 (26 tasks, ~8-12 hours) — Production-ready  
**Suggested Start**: Begin with Phase 1 (Audit), then Phase 2 (Foundational), then run Phases 3-5 in parallel or sequentially as preferred.

---

## Notes

- All file paths are absolute from `lib/` directory
- Task IDs follow execution order (setup → foundational → stories P1/P2/P3 → polish)
- Parallelizable tasks ([P]) can run simultaneously within each phase or user story
- Each user story is independently testable and deployable
- No new dependencies added; only removal and simplification
- ZATCA compliance verified explicitly (T023)
