import { Router } from 'express';
import type { PermissionGuardFactory } from '../../shared/rbac.js';
import { validateBody } from '../../shared/validation.js';
import { z } from 'zod';
import { createJobOrder, listJobOrders } from './job-orders.repo.js';
import { applyTransition } from './job-orders.workflow.js';

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

const actionSchema = z.object({
  action: z.enum(['start','finish','cancel','control_ok','stock_approve'])
});

export function jobOrderRouter(guard: PermissionGuardFactory) {
  const r = Router();

  r.get('/', guard('job_order.read'), async (req, res, next) => {
    try {
      const limit = req.query.limit ? Number(req.query.limit) : 200;
      const offset = req.query.offset ? Number(req.query.offset) : 0;
      const data = await listJobOrders(limit, offset);
      return res.json({ ok: true, data });
    } catch (e) { return next(e); }
  });

  // Create baseline job order (kept from Phase2; locked columns only)
  r.post('/', guard('job_order.create'), validateBody(createSchema), async (req, res, next) => {
    try {
      const p = req.body as any;
      const affected = await createJobOrder({
        JobOrderID: p.JobOrderID,
        CustomerID: p.CustomerID ?? null,
        EqptID: p.EqptID ?? null,
        OrderType: p.OrderType ?? null,
        OrderStatus: p.OrderStatus ?? 'NEW',
        notes: p.notes ?? null,
        actor_user_id: req.user?.user_id ?? 'SYSTEM',
        service_center: p.service_center ?? null,
        location_id: p.location_id ?? null,
        sales_rep: p.sales_rep ?? null
      });
      return res.json({ ok: true, data: { affected } });
    } catch (e) { return next(e); }
  });

  // Workflow action (soft validated)
  r.post('/:JobOrderID/action', guard('job_order.update'), validateBody(actionSchema), async (req, res, next) => {
    try {
      const jobOrderId = req.params.JobOrderID;
      const { action } = req.body as any;
      const affected = await applyTransition(jobOrderId, action);
      return res.json({ ok: true, data: { affected } });
    } catch (e) { return next(e); }
  });

  return r;
}
