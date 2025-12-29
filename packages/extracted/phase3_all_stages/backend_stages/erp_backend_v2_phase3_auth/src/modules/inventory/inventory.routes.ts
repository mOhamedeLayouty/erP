import { Router } from 'express';
import type { PermissionGuardFactory } from '../../shared/rbac.js';

export function inventoryRouter(guard: PermissionGuardFactory) {
  const r = Router();
  r.get('/stock', guard('inventory.read'), async (_req, res) => res.json({ ok: true, data: [] }));
  return r;
}
