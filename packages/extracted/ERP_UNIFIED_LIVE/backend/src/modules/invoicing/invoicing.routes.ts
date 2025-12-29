import { Router } from 'express';
import type { PermissionGuardFactory } from '../../shared/rbac.js';
import { validateBody } from '../../shared/validation.js';
import { z } from 'zod';
import { connectDb } from '../../shared/db/odbc.js';
import { listInvoices, listInvoiceDetails, createInvoiceHeader, createInvoiceDetail } from './invoicing.repo.js';

const anyObject = z.record(z.any());

const createFullSchema = z.object({
  header: z.record(z.any()),
  details: z.array(z.record(z.any())).default([])
});

export function invoicingRouter(guard: PermissionGuardFactory) {
  const r = Router();

  r.get('/invoices', guard('invoice.read'), async (_req, res, next) => {
    try { return res.json({ ok: true, data: await listInvoices(200) }); }
    catch (e) { return next(e); }
  });

  r.get('/invoices/:InvoiceID/details', guard('invoice.read'), async (req, res, next) => {
    try { return res.json({ ok: true, data: await listInvoiceDetails(req.params.InvoiceID, 500) }); }
    catch (e) { return next(e); }
  });

  // Generic inserts (locked columns only)
  r.post('/invoices', guard('invoice.write'), validateBody(anyObject), async (req, res, next) => {
    try {
      const affected = await createInvoiceHeader(req.body as any);
      return res.json({ ok: true, data: { affected } });
    } catch (e) { return next(e); }
  });

  r.post('/invoice-details', guard('invoice.write'), validateBody(anyObject), async (req, res, next) => {
    try {
      const affected = await createInvoiceDetail(req.body as any);
      return res.json({ ok: true, data: { affected } });
    } catch (e) { return next(e); }
  });

  // Transactional create (best-effort; if driver supports)
  r.post('/invoice-full', guard('invoice.write'), validateBody(createFullSchema), async (req, res, next) => {
    const db = await connectDb();
    try {
      const { header, details } = req.body as any;
      await db.exec('BEGIN TRANSACTION');
      const hAffected = await createInvoiceHeader(header);
      let dAffected = 0;
      for (const d of (details ?? [])) {
        dAffected += await createInvoiceDetail(d);
      }
      await db.exec('COMMIT');
      return res.json({ ok: true, data: { header_affected: hAffected, detail_affected: dAffected } });
    } catch (e) {
      try { await db.exec('ROLLBACK'); } catch {}
      return next(e);
    } finally { await db.close(); }
  });

  return r;
}
