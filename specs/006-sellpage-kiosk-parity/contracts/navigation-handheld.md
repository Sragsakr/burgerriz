# Contract: Handheld ordering navigation

**Version**: 1.0 (draft)  
**Spec**: [spec.md](../spec.md) FR-009, FR-010

## Ordered screens (staff handheld)

1. `HomeWidget`  
2. `CashierWidget` (or equivalent cashier landing)  
3. `SaleTypesWidget` — sale type selection and **must trigger shared catalog preload** for Sell page  
4. Customer selection screen (existing customers flow)  
5. **If** `show_split_store_handheld == true` **and** multi-store enabled: `SplitStoreScreen`  
6. `SellpageWidget` (`/sell-page`)

## Invariants

- **Sell page** MUST NOT show a catalog until **sale type** is chosen and **effective** `reportGroupId` is resolved (explicit or default).  
- **GoRouter** transitions MUST NOT skip customer step when spec requires it (FR-010).  
- Deep links to `/sell-page` SHOULD redirect through guard that ensures sale type + scope (or show error).
