import { Router } from 'express';
import type { PermissionGuardFactory } from '../../shared/rbac.js';
import { validateBody } from '../../shared/validation.js';
import { z } from 'zod';
import { connectDb } from '../../shared/db/odbc.js';

const listCols = ["InvoiceID", "InvoiceType", "CustomerID", "EqptID", "InvoiceDate", "Status", "invoiceno", "service_center", "location_id"];

const createSchema = z.object({
  InvoiceID: z.string().min(1),
  InvoiceType: z.string().min(1),
  InvoiceDate: z.string().optional(),
  CustomerID: z.string().optional(),
  EqptID: z.string().optional(),
  Receptionist: z.string().optional(),
  Status: z.string().optional(),
  service_center: z.number().int().optional(),
  location_id: z.number().int().optional()
});

export function invoicingRouter(guard: PermissionGuardFactory) {
  const r = Router();

  r.get('/invoices', guard('invoicing.read'), async (req, res, next) => {
    const db = await connectDb();
    try {
      const cols = listCols.join(', ');
      const rows = await db.query(
        `SELECT TOP 200 ${cols} FROM DBA.ws_InvoiceHeader ORDER BY InvoiceDate DESC, InvoiceID DESC`
      );
      return res.json({ ok: true, data: rows });
    } catch (e) { return next(e); }
    finally { await db.close(); }
  });

  r.post('/invoices', guard('invoicing.create'), validateBody(createSchema), async (req, res, next) => {
    const db = await connectDb();
    try {
      const p = req.body as any;
      const affected = await db.exec(
        `INSERT INTO DBA.ws_InvoiceHeader (
           InvoiceID, InvoiceType, InvoiceDate, CustomerID, EqptID, Receptionist, Status, user_id, entry_date, service_center, location_id
         ) VALUES (
           ?, ?, COALESCE(?, CURRENT DATE), ?, ?, ?, ?, ?, CURRENT TIMESTAMP,
           COALESCE(?, 1), COALESCE(?, 1)
         )`,
        [
          p.InvoiceID,
          p.InvoiceType,
          p.InvoiceDate ?? null,
          p.CustomerID ?? null,
          p.EqptID ?? null,
          p.Receptionist ?? null,
          p.Status ?? null,
          req.user!.user_id,
          p.service_center ?? null,
          p.location_id ?? null
        ]
      );
      return res.json({ ok: true, data: { affected } });
    } catch (e) { return next(e); }
    finally { await db.close(); }
  });

  return r;
}
