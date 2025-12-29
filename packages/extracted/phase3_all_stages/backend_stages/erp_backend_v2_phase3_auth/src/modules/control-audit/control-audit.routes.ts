import { Router } from 'express';
import type { PermissionGuardFactory } from '../../shared/rbac.js';

export function auditRouter(guard: PermissionGuardFactory) {
  const r = Router();
  r.get('/events', guard('audit.read'), async (_req, res) => res.json({ ok: true, data: [] }));
  return r;
}
