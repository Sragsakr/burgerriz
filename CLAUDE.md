# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.
# Constrains
any plan must save it in docs folder 

## Commands

```bash
# Run on a connected Android device / emulator
flutter run

# Release build (Android APK)
flutter build apk --release

# Run tests
flutter test

# Run a single test file
flutter test test/path/to/test_file.dart

# Analyze for lint errors
flutter analyze

# Format code
dart format lib/
```

The app targets **Android only** (iOS and web are disabled in `pubspec.yaml`).

## Architecture

The app is a Flutter kiosk POS (Point of Sale) for Saudi Arabia, using MVVM with Riverpod.

### Dual UI mode

`AppConfig.mode` is either `AppMode.handheld` or `AppMode.kiosk`. Use `AppConfig.isMobile` / `AppConfig.isKiosk` for conditional UI branches. `AppModeSession` (`lib/core/config/app_mode_session.dart`) exposes mode-aware routing helpers (`postCashierRoute`, `postSaleTypeRoute`, `postPaymentRoute`, `useCustomizationWizard`) so flow logic stays out of individual screens.

Features split by mode live in:
- `lib/features/kiosk-features/` — self-service kiosk screens
- `lib/features/mobile-features/` — cashier handheld screens
- `lib/features/shared-features/` — shared: Login, Install, Cashier, Orders, customization dialogs

### Boot sequence

`main()` → `initializeApp()` opens the SQLite DB (`AppDB.init()`), loads `AppPreferences` (SharedPreferences singleton), and initializes theme/localizations. Then `checkValues()` inspects stored prefs to decide the initial route: **Install** (first launch, no config) or **Login** (configured device).

### Folder structure

