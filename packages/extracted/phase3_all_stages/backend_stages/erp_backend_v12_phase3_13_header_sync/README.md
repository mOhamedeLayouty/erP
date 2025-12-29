# ERP Backend – Phase 3.13 (Header Sync + Summary)
Date: 2025-12-26

## Added
- Summary:
  - GET `/api/inventory/issue-requests/:debit_header/summary`
  - GET `/api/inventory/return-requests/:credit_header/summary`
- Sync header (derive header status from line statuses):
  - POST `/api/inventory/issue-requests/:debit_header/sync`
  - POST `/api/inventory/return-requests/:credit_header/sync`

## Rule
- all rejected => header status=2
- no pending and at least one approved => header status=1
- else => header status=0
