# Implementation Plan: Mobile-Adaptive Customization UI

**Branch**: `008-mobile-customization-ui` | **Date**: 2026-04-07 | **Spec**: [spec.md](spec.md)  
**Input**: Feature specification from `specs/008-mobile-customization-ui/spec.md`

## Summary

Create two new mobile-specific widgets — `MobileItemCustomizationSheet` and `MobileComboMealSheet` — that present the product customization and combo meal flows as modal bottom sheets (fixed 85% height, single scrollable page) when the app runs in handheld mode. The existing kiosk widgets (`ItemCustomizationDialog`, `ComboMealWidget`) are left completely unchanged. Routing to the correct widget is updated at two existing switch points: `ProductCustomizationHost` and `showComboMealDialog`.

---

## Technical Context

**Language/Version**: Dart 3.x (Flutter 3.x)  
**Primary Dependencies**: `flutter_riverpod`, `flutter_localizations`, `sqflite`  
**Storage**: N/A — pure UI feature; no new persistence  
**Testing**: `flutter_test` (widget tests optional per constitution; manual regression testing required)  
**Target Platform**: Android only (handheld cashier devices)  
**Project Type**: Mobile app (Flutter)  
**Performance Goals**: Sheet opens < 300 ms; live total updates within one frame (< 16 ms)  
**Constraints**: Fixed 85% screen height; 48 dp minimum touch targets; safe-area inset respected; RTL/LTR layout parity  
**Scale/Scope**: 2 new widget files, 2 call-site updates, reuse of existing sub-widgets and providers

---

## Constitution Check

| Principle | Impact | Status |
|---|---|---|
| I. Layered Architecture | New widgets in `lib/features/mobile-features/customization/` (view layer only). No business logic in views — all state via existing Riverpod providers. | ✅ Compliant |
| II. Offline-First | Pure UI change; no network calls introduced. | ✅ No impact |
| III. ZATCA Compliance | No touch to tax calculation, invoice generation, or QR logic. | ✅ No impact |
| IV. Hardware Abstraction | No hardware interactions. | ✅ No impact |
| V. Bilingual AR+EN | **Must enforce**: All new user-facing strings use `translator(arText:, enText:)`. Layouts validated in both RTL (Arabic) and LTR (English). | ⚠️ Must verify |

**Constitution verdict**: PASS. Principle V requires active enforcement during implementation — no hard-coded strings, RTL layout must be tested.

---

## Project Structure

### Documentation (this feature)

```text
specs/008-mobile-customization-ui/
├── plan.md              ← this file
├── research.md          ← Phase 0 output
├── data-model.md        ← Phase 1 output
├── quickstart.md        ← Phase 1 output
├── contracts/
│   ├── mobile-item-customization-sheet.md
│   └── mobile-combo-meal-sheet.md
└── tasks.md             ← Phase 2 output (/speckit.tasks)
```

### Source Code (repository root)

```text
lib/
├── features/
│   ├── mobile-features/
│   │   └── customization/                        ← NEW directory
│   │       ├── mobile_item_customization_sheet.dart   ← NEW
│   │       └── mobile_combo_meal_sheet.dart           ← NEW
│   └── shared-features/
│       └── customization/
│           ├── product_customization_host.dart    ← UPDATED (swap mobile branch)
│           └── combo_meal_dialog.dart             ← UPDATED (add mobile branch)
```

**Structure Decision**: New widgets go under `lib/features/mobile-features/customization/` to mirror the existing `kiosk-features/` pattern. All call-site changes are confined to the two existing shared-features host files.

---

## Complexity Tracking

*No constitution violations — section not required.*
