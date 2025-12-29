# ERP Unified Live Demo Package (Phase 3.16 + CRM minimal)

## الهدف
تشغيل **Backend واحد** + **Frontend واحد** يعرض:
- Inventory (Phase 3.16 UI)
- Job Orders / Invoicing / Audit (الموجودين في التجميعة)
- **CRM Customers (Minimal Live)**: قراءة العملاء والمتابعات من قاعدة البيانات

> ملاحظة: باك اند المراحل القديمة كانت فيها تعارضات TypeScript/paths، دي التجميعة المتظبطة لتشغيل الديمو لايف.

---

## 0) اقفل أي تشغيل قديم
من Git Bash:
```bash
for P in 8080 5173 5174 5175; do
  PID=$(netstat -ano 2>/dev/null | grep ":$P" | grep LISTENING | awk '{print $5}' | head -n 1)
  if [ -n "$PID" ]; then taskkill //PID $PID //F || true; fi
done
```

---

## 1) Backend
```bash
cd backend
cp .env.example .env
# عدل DSN/UID/PWD حسب بيئتك
notepad .env

npm i
npm run dev
```
هيشتغل على:
- http://localhost:8080

### 1.1) اعمل Token سريع
```bash
TOKEN=$(curl -s -X POST http://localhost:8080/auth/token \
  -H "Content-Type: application/json" \
  -d '{"user_id":"1","user_name":"demo","roles":["admin","inventory.read","inventory.write","inventory.post","audit.read","crm.read"]}' \
  | sed -E 's/.*"token":"([^"]+)".*/\1/')

echo $TOKEN
curl -s "http://localhost:8080/api/inventory/transfers" -H "Authorization: Bearer $TOKEN" | head
curl -s "http://localhost:8080/api/crm/customers" -H "Authorization: Bearer $TOKEN" | head
```

---

## 2) Frontend
في Terminal تاني:
```bash
cd frontend
cp .env.example .env

npm i
npm run dev
```
هتلاقيه على:
- http://localhost:5173 (أو 5174 لو 5173 مستخدم)

### Login
- افتح صفحة Login
- اضغط "Mint Demo Token" (أو حط Token يدوي)
- بعد كده ادخل على Inventory / CRM Customers

---

## 3) Single-port (اختياري)
لو عايز UI يتقدم من نفس Port الباك اند:
1) ابنِ الفرونت:
```bash
cd frontend
npm run build
```
2) فعّل السيرف في backend:
- في `backend/.env`: خلي `SERVE_FRONTEND=true`
- شغل backend عادي

هتفتح:
- http://localhost:8080

---

## Troubleshooting سريع
- لو Inventory Stores/Items فاضيين: غير جداول `INVENTORY_STORES_TABLE` و `INVENTORY_ITEMS_TABLE` في backend `.env` للجداول اللي فيها بيانات عندك.
- لو auth/token "Endpoint disabled": تأكد `ENABLE_DEV_TOKEN=true`.
- Node version: الأفضل 18 أو 20+ (بس dev ممكن يشتغل على 19.9.0).
