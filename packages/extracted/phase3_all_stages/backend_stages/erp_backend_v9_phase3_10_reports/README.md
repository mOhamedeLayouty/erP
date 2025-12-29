# ERP Backend – Phase 3.10 (Inventory Reports)
Date: 2025-12-26

## Added endpoints
- GET `/api/inventory/lost-sales`
- GET `/api/inventory/balances`
- GET `/api/inventory/item-card?store_id=1&item_id=ITM-01`
- GET `/api/inventory/posted-issue/:debit_header`
- GET `/api/inventory/posted-return/:credit_header`

## Notes
- Item Card is built from posted issue/return docs (sc_debit_* and sc_credit_*).
- Lost of Sales comes from `sc_lost_sales` (filled in Phase 3.9 when lines rejected).
