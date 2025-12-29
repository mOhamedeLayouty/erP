import { Router } from 'express';
import type { PermissionGuardFactory } from '../../shared/rbac.js';
import { validateBody } from '../../shared/validation.js';
import { z } from 'zod';
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
} from './requests.repo.js';
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
  r.get('/stores', guard('inventory.read'), async (_req, res, next) => {
    try { return res.json({ ok: true, data: await listStores(200) }); }
    catch (e) { return next(e); }
  });

  r.get('/items', guard('inventory.read'), async (_req, res, next) => {
    try { return res.json({ ok: true, data: await listItems(200) }); }
    catch (e) { return next(e); }
  });

  r.get('/transfers', guard('inventory.read'), async (_req, res, next) => {
    try { return res.json({ ok: true, data: await listTransfers(200) }); }
    catch (e) { return next(e); }
  });

  r.get('/transfer-details', guard('inventory.read'), async (_req, res, next) => {
    try { return res.json({ ok: true, data: await listTransferDetails(500) }); }
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
  r.get('/issue-requests', guard('inventory.read'), async (_req, res, next) => {
    try { return res.json({ ok: true, data: await listIssueRequests(200) }); }
    catch (e) { return next(e); }
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
        return res.json({ ok: true, data: await setIssueLineStatus(debit_header, debit_detail, 1) });
      }
      return res.json({ ok: true, data: await setIssueLineStatus(debit_header, debit_detail, 2, reason ?? 'lost_of_sales', note) });
    } catch (e) { return next(e); }
  });

  r.get('/return-requests', guard('inventory.read'), async (_req, res, next) => {
    try { return res.json({ ok: true, data: await listReturnRequests(200) }); }
    catch (e) { return next(e); }
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
        return res.json({ ok: true, data: await setReturnLineStatus(credit_header, credit_detail, 1) });
      }
      return res.json({ ok: true, data: await setReturnLineStatus(credit_header, credit_detail, 2, reason ?? 'lost_of_sales', note) });
    } catch (e) { return next(e); }
  });

  return r;
}
