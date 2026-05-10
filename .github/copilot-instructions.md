# GitHub Copilot Instructions — POSMena POS

## Project Context

POSMena is a Flutter POS (Point of Sale) application for Saudi Arabia that runs on Android devices in two modes:
- **Handheld** — cashier-operated mobile POS
- **Kiosk** — self-service customer-facing terminal

Tech stack: Flutter 3.32.8, Riverpod, SQLite (sqflite), Dio, GoRouter, ZATCA e-invoicing.

## Commands

```bash
flutter run                          # Run on connected device
flutter build apk --release          # Release APK
flutter test                         # Run all tests
flutter analyze                      # Lint analysis
dart format lib/                     # Format code
```

## Architecture

```
lib/
├── core/           # Config, helpers, routing, theme, services, SDKs
├── data/
│   ├── models/     # Pure data classes
│   └── services/
│       ├── local_data/   # SQLite tables (one per table)
│       └── remote_data/
│           ├── interfaces/      # API contracts
│           └── implementations/ # Dio-based API services
├── repository/     # Combines local + remote data
├── providers/      # Riverpod StateNotifiers/Providers
├── features/
│   ├── kiosk-features/   # Kiosk UI
│   ├── mobile-features/  # Handheld UI
│   └── shared-features/  # Shared: Login, Install, Cashier, customization
└── main.dart
```

## Conventions

### State Management
- New code **must** use Riverpod (`flutter_riverpod`).
- Older pages use ChangeNotifier — do not expand this pattern.
- Key providers: `cartProvider`, `MenuProviders`, `PaymentBreakdownProvider`, `PromotionProvider`.

### Error Handling
- Return `Either<Failure, T>` (from `eitherx`) — never throw exceptions across layers.
- Consume with `.fold()` in repository layer.

### Logging
- Use `dPrint()` from `lib/core/helpers/helper_functions.dart` — never raw `print()`.
- For structured logs: `AppLogger` from `lib/core/helpers/logger.dart`.

### Routing
- `GoRouter` — flat route list in `lib/core/routers/router.dart`.
- Route constants: `AppRoutes` in `lib/core/routers/app_routes.dart`.
- Each screen declares `static const routePath` and `static const routeName`.
- Navigate with `context.goNamed(WidgetName.routeName)`.
- Mode-aware routing through `AppModeSession` — not raw `AppConfig.isKiosk` checks.

### Product Tap Flow
**Always** use `ProductTapHandler.handleProductTap()` to add products to cart. Handles: quantity selection → combo detection → variant selection → customization → cart insertion.

### Database
- SQLite via sqflite. `AppDB` opens `posmena_db.db` at startup.
- Each table = standalone class with static `create()` and CRUD methods.

### API Layer
- `BaseApiService` wraps Dio (60s timeout, `TalkerDioLogger`).
- Always call `await service.initialize()` before use.
- Auth via `addAuthToken()`.

### Localization
- Supported: `en`, `ar`. RTL automatic for Arabic.
- Use `isAr()` for inline locale checks.
- Arabic fonts: Almarai, Cairo, bank. English: Rubik.

### ZATCA
- Saudi e-invoice via `zatca_2_invoice_generator` (git dependency).
- QR, XML signing. Synced via `GlobalSyncService`.

## Do NOT

- Use raw `print()` — use `dPrint()` or `AppLogger`
- Throw exceptions across layer boundaries
- Add products to cart directly from UI — use `ProductTapHandler`
- Use ChangeNotifier for new state — use Riverpod
- Hardcode mode-based route decisions — use `AppModeSession`
