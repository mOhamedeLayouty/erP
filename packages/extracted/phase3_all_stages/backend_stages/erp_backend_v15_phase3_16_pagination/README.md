# ERP Backend – Phase 3.16 (Pagination for Requests)
Date: 2025-12-27

## Added
- Pagination support for list endpoints via query:
  - `limit` (default 50)
  - `offset` (default 0)

## Response shape
Both endpoints now return in `data`:
`{ rows, total, limit, offset }`

Endpoints:
- GET `/api/inventory/issue-requests`
- GET `/api/inventory/return-requests`
