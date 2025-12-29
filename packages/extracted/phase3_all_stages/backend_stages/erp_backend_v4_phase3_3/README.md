# ERP Backend v3 – Phase 3.2 (Modules Expansion; RBAC Deferred)

## Agreement applied
- Users & permissions are deferred to the end of the project.
- Set `DEFER_RBAC=true` to bypass permission checks during Phase 3 execution.
- Keep JWT auth middleware as-is for now (use /auth/token in dev if needed).

## New in 3.2
### Inventory APIs (Locked tables from reload.sql)
- GET  /api/inventory/stores        -> CRM.stores
- GET  /api/inventory/items         -> DBA.fx_item
- GET  /api/inventory/transfers     -> DBA.car_transfer_header
- GET  /api/inventory/transfer-details -> DBA.car_transfer_detail
- POST /api/inventory/transfers
- POST /api/inventory/transfer-details

### Audit (File sink by default)
- Writes are logged to: `AUDIT_FILE_PATH` (default: `./logs/audit.ndjson`)
- GET /api/audit/events (last 500)

Optional DB audit read:
- Set `AUDIT_DB_TABLE` then:
  - GET /api/audit/db-log-tracking

## Run
```bash
npm i
cp .env.example .env
# Set ODBC_CONNECTION_STRING
npm run dev
```
