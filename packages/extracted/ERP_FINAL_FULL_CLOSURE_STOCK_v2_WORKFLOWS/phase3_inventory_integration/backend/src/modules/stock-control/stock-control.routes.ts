import { Router } from 'express';
import { badRequest } from '../../shared/errors.js';
import { STOCK_CONTROL_TABLES } from './stock-control.tables.js';
import {
  listRows,
  getTableColumns,
  insertRow,
  updateRow,
  deleteRow
} from './stock-control.repo.js';
import { stockOpsRouter } from './stock-ops.routes.js';

function assertKey(k: string) {
  if (!k || !(k in STOCK_CONTROL_TABLES)) {
    throw badRequest(`Unknown table key: ${k}`);
  }
  return k as keyof typeof STOCK_CONTROL_TABLES;
}

export function stockControlRouter(permissionGuard: (permissionKey: string) => any) {
  const r = Router();

  r.get('/meta/tables', permissionGuard('stock.read'), (_req, res) => {
    res.json({ tables: STOCK_CONTROL_TABLES });
  });

  r.get('/meta/:tableKey/columns', permissionGuard('stock.read'), async (req, res, next) => {
    try {
      const key = assertKey(req.params.tableKey);
      const columns = await getTableColumns(key);
      res.json({ columns });
    } catch (e) {
      next(e);
    }
  });

  r.get('/:tableKey', permissionGuard('stock.read'), async (req, res, next) => {
    try {
      const key = assertKey(req.params.tableKey);
      const rows = await listRows(key, (req.query as any).limit);
      res.json({ data: rows });
    } catch (e) {
      next(e);
    }
  });

  r.post('/:tableKey', permissionGuard('stock.write'), async (req, res, next) => {
    try {
      const key = assertKey(req.params.tableKey);
      const result = await insertRow(key, req.body);
      res.json(result);
    } catch (e) {
      next(e);
    }
  });

  r.put('/:tableKey', permissionGuard('stock.write'), async (req, res, next) => {
    try {
      const key = assertKey(req.params.tableKey);
      const pkColumn = String((req.query as any).pk ?? '');
      const pkValue = (req.query as any).id;
      if (!pkColumn || pkValue === undefined) {
        throw badRequest('Query params required: pk=<column>&id=<value>');
      }
      const result = await updateRow(key, pkColumn, pkValue, req.body);
      res.json(result);
    } catch (e) {
      next(e);
    }
  });

  r.delete('/:tableKey', permissionGuard('stock.write'), async (req, res, next) => {
    try {
      const key = assertKey(req.params.tableKey);
      const pkColumn = String((req.query as any).pk ?? '');
      const pkValue = (req.query as any).id;
      if (!pkColumn || pkValue === undefined) {
        throw badRequest('Query params required: pk=<column>&id=<value>');
      }
      const result = await deleteRow(key, pkColumn, pkValue);
      res.json(result);
    } catch (e) {
      next(e);
    }
  });

  // ✅ FIX: كان بيستخدم guard مش موجود
  r.use('/ops', stockOpsRouter(permissionGuard));

  return r;
}
