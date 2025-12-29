import { Router } from 'express';
import type { PermissionGuardFactory } from '../../shared/rbac.js';
import { validateBody } from '../../shared/validation.js';
import { z } from 'zod';
import { connectDb } from '../../shared/db/odbc.js';
import { listJobOrders } from './job-orders.repo.js';

const createSchema = z.object({
  JobOrderID: z.string().min(1),
  CustomerID: z.string().optional(),
  EqptID: z.string().optional(),
  OrderType: z.string().optional(),
  OrderStatus: z.string().optional(),
  notes: z.string().optional(),
  service_center: z.number().int().optional(),
  location_id: z.number().int().optional(),
  sales_rep: z.string().optional()
});

export function jobOrderRouter(guard: PermissionGuardFactory) {
  const r = Router();

  r.get('/', guard('job_order.read'), async (req, res, next) => {
    try {
      const data = await listJobOrders(200);
      return res.json({ ok: true, data });
    } catch (e) { return next(e); }
  });

  r.post('/', guard('job_order.create'), validateBody(createSchema), async (req, res, next) => {
    const db = await connectDb();
    try {
      const p = req.body as any;
      const affected = await db.exec(
        `INSERT INTO DBA.ws_JobOrder (
           JobOrderID, JobDate, CustomerID, EqptID, OrderType, OrderStatus, notes, user_id, entry_date, service_center, location_id, sales_rep
         ) VALUES (
           ?, CURRENT DATE, ?, ?, ?, ?, ?, ?, CURRENT TIMESTAMP,
           COALESCE(?, 1), COALESCE(?, 1), ?
         )`,
        [
          p.JobOrderID,
          p.CustomerID ?? null,
          p.EqptID ?? null,
          p.OrderType ?? null,
          p.OrderStatus ?? null,
          p.notes ?? null,
          req.user!.user_id,
          p.service_center ?? null,
          p.location_id ?? null,
          p.sales_rep ?? null
        ]
      );
      return res.json({ ok: true, data: { affected } });
    } catch (e) { return next(e); }
    finally { await db.close(); }
  });

  return r;
}
