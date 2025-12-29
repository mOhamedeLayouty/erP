# ERP Backend – Phase 3.14 (Audit Trail + History)
Date: 2025-12-26

## Added
- Audit repository: `src/modules/inventory/audit.repo.ts`
- SQL: `sql/phase3_14_inv_request_audit.sql` (create table `inv_request_audit`)
- History endpoints:
  - GET `/api/inventory/issue-requests/:debit_header/history`
  - GET `/api/inventory/return-requests/:credit_header/history`

## Logging
- Best-effort logging on:
  - Header actions (approve/reject/post/unpost)
  - Line actions (approve/reject + reason/note)
  - Bulk actions (approve-all, bulk reject)
  - Sync header
