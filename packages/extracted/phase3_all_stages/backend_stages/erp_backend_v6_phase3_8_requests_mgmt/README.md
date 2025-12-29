# ERP Backend – Phase 3.8 (Issue/Return Request Lifecycle)
Date: 2025-12-26

## What is implemented (critical operations)
Inventory now manages the full lifecycle for workshop-related requests:

- Create Issue Request: `POST /api/inventory/issues`
- Create Return Request: `POST /api/inventory/returns`

- List Issue Requests: `GET /api/inventory/issue-requests`
- Issue Details: `GET /api/inventory/issue-requests/:debit_header/details`
- Issue Action: `POST /api/inventory/issue-requests/:debit_header/action` with action: approve|reject|post|unpost

- List Return Requests: `GET /api/inventory/return-requests`
- Return Details: `GET /api/inventory/return-requests/:credit_header/details`
- Return Action: `POST /api/inventory/return-requests/:credit_header/action` with action: approve|reject|post|unpost

## Notes
- `status`: 0 pending, 1 approved, 2 rejected
- `post_flag`: 'y' posted, 'n' not posted
- Actual inventory balance deduction/crediting posting logic will be implemented in the next phase once the posting tables/procs are locked.
