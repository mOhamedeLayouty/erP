import type { Express } from 'express';

import { authMiddleware } from './shared/auth.js';
import { permissionGuard } from './shared/rbac.js';

import { authRouter } from './modules/auth/auth.routes.js';
import { meRouter } from './modules/auth/me.routes.js';
import { masterDataRouter } from './modules/master-data/master-data.routes.js';
import { jobOrderRouter } from './modules/job-orders/job-orders.routes.js';
import { invoicingRouter } from './modules/invoicing/invoicing.routes.js';
import { inventoryRouter } from './modules/inventory/inventory.routes.js';
import { stockControlRouter } from './modules/stock-control/stock-control.routes.js';
import { auditRouter } from './modules/control-audit/control-audit.routes.js';

export function buildRoutes(app: Express) {
  // Health
  app.get('/health', (_req, res) => res.json({ ok: true }));

  // Public auth endpoints (Phase 3.1)
  app.use('/auth', authRouter(permissionGuard));

  // Protected APIs
  app.use('/api', authMiddleware);

  // Auth info
  app.use('/api/auth', meRouter());

  app.use('/api/master-data', masterDataRouter(permissionGuard));
  app.use('/api/job-orders', jobOrderRouter(permissionGuard));
  app.use('/api/invoicing', invoicingRouter(permissionGuard));
  app.use('/api/inventory', inventoryRouter(permissionGuard));
  app.use('/api/stock', stockControlRouter(permissionGuard));
  app.use('/api/audit', auditRouter(permissionGuard));
}
