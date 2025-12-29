import { Router } from 'express';
import type { PermissionGuardFactory } from '../../shared/rbac.js';
import { validateBody } from '../../shared/validation.js';
import { z } from 'zod';
import { toCsv } from '../../shared/utils/csv.js';
import { insertAudit, listAudit } from './audit.repo.js';
import {
  listStores, listItems, listTransfers, listTransferDetails,
  createTransferHeader, createTransferDetail
} from './inventory.repo.js';
import { postTransfer } from './stock-posting.service.js';
import { createIssueRequest, createReturnRequest } from './issue-return.repo.js';
import {
  listIssueRequests, listReturnRequests,
  getIssueDetails, getReturnDetails,
  setIssueStatus, setReturnStatus,
  setIssueLineStatus, setReturnLineStatus
,
  listIssueRequestsFiltered,
  listReturnRequestsFiltered,
  approveAllIssueLines,
  approveAllReturnLines,
  rejectIssueLines,
  rejectReturnLines
,
  getIssueLineStats,
  getReturnLineStats,
  syncIssueHeaderStatusFromLines,
  syncReturnHeaderStatusFromLines
,
  canPostIssue,
  canPostReturn
,
  countIssueRequestsFiltered,
  countReturnRequestsFiltered
} from './requests.repo.js';
// Phase 3.11 ops: filters + bulk line actions
import { listLostSales, listBalances, getItemCard, getPostedIssue, getPostedReturn } from './reports.repo.js';
import { postIssueRequest, postReturnRequest } from './request-posting.service.js';

const anyObject = z.record(z.any());

const postSchema = z.object({
  transfer_id: z.string().min(1)
});

const lineSchema = z.object({
  item_id: z.string().min(1),
  qty: z.number().positive(),
  price: z.number().optional(),
  notes: z.string().optional()
});

const reqSchema = z.object({
  ref_type: z.enum(['JOB_ORDER']),
  ref_id: z.string().min(1),
  store_id: z.number().int().positive(),
  notes: z.string().optional(),
  lines: z.array(lineSchema).min(1)
});

const actionSchema = z.object({
  action: z.enum(['approve','reject','post','unpost'])
});

const lineActionSchema = z.object({
  action: z.enum(['approve','reject']),
  reason: z.enum(['lost_of_sales']).optional(),
  note: z.string().optional()
});

