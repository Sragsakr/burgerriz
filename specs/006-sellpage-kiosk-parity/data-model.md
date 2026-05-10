# Data model & session state — 006 sellpage-kiosk-parity

## New or extended preferences (proposed keys)

| Key | Type | Purpose |
|-----|------|---------|
| `show_split_store_handheld` | bool | FR-009: if **true**, handheld navigates through **SplitStoreScreen** before Sell page (when multi-store applies). If **false**, skip. |
| `default_report_group_id_handheld` | int? | When split store is **skipped**, set `selectedReportGroupIdProvider` to this value before catalog load; **null** = legacy “no filter” (document risk). |

*Naming*: align with `AppPreferences` existing style; may live under **Settings** UI backed by same store.

## Riverpod state (existing)

| Provider | Role after feature |
|----------|-------------------|
| `selectedReportGroupIdProvider` | Must be set consistently on handheld before any `productsProvider` fill used by Sell page. |
| `selectedStoreInfoProvider` | Optional branding; should match chosen report group. |
| `saleTypeNotifier` | Unchanged; drives `priceListId`. |
| `categoriesProvider` / `productsProvider` | Filled by shared loader with same rules as kiosk. |

## Navigation state machine (handheld)

```text
Home → Cashier → SaleTypesWidget → CustomerSelection → [SplitStore IF show_split_store_handheld] → SellpageWidget
```

## Entities (spec alignment)

- **Ordering session** includes: `show_split_store_handheld`, `default_report_group_id_handheld` resolution, effective `reportGroupId`, `saleTypeId`, customer id.
