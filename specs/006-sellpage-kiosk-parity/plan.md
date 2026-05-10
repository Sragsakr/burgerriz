# Implementation Plan: Handheld and kiosk ordering parity

**Branch**: `006-sellpage-kiosk-parity` | **Date**: 2026-04-05 | **Spec**: [spec.md](./spec.md)  
**Input**: Feature specification from `specs/006-sellpage-kiosk-parity/spec.md` (incl. clarifications: split-store settings flag, handheld path Home → Cashier → Sale type → Customer → Sell page)

## Summary

Unify **SellPage (handheld)** with **kiosk** so that: (1) **routing** follows the spec—handheld uses the staff chain ending on **Sell page**; kiosk keeps **Entry → split store (when applicable) → sale type → menu**. (2) **Catalog scope** uses the same **effective reporting group / store** as kiosk when the new **“show split store”** setting is on; when off, handheld **skips** `SplitStoreScreen` and applies a **configured default** `selectedReportGroupIdProvider` (or equivalent). (3) **Add-to-cart** from the **ProductGrid** and **barcode** paths call the same pipeline as kiosk (`MenuProductTapHandler` + `KioskProductCustomizationSheet` / combo dialog), replacing or bypassing **ProductUnitDialog** for parity. (4) **Menu preload** after sale type on handheld reuses the same **filtered-by-report-group** loading as [`MenuCategoryAndSaleTypeBar._loadFilteredMenu`](../../lib/views/kiosk/menu_widget/components/menu_category_and_sale_type_bar.dart) / [`KioskSaleTypeScreen._loadFilteredMenu`](../../lib/views/kiosk/sale_type_kiosk/kiosk_sale_type_screen.dart).

Reference: [docs/menu_items_readme.md](../../docs/menu_items_readme.md).

## Technical Context

| Item | Value |
|------|--------|
| **Language/Version** | Dart 3.x / Flutter (Android target per `pubspec.yaml`) |
| **Primary dependencies** | `flutter_riverpod`, `go_router`, `sqflite` |
| **Storage** | SQLite (`AppDB`), `SharedPreferences` via `AppPreferences` |
| **Testing** | `flutter test`, manual device matrix (phone vs kiosk) |
| **Target platform** | Android tablets/phones (kiosk + handheld) |
| **Project type** | Flutter POS monolith (`lib/views`, `lib/providers`, `lib/repository`) |
| **Performance** | Menu preload must stay non-blocking UI (existing overlay patterns) |
| **Constraints** | Offline-first menu reads; no blocking network for catalog; ZATCA unchanged by this feature |
| **Scale** | Two store brands (report groups 5/6) + optional single-store deployments |

## Constitution Check

| Principle | Status | Notes |
|-----------|--------|--------|
| **I. MVVM layers** | Pass with care | Prefer keeping **navigation + thin delegation** in views; reuse existing [`MenuProductTapHandler`](../../lib/views/kiosk/menu_widget/components/menu_product_tap_handler.dart) rather than duplicating logic in widgets. If preload grows, consider a small **repository-level** helper callable from sale-type flow (repository owns catalog assembly). |
| **II. Offline-first** | Pass | All catalog changes remain SQLite-backed; no new hard dependency on network for browsing. |
| **III. ZATCA** | Pass | Cart line shape preserved; no invoice signing changes in scope. |
| **IV. Hardware** | Pass | Barcode still via existing scanner listener / manual entry. |
| **V. Bilingual** | Pass | Reuse existing localization patterns on any new settings strings. |

**Gate**: Proceed. Re-check after implementation: no new direct SDK calls from views.

## Project Structure (this feature)

### Documentation

```text
specs/006-sellpage-kiosk-parity/
├── spec.md
├── plan.md              # this file
├── research.md          # decisions summary
├── data-model.md        # settings + session state
├── quickstart.md        # QA smoke steps
└── contracts/
    └── navigation-handheld.md
```

### Source (touch list)

```text
lib/
├── core/routers/router.dart              # redirects: handheld vs kiosk initial branches (if needed)
├── core/helpers/app_pref.dart           # optional: new pref keys (or settings table)
├── providers/payment_breakdown_provider.dart   # selectedReportGroupIdProvider (fallback)
├── providers/menu_providers.dart        # unchanged contract; callers change
├── views/sale_typs/sale_type_widget.dart    # _preloadData → filtered load + split-store gate
├── views/SellPage/sellpage_widget.dart      # optional: ensure context before grid
├── components/widgets/SellPage/
│   ├── product_grid.dart                    # wire onTap → MenuProductTapHandler
│   ├── custom_tab_bar.dart                  # optional: quantity provider for grid
│   └── sell_page_custom_nav_bar.dart        # barcode → same handler as kiosk
├── views/kiosk/menu_widget/components/menu_product_tap_handler.dart  # shared (minor refactors)
├── views/settings/settings_screen.dart      # new toggle: show split store on handheld
└── views/Home/, views/Cashier/              # verify goNamed chain matches FR-010
```