```
lib/
├── core/                           # Cross-cutting concerns
│   ├── assets/                     # Asset path references
│   ├── colors/                     # Color palettes
│   ├── components/widgets/         # Shared UI components
│   ├── config/                     # App-wide configuration
│   │   ├── app_config.dart         # AppMode enum, DecimalsNumbers, API base URL
│   │   ├── app_mode_session.dart   # Mode-aware routing helpers
│   │   └── api_config.dart         # API endpoint definitions
│   ├── constants/                  # App-wide constants
│   ├── enums/                      # Shared enums
│   ├── extentions/                 # Extension methods
│   ├── helpers/                    # ~22 utility files
│   │   ├── menu_product_tap_handler.dart   # Product tap orchestration entry point
│   │   ├── app_pref.dart                   # SharedPreferences singleton
│   │   └── helper_functions.dart           # dPrint(), isAr(), etc.
│   ├── routers/
│   │   ├── router.dart             # Flat GoRouter with popScopeWidget wrapping
│   │   ├── app_routes.dart         # Route path constants
│   │   └── route_transitions.dart  # Custom page transitions
│   ├── services/
│   │   ├── order_services/         # Order calculation, cart support, ProductTap modules
│   │   ├── printing_services/      # 3 print backends + receipt content builders
│   │   ├── pdf_services/           # Isolate-based PDF rendering
│   │   ├── sync_services/          # GlobalSyncService, ConnectivityService
│   │   ├── kds_service/            # Kitchen Display System HTTP client
│   │   ├── kiosk_mode_services/    # Inactivity timeout management
│   │   ├── loading_services/       # Splash/progress tracking
│   │   ├── variations_services/    # Variant comparison & translation helpers
│   │   └── qr_invoice_service/     # ZATCA QR & Feedmena/ZIGS integrations
│   └── theme/                      # App themes and report-group theming
│
├── data/
│   ├── models/                     # Pure Dart data classes (no Flutter imports)
│   │   ├── cart_item.dart
│   │   ├── sync_product/           # SyncProduct, SyncCategory
│   │   ├── menu_item/              # MenuItemDetails, SelectedVariant
│   │   ├── sales_models/           # SalesOrder, SalesItems, SalesInvoice
│   │   ├── combo_meal/
│   │   ├── promotions/
│   │   ├── sale_types/
│   │   └── Synchronization/        # Sync-related entities
│   ├── services/
│   │   ├── local_data/
│   │   │   ├── db/app_db.dart      # SQLite DB manager (CREATE TABLE IF NOT EXISTS)
│   │   │   ├── sales_tables/       # SalesOrdersTable, SalesItemsTable, SalesPaymethodsTable
│   │   │   ├── menu_tables/        # MenuItemFBTable, category/variation/translation tables
│   │   │   ├── customer_tables/    # CustomerTable, CustomerAddressTable
│   │   │   └── [other tables]      # Device, config, shift, promotions
│   │   └── remote_data/
│   │       ├── implementations/    # 25+ concrete Dio-based API services
│   │       ├── interfaces/         # Contracts for each service
│   │       └── service_locator.dart
│   └── NearPay/                    # NearPay payment SDK integration
│
├── repository/                     # Domain logic; combines local + remote sources
│   ├── menu_item_sync_repository.dart    # Menu + UOM + variants loading & caching
│   ├── combo_meal_repository.dart
│   ├── customer_repository.dart
│   └── promotions/
│       ├── promotion_handler_factory.dart
│       ├── handlers/               # One file per promotion type
│       └── enums/                  # PromotionTypes, PromotionValueType, etc.
│
├── providers/                      # Riverpod providers (~25 total)
│   ├── cart_provider.dart          # CartNotifier — in-memory cart
│   ├── menu_providers.dart         # categoriesProvider, allProductsProvider, productsProvider
│   ├── payment_breakdown_provider.dart
│   ├── combo_meal_provider.dart
│   ├── category_navigation_provider.dart
│   ├── quantity_selection_provider.dart
│   ├── customer_provider.dart
│   ├── order_summary_provider.dart
│   ├── promotion_provider.dart
│   ├── app_language_provider.dart
│   └── [ads, loading, login, nearpay providers]
│
├── features/
│   ├── shared-features/            # Cross-mode screens
│   │   ├── Login/                  # login_widget.dart (ChangeNotifier-based, legacy)
│   │   ├── Install/                # Device setup (separate flows for kiosk/handheld)
│   │   ├── Cashier/
│   │   ├── Orders/
│   │   ├── customization/          # product_customization_host.dart, combo_meal_dialog.dart
│   │   ├── payment/                # Checkout, final_invoice_builder.dart
│   │   ├── admin/                  # Reports, cashier shift reports
│   │   ├── customers/
│   │   ├── settings/
│   │   ├── qr_invoice/
│   │   ├── refunds/
│   │   ├── sale_typs/
│   │   └── debug/
│   ├── kiosk-features/             # Self-service kiosk screens
│   │   ├── entry_widget/           # Kiosk idle/attract screen
│   │   ├── menu_widget/            # Menu browsing + product cards
│   │   ├── cart/                   # Kiosk cart sidebar
│   │   ├── pay_widget/             # Payment UI
│   │   ├── success_payment/
│   │   ├── sale_type_kiosk/
│   │   ├── splite-stores/          # Multi-store selector
│   │   └── control/                # Admin control panel (kiosk)
│   └── mobile-features/            # Cashier handheld screens
│       ├── SellPage/
│       ├── CheckOut/
│       └── search_products/
│
├── viewModels/                     # Page-level state (ChangeNotifier, legacy pages)
├── views/                          # UI only; reads providers/viewModels
└── sdks/                           # Hardware SDK wrappers (barcode scanner, USB/serial)
```

### Layer responsibilities

| Layer | Location | Rule |
|---|---|---|
| Data models | `data/models/` | Pure Dart — no Flutter imports |
| Local DB | `data/services/local_data/` | One class per table; static CRUD methods |
| Remote API | `data/services/remote_data/` | Extend `BaseApiService`; call `initialize()` before use |
| Repository | `repository/` | Combines local + remote; returns `Either<Failure, T>` |
| Providers | `providers/` | Riverpod `StateNotifier` / `Provider`; no direct DB access |
| Services | `core/services/` | Stateless helpers (order calc, printing, sync, KDS) |
| Features / UI | `features/` | Read providers only; no business logic |

### Routing

All routes are declared in `lib/core/routers/router.dart` as a flat `GoRouter`. Every route is wrapped in `popScopeWidget()` which prevents system back navigation. Kiosk-mode screens additionally use `InteractionDetectorWidget` that redirects to `/entry` after configurable inactivity (default 240 s).

