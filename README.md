# ERP Reference Repo (CRM + Workshop + Phase 3)

ده **Repo مرجعي** يجمع كل الشغل اللي اتعمل في الـ ERP (CRM + Workshop + Phase 3) عشان:
- ما نتوهش بين Versions كتير
- أي حد فينا يقدر يرجع لملفات “المرجع” بسرعة
- نخزن Snapshots من الداتا (آخر 10 rows من كل جدول) كـ TXT على GitHub

## المحتوى الموجود حاليًا
- `packages/original_zips/`
  - نسخ الزيب اللي كانت معانا + النسخة patched.
- `packages/extracted/phase3_inventory_integration/`
  - فكّ النسخة patched (للمراجعة السريعة/البحث).
- `tools/dump_last10.js`
  - Script بيطلع Snapshot (آخر 10 rows) من كل جدول في Schemas تختارها.
- `docs/STOP_POINT.md`
  - نقطة التوقف الحالية + المطلوب أول ما نرجع.
- `docs/GITHUB_PUSH.md`
  - خطوات رفع الريبو على GitHub.

## ازاي تضيف Phase 1 / Workshop / باقي النسخ اللي عندك
1) حط أي Zip/Folder عندك في:
   - `packages/original_zips/` (لو Zip)
   - `packages/extracted/<name>/` (لو Folder)
2) اكتب سطرين في `docs/STOP_POINT.md` يوضحوا النسخة دي بتاعة إيه.
3) `git add . && git commit -m "chore: add phaseX artifacts"`

## Snapshot DB: آخر 10 rows من كل جدول
من جذر الريبو:

```bash
# لازم ODBC_CONNECTION_STRING يكون متظبط
# مثال في Windows Git Bash:
# export ODBC_CONNECTION_STRING="DSN=...;UID=...;PWD=..."

node tools/dump_last10.js
```

الـ Output الافتراضي: `snapshots/db_last10_dump.txt`

> ملاحظة: “last 10” هنا best-effort لأن مش كل الجداول ليها PK واضح، فبنحاول `ORDER BY 1 DESC` ولو فشل بنعمل `SELECT TOP 10` بدون ترتيب.

## نقطة التوقف
راجع: `docs/STOP_POINT.md`
