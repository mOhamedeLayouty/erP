# Phase 3.2 Notes (No Users/Permissions Work)

Date: 2025-12-26

## What we did
- Implemented Inventory module using locked tables from reload.sql:
  - Stores table: CRM.stores
  - Items table: DBA.fx_item
  - Transfer header: DBA.car_transfer_header
  - Transfer detail: DBA.car_transfer_detail
- Implemented audit logging for all mutating requests (POST/PUT/PATCH/DELETE) to NDJSON file

## What we did NOT do (by agreement)
- No user tables integration
- No permissions finalization
- RBAC is bypassable via `DEFER_RBAC=true`
