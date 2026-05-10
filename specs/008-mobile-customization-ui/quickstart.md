# Quickstart: Mobile-Adaptive Customization UI

**Branch**: `008-mobile-customization-ui` | Date: 2026-04-07

---

## What is being built

Two new Flutter widgets for the **handheld/mobile mode** of the POS app:

1. **`MobileItemCustomizationSheet`** — bottom-sheet version of the product customization flow (size, modifiers, variants)
2. **`MobileComboMealSheet`** — bottom-sheet version of the combo meal builder

Both replace their kiosk counterparts only when `AppConfig.isMobile` is true. The kiosk widgets are untouched.

---

## Files to create

```
lib/features/mobile-features/customization/
├── mobile_item_customization_sheet.dart   ← NEW
└── mobile_combo_meal_sheet.dart           ← NEW
```

## Files to update

```
lib/features/shared-features/customization/
├── product_customization_host.dart        ← swap mobile branch
└── combo_meal_dialog.dart                 ← add mobile branch
```

---

## Key implementation notes

### Bottom sheet pattern

```dart
// In MobileItemCustomizationSheet:
static Future<ItemCustomizationResult?> show(BuildContext context, { ...params... }) {
  return showModalBottomSheet<ItemCustomizationResult>(
    context: context,
    isScrollControlled: true,   // required for > 50% height
    enableDrag: true,           // swipe-to-dismiss
    useSafeArea: true,          // Android bottom inset handled
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: MobileItemCustomizationSheet(...params...),
    ),
  );
}
```

### Drag handle

```dart
// Top of sheet body column:
Center(
  child: Container(
    width: 40, height: 4,
    margin: const EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(
      color: Colors.grey.shade300,
      borderRadius: BorderRadius.circular(2),
    ),
  ),
),
```

### UOM grid — 2 columns (mobile) vs 4 columns (kiosk)

```dart
// Mobile: cols = 2
LayoutBuilder(builder: (context, constraints) {
  const cols = 2;
  const spacing = 8.0;
  final tileW = (constraints.maxWidth - spacing * (cols - 1)) / cols;
  return Wrap(
    spacing: spacing, runSpacing: spacing,
    children: widget.unitOptions.map((unit) =>
      KioskStyleCustomizationOptionTile(
        ...,
        tileWidth: tileW,
      ),
    ).toList(),
  );
}),
```

### Single-scroll layout (no wizard steps)

All sections (UOM → modifiers → variants) are rendered in one `Column` inside a `SingleChildScrollView`. No `_currentStepIndex` state is needed.

```dart
SingleChildScrollView(
  child: Column(
    children: [
      if (widget.unitOptions.length > 1) _buildUomSection(),
      ..._modifierGroups.map((g) => _buildGroupSection(g)),
      ..._variantGroups.map((g) => _buildGroupSection(g)),
      const SizedBox(height: 16),
    ],
  ),
),
```

### Validation on confirm (all groups at once)

Since there are no wizard steps, validation runs across all groups on the single "Add" button press — same logic as `ItemCustomizationDialog._confirm()`.

### ProductCustomizationHost update

```dart
// Before (mobile branch):
return ItemCustomizationDialog(...);

// After (mobile branch — widget is never returned directly, sheet is shown):
WidgetsBinding.instance.addPostFrameCallback((_) {
  MobileItemCustomizationSheet.show(context, ...).then((result) {
    // result handling identical to existing caller pattern
  });
});
return const SizedBox.shrink();
```

> **Note**: Check how the caller currently handles the result from `showAppDialog` + `ProductCustomizationHost` to ensure the `then()` chain is wired correctly. The `product_tap_cart_support.dart` service is the ultimate consumer.

### combo_meal_dialog.dart update

```dart
Future<void> showComboMealDialog({ required BuildContext context, ... }) async {
  if (AppConfig.isMobile) {
    await MobileComboMealSheet.show(context, ...);
  } else {
    await showAppDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ComboMealWidget(...),
    );
  }
}
```

---

## Bilingual rule

All new strings use `translator(arText: '...', enText: '...')`. No `Text('...')` with hardcoded English. Check with `flutter analyze` — the linter will not catch this, so do a manual string search before PR.

---

## Manual testing checklist

- [ ] Mobile mode: customization sheet slides up as bottom sheet
- [ ] Mobile mode: drag handle visible; swipe down dismisses and returns cancelled
- [ ] Mobile mode: UOM tiles in 2-column grid, min 48 dp height
- [ ] Mobile mode: all modifier/variant groups visible in one scroll
- [ ] Mobile mode: live total updates on every selection change
- [ ] Mobile mode: required group shows inline error on confirm attempt
- [ ] Mobile mode: edit mode pre-populates all previous selections
- [ ] Mobile mode: combo sheet shows spinner, then packages, then add button
- [ ] Mobile mode: combo button disabled until all packages complete
- [ ] Kiosk mode: `ItemCustomizationDialog` and `ComboMealWidget` completely unchanged
- [ ] Arabic locale: RTL layout correct, Arabic text displayed
- [ ] Small phone (360 dp width): no overflow or clipping
