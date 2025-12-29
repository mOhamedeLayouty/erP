# Phase 3.3 Notes (Workflow + Invoicing Details + Stock Posting)

Date: 2025-12-26

## Agreement respected
- Users & permissions are still deferred.
- RBAC is bypassable via `DEFER_RBAC=true`.

## Job Orders (Workflow)
- Added action endpoint to apply soft transitions:
  - POST /api/job-orders/:JobOrderID/action
    action in: start | finish | cancel | control_ok | stock_approve

Table: DBA.ws_JobOrder

## Invoicing (Header + Detail)
- GET /api/invoicing/invoices
- GET /api/invoicing/invoices/:InvoiceID/details
- POST /api/invoicing/invoices          (generic insert)
- POST /api/invoicing/invoice-details   (generic insert)
- POST /api/invoicing/invoice-full      (best-effort transaction: header + details)

Header table: DBA.ws_InvoiceHeader
Detail table: DBA.ws_InvoiceDetail

## Stock Posting (Transfers)
- POST /api/inventory/post-transfer
  - validates header & details exist
  - marks "posted" flag if such column exists (best-effort, locked schema)

Transfer header: DBA.car_transfer_header
Transfer detail: DBA.car_transfer_detail
