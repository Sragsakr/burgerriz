# AGENTS.md

> Cross-tool AI agent instructions for the POSMena POS project.

# Constrains
any plan must save it in docs folder 

## Identity

**POSMena** is a production Flutter POS (Point of Sale) system for Saudi Arabia with:
- **Dual UI mode**: Handheld (cashier-operated) and Kiosk (self-service)
- **Offline-first architecture** with SQLite + background sync
- **ZATCA compliance** for Saudi e-invoicing
- **Multi-printer support**: Bluetooth, USB/Network, PDF

**Platform**: Android only  
**Flutter**: 3.32.8 (stable)  
**State**: Riverpod (new) + ChangeNotifier (legacy)  
**Database**: SQLite via sqflite  
**API**: Dio-based services  
**Router**: GoRouter  

---

## Quick Commands

| Action | Command |
|--------|---------|
| Run (dev) | `flutter run` |
| Build APK | `flutter build apk --release` |
| Test | `flutter test` |
| Analyze | `flutter analyze` |
| Format | `dart format lib/` |

---

## Architecture

```
lib/
├── core/                    # Cross-cutting concerns
│   ├── config/              # AppConfig, AppModeSession, ApiConfig
│   ├── helpers/             # dPrint, AppPreferences, ProductTapHandler, responsive
│   ├── routers/             # GoRouter, AppRoutes
│   ├── services/            # KDS, printing, PDF, sync, variations
│   ├── theme/               # App theme
│   └── sdks/                # Hardware SDK wrappers
├── data/
│   ├── models/              # Pure data classes (no Flutter imports)
│   └── services/
│       ├── local_data/      # SQLite tables (one class per table)
│       └── remote_data/
│           ├── interfaces/  # API contracts (*_api_interface.dart)
│           └── implementations/ # Dio services (*_api_service.dart)
├── repository/              # Domain logic (local + remote)
├── providers/               # Riverpod StateNotifiers & Providers
├── features/
│   ├── kiosk-features/      # Kiosk-only screens
│   ├── mobile-features/     # Handheld-only screens
│   └── shared-features/     # Shared: Login, Install, Cashier, Orders, customization
└── main.dart
```

### Dual UI Mode

`AppConfig.mode` → `AppMode.handheld` | `AppMode.kiosk`

- Check mode: `AppConfig.isMobile` / `AppConfig.isKiosk`
- Route decisions: Use `AppModeSession` (provides `postCashierRoute`, `postSaleTypeRoute`, `postPaymentRoute`)
- **Never** hardcode mode-based routing in individual screens

### Boot Sequence

1. `main()` → `initializeApp()`
2. Opens SQLite DB (`AppDB.init()`)
3. Loads `AppPreferences` (SharedPreferences singleton)
4. Initializes theme + localizations
5. `checkValues()` → determines initial route: Install (unconfigured) or Login (configured)
6. In debug mode: `AppDB.deleteAllSaleDb()` wipes sales data

---

## Conventions

### State Management
- **New code**: Riverpod (`flutter_riverpod`)
- **Legacy**: ChangeNotifier via `provider` — do not extend
- Key providers: `cartProvider`, `MenuProviders`, `PaymentBreakdownProvider`, `PromotionProvider`, `CategoryNavigationProvider`

### Error Handling
- Data + repository methods return `Either<Failure, T>` from `eitherx`
- Consume with `.fold()` in the repository layer
- **Never** throw exceptions across layer boundaries

### Logging
- `dPrint()` → debug-only print (from `lib/core/helpers/helper_functions.dart`)
- `AppLogger.info/error/warning()` → structured logging (from `lib/core/helpers/logger.dart`)
- **Never** use raw `print()`

### Routing
- Flat `GoRouter` configuration in `lib/core/routers/router.dart`
- Route constants in `AppRoutes` (`lib/core/routers/app_routes.dart`)
- Screens declare `static const routePath` and `static const routeName`
- Navigate: `context.goNamed(WidgetName.routeName)`
- `popScopeWidget()` wraps every route (prevents system back)
- Kiosk: `InteractionDetectorWidget` → redirects to `/entry` after 240s inactivity

### Product Tap Flow
`ProductTapHandler.handleProductTap()` is the **single entry-point** for adding any product to the cart.
Flow: quantity pre-selection → combo meal detection → variant selection → customization → cart insertion + order recalculation + promotion check + free-item dialogs.
**Never** add to cart directly from UI widgets.

### Database (SQLite)
- `AppDB` opens `posmena_db.db` at startup
- Tables: standalone classes with static `create()` and CRUD methods
- Key groups: Sales (`SalesOrderTable`, `SalesItemsTable`, `SalesPayMethodTable`), Menu sync, Device config, Promotions

