import { Router } from 'express';
import type { PermissionGuardFactory } from '../../shared/rbac.js';
import { validateBody } from '../../shared/validation.js';
import { z } from 'zod';
import {
  listStores, listItems, listTransfers, listTransferDetails,
  createTransferHeader, createTransferDetail
} from './inventory.repo.js';

const anyObject = z.record(z.any());

export function inventoryRouter(guard: PermissionGuardFactory) {
  const r = Router();

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

  return r;
}
