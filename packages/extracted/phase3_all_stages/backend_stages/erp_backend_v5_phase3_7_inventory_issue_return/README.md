# ERP Backend – Phase 3.7 (Inventory Issue/Return Requests)
Date: 2025-12-26

## Rule (locked)
- Workshop ONLY creates requests.
- Inventory owns stock transactions.

## New endpoints (protected under /api/inventory)
- POST `/api/inventory/issues`
- POST `/api/inventory/returns`

### Request body
```json
{
  "ref_type": "JOB_ORDER",
  "ref_id": "JOB-123",
  "store_id": 1,
  "notes": "optional",
  "lines": [
    { "item_id": "ITM-01", "qty": 2, "price": 0, "notes": "optional" }
  ]
}
```

## DB tables used (locked schema)
- `DBA.sc_debit_header_request`, `DBA.sc_debit_detail_request`
- `DBA.sc_ret_request_header`, `DBA.sc_ret_request_detail`
