# UI Contract: MobileComboMealSheet

**Type**: Flutter ConsumerStatefulWidget (mobile-mode only)  
**Location**: `lib/features/mobile-features/customization/mobile_combo_meal_sheet.dart`  
**Replaces**: `ComboMealWidget` in the mobile branch of `showComboMealDialog`

---

## Constructor parameters

| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `product` | `SyncProduct` | ✅ | — | Combo product (name, image, nutrition) |
| `basePrice` | `double` | ✅ | — | Base price before package add-ons |
| `initialQuantity` | `int` | ✅ | — | Starting quantity (clamped 1–999) |

---

## Static launch method

```
MobileComboMealSheet.show(context, { product, basePrice, initialQuantity })
  → Future<void>
```

- Called from `showComboMealDialog` when `AppConfig.isMobile` is true.
- Calls `showModalBottomSheet` with `isScrollControlled: true`, `enableDrag: true`, `useSafeArea: true`.
- Returns `void` — cart insertion happens internally (same as `ComboMealWidget`).

---

## Riverpod providers consumed

| Provider | Access | Purpose |
|---|---|---|
| `comboMealProvider` | `ref.watch` | Package selections, total, isComplete, loading, error |
| `comboMealProvider.notifier` | `ref.read` | `reset()` on close |
| `cartProvider.notifier` | `ref.read` | `addItem()` on confirm |
| `reportGroupThemeProvider` | `ref.watch` | Accent color |

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
│    [Loading spinner OR           │
│     Package 1 selector           │
│     Package 2 selector           │
│     ...all packages in one list] │
│                                  │
│  ─────────────────────────────── │
│  [ − qty + ]  [ Add / Complete ] │  ← pinned footer + safe area
└──────────────────────────────────┘
```

---

## States

| State | Condition | Display |
|---|---|---|
| Loading | `state.isLoading` | Centered `CircularProgressIndicator` in body |
| Error | `state.error != null` | Centered error icon + message |
| Ready — incomplete | `!state.isComplete` | Footer button disabled, label "Complete your selections" |
| Ready — complete | `state.isComplete` | Footer button enabled, label "Add To Cart (SAR X)" |

---

## Bilingual strings

| Context | Arabic | English |
|---|---|---|
| Confirm (complete) | أضف إلى السلة | Add To Cart |
| Confirm (incomplete) | أكمل اختياراتك | Complete your selections |
| Loading | جاري التحميل... | Loading... |
| Nutrition label | التغذية | Nutrition |
