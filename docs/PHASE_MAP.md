# خريطة المراحل (Phase → Modules)

## المصادر المُراجَعة
- `packages/original_zips/` (ZIPs):
  - `ERP_FINAL_FULL_CLOSURE_STOCK_v1.zip`
  - `ERP_FINAL_FULL_CLOSURE_STOCK_v2_WORKFLOWS.zip`
  - `ERP_FINAL_FULL_CLOSURE_STOCK_v2_WORKFLOWS_PATCHED.zip`
  - `ERP_FINAL_UNIFIED_PACKAGE_v2.zip`
  - `ERP_UNIFIED_LIVE_DEMO.zip`
- `packages/extracted/`:
  - `phase1_crm/`
  - `phase2_workshop/`
  - `phase3_inventory_integration/`
  - `phase3_all_stages/`
  - `ERP_UNIFIED_LIVE/`
  - `ERP_FINAL_FULL_CLOSURE_STOCK_v2_WORKFLOWS/`
- `docs/STOP_POINT.md`
- `snapshots/`: غير موجودة في هذا المسار (لم يتم العثور على لقطات DB)

## Phase → Modules (بناءً على أسماء المجلدات والـ code)

### Phase 1 — CRM
- **Modules**: CRM
- **المصدر**:
  - ZIPs داخل `packages/extracted/phase1_crm/deliverables/`:
    - `proactive-crm-backend.zip`
    - `proactive-crm-frontend-m365.zip`
  - مرجع إضافي داخل `packages/extracted/ERP_UNIFIED_LIVE/_source_crm_backend/` و`_source_crm_frontend/`
- **الدليل**:
  - اسم المرحلة `phase1_crm`
  - وجود مصادر CRM في حزمة الـ Unified Live

### Phase 2 — Workshop + Master Data (Mapping فقط)
- **Modules**: Workshop, Master Data (تعريفات/Mapping)
- **المصدر**:
  - `packages/extracted/phase2_workshop/06_Data_Mapping/data_dictionary.xlsx`
  - ملف الحالة `WORKSHOP_2_1_MASTER_DATA_CLOSED.md`
- **الدليل**:
  - أسماء الملفات تشير إلى Workshop و Master Data
  - لا يوجد كود Backend/Frontend مُنفّذ في هذه المرحلة

### Phase 3 — Inventory Integration (تشغيل فعلي)
- **Modules (Backend)** من `packages/extracted/phase3_inventory_integration/backend/src/modules/`:
  - Auth
  - Control Audit
  - Inventory
  - Invoicing
  - Job Orders
  - Master Data
- **Modules (Frontend UI)** من `packages/extracted/phase3_inventory_integration/frontend/src/ui/pages/`:
  - Inventory (Inventory, InventoryRequests, InventoryReports)
  - Workshop Stock
  - Job Orders
  - Invoices
  - Audit
  - Dashboard
  - Login
- **المصدر**:
  - ZIPs الأصلية: `ERP_FINAL_FULL_CLOSURE_STOCK_v2_WORKFLOWS*.zip`
  - نسخة مُفكوكة: `packages/extracted/phase3_inventory_integration/`
  - نسخة إضافية ضمن: `packages/extracted/ERP_FINAL_FULL_CLOSURE_STOCK_v2_WORKFLOWS/phase3_inventory_integration/`

### Phase 3 — All Stages (Timeline للأعمال)
- **Modules**: نفس نطاق Phase 3 (Inventory/Requests/Reports/Posting/Operations/Audit… إلخ)
- **المصدر**:
  - `packages/extracted/phase3_all_stages/PHASE3_CHANGELOG_AND_MAP.md`
  - مراحل Backend/Frontend داخل `backend_stages/` و`frontend_stages/`

### Unified / Live Package (CRM + Phase 3)
- **Modules**:
  - CRM (مصادر مستقلة)
  - Phase 3 Inventory/Requests/Reports/Operations… إلخ (من الـ backend/frontend الموحدة)
- **المصدر**:
  - ZIP: `ERP_UNIFIED_LIVE_DEMO.zip`
  - مفكوك: `packages/extracted/ERP_UNIFIED_LIVE/`

## ربط المصدر حسب نوع الملفات
- **ZIPs**: `packages/original_zips/` (تحتوي على حزم مرحلة 3 والـ Unified)
- **Code مفكوك**: `packages/extracted/` (كل المراحل المفكوكة)
- **PBD / DAT**: لم يتم العثور على ملفات بهذا الامتداد في المجلدات الحالية
- **DB Snapshots**: غير موجودة في `snapshots/`

## Gaps (Modules ناقصة أو غير مكتملة)
1) **CRM غير مدمج ضمن Phase 3 التشغيلية**
   - لا يظهر ضمن Modules الخاصة بـ Phase 3 (Backend/Frontend)
   - CRM موجود كحزم مستقلة فقط (Phase 1 أو مصادر Unified)

2) **Workshop لا يحتوي كود Backend/Frontend واضح**
   - Phase 2 يحتوي على Mapping فقط بدون مشروع تنفيذ
   - في Phase 3 يوجد صفحة `WorkshopStock` بالواجهة فقط، بدون Module Backend باسم Workshop

3) **Master Data UI غير واضحة**
   - يوجد Module Backend باسم `master-data`
   - لا توجد صفحة UI تحمل اسم Master Data صراحةً ضمن صفحات الواجهة

4) **PBD/DAT Snapshots غير متوفرة**
   - لا يوجد أثر لملفات PBD/DAT
   - لا توجد snapshots DB لتأكيد بيانات تشغيلية
