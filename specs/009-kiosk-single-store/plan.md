# Implementation Plan: Remove Multi-Store ReportGroup Feature from Kiosk Mode

**Branch**: `009-kiosk-single-store` | **Date**: 2026-04-07 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/009-kiosk-single-store/spec.md`

## Summary

Remove ReportGroup multi-store feature from kiosk mode to simplify operation to single-store (parity with mobile/handheld mode). Kiosk flow remains: Entry → Cashier → Sell → Sale Type → Menu → Checkout → Entry. Primary changes: remove SplitStoresScreen UI, eliminate ReportGroup filtering in product loading, simplify session initialization.

## Technical Context

**Language/Version**: Dart 3.x / Flutter 3.x  
**Primary Dependencies**: flutter_riverpod, sqflite, go_router, flutter_localizations, collection  
**Storage**: SQLite (sqflite) — tables: MenuItemFBTable, SalesOrdersTable, SalesItemsTable, ReportGroupTables (to be deprecated)  
**Testing**: flutter test (integration + widget tests for flow verification)  
**Target Platform**: Android (kiosk mode; mobile mode already single-store)  
**Project Type**: Mobile POS application (self-service kiosk + cashier handheld)  
**Performance Goals**: Entry screen displays in <2 seconds, menu load <500ms  
**Constraints**: Offline-capable, ZATCA Phase 2 compliant e-invoicing, bilingual AR/EN  
**Scale/Scope**: Single-store kiosk mode, 50+ existing screens, 25+ Riverpod providers

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

✅ **Principle I (Layered Architecture/MVVM)**: ALIGNED
- ReportGroup removal affects repository layer (menu loading) and data layer (filtering logic removal)
- Views will no longer see ReportGroup UI components
- No layer violations introduced

✅ **Principle II (Offline-First Core Operations)**: MAINTAINED
- Menu loading and cart operations continue to work offline
- ReportGroup filtering removal simplifies offline logic
- No new network dependencies

✅ **Principle III (ZATCA Compliance)**: VERIFY POST-IMPLEMENTATION
- Current ZATCA integration does not depend on ReportGroup (invoicing is per-transaction, not per-store)
- PR must include verification that invoice generation continues to work correctly
- No changes to tax calculation or invoice signing

✅ **Principle IV (Hardware Abstraction)**: NO IMPACT
- Hardware integrations (printers, payment) not affected

✅ **Principle V (Bilingual Support)**: NO IMPACT
- No string changes; removal of store selector UI removes bilingual labels only (a simplification)

**Gate Status**: ✅ PASS — All principles either aligned or unaffected. No violations.

## Project Structure

### Documentation (this feature)

```text
specs/009-kiosk-single-store/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── spec.md              # Feature specification
├── checklists/
│   └── requirements.md  # Quality validation
└── tasks.md             # Phase 2 output (/speckit.tasks command)
```

### Source Code (repository root — Flutter POS)

```text
lib/
├── core/                           # Cross-cutting concerns
│   ├── config/
│   │   ├── app_config.dart         # AppMode enum, AppConfig.isMobile/isKiosk
│   │   └── app_mode_session.dart   # Mode-aware routing helpers (REMOVE ReportGroup logic)
│   ├── services/
│   │   ├── order_services/
│   │   │   └── product_tap_menu_loader.dart  # REMOVE ReportGroup filtering
│   │   └── ...
│   └── theme/
│       ├── report_group_theme.dart # REMOVE or simplify (deprecate ReportGroup theme)
│       └── ...
├── features/
│   ├── kiosk-features/
│   │   ├── splite-stores/          # REMOVE entire directory (SplitStoresScreen)
│   │   ├── entry_widget/           # KEEP — entry screen (no store selector)
│   │   ├── menu_widget/            # MODIFY — remove ReportGroup filtering
│   │   ├── cart/
│   │   ├── pay_widget/
│   │   └── ...
│   ├── mobile-features/            # UNCHANGED (already single-store)
│   ├── shared-features/
│   │   ├── customization/
│   │   ├── payment/
│   │   └── ...
│   └── ...
├── data/
│   ├── models/
│   │   ├── store/                  # REMOVE ReportGroup-related models
│   │   └── ...
│   ├── services/
│   │   ├── local_data/
│   │   │   ├── db/
│   │   │   │   └── app_db.dart     # MODIFY — handle ReportGroup table deprecation
│   │   │   └── ...
│   │   └── ...
│   └── ...
├── repository/
│   ├── menu_item_sync_repository.dart  # MODIFY — remove ReportGroup filtering
│   ├── menu_catalog_preload_helper.dart # MODIFY — remove ReportGroup branch
│   └── ...
├── providers/                      # MODIFY related providers (reportGroupThemeProvider, selectedReportGroupIdProvider)
└── main.dart                       # MODIFY initialization (skip store selector)
```

**Structure Decision**: Single Flutter project, kiosk-features directory. Primary removals: `splite-stores/` directory, ReportGroup filtering in menu loaders, store-switching providers. Preservation: Existing kiosk flow (entry → cashier → sell → checkout).

## Complexity Tracking

No constitution violations. All design aligns with MVVM, offline-first, ZATCA compliance, hardware abstraction, and bilingual support principles.

---

## Phase 0: Outline & Research

### Research Questions & Findings

**Q1: How to handle legacy ReportGroup data in the database?**
- **Decision**: Clear ReportGroup data on app startup if it exists. SQLite tables remain defined but unused (safe for backward compatibility).
- **Rationale**: Avoids complex migration logic; kiosk is single-instance, can afford startup cleanup.
- **Implementation**: In `AppDB.init()`, after opening the database, query for any ReportGroup references and nullify them.

**Q2: What is the "default store" when ReportGroup is removed?**
- **Decision**: Use a hardcoded `defaultReportGroupId = 1` or remove the concept entirely and set all store lookups to null.
- **Rationale**: ZATCA invoicing doesn't require store association; menu loading uses price-list, not store. Simplest: pass null for ReportGroup in all product queries.
- **Implementation**: Modify `MenuItemSyncRepository.getAllProducts()` to not filter by ReportGroup.

**Q3: Does ZATCA invoice generation depend on ReportGroup?**
- **Decision**: No. Current `zatca_2_invoice_generator` integration operates per-transaction and doesn't use ReportGroup. Safe to remove.
- **Rationale**: Invoice serial numbers are per-device, not per-store. Removed ReportGroup references will not affect tax, QR, or signing.
- **Implementation**: No changes to invoice generation logic required.

---

## Phase 1: Design & Contracts

### Data Model Changes

**Entities to Remove/Deprecate**:
- **ReportGroup Table** (data/models/Synchronization/tables/): Leave schema intact but unused; no new references added.
- **MenuItemFBEntity.reportGroupId** (data/models/Synchronization/menu_item_fb_entity.dart): Field remains but always null.
- **ProductCategoryModel.reportGroupId** (if exists): Remove or nullify.

**Entities to Modify**:
- **SyncCategory** (data/models/sync_product/sync_product_model.dart): Remove `reportGroupId` field if present.
- **SyncProduct** (data/models/sync_product/sync_product_model.dart): Ensure no ReportGroup filtering applied during instantiation.

**Session State**:
- **ReportGroupSession** (core/config/app_mode_session.dart): Simplify or remove `effectiveCatalogReportGroupId()` method. Return null for kiosk.
- **reportGroupThemeProvider** (providers/): Simplify to use default theme (not store-specific).
- **selectedReportGroupIdProvider** (providers/): Remove or disable in kiosk mode.

### Key Changes by File

1. **lib/core/config/app_mode_session.dart**
   - Remove `effectiveCatalogReportGroupId()` or return null when kiosk
   - Remove `ReportGroupSession` class if kiosk-specific

2. **lib/core/services/order_services/product_tap_menu_loader.dart**
   - Remove ReportGroup parameter from `load()` call
   - Always call `MenuItemSyncRepository.getAllProducts(priceListId)` without filtering

3. **lib/repository/menu_item_sync_repository.dart**
   - Remove `getProductsByCategoryFilteredByItems()` method or simplify to no-op
   - Ensure `getProductsByCategory()` returns all products for category (no store filtering)

4. **lib/repository/menu_catalog_preload_helper.dart**
   - Remove ReportGroup filtering branch (lines 44-76)
   - Always call `getAllProducts()` and group by category in memory

5. **lib/features/kiosk-features/splite-stores/splite-store-screen.dart**
   - REMOVE entire file (UI screen for store selection)

6. **lib/features/kiosk-features/entry_widget/entry_widget.dart**
   - Remove navigation to SplitStoresScreen
   - Direct to menu/cashier after login

7. **lib/core/routers/router.dart**
   - Remove route for SplitStoresScreen
   - Update entry navigation logic

8. **lib/providers/ (multiple)**
   - Remove or stub `selectedReportGroupIdProvider`
   - Remove `reportGroupThemeProvider` or simplify to single theme

9. **lib/data/services/local_data/db/app_db.dart**
   - Add cleanup logic: nullify ReportGroup references on startup

### Interface Contracts

No new external interfaces exposed. This is a removal/refactoring feature. Existing menu product loading contract remains unchanged:
- **Input**: priceListId (int)
- **Output**: List<SyncProduct> (unfiltered by store)

### Quickstart & Integration Scenarios

**Scenario 1: Kiosk Startup with Existing ReportGroup Data**
1. App initializes
2. AppDB.init() opens database
3. Cleanup task runs: nullify any ReportGroup references
4. Entry screen displays (no store selector)
5. Operator selects sale type
6. Menu loads with full product catalog

**Scenario 2: Fresh Install (No Legacy Data)**
1. App initializes
2. Database created with all tables (ReportGroup tables present but unused)
3. Entry screen displays immediately
4. Normal kiosk flow continues

**Scenario 3: Mobile Mode Unaffected**
1. Mobile/handheld mode continues to function as before
2. No store selector screen (already single-store)
3. Menu loads with single price-list products

---

## Phase 1 Summary

**Output Files Generated**:
- ✅ research.md (Phase 0, above)
- ✅ data-model.md (this section)
- ✅ contracts/ (no new external contracts; internal refactoring)
- ✅ quickstart.md (scenarios documented above)

**Constitution Check Re-evaluation (Post-Design)**:
✅ PASS — All principles maintained. No new violations introduced.

**Readiness for Phase 2 (Task Generation)**:
Ready. Technical design is complete and clear. Next: `/speckit.tasks` to generate implementation task list.
