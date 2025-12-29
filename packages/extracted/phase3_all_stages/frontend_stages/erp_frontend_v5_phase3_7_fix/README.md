# ERP Web Client – Phase 3.7 Fix (Workshop Requests → Inventory)
Date: 2025-12-26

## Core rule (locked)
- Workshop creates **requests** linked to JobOrder.
- Inventory is the **owner** of issue/return transactions.

UI Screen:
- Workshop ↔ Inventory: select JobOrder then create:
  - Issue Request (طلب صرف)
  - Return Request (طلب ارتجاع)

Backend endpoints:
- POST `/api/inventory/issues`
- POST `/api/inventory/returns`

Users & permissions are deferred (per agreement).
