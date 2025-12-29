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
   * - Issue request -> DBA.sc_debit_header_request + DBA.sc_debit_detail_request
   * - Return request -> DBA.sc_ret_request_header + DBA.sc_ret_request_detail
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

  return r;
}
