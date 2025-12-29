# ERP Web Client – Phase 3.8 (Inventory Requests Screen)
Date: 2025-12-26

## What is added
- Inventory Requests screen:
  - Issue Requests list + details + actions (approve/reject/post/unpost)
  - Return Requests list + details + actions

Backend endpoints used:
- GET `/api/inventory/issue-requests`
- GET `/api/inventory/issue-requests/:debit_header/details`
- POST `/api/inventory/issue-requests/:debit_header/action`

- GET `/api/inventory/return-requests`
- GET `/api/inventory/return-requests/:credit_header/details`
- POST `/api/inventory/return-requests/:credit_header/action`