### State management

**Riverpod** (`flutter_riverpod`) is used for all new state. Key providers:

| Provider | Type | Purpose |
|---|---|---|
| `cartProvider` | `StateNotifierProvider` | In-memory cart (list of `CartItem`) |
| `categoriesProvider` | `StateProvider` | Menu categories from SQLite |
| `allProductsProvider` | `StateProvider` | All menu products |
| `productsProvider` | `StateProvider.family` | Products filtered by category |
| `searchProductsProvider` | `Provider` | Computed: filtered products by query |
| `paymentBreakdownProvider` | `StateNotifierProvider` | Payment methods & totals |
| `saleTypeNotifier` | `StateProvider` | Selected sale type |
| `comboMealProvider` | `StateNotifierProvider` | Combo meal composition state |
| `quantitySelectionProvider` | `StateProvider` | Quick quantity entry |
| `orderSummaryProvider` | `StateNotifierProvider` | Subtotal, tax, discount totals |
| `categoryNavigationProvider` | `StateNotifierProvider` | Category breadcrumb state |
| `selectedReportGroupIdProvider` | `StateProvider` | Multi-store: active store/brand |
| `reportGroupThemeProvider` | `Provider` | UI theme per report group |
| `menuItemDetailsProvider` | `FutureProvider.family` | UOM + pricing for a product |

Older pages (Login, Install, Cashier) still use `ChangeNotifier` via the `provider` package. New code must use Riverpod.

### Local database (SQLite)

`AppDB` opens `posmena_db.db` at startup and `CREATE TABLE IF NOT EXISTS` every table. Each table is a standalone class with a static `create()` and CRUD methods. In debug mode, `AppDB.deleteAllSaleDb()` is called on startup to wipe sales data.

Key table groups:
- **Sales**: `SalesOrderTable`, `SalesItemsTable`, `SalesPayMethodTable`
- **Menu sync**: `MenuItemFBTable`, product categories, variations, translations
- **Device**: `DeviceConfigTable`, `CashierShiftTable`
- **Promotions**: `PromotionsFBTable` and related tables

### Remote API

`BaseApiService` (abstract) wraps Dio with a 60 s timeout and `TalkerDioLogger` interceptor. Every API service calls `await service.initialize()` before use to create the Dio instance. Auth token is injected via `addAuthToken()`. Each domain area has an interface + implementation pair under `data/services/remote_data/`.

Sync flow (`GlobalSyncService`): runs as a periodic background job after login, uploading unsynced sales orders, refunds, and ZATCA invoices to the back office.

### Core services

| Service group | Location | Purpose |
|---|---|---|
| Order services | `core/services/order_services/` | `OrderCalculator`, `FreeItemService`, `ProductTap*` modules |
| Printing | `core/services/printing_services/` | 3 backends (Bluetooth, Network/USB, PDF) via `PrintController` |
| PDF | `core/services/pdf_services/` | Isolate-based PDF rendering (`pdf_isolate.dart`) |
| Sync | `core/services/sync_services/` | `GlobalSyncService`, `ConnectivityService` |
| KDS | `core/services/kds_service/` | HTTP client to local Kitchen Display System |
| Kiosk mode | `core/services/kiosk_mode_services/` | Inactivity timeout, idle redirect |
| Loading | `core/services/loading_services/` | Splash progress tracking, performance monitor |
| Variations | `core/services/variations_services/` | Variant comparison, localized variant names |
| QR invoice | `core/services/qr_invoice_service/` | ZATCA QR, Feedmena & ZIGS integrations |

### Printing

Three print paths share `PrintUtils` / `PrintController`:
1. **Bluetooth** — `blue_thermal_printer` / `flutter_bluetooth_printer`
2. **USB/Network** — `drago_pos_printer` / `flutter_thermal_printer`
3. **PDF** — `pdf` + `printing` packages, rendered in an isolate (`pdf_isolate.dart`)

Receipt content is built in `invoice_content.dart`/`invoice_pdf_content.dart` and rendered as a Flutter widget tree or PDF.

