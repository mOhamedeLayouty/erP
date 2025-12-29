import { Router } from 'express';
import type { PermissionGuardFactory } from '../../shared/rbac.js';
import { listCustomers, getCustomer, listCustomerFollowups } from './crm.repo.js';

// Minimal CRM read module for live demo.
// This intentionally uses SELECT * so it works across slightly different schemas.

export function crmRouter(guard: PermissionGuardFactory) {
  const r = Router();

  r.get('/customers', guard('crm.read'), async (req, res, next) => {
    try {
      const limit = req.query.limit ? Number(req.query.limit) : 200;
      const offset = req.query.offset ? Number(req.query.offset) : 0;
      return res.json({ ok: true, data: await listCustomers(limit, offset) });
    } catch (e) { return next(e); }
  });

  r.get('/customers/:id', guard('crm.read'), async (req, res, next) => {
    try {
      const id = String(req.params.id);
      return res.json({ ok: true, data: await getCustomer(id) });
    } catch (e) { return next(e); }
  });

  r.get('/followups', guard('crm.read'), async (req, res, next) => {
    try {
      const limit = req.query.limit ? Number(req.query.limit) : 200;
      const offset = req.query.offset ? Number(req.query.offset) : 0;
      return res.json({ ok: true, data: await listCustomerFollowups(limit, offset) });
    } catch (e) { return next(e); }
  });

  return r;
}
