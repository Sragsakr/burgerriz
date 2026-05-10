# Data Model: Mobile-Adaptive Customization UI

**Phase 1 output** | Branch: `008-mobile-customization-ui` | Date: 2026-04-07

---

## No new data entities

This feature is a pure UI adaptation. All data models are pre-existing and reused without modification:

| Model | Location | Role |
|---|---|---|
| `ItemCustomizationResult` | `data/models/menu_item/item_customization_result.dart` | Return value from customization flow (unchanged) |
| `MenuItemDetails` | `data/models/menu_item/menu_item_details.dart` | UOM option (unit of measure + price) |
| `SelectedVariant` | `data/models/menu_item/selected_variant.dart` | A chosen variant value with quantity and free flag |
| `VariantGroupData` | `features/kiosk-features/menu_widget/components/item_customization/models/variant_group_data.dart` | Modifier or variant group metadata |
| `VariantValueOption` | same file as above | Individual option within a group |
| `SyncProduct` | `data/models/sync_product/sync_product_model.dart` | Product passed into combo and customization widgets |
| `CartItem` | `data/models/cart_item.dart` | Cart entry added on confirm |
| `ComboMealItem` | `data/models/cart_item.dart` | Sub-item within a combo cart entry |
| `ComboMealState` | `providers/combo_meal_provider.dart` | Riverpod state for combo package selections |

---

## State owned by new widgets

Each new mobile widget owns its own `State` class (no shared base). The state fields mirror the existing kiosk widgets exactly:

### `_MobileItemCustomizationSheetState`

| Field | Type | Purpose |
|---|---|---|
| `_selectedUnit` | `MenuItemDetails?` | Currently selected UOM |
| `_selectedByGroup` | `Map<int, List<SelectedVariant>>` | Selections keyed by `variantId` |
| `_validationErrors` | `Map<int, String>` | Per-group inline error messages |
| `_quantity` | `int` | Item quantity (1–999) |
| `_uomShowError` | `bool` | Inline error flag for UOM group |
| `_modifierGroups` | `List<VariantGroupData>` | Modifier-type groups |
| `_variantGroups` | `List<VariantGroupData>` | Variant-type groups |

### `_MobileComboMealSheetState`

| Field | Type | Purpose |
|---|---|---|
| `_quantity` | `int` | Item quantity (1–999) |
| `_scrollController` | `ScrollController` | Sheet body scroll |

`ComboMealState` (packages, selections, total, isComplete) lives in `comboMealProvider` — accessed via `ref.watch`.

---

## Provider dependencies (read-only, unchanged)

| Provider | Used by | Purpose |
|---|---|---|
| `comboMealProvider` | `MobileComboMealSheet` | Combo package state + total |
| `cartProvider` | `MobileComboMealSheet` | Add item to cart on confirm |
| `reportGroupThemeProvider` | both | Accent color for buttons/highlights |
