# UI Contract: MobileItemCustomizationSheet

**Type**: Flutter StatefulWidget (mobile-mode only)  
**Location**: `lib/features/mobile-features/customization/mobile_item_customization_sheet.dart`  
**Replaces**: `ItemCustomizationDialog` in the mobile branch of `ProductCustomizationHost`

---

## Constructor parameters

| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `menuItemName` | `String` | ✅ | — | Localized product name for the header |
| `menuItemId` | `int` | ✅ | — | ID used for variant lookup |
| `imageId` | `String?` | — | `null` | Product image identifier; header shown if non-null |
| `unitOptions` | `List<MenuItemDetails>` | ✅ | — | UOM options; skipped if length ≤ 1 |
| `variants` | `List<Map<String, dynamic>>` | ✅ | — | Raw variant/modifier data |
| `isVatExclusive` | `bool` | — | `false` | VAT exclusivity flag |
| `taxRate` | `double` | — | `0.0` | Tax rate for price calculations |
| `isEditMode` | `bool` | — | `false` | Pre-populate from initial selections when true |
| `initialSelectedUnit` | `MenuItemDetails?` | — | `null` | Pre-selected UOM (edit mode) |
| `initialSelectedVariants` | `List<SelectedVariant>?` | — | `null` | Pre-selected variants (edit mode) |
| `initialQuantity` | `int` | — | `1` | Starting quantity (clamped 1–999) |
| `accentColor` | `Color?` | — | `null` | Brand accent; falls back to default red |
| `numberOfCalories` | `String?` | — | `null` | Nutrition chip content |
| `numberOfSteps` | `String?` | — | `null` | Nutrition chip content |

---

## Static launch method

```
MobileItemCustomizationSheet.show(context, { ...same params... })
  → Future<ItemCustomizationResult?>
```

- Calls `showModalBottomSheet` with `isScrollControlled: true`, `enableDrag: true`, `useSafeArea: true`.
- Returns `ItemCustomizationResult` on confirm or `ItemCustomizationResult.cancelled()` on dismiss/swipe.
- The caller (ProductCustomizationHost) uses this return value identically to how it uses `showAppDialog` today.

---

## Return value

`ItemCustomizationResult` (unchanged contract):

| Field | Type | Description |
|---|---|---|
| `wasCancelled` | `bool` | `true` if dismissed without confirming |
| `selectedUnit` | `MenuItemDetails?` | Chosen UOM |
| `selectedVariants` | `List<SelectedVariant>` | All chosen variants with pricing rules applied |
| `totalPrice` | `double` | Unit price + variant additions |
| `quantity` | `int` | Final quantity |

---

## Layout contract (mobile)

```
┌──────────────────────────────────┐  ← sheet at 85% screen height
│  ────  (drag handle pill)        │
│  [product image, max 160px tall] │
│  Product Name          SAR total │
│  [Nutrition chips if available]  │
│  ─────────────────────────────── │
│  ▼ scrollable body               │
│    [UOM section — 2-col grid]    │
│    [Modifier groups — listed]    │
│    [Variant groups — listed]     │
│                                  │
│  ─────────────────────────────── │
│  [ − qty + ]  [    Add (SR X)  ] │  ← pinned footer + safe area
└──────────────────────────────────┘
```

---

## Validation rules (unchanged from ItemCustomizationDialog)

- Required UOM: must select one before confirming if `unitOptions.length > 1`.
- Required group: `group.isRequired && selectedCount < group.minSelections` → inline error per group.
- Max selections: enforced on toggle via `showMaxSelectionsExceededPopup`.
- Max qty per modifier: enforced on quantity update via `showMaxQtyPerModifierExceededPopup`.

---

## Bilingual strings

| Context | Arabic | English |
|---|---|---|
| Section: size | اختر الحجم | Choose Size |
| Section: modifiers | الإضافات | Modifiers |
| Section: variants | الخيارات | Options |
| Confirm button | إضافة | Add |
| Confirm button (edit) | تحديث | Update |
| UOM error | يرجى اختيار الحجم | Please select a size. |
| Nutrition label | التغذية | Nutrition |
