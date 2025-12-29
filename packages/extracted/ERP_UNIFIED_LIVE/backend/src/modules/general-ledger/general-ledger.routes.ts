import { Router } from 'express';
import type { PermissionGuardFactory } from '../../shared/rbac.js';
import { listAccounts, listBudgets, listJournals, listLedgers } from './general-ledger.repo.js';

export function generalLedgerRouter(guard: PermissionGuardFactory) {
  const r = Router();

  r.get('/accounts', guard('gl.read'), async (req, res, next) => {
    try {
      const limit = req.query.limit ? Number(req.query.limit) : 200;
      return res.json({ ok: true, data: await listAccounts(limit) });
    } catch (e) {
      return next(e);
    }
  });

  r.get('/ledgers', guard('gl.read'), async (req, res, next) => {
    try {
      const limit = req.query.limit ? Number(req.query.limit) : 200;
      return res.json({ ok: true, data: await listLedgers(limit) });
    } catch (e) {
      return next(e);
    }
  });

  r.get('/journals', guard('gl.read'), async (req, res, next) => {
    try {
      const limit = req.query.limit ? Number(req.query.limit) : 200;
      return res.json({ ok: true, data: await listJournals(limit) });
    } catch (e) {
      return next(e);
    }
  });

  r.get('/budgets', guard('gl.read'), async (req, res, next) => {
    try {
      const limit = req.query.limit ? Number(req.query.limit) : 200;
      return res.json({ ok: true, data: await listBudgets(limit) });
    } catch (e) {
      return next(e);
    }
  });

  return r;
}
