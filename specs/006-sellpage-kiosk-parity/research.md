# Phase 0 — Research: SellPage vs kiosk parity

**Feature**: `006-sellpage-kiosk-parity`  
**Date**: 2026-04-05

## Current gaps (from code + menu_items_readme)

| Area | Kiosk behavior | Handheld / SellPage today |
|------|----------------|---------------------------|
| Catalog load | `getProductsByCategoryFilteredByItems` when `selectedReportGroupIdProvider` set ([`KioskSaleTypeScreen`](../../lib/views/kiosk/sale_type_kiosk/kiosk_sale_type_screen.dart), [`MenuCategoryAndSaleTypeBar`](../../lib/views/kiosk/menu_widget/components/menu_category_and_sale_type_bar.dart)) | [`SaleTypesWidget._preloadData`](../../lib/views/sale_typs/sale_type_widget.dart) uses `getProductsByCategory` only — **no report-group filter** |
| Grid tap | `MenuProductTapHandler.handleProductTap` | [`ProductGrid`](../../lib/components/widgets/SellPage/product_grid.dart) `onTap: () {}` — **no-op** |
| Barcode | `MenuProductTapHandler` after lookup | `ProductUnitDialog` or direct `CartItem` — **different** from kiosk |
| Customization | `KioskProductCustomizationSheet` | `ProductUnitDialog` (`SingleVariationWithPrice`) |
| Session scope | `selectedReportGroupIdProvider` set at split store | Often **null** on pure handheld flow → misleading accent colors |

## Decisions

1. **Single catalog loader**: Extract shared preload used by kiosk sale-type flows **and** `SaleTypesWidget._preloadData` so filtered vs unfiltered logic lives in one place.
2. **Single add pipeline**: Handheld grid + handheld barcode → **`MenuProductTapHandler`** (same as kiosk).
3. **Split store on handheld**: Gated by **new settings flag**; off → **`defaultReportGroupId`** (or documented null policy) written to `selectedReportGroupIdProvider` before Sell page.
4. **Device class**: Reuse existing prefs / layout heuristics already in app (`find_first_path`, install flow); document chosen predicate in `data-model.md`.

## Non-goals (this release)

- Rewriting `CartNotifier.addItem` merge semantics (+1 vs full qty) unless a separate bug is filed.
- Full free-item promotion dialog port (`MenuProductTapHandler` placeholder).
- iOS/web (project is Android-focused).
