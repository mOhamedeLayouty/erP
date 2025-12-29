import { Router } from 'express';
import type { PermissionGuardFactory } from '../../shared/rbac.js';
import { validateBody } from '../../shared/validation.js';
import { z } from 'zod';
import { listCustomers, createCustomer, listEquipment } from './master-data.repo.js';

const createCustomerSchema = z.object({
  customer_id: z.string().min(1),
  customer_name_a: z.string().optional(),
  customer_name_e: z.string().optional(),
  GSM: z.string().optional(),
  email: z.string().optional(),
  address: z.string().optional()
});

export function masterDataRouter(guard: PermissionGuardFactory) {
  const r = Router();

  r.get('/customers', guard('master_data.read'), async (req, res, next) => {
    try {
      const data = await listCustomers(200);
      return res.json({ ok: true, data });
    } catch (e) { return next(e); }
  });

  r.post('/customers', guard('master_data.create'), validateBody(createCustomerSchema), async (req, res, next) => {
    try {
      const affected = await createCustomer(req.body, req.user!.user_id);
      return res.json({ ok: true, data: { affected } });
    } catch (e) { return next(e); }
  });

  r.get('/equipment', guard('master_data.read'), async (req, res, next) => {
    try {
      const data = await listEquipment(200);
      return res.json({ ok: true, data });
    } catch (e) { return next(e); }
  });

  return r;
}
