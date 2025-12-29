# ERP Backend v2 – Phase 3.1 (Auth)

## New endpoints
- POST /auth/login
- POST /auth/refresh
- GET  /api/auth/me

## Dev token
- POST /auth/token (disabled by default; enable with ENABLE_DEV_TOKEN=true)

## Locked user mapping (auto-detected from reload.sql)
- USER_TABLE=HR.dbs_s_employe
- USER_COL_ID=user_id
- USER_COL_NAME=user_name
- USER_COL_PASSWORD=NOT FOUND
- USER_COL_ACTIVE=NOT FOUND
- USER_COL_ROLE=NOT FOUND

## Roles resolution
1) If USER_COL_ROLE configured and has value, it's split by ',' or ';'
2) Else load from `config/user_roles.json` (copy from `.example`)

## Password strategy
- PASSWORD_STRATEGY=plain  (default)
- PASSWORD_STRATEGY=sha256

## Run
```bash
npm i
cp .env.example .env
npm run dev
```

## If DB has no password column
- Create `config/user_secrets.json` from `.example`
- Store password hashes there (recommended: sha256)
- Set `USER_SECRETS_JSON_PATH` in env (optional)