**Structure decision**: Single Flutter app; feature spans **routing**, **settings**, **SellPage widgets**, and **sale-type preload** only—no new package.

## Phased implementation

### Phase 0 — Discovery (complete)

Documented in [research.md](./research.md): current gaps (empty `ProductGrid` tap, unfiltered `SaleTypesWidget._preloadData`, `ProductUnitDialog` vs sheet), and decision to **centralize catalog loading** in one function used by kiosk sale-type bar and handheld sale-type widget.

### Phase 1 — Settings + session defaults

1. Add **boolean** preference (or settings row): `showSplitStoreOnHandheld` (name TBD), default **true** or **false** per product owner—document in `data-model.md`.
2. When **false** on handheld path: after login/sale type, **set** `selectedReportGroupIdProvider` from **new** pref `defaultReportGroupId` (int?) **before** `SellpageWidget` builds catalog; if null, define policy (e.g. first store in DB or “no filter”) and document.
3. When **true** and multi-store: on handheld, show **SplitStoreScreen** **after** **Customer selection** and **immediately before** navigating to **Sell page** (extends FR-010: `… → Customer → [Split store if setting on] → Sell page`). When **false**, skip that screen and apply **default** `reportGroupId` before opening Sell page.

4. Ensure `selectedStoreInfoProvider` / accent colors match loaded `reportGroupId` on handheld (FR-007).

### Phase 2 — Catalog preload parity (FR-003)

1. Extract **shared** `Future<void> loadMenuCatalogForSession(WidgetRef ref, {required SaleType saleType, required int? reportGroupId, required bool filterByReportGroup})` (or static on `MenuItemSyncRepository`) implementing logic from [`MenuCategoryAndSaleTypeBar._loadFilteredMenu`](../../lib/views/kiosk/menu_widget/components/menu_category_and_sale_type_bar.dart) (lines 34–86 pattern).
2. Call it from **`SaleTypesWidget._preloadData`** (handheld) with:
   - `filterByReportGroup = showSplitStoreOnHandheld && selectedReportGroupId != null` OR always when `reportGroupId` resolved from default.
3. Keep **`KioskSaleTypeScreen`** / **`MenuCategoryAndSaleTypeBar`** using the same helper to avoid drift.

### Phase 3 — Product grid + barcode parity (FR-004–FR-006)

1. **`product_grid.dart`**: `onTap` → `MenuProductTapHandler.handleProductTap(context, ref, product, isEnglish, false)` (match [`MenuProductCardWidget`](../../lib/views/kiosk/menu_widget/components/menu_product_card_widget.dart)).
2. **Optional**: expose `quantitySelectionProvider` on Sell grid (compact stepper or default 1)—match kiosk if product cards include quantity.
3. **`sellpage_widget.dart` / `sell_page_custom_nav_bar.dart`**: replace barcode branches that open **`ProductUnitDialog`** with **`MenuProductTapHandler.handleProductTap`** after `getProductByBarcode` (same as [`MenuWidget.onBarcodeScanned`](../../lib/views/kiosk/menu_widget/menu_widget.dart)).
4. Deprecate or limit **`ProductUnitDialog`** to legacy screens only; add comment.

### Phase 4 — Routing & device class (FR-001, FR-002)

1. Define **single source of truth** for handheld vs kiosk: e.g. `AppPreferences().getKioskMode()` + `ResponsiveHelper.isTablet(context)`—document in research.
2. **`createRouterKiosk` / `find_first_path`**: initial location and post-login **go** targets:
   - Handheld: ensure path reaches **Cashier** → **SaleTypesWidget** → **customers** → **Sell page** (fix any shortcut that skips customer or sale type).
   - Kiosk: unchanged **Entry** → **SplitStore** (if applicable) → **KioskSaleType** → **Menu**.

### Phase 5 — Verification

Execute [quickstart.md](./quickstart.md); run `flutter analyze`; manual SC-001–SC-003 matrix.

## Risk & rollback

| Risk | Mitigation |
|------|------------|
| Double preload / flicker | Debounce or single-flight catalog load keyed by `(saleTypeId, reportGroupId)`. |
| Wrong default report group | Feature-flag settings; default **null** = legacy unfiltered until configured. |
| Regression on pure kiosk | Gate all handheld-only branches on device class + prefs. |

## Complexity Tracking

No constitution violations required; shared static `MenuProductTapHandler` remains—future refactor to repository/use-case is optional tech debt.

## Suggested next command

`/speckit.tasks` — break phases into checkable tasks in `tasks.md`.