### Remote API
- `BaseApiService` (abstract) wraps Dio with 60s timeout + `TalkerDioLogger`
- Call `await service.initialize()` before use
- Auth via `addAuthToken()`
- Interface pattern: `*_api_interface.dart` → `*_api_service.dart`

### Sync
`GlobalSyncService` runs periodically after login. Uploads: unsynced sales orders, refunds, ZATCA invoices.

### Printing
Three paths sharing `PrintUtils` / `PrintController`:
1. Bluetooth — `blue_thermal_printer` / `flutter_bluetooth_printer`
2. USB/Network — `drago_pos_printer` / `flutter_thermal_printer`
3. PDF — `pdf` + `printing`, rendered in isolate (`pdf_isolate.dart`)

### ZATCA (Saudi e-invoice)
`zatca_2_invoice_generator` handles QR + XML signing. Device creds in `DeviceConfigTable`. Sync via `GlobalSyncService`.

### Localization
- Locales: `en`, `ar`. RTL automatic for Arabic.
- `isAr()` helper for inline locale checks
- Arabic fonts: Almarai, Cairo, bank. English: Rubik.
- Language persisted in `AppPreferences.getLanguage()`

---

## Strict Rules (Do NOT Violate)

| # | Rule |
|---|------|
| 1 | Use `dPrint()` or `AppLogger` — never raw `print()` |
| 2 | Return `Either<Failure, T>` — never throw across layers |
| 3 | Add to cart via `ProductTapHandler` only — never from UI directly |
| 4 | Use `AppModeSession` for routing — never hardcode mode checks |
| 5 | Use Riverpod for new state — never extend ChangeNotifier patterns |
| 6 | Each screen: `static const routePath` + `static const routeName` |
| 7 | Navigate: `context.goNamed()` — never hardcode paths |
| 8 | API services: `await service.initialize()` before use |
| 9 | `AppPreferences().init()` must run in `main()` before any access |
| 10 | Flutter SDK: 3.32.8 stable channel |


<claude-mem-context>
# Memory Context

# [posmena-pos] recent context, 2026-05-07 2:17pm GMT+3

Legend: 🎯session 🔴bugfix 🟣feature 🔄refactor ✅change 🔵discovery ⚖️decision 🚨security_alert 🔐security_note
Format: ID TIME TYPE TITLE
Fetch details: get_observations([IDs]) | Search: mem-search skill

Stats: 17 obs (6,931t read) | 131,628t work | 95% savings

### Apr 26, 2026
7 11:06p 🔵 Saudi Riyal Icon Asset Usage Analysis Requested
8 " 🔵 Saudi Riyal Icon Asset Usage Map Across posmena-pos
9 11:14p ⚖️ Currency Symbol Display Logic: Image for SAR, Text for Others
10 " 🔵 Currency System Architecture in posmena-pos
11 " 🔵 CurrencyTable.getSarCurrency() Is a Misnomer — Returns First Row, Not SAR-Specific
12 11:15p 🔵 _currencySymbol() Is Static — Cannot Easily Become Async/Dynamic
13 " 🔵 Currency Symbol Call Sites: Mixed Widget Types Complicate Riverpod-Based Fix
14 " 🔵 Currency Symbol Color Variant Usage Pattern Confirmed Across All Call Sites
### Apr 27, 2026
15 12:16a ⚖️ Default Currency UI – Hard Remove currencyId Plan Loaded
16 " 🔵 CurrencyDisplayWidget Codebase Reconnaissance Complete
17 12:17a 🟣 Phase 1 Complete: currencyId Removed from CurrencyDisplayWidget Public API
18 " 🔄 CurrencyDisplayHelper currencyId Parameter Fully Removed from Helper API
19 " 🟣 Phase 3 Complete: Unit Tests Created for CurrencyDisplayHelper Default Currency Behavior
20 " 🟣 Phase 4 Complete: Usage Guard Test and Documentation Added
21 " 🟣 All 5 Tests Pass — Default Currency UI Plan Fully Implemented and Verified
22 12:18a 🔵 flutter analyze: 701 Pre-Existing Issues, Zero New Issues from Currency Changes
23 " ✅ Final State Verified: All Modified Files Clean, Git Status Confirms Scope

Access 132k tokens of past work via get_observations([IDs]) or mem-search skill.
</claude-mem-context>

<!-- SPECKIT START -->
For additional context about technologies to be used, project structure,
shell commands, and other important information, read the current plan:
specs/014-install-cluster-validation/plan.md
<!-- SPECKIT END -->
