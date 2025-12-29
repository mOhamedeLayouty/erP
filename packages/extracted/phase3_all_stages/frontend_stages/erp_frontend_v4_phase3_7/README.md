# ERP Web Client – Phase 3.7 (Workshop ↔ Inventory)
Date: 2025-12-26

## Critical relationship (Workshop & Stock Control)
- Issue (صرف) parts from inventory to a Job Order
- Return (ارتجاع) unused parts back to inventory

UI Screen:
- **Workshop ↔ Inventory**: select JobOrder then submit Issue/Return lines (items + qty)

> Note: this UI calls dedicated backend endpoints:
- POST `/api/workshop/job-orders/:JobOrderID/issue`
- POST `/api/workshop/job-orders/:JobOrderID/return`

Users & permissions are deferred (per agreement).

## Setup
```bash
npm i
cp .env.example .env
npm run dev
```
