# ERP Backend – Phase 3.15 (Posting Guards)
Date: 2025-12-26

## Added
- Pre-check endpoints:
  - GET `/api/inventory/issue-requests/:debit_header/can-post`
  - GET `/api/inventory/return-requests/:credit_header/can-post`

## Enforced on POST action
- Before `post`, backend checks:
  - header exists
  - not already posted
  - header status must be approved (1)
  - no pending lines
  - at least one approved line
If check fails => HTTP 400 with `error` reason.