export function inventoryRouter(guardFactory: PermissionGuardFactory) {
  const r = Router();
  const guard = guardFactory;

  // Reads
  r.get('/stores', guard('inventory.read'), async (req, res, next) => {
    try {
      const limit = req.query.limit ? Number(req.query.limit) : 200;
      const offset = req.query.offset ? Number(req.query.offset) : 0;
      return res.json({ ok: true, data: await listStores(limit, offset) });
    }
    catch (e) { return next(e); }
  });

  r.get('/items', guard('inventory.read'), async (req, res, next) => {
    try {
      const limit = req.query.limit ? Number(req.query.limit) : 200;
      const offset = req.query.offset ? Number(req.query.offset) : 0;
      return res.json({ ok: true, data: await listItems(limit, offset) });
    }
    catch (e) { return next(e); }
  });

  r.get('/transfers', guard('inventory.read'), async (req, res, next) => {
    try {
      const limit = req.query.limit ? Number(req.query.limit) : 200;
      const offset = req.query.offset ? Number(req.query.offset) : 0;
      return res.json({ ok: true, data: await listTransfers(limit, offset) });
    }
    catch (e) { return next(e); }
  });

  r.get('/transfer-details', guard('inventory.read'), async (req, res, next) => {
    try {
      const limit = req.query.limit ? Number(req.query.limit) : 500;
      const offset = req.query.offset ? Number(req.query.offset) : 0;
      return res.json({ ok: true, data: await listTransferDetails(limit, offset) });
    }
    catch (e) { return next(e); }
  });

  // Writes (generic payload – locked columns only)
  r.post('/transfers', guard('inventory.write'), validateBody(anyObject), async (req, res, next) => {
    try {
      const affected = await createTransferHeader(req.body as any);
      return res.json({ ok: true, data: { affected } });
    } catch (e) { return next(e); }
  });

  r.post('/transfer-details', guard('inventory.write'), validateBody(anyObject), async (req, res, next) => {
    try {
      const affected = await createTransferDetail(req.body as any);
      return res.json({ ok: true, data: { affected } });
    } catch (e) { return next(e); }
  });

  // Phase 3.3: Post/Validate transfer (best-effort)
  r.post('/post-transfer', guard('inventory.post'), validateBody(postSchema), async (req, res, next) => {
    try {
      const { transfer_id } = req.body as any;
      const data = await postTransfer(transfer_id);
      return res.json({ ok: true, data });
    } catch (e) { return next(e); }
  });

  /**
   * Phase 3.7: Workshop Requests (Inventory is the owner)
   */
  r.post('/issues', guard('inventory.write'), validateBody(reqSchema), async (req, res, next) => {
    try {
      const body = req.body as any;
      const data = await createIssueRequest({
        joborderid: String(body.ref_id),
        store_id: Number(body.store_id),
        notes: body.notes,
        user_name: req.user?.user_name ?? req.user?.user_id ?? 'SYSTEM',
        lines: body.lines
      });
      return res.json({ ok: true, data });
    } catch (e) { return next(e); }
  });

  r.post('/returns', guard('inventory.write'), validateBody(reqSchema), async (req, res, next) => {
    try {
      const body = req.body as any;
      const data = await createReturnRequest({
        joborderid: String(body.ref_id),
        store_id: Number(body.store_id),
        notes: body.notes,
        user_name: req.user?.user_name ?? req.user?.user_id ?? 'SYSTEM',
        lines: body.lines
      });
      return res.json({ ok: true, data });
    } catch (e) { return next(e); }
  });

  /**
   * Phase 3.8/3.9: Requests lifecycle + line-level reject + real posting
   */
  r.get('/issue-requests', guard('inventory.read'), async (req, res, next) => {
  try {
    const q: any = req.query ?? {};
    const hasAny = Object.keys(q).length > 0;
    if (hasAny) {
      const data = await listIssueRequestsFiltered({
        store_id: q.store_id ? Number(q.store_id) : undefined,
        joborderid: q.joborderid ? String(q.joborderid) : undefined,
        status: (typeof q.status !== 'undefined' && q.status !== '') ? Number(q.status) as any : undefined,
        post_flag: q.post_flag ? String(q.post_flag) as any : undefined,
        from: q.from ? String(q.from) : undefined,
        to: q.to ? String(q.to) : undefined,
        limit: q.limit ? Number(q.limit) : 50,
        offset: q.offset ? Number(q.offset) : 0
      });
      return res.json({ ok: true, data });
    }
    return res.json({ ok: true, data: await listIssueRequests(200) });
  } catch (e) { return next(e); }
});

  r.get('/issue-requests/:debit_header/details', guard('inventory.read'), async (req, res, next) => {
    try {
      const debit_header = Number(req.params.debit_header);
      return res.json({ ok: true, data: await getIssueDetails(debit_header) });
    } catch (e) { return next(e); }
  });

  r.post('/issue-requests/:debit_header/action', guard('inventory.write'), validateBody(actionSchema), async (req, res, next) => {
    try {
      const debit_header = Number(req.params.debit_header);
      const { action } = req.body as any;

      if (action === 'approve') return res.json({ ok: true, data: await setIssueStatus(debit_header, 1) });
      if (action === 'reject') return res.json({ ok: true, data: await setIssueStatus(debit_header, 2) });

      if (action === 'post') {
        const actor = (req.user?.user_name ?? req.user?.user_id ?? 'SYSTEM') as string;
        const data = await postIssueRequest(debit_header, actor);
        return res.json({ ok: true, data });
      }

      if (action === 'unpost') return res.json({ ok: true, data: await setIssueStatus(debit_header, 1, 'n') });

      return res.json({ ok: false });
    } catch (e) { return next(e); }
  });

  r.post('/issue-requests/:debit_header/lines/:debit_detail/action', guard('inventory.write'), validateBody(lineActionSchema), async (req, res, next) => {
    try {
      const debit_header = Number(req.params.debit_header);
      const debit_detail = Number(req.params.debit_detail);
      const { action, reason, note } = req.body as any;
      if (action === 'approve') {
        try { await insertAudit({ entity:'ISSUE', header_id: debit_header, line_id: debit_detail, action: `LINE_${String(action).toUpperCase()}` as any, reason: reason || null, note: note || null, actor: (req as any).user?.username || null }); } catch { /* ignore audit */ }
        return res.json({ ok: true, data: await setIssueLineStatus(debit_header, debit_detail, 1) });
      }
      return res.json({ ok: true, data: await setIssueLineStatus(debit_header, debit_detail, 2, reason ?? 'lost_of_sales', note) });
    } catch (e) { return next(e); }
  });

  r.get('/return-requests', guard('inventory.read'), async (req, res, next) => {
  try {
    const q: any = req.query ?? {};
    const hasAny = Object.keys(q).length > 0;
    if (hasAny) {
      const data = await listReturnRequestsFiltered({
        store_id: q.store_id ? Number(q.store_id) : undefined,
        joborderid: q.joborderid ? String(q.joborderid) : undefined,
        status: (typeof q.status !== 'undefined' && q.status !== '') ? Number(q.status) as any : undefined,
        post_flag: q.post_flag ? String(q.post_flag) as any : undefined,
        from: q.from ? String(q.from) : undefined,
        to: q.to ? String(q.to) : undefined,
        limit: q.limit ? Number(q.limit) : 50,
        offset: q.offset ? Number(q.offset) : 0
      });
      return res.json({ ok: true, data });
    }
    return res.json({ ok: true, data: await listReturnRequests(200) });
  } catch (e) { return next(e); }
});

  r.get('/return-requests/:credit_header/details', guard('inventory.read'), async (req, res, next) => {
    try {
      const credit_header = Number(req.params.credit_header);
      return res.json({ ok: true, data: await getReturnDetails(credit_header) });
    } catch (e) { return next(e); }
  });

  r.post('/return-requests/:credit_header/action', guard('inventory.write'), validateBody(actionSchema), async (req, res, next) => {
    try {
      const credit_header = Number(req.params.credit_header);
      const { action } = req.body as any;

      if (action === 'approve') return res.json({ ok: true, data: await setReturnStatus(credit_header, 1) });
      if (action === 'reject') return res.json({ ok: true, data: await setReturnStatus(credit_header, 2) });

      if (action === 'post') {
        const actor = (req.user?.user_name ?? req.user?.user_id ?? 'SYSTEM') as string;
        const data = await postReturnRequest(credit_header, actor);
        return res.json({ ok: true, data });
      }

      if (action === 'unpost') return res.json({ ok: true, data: await setReturnStatus(credit_header, 1, 'n') });

      return res.json({ ok: false });
    } catch (e) { return next(e); }
  });

  r.post('/return-requests/:credit_header/lines/:credit_detail/action', guard('inventory.write'), validateBody(lineActionSchema), async (req, res, next) => {
    try {
      const credit_header = Number(req.params.credit_header);
      const credit_detail = Number(req.params.credit_detail);
      const { action, reason, note } = req.body as any;
      if (action === 'approve') {
        try { await insertAudit({ entity:'RETURN', header_id: credit_header, line_id: credit_detail, action: `LINE_${String(action).toUpperCase()}` as any, reason: reason || null, note: note || null, actor: (req as any).user?.username || null }); } catch { /* ignore audit */ }
        return res.json({ ok: true, data: await setReturnLineStatus(credit_header, credit_detail, 1) });
      }
      return res.json({ ok: true, data: await setReturnLineStatus(credit_header, credit_detail, 2, reason ?? 'lost_of_sales', note) });
    } catch (e) { return next(e); }
  });
/**
 * Phase 3.10: Reports (Ops visibility)
 */
r.get('/lost-sales', guard('inventory.read'), async (_req, res, next) => {
  try { return res.json({ ok: true, data: await listLostSales(200) }); }
  catch (e) { return next(e); }
});

r.get('/balances', guard('inventory.read'), async (_req, res, next) => {
  try { return res.json({ ok: true, data: await listBalances(200) }); }
  catch (e) { return next(e); }
});

r.get('/item-card', guard('inventory.read'), async (req, res, next) => {
  try {
    const store_id = Number(req.query.store_id);
    const item_id = String(req.query.item_id ?? '');
    const data = await getItemCard(store_id, item_id, 200);
    return res.json({ ok: true, data });
  } catch (e) { return next(e); }
});

r.get('/posted-issue/:debit_header', guard('inventory.read'), async (req, res, next) => {
  try {
    const debit_header = Number(req.params.debit_header);
    return res.json({ ok: true, data: await getPostedIssue(debit_header) });
  } catch (e) { return next(e); }
});

r.get('/posted-return/:credit_header', guard('inventory.read'), async (req, res, next) => {
  try {
    const credit_header = Number(req.params.credit_header);
    return res.json({ ok: true, data: await getPostedReturn(credit_header) });
  } catch (e) { return next(e); }
});
// Bulk line actions (Phase 3.11)
const bulkRejectSchema = z.object({
  line_ids: z.array(z.number().int().positive()).min(1),
  reason: z.enum(['lost_of_sales']).default('lost_of_sales'),
  note: z.string().optional()
});

r.post('/issue-requests/:debit_header/lines/approve-all', guard('inventory.write'), async (req, res, next) => {
  try {
    const debit_header = Number(req.params.debit_header);
    await syncIssueHeaderStatusFromLines(debit_header);
    try { await insertAudit({ entity:'ISSUE', header_id: debit_header, line_id: null, action: 'BULK_APPROVE_ALL', actor: (req as any).user?.username || null }); } catch { /* ignore audit */ }
    return res.json({ ok: true, data: await approveAllIssueLines(debit_header) });
  } catch (e) { return next(e); }
});

r.post('/issue-requests/:debit_header/lines/reject', guard('inventory.write'), validateBody(bulkRejectSchema), async (req, res, next) => {
  try {
    const debit_header = Number(req.params.debit_header);
    const { line_ids, reason, note } = req.body as any;
    await syncIssueHeaderStatusFromLines(debit_header);
    try { await insertAudit({ entity:'ISSUE', header_id: debit_header, line_id: null, action: 'BULK_REJECT', reason: reason || null, note: note || null, actor: (req as any).user?.username || null }); } catch { /* ignore audit */ }
    return res.json({ ok: true, data: await rejectIssueLines(debit_header, line_ids, reason ?? 'lost_of_sales', note) });
  } catch (e) { return next(e); }
});

r.post('/return-requests/:credit_header/lines/approve-all', guard('inventory.write'), async (req, res, next) => {
  try {
    const credit_header = Number(req.params.credit_header);
    await syncReturnHeaderStatusFromLines(credit_header);
    try { await insertAudit({ entity:'RETURN', header_id: credit_header, line_id: null, action: 'BULK_APPROVE_ALL', actor: (req as any).user?.username || null }); } catch { /* ignore audit */ }
    return res.json({ ok: true, data: await approveAllReturnLines(credit_header) });
  } catch (e) { return next(e); }
});

r.post('/return-requests/:credit_header/lines/reject', guard('inventory.write'), validateBody(bulkRejectSchema), async (req, res, next) => {
  try {
    const credit_header = Number(req.params.credit_header);
    const { line_ids, reason, note } = req.body as any;
    await syncReturnHeaderStatusFromLines(credit_header);
    try { await insertAudit({ entity:'RETURN', header_id: credit_header, line_id: null, action: 'BULK_REJECT', reason: reason || null, note: note || null, actor: (req as any).user?.username || null }); } catch { /* ignore audit */ }
    return res.json({ ok: true, data: await rejectReturnLines(credit_header, line_ids, reason ?? 'lost_of_sales', note) });
  } catch (e) { return next(e); }
});
// Export CSV + Print (Phase 3.12)
r.get('/issue-requests/:debit_header/export.csv', guard('inventory.read'), async (req, res, next) => {
  try {
    const debit_header = Number(req.params.debit_header);
    const details = await getIssueDetails(debit_header);
    const rows = details.map((d: any) => ({ debit_header, ...d }));
    const csv = toCsv(rows);
    res.setHeader('Content-Type', 'text/csv; charset=utf-8');
    res.setHeader('Content-Disposition', `attachment; filename="issue_request_${debit_header}.csv"`);
    return res.send(csv);
  } catch (e) { return next(e); }
});

r.get('/return-requests/:credit_header/export.csv', guard('inventory.read'), async (req, res, next) => {
  try {
    const credit_header = Number(req.params.credit_header);
    const details = await getReturnDetails(credit_header);
    const rows = details.map((d: any) => ({ credit_header, ...d }));
    const csv = toCsv(rows);
    res.setHeader('Content-Type', 'text/csv; charset=utf-8');
    res.setHeader('Content-Disposition', `attachment; filename="return_request_${credit_header}.csv"`);
    return res.send(csv);
  } catch (e) { return next(e); }
});

function htmlTable(title: string, id: number, rows: any[]) {
  const cols = Object.keys(rows?.[0] || {});
  const esc = (s: any) => String(s ?? '').replaceAll('&','&amp;').replaceAll('<','&lt;').replaceAll('>','&gt;');
  return `<!doctype html><html><head><meta charset="utf-8"/><title>${title} ${id}</title>
  <style>body{font-family:Arial;padding:16px} table{width:100%;border-collapse:collapse} th,td{border:1px solid #ddd;padding:6px;font-size:12px} th{background:#f5f5f5;text-align:left}</style>
  </head><body>
  <h2>${title} #${id}</h2>
  <p>Printed at: ${new Date().toISOString()}</p>
  <table><thead><tr>${cols.map(k=>`<th>${esc(k)}</th>`).join('')}</tr></thead>
  <tbody>${rows.map((r:any)=>`<tr>${cols.map(k=>`<td>${esc(r[k])}</td>`).join('')}</tr>`).join('')}</tbody></table>
  <script>window.print()</script>
  </body></html>`;
}

r.get('/issue-requests/:debit_header/print', guard('inventory.read'), async (req, res, next) => {
  try {
    const debit_header = Number(req.params.debit_header);
    const details = await getIssueDetails(debit_header);
    const html = htmlTable('Issue Request', debit_header, details);
    res.setHeader('Content-Type', 'text/html; charset=utf-8');
    return res.send(html);
  } catch (e) { return next(e); }
});

r.get('/return-requests/:credit_header/print', guard('inventory.read'), async (req, res, next) => {
  try {
    const credit_header = Number(req.params.credit_header);
    const details = await getReturnDetails(credit_header);
    const html = htmlTable('Return Request', credit_header, details);
    res.setHeader('Content-Type', 'text/html; charset=utf-8');
    return res.send(html);
  } catch (e) { return next(e); }
});
// Request Summary + Header Sync (Phase 3.13)
r.get('/issue-requests/:debit_header/summary', guard('inventory.read'), async (req, res, next) => {
  try {
    const debit_header = Number(req.params.debit_header);
    return res.json({ ok: true, data: await getIssueLineStats(debit_header) });
  } catch (e) { return next(e); }
});

r.get('/return-requests/:credit_header/summary', guard('inventory.read'), async (req, res, next) => {
  try {
    const credit_header = Number(req.params.credit_header);
    return res.json({ ok: true, data: await getReturnLineStats(credit_header) });
  } catch (e) { return next(e); }
});

r.post('/issue-requests/:debit_header/sync', guard('inventory.write'), async (req, res, next) => {
  try {
    const debit_header = Number(req.params.debit_header);
    try { await insertAudit({ entity:'ISSUE', header_id: debit_header, line_id: null, action: 'HEADER_SYNC', actor: (req as any).user?.username || null }); } catch { /* ignore audit */ }
    return res.json({ ok: true, data: await syncIssueHeaderStatusFromLines(debit_header) });
  } catch (e) { return next(e); }
});

r.post('/return-requests/:credit_header/sync', guard('inventory.write'), async (req, res, next) => {
  try {
    const credit_header = Number(req.params.credit_header);
    try { await insertAudit({ entity:'RETURN', header_id: credit_header, line_id: null, action: 'HEADER_SYNC', actor: (req as any).user?.username || null }); } catch { /* ignore audit */ }
    return res.json({ ok: true, data: await syncReturnHeaderStatusFromLines(credit_header) });
  } catch (e) { return next(e); }
});
// Audit History (Phase 3.14)
r.get('/issue-requests/:debit_header/history', guard('inventory.read'), async (req, res, next) => {
  try {
    const debit_header = Number(req.params.debit_header);
    const rows = await listAudit('ISSUE', debit_header);
    return res.json({ ok: true, data: rows });
  } catch (e) { return next(e); }
});

r.get('/return-requests/:credit_header/history', guard('inventory.read'), async (req, res, next) => {
  try {
    const credit_header = Number(req.params.credit_header);
    const rows = await listAudit('RETURN', credit_header);
    return res.json({ ok: true, data: rows });
  } catch (e) { return next(e); }
});
// Posting Guards (Phase 3.15)
r.get('/issue-requests/:debit_header/can-post', guard('inventory.read'), async (req, res, next) => {
  try {
    const debit_header = Number(req.params.debit_header);
    return res.json({ ok: true, data: await canPostIssue(debit_header) });
  } catch (e) { return next(e); }
});

r.get('/return-requests/:credit_header/can-post', guard('inventory.read'), async (req, res, next) => {
  try {
    const credit_header = Number(req.params.credit_header);
    return res.json({ ok: true, data: await canPostReturn(credit_header) });
  } catch (e) { return next(e); }
});


  return r;
}
