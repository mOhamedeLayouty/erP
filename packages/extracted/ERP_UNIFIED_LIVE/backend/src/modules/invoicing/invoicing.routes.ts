import { Router } from 'express';
import type { PermissionGuardFactory } from '../../shared/rbac.js';
import { validateBody } from '../../shared/validation.js';
import { z } from 'zod';
import { withTransaction } from '../../shared/db/odbc.js';
import { listInvoices, listInvoiceDetails, createInvoiceHeader, createInvoiceDetail } from './invoicing.repo.js';

const anyObject = z.record(z.any());

const createFullSchema = z.object({
  header: z.record(z.any()),
  details: z.array(z.record(z.any())).default([])
});

export function invoicingRouter(guard: PermissionGuardFactory) {
  const r = Router();

  r.get('/invoices', guard('invoice.read'), async (req, res, next) => {
    try {
      const limit = req.query.limit ? Number(req.query.limit) : 200;
      const offset = req.query.offset ? Number(req.query.offset) : 0;
      return res.json({ ok: true, data: await listInvoices(limit, offset) });
    }
    catch (e) { return next(e); }
  });

  r.get('/invoices/:InvoiceID/details', guard('invoice.read'), async (req, res, next) => {
    try {
      const limit = req.query.limit ? Number(req.query.limit) : 500;
      const offset = req.query.offset ? Number(req.query.offset) : 0;
      return res.json({ ok: true, data: await listInvoiceDetails(req.params.InvoiceID, limit, offset) });
    }
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
    try {
      const { header, details } = req.body as any;
      const result = await withTransaction(async (db) => {
        const hAffected = await createInvoiceHeader(header, db);
        let dAffected = 0;
        for (const d of (details ?? [])) {
          dAffected += await createInvoiceDetail(d, db);
        }
        return { header_affected: hAffected, detail_affected: dAffected };
      });
      return res.json({ ok: true, data: result });
    } catch (e) { return next(e); }
  });

  return r;
}
