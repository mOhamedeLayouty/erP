import { Router } from 'express';
import type { PermissionGuardFactory } from '../../shared/rbac.js';
import { listCarCustomers, listSalesDocs, listVehicles } from './cars.repo.js';

export function carsRouter(guard: PermissionGuardFactory) {
  const r = Router();

  r.get('/vehicles', guard('cars.read'), async (req, res, next) => {
    try {
      const limit = req.query.limit ? Number(req.query.limit) : 200;
      return res.json({ ok: true, data: await listVehicles(limit) });
    } catch (e) {
      return next(e);
    }
  });

  r.get('/customers', guard('cars.read'), async (req, res, next) => {
    try {
      const limit = req.query.limit ? Number(req.query.limit) : 200;
      return res.json({ ok: true, data: await listCarCustomers(limit) });
    } catch (e) {
      return next(e);
    }
  });

  r.get('/sales-docs', guard('cars.read'), async (req, res, next) => {
    try {
      const limit = req.query.limit ? Number(req.query.limit) : 200;
      return res.json({ ok: true, data: await listSalesDocs(limit) });
    } catch (e) {
      return next(e);
    }
  });

  return r;
}
