# Proactive CRM Frontend (Microsoft 365 UI using Fluent UI v9)

## Install & Run
```bash
npm i
cp .env.example .env
npm run dev
```

## Backend
Set:
- `VITE_API_BASE=http://localhost:8080`

Headers are sent automatically:
- `X-Service-Center` (selected in UI)

## Search
Search box filters the currently loaded customer rows immediately.
It also sends `q=` to backend endpoint (future-proof).

For full DB search across columns, enable backend-side search by setting a list of columns there (recommended).
