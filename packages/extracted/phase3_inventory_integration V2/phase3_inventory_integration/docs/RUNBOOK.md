# ERP Web Client – RUNBOOK (Live via ODBC)

## المتطلبات
- Node.js 18+ (يفضل 20)
- ODBC Driver لـ SQL Anywhere (Sybase SQL Anywhere 17)
- اتصال بقاعدة البيانات الفعلية عبر Connection String

## Backend

### إعداد
داخل `backend/`:

1) انسخ ملف البيئة:
```bash
cp .env.example .env
```

2) عدّل `.env`:
- `ODBC_CONNECTION_STRING=...` (إجباري)

### تشغيل
```bash
cd backend
npm i
npm run dev
```

### أهم الـ Endpoints
- Health: `GET /health`
- Auth: `POST /auth/login`
- Workshop Inventory (قديم): `/api/inventory/*`
- **Stock Control System (Inventory الكامل):**
  - `GET /api/stock/meta/tables`
  - `GET /api/stock/meta/:tableKey/columns`
  - `GET /api/stock/:tableKey?limit=200`
  - `POST /api/stock/:tableKey`
  - `PUT /api/stock/:tableKey?pk=<col>&id=<value>`
  - `DELETE /api/stock/:tableKey?pk=<col>&id=<value>`

> ملاحظة أمان: الـ Stock endpoints مقفولة على قائمة جداول ثابتة (Table Keys) وليست SQL حر.

## Frontend
داخل `frontend/`:

```bash
cd frontend
npm i
npm run dev
```

افتح:
- `http://localhost:5173`

### الصفحات
- Inventory (Workshop-related)
- **Stock Control (Inventory الكامل)**: `/stock-control`

## Troubleshooting
- لو ظهر خطأ ODBC: تأكد من Driver + Connection String.

## ملاحظة هامة عن الصلاحيات
- كل الموديولز تعمل مؤقتًا بدون صلاحيات (RBAC متعطل بالكامل).
- ده إجراء مؤقت لحد ما مراجعة كل موديول تكتمل ويتم إعادة تفعيل الصلاحيات.


## Stock Workflows (Inventory الحقيقي)

افتح:
- `http://localhost:5173/stock-workflows`

### العمليات المتاحة
- Purchase Order (PO): إنشاء أمر شراء على `DBA.sc_buy_order_header/detail`
- Receipt (GRN): إنشاء سند إضافة على `DBA.sc_credit_header/detail`
- Issue: إنشاء سند صرف على `DBA.sc_debit_header/detail`
- Transfer: تحويل باستخدام `DBA.sc_credit_*` + `DBA.sc_transfer_detail`
- Balance Inquiry: استعلام أرصدة من `DBA.sc_balance`

### API
- `POST /api/stock/ops/po`
- `PUT /api/stock/ops/po/:id/approve`
- `POST /api/stock/ops/receipt`
- `PUT /api/stock/ops/receipt/:id/post`
- `POST /api/stock/ops/issue`
- `PUT /api/stock/ops/issue/:id/post`
- `POST /api/stock/ops/transfer`
- `PUT /api/stock/ops/transfer/:id/post`
- `GET /api/stock/ops/balance?store_id=&item_id=`

> ملاحظة: تأثيرات الرصيد/الحركة بعد Posting متوقع أنها تُدار من قواعد/Triggers قاعدة البيانات.
