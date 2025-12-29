# ERP Web Client – Phase 3.4 (UI Binding Start)
Date: 2025-12-26

## Goal
Start binding UI screens to Backend v4 endpoints.
Users & permissions are deferred (per agreement).

## Setup
```bash
npm i
cp .env.example .env
npm run dev
```

## Configure backend URL
- Default: http://localhost:8080
- Or edit `.env` (VITE_API_BASE_URL)

## Screens
- Dashboard (base URL)
- Job Orders (list)
- Invoices (list)
- Inventory (stores/items/transfers/details)
- Audit (events)

## Auth (Deferred)
Login page accepts pasting a token (dev) to unblock testing.
