# Permissions Roadmap (Post-Module Review)

## الحالة الحالية
- الصلاحيات (RBAC) متوقفة بالكامل مؤقتًا.
- الهدف: إبقاء الموديولز شغالة بدون قيود إلى حين اكتمال مراجعات كل موديول.

## تصميم جداول Users / Roles / Permissions (بدون تعديل Legacy)
> سيتم إنشاء الجداول في سكيمة/DB جديدة منفصلة أو عبر خدمة خارجية، بدون لمس جداول الـ legacy الحالية.

### خيار قاعدة بيانات منفصلة (Preferred)
**Schema: `erp_access` (أو DB جديدة كاملة)**

**Tables**
1) `users`
   - `id` (UUID, PK)
   - `legacy_user_id` (VARCHAR, nullable)
   - `user_name` (VARCHAR, unique, required)
   - `display_name` (VARCHAR)
   - `email` (VARCHAR, nullable)
   - `status` (ENUM: active, disabled)
   - `created_at`, `updated_at`

2) `roles`
   - `id` (UUID, PK)
   - `key` (VARCHAR, unique, required) — مثال: `stock_read`
   - `name` (VARCHAR)
   - `description` (TEXT, nullable)
   - `created_at`, `updated_at`

3) `permissions`
   - `id` (UUID, PK)
   - `key` (VARCHAR, unique, required) — مثال: `stock.read`
   - `module` (VARCHAR) — مثال: `stock`, `inventory`, `job-orders`
   - `description` (TEXT, nullable)
   - `created_at`, `updated_at`

4) `role_permissions`
   - `role_id` (FK -> roles.id)
   - `permission_id` (FK -> permissions.id)
   - `created_at`
   - PK مركب (`role_id`, `permission_id`)

5) `user_roles`
   - `user_id` (FK -> users.id)
   - `role_id` (FK -> roles.id)
   - `created_at`
   - PK مركب (`user_id`, `role_id`)

### خيار خدمة خارجية (AuthZ service)
- واجهات REST/GraphQL لإدارة Users/Roles/Permissions.
- ربط الـ backend عبر SDK/HTTP client.
- يتم تخزين البيانات خارج الـ legacy DB بالكامل.

## خطة ربط UI Permissions بعد اكتمال مراجعة الموديولز
1) **تثبيت قاموس الصلاحيات لكل موديول**
   - توثيق permissions keys لكل Route/Action في backend.
   - اعتماد naming pattern ثابت: `module.action` (مثل `stock.read`).

2) **إضافة طبقة AuthZ في الـ backend**
   - إعادة تفعيل `permissionGuard` لقراءة الصلاحيات من جدول/خدمة جديدة.
   - دعم cache في الذاكرة أو Redis لتقليل الضغط.

3) **توفير permission manifest للـ frontend**
   - Endpoint مثل `GET /auth/permissions` يرجّع permissions الخاصة باليوزر.
   - تخزينها في state (Redux/React context).

4) **ربط الـ UI**
   - Guards على Routes (مثال: منع تحميل صفحة إذا permission مفقودة).
   - إخفاء/تعطيل أزرار الأكشن حسب permission.
   - استخدام helper مثل `can('stock.read')`.

5) **تدريج التفعيل**
   - تفعيل الصلاحيات موديول بموديول بعد اجتياز الفحص.
   - إضافة feature flag لكل موديول لتسهيل rollback.
