# ERP Backend – Phase 3.16 (Proper Unpost / Reversal)
Date: 2025-12-27

## Fixed
- `action=unpost` no longer فقط يغير flags.
- الآن يعمل reversal حقيقي:
  - يقرأ الـ posted doc id من notes (`POSTED_TO:...`)
  - يرجّع balance (Issue: +qty, Return: -qty)
  - يحذف posted header/detail
  - يمسح lost sales rows المرتبطة بالـ request (للـ Issue) لتجنب التكرار عند إعادة الـ post
  - يحدث request header `post_flag='n'` ويضيف tag `UNPOSTED_FROM:...`

## Note
- Balance update is best-effort (حتى لو في triggers موجودة).
