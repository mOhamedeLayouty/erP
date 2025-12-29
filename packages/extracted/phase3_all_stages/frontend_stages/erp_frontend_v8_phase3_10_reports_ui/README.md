# ERP Web Client – Phase 3.10 (Requests + Reports)
Date: 2025-12-26

## Screens
- Inventory Requests (with line-level reject: lost_of_sales)
- Inventory Reports:
  - Lost of Sales
  - Balances
  - Item Card
  - Posted Doc viewer

## Endpoints used
- Requests lifecycle: `/api/inventory/issue-requests/*` and `/api/inventory/return-requests/*`
- Reports:
  - GET `/api/inventory/lost-sales`
  - GET `/api/inventory/balances`
  - GET `/api/inventory/item-card`
  - GET `/api/inventory/posted-issue/:id`
  - GET `/api/inventory/posted-return/:id`
