# رفع الـ Reference Repo على GitHub

## 1) جهّز الريبو محليًا
من داخل فولدر `ERP_REFERENCE_REPO`:

```bash
cd /path/to/ERP_REFERENCE_REPO

git init
git branch -M main
git add .
git commit -m "chore: baseline reference repo"
```

## 2) اعمل Repo جديد على GitHub
- Repository name المقترح: `erp-reference`
- Private (مُفضّل)

## 3) اربط الريموت و ارفع
استبدل `<YOUR_GITHUB_URL>` برابط الريبو (SSH أو HTTPS):

```bash
git remote add origin <YOUR_GITHUB_URL>
git push -u origin main
```

## 4) كل مرة تضيف فيها نسخة جديدة
```bash
# ضيف الـ zip/الفولدر الجديد في packages/
# حدّث STOP_POINT أو أي docs
node tools/dump_last10.js   # لو عايز Snapshot جديد

git add .
git commit -m "chore: update reference artifacts"
git push
```

## نصيحة تنظيم Versions
لو عندك Versions كتير ومش عارف “المعتمد” منهم:
- خلّي كل Version في `packages/original_zips/` باسم واضح فيه تاريخ/وصف.
- اعمل ملف صغير لكل Version داخل `docs/versions/` يشرح:
  - جاي منين؟
  - ايه اللي اتغير فيه؟
  - هل اتجرب وتشغّل؟
