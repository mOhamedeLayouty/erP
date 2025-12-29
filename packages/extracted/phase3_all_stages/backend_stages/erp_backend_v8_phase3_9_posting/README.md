# ERP Backend – Phase 3.9 (Real Posting from Requests)
Date: 2025-12-26

## What is implemented
When you click **Post** on a request header:

### Issue request posting
- Source: `DBA.sc_debit_header_request` / `DBA.sc_debit_detail_request`
- Target: `DBA.sc_debit_header` / `DBA.sc_debit_detail`
- Posts accepted lines only (detail.status != 2)

### Return request posting
- Source: `DBA.sc_ret_request_header` / `DBA.sc_ret_request_detail`
- Target: `DBA.sc_credit_header` / `DBA.sc_credit_detail`
- Posts accepted lines only (detail.status != 2)

### Lost Sales logging
- For each rejected detail line (status=2), we insert a row into:
  - `DBA.sc_lost_sales`
- `required` = rejected qty
- `on_hand` = current `DBA.sc_balance.balance` for the store/item
- `notes` carries the reason text (default lost_of_sales)

## API (same UI buttons)
- POST `/api/inventory/issue-requests/:debit_header/action` with `{"action":"post"}`
- POST `/api/inventory/return-requests/:credit_header/action` with `{"action":"post"}`

## Notes
- Request header is marked `post_flag='y'`, status=1
- Request header notes appended with `POSTED_TO:sc_debit_header=...` / `POSTED_TO:sc_credit_header=...`
- service_center/location_id are locked to 1 for now.
