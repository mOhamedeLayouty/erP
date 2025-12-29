# ERP Backend – Phase 3.11 (Ops Enhancements)
Date: 2025-12-26

## Filters
- GET `/api/inventory/issue-requests?store_id=&joborderid=&status=&post_flag=&from=YYYY-MM-DD&to=YYYY-MM-DD`
- GET `/api/inventory/return-requests?...`

## Bulk
- POST `/api/inventory/issue-requests/:debit_header/lines/approve-all`
- POST `/api/inventory/return-requests/:credit_header/lines/approve-all`
- POST `/api/inventory/issue-requests/:debit_header/lines/reject`
- POST `/api/inventory/return-requests/:credit_header/lines/reject`
Body: `{ "line_ids":[1,2], "reason":"lost_of_sales", "note":"optional" }`
