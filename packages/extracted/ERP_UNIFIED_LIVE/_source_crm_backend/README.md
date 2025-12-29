# Proactive CRM Backend (Node.js + SQL Anywhere via ODBC)

This backend runs against your existing SQL Anywhere 17 databases (no migration).
Multi-branch is handled by selecting DB connection using `X-Service-Center` header.

## Install
```bash
npm i
cp .env.example .env
```

## Configure branch DBs
Edit `branches.json` and add one entry per `service_center`.
Each entry contains an ODBC connection string.

## Run
```bash
npm run dev
# or
npm start
```

## Required Headers
- `X-Service-Center: <center_id>`  (required for every request)
- `X-Location-Id: <location_id>`   (optional for CRM, used later for Workshop/Stock)

## Endpoints
- `GET /health`
- `GET /meta/service-centers` (from branches.json)
- CRM:
  - `GET /crm/customers?page=&pageSize=`
  - `GET /crm/customers/:customerId`
  - `POST /crm/customers`
  - `PUT /crm/customers/:customerId`
  - `DELETE /crm/customers/:customerId`
  - `GET /crm/customers/:customerId/calls`
  - `POST /crm/customers/:customerId/calls`
  - `PUT /crm/calls/:callId`
  - `GET /crm/calls/:callId/history`
  - `POST /crm/calls/:callId/history`

## Dynamic column safety
On create/update, the server validates JSON keys against table columns using `INFORMATION_SCHEMA.COLUMNS`.
Unknown fields are rejected (400) to protect your DB.

If INFORMATION_SCHEMA is not available in your SQL Anywhere config, adjust `src/db/metadata.js` to use sys tables.
