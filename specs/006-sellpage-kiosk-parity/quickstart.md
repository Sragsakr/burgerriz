# Quickstart — QA smoke (006 sellpage-kiosk-parity)

## Preconditions

- Android device or emulator: **phone** (handheld) and **tablet** (kiosk) profiles.
- DB with multi-store data (`ReportGroupTranslationTable` ≥ 2 rows) and items tagged with `reportGroupId`.

## Handheld — setting ON

1. Enable **show split store** in settings.
2. Flow: Home → Cashier → Sale type → Customer → **Split store** → Sell page.
3. Pick store A; open category; **note product IDs**.
4. Tap a **simple** product → line added without dead tap.
5. Tap **multi-UOM** product → **KioskProductCustomizationSheet** (not legacy checkbox dialog).
6. Scan barcode of same multi-UOM product → same sheet path.
7. Compare category product set with kiosk (store A, same sale type) → **must match**.

## Handheld — setting OFF

1. Disable **show split store**; set **default report group** to store B.
2. Flow: Home → … → Customer → **no** split screen → Sell page.
3. Catalog **only** store B items; accents match store B.

## Kiosk — regression

1. Entry → split store → sale type → menu unchanged.
2. No handheld-only routes appear on kiosk cold start.

## Pass / fail

- Any **no-op** grid tap on Sell page → **fail** (FR-004).
- Handheld shows products from wrong report group vs kiosk for same declared scope → **fail** (FR-003 / SC-002).
