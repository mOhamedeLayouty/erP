import { Router } from 'express';
import type { PermissionGuardFactory } from '../../shared/rbac.js';
import { listAttendance, listEmployees, listVacations } from './hr.repo.js';

export function hrRouter(guard: PermissionGuardFactory) {
  const r = Router();

  r.get('/employees', guard('hr.read'), async (req, res, next) => {
    try {
      const limit = req.query.limit ? Number(req.query.limit) : 200;
      return res.json({ ok: true, data: await listEmployees(limit) });
    } catch (e) {
      return next(e);
    }
  });

  r.get('/attendance', guard('hr.read'), async (req, res, next) => {
    try {
      const limit = req.query.limit ? Number(req.query.limit) : 200;
      return res.json({ ok: true, data: await listAttendance(limit) });
    } catch (e) {
      return next(e);
    }
  });

  r.get('/vacations', guard('hr.read'), async (req, res, next) => {
    try {
      const limit = req.query.limit ? Number(req.query.limit) : 200;
      return res.json({ ok: true, data: await listVacations(limit) });
    } catch (e) {
      return next(e);
    }
  });

  return r;
}
