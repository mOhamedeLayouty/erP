# نقطة التوقف (Stop Point) — 2025-12-29

## الحالة الحالية
- Backend شغال على: `http://localhost:8080`
- Frontend (Vite) شغال على: `http://localhost:5174` (عندك شاشة بيضا)

## اللي اتأكدنا منه
- Auth endpoint بيرجع `dev-token` من `/auth/login`.
- في DB فيه بيانات Stores و Items (اتعملت queries بـ ODBC وطلعت rows).

## المشكلة
- UI شاشة بيضا (لازم نفتح DevTools Console ونشوف error).
- وفي API حصل `UNAUTHORIZED` على `/api/master-data/stores` مع `Bearer dev-token`.
  - ده معناه إن `authMiddleware` غالباً مش بيقبل `dev-token` أو بيطلب token شكل تاني.
  - أو إن الـ frontend بيبعت token غلط/مش بيبعت.

## أول خطوة لما نرجع
1) افتح Console في المتصفح على `localhost:5174` وشوف أول error.
2) جرّب API من curl بعد login:
   - `/api/auth/me` للتأكد إن `authMiddleware` شايف user.
3) لو dev-token خاص بالتطوير: هنخلّي `authMiddleware` يقبل `dev-token` في وضع DEV.

## ملاحظة مهمة (Reference repo)
- النسخة اللي اتفكت هنا: `packages/extracted/phase3_inventory_integration`.
- أي تعديل جديد: نسجله في `docs/CHANGELOG.md`.
