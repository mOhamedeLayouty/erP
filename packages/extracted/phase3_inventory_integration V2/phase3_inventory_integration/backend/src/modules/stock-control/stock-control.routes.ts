import { Router } from 'express';
import type { PermissionGuardFactory } from '../../shared/rbac.js';
import { badRequest } from '../../shared/errors.js';
import { STOCK_CONTROL_TABLES, type StockControlTableKey } from './stock-control.tables.js';
import { listRows, getTableColumns, insertRow, updateRow, deleteRow } from './stock-control.repo.js';
import { stockOpsRouter } from './stock-ops.routes.js';

function assertKey(k: string): StockControlTableKey {
  if (!k || !(k in STOCK_CONTROL_TABLES)) {
    throw badRequest(`Unknown table key: ${k}`);
  }
  return k as StockControlTableKey;
}

/**
 * Stock Control System (Inventory proper)
 *
 * Endpoints are intentionally generic but *table-keyed* (not arbitrary SQL)
 * to keep it safe while still covering the full module scope.
 */
export function stockControlRouter(permissionGuard: PermissionGuardFactory) {
  const r = Router();

  // Meta
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

  // List
  r.get('/:tableKey', permissionGuard('stock.read'), async (req, res, next) => {
    try {
      const key = assertKey(req.params.tableKey);
      const rows = await listRows(key, req.query.limit);
      res.json({ data: rows });
    } catch (e) {
      next(e);
    }
  });

  // Insert
  r.post('/:tableKey', permissionGuard('stock.write'), async (req, res, next) => {
    try {
      const key = assertKey(req.params.tableKey);
      const result = await insertRow(key, req.body);
      res.json(result);
    } catch (e) {
      next(e);
    }
  });

  // Update (requires pk column + value)
  r.put('/:tableKey', permissionGuard('stock.write'), async (req, res, next) => {
    try {
      const key = assertKey(req.params.tableKey);
      const pkColumn = String(req.query.pk ?? '');
      const pkValue = req.query.id;
      if (!pkColumn || pkValue === undefined) throw badRequest('Query params required: pk=<column>&id=<value>');
      const result = await updateRow(key, pkColumn, pkValue, req.body);
      res.json(result);
    } catch (e) {
      next(e);
    }
  });

  // Delete
  r.delete('/:tableKey', permissionGuard('stock.write'), async (req, res, next) => {
    try {
      const key = assertKey(req.params.tableKey);
      const pkColumn = String(req.query.pk ?? '');
      const pkValue = req.query.id;
      if (!pkColumn || pkValue === undefined) throw badRequest('Query params required: pk=<column>&id=<value>');
      const result = await deleteRow(key, pkColumn, pkValue);
      res.json(result);
    } catch (e) {
      next(e);
    }
  });

  // Workflows
  r.use('/ops', stockOpsRouter(guard));

  return r;
}