### ZATCA

`zatca_2_invoice_generator` (git dependency) handles Saudi e-invoice QR generation and XML signing. Device ZATCA credentials are stored in `DeviceConfigTable` (`tenantIdZatca` field). Sync to ZATCA happens as part of the periodic `GlobalSyncService`.

### Localization

`FFLocalizations` wraps `flutter_localizations`. Supported locales: `en`, `ar`. Language is persisted in `AppPreferences.getLanguage()`. RTL is automatic for Arabic via `MaterialApp` locale propagation. Arabic fonts: Almarai, Cairo, bank. English: Rubik.

### Product tap flow

`ProductTapHandler.handleProductTap()` (`lib/core/helpers/menu_product_tap_handler.dart`) is the single entry point for adding any product to the cart from either UI. It orchestrates:
1. Quantity pre-selection (`quantitySelectionProvider`)
2. Combo meal detection → `combo_meal_dialog.dart`
3. Variant selection → `product_tap_variant_support.dart`
4. Customization → `product_customization_host.dart` (shared, `lib/features/shared-features/customization/`)
5. Cart insertion + order recalculation + promotion check + free-item dialogs (`FreeItemService`)

Supporting service modules under `core/services/order_services/`:
- `product_tap_menu_loader.dart` — fetches UOM & menu item details
- `product_tap_variant_support.dart` — variant selection logic
- `product_tap_cart_support.dart` — cart item building, free-item merging

Always route product taps through `ProductTapHandler` — never add to cart directly from UI widgets.

### Promotion engine

`PromotionHandlerFactory` (`repository/promotions/`) selects the correct `PromotionHandler` subclass based on `PromotionTypes` enum. Each handler encapsulates rules for one promotion category (e.g., highest/lowest price discount, product/category discount, gift voucher). Handlers return adjusted `CartItem` lists; the repository layer applies them before `OrderCalculator` computes totals.

### KDS (Kitchen Display System)

`ClientService` (`lib/core/services/kds_service/client_service.dart`) sends orders to a local KDS server via HTTP (`LocalRequest`). Endpoints defined in `LocalEndPoints`. The KDS IP is configured during device installation.

### Error handling pattern

Remote and local data methods return `Either<Failure, T>` (from `eitherx`). Repository layer consumes these with `.fold()`. Do not throw exceptions across layer boundaries.

### Key patterns

- **`dPrint()`** (`lib/core/helpers/helper_functions.dart`) — debug-only print wrapper; use instead of `print()`.
- **`AppPreferences()`** — singleton; must call `.init()` in `main()` before any access.
- **Route names** — each screen widget declares `static const routePath` and `static const routeName`; navigate with `context.goNamed(WidgetName.routeName)`.
- **`isAr()`** helper — returns `true` if current locale is Arabic; used throughout for inline Arabic/English string selection.
- **`AppModeSession`** — use instead of raw `AppConfig.isKiosk` checks when deciding post-action routes.
- **`DecimalsNumbers`** — `AppConfig.decimalsNumbers` controls decimal precision (set to `two` for Saudi Arabia).
- **Repository caching** — `MenuItemSyncRepository` bulk-loads all menu dependencies in one call to avoid N+1 SQLite queries; do not bypass it with direct table access.

## Recent Changes
- 013-install-login-workflow: Added Dart 3.x (Flutter 3.32.8 stable) + `flutter_riverpod`, `go_router`, `dio` services via existing remote_data services, `shared_preferences` (`AppPreferences`)
- 008-mobile-customization-ui: Added Dart 3.x (Flutter 3.x) + `flutter_riverpod`, `flutter_localizations`, `sqflite`
- 001-combo-customization-parity: Refactored `ComboMealWidget` to accept `SyncProduct` directly (parity with `KioskProductCustomizationSheet`)

## Active Technologies
- Dart 3.x (Flutter 3.32.8 stable) + `flutter_riverpod`, `go_router`, `dio` services via existing remote_data services, `shared_preferences` (`AppPreferences`) (013-install-login-workflow)
- SQLite (`AppDB` tables) + SharedPreferences (`AppPreferences`) + secure storage for auth token material (013-install-login-workflow)
