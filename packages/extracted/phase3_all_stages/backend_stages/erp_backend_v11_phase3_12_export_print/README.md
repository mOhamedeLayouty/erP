# ERP Backend – Phase 3.12 (Export + Print)
Date: 2025-12-26

## Added
- Export request details to CSV:
  - GET `/api/inventory/issue-requests/:debit_header/export.csv`
  - GET `/api/inventory/return-requests/:credit_header/export.csv`
- Print request details (HTML auto-print):
  - GET `/api/inventory/issue-requests/:debit_header/print`
  - GET `/api/inventory/return-requests/:credit_header/print`
