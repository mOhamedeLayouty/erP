import { Router } from 'express';
import type { PermissionGuardFactory } from '../../shared/rbac.js';
import fs from 'node:fs';
import path from 'node:path';
import { connectDb } from '../../shared/db/odbc.js';

export function auditRouter(guard: PermissionGuardFactory) {
  const r = Router();

  // Read audit events written by the API (file sink)
  r.get('/events', guard('audit.read'), async (_req, res) => {
    const p = process.env.AUDIT_FILE_PATH ?? './logs/audit.ndjson';
    const abs = path.isAbsolute(p) ? p : path.join(process.cwd(), p);
    if (!fs.existsSync(abs)) return res.json({ ok: true, data: [] });

    const lines = fs.readFileSync(abs, 'utf-8').split(/\r?\n/).filter(Boolean);
    const last = lines.slice(-500).map(l => {
      try { return JSON.parse(l); } catch { return { raw: l }; }
    });
    return res.json({ ok: true, data: last });
  });

  // Best-effort DB log tracking read (locked table if exists)
  r.get('/db-log-tracking', guard('audit.read'), async (_req, res, next) => {
    const t = process.env.AUDIT_DB_TABLE;
    if (!t) return res.status(404).json({ ok: false, code: 'NOT_CONFIGURED', message: 'AUDIT_DB_TABLE not set' });

    const db = await connectDb();
    try {
      const rows = await db.query(`SELECT TOP 200 * FROM ${t} ORDER BY 1 DESC`);
      return res.json({ ok: true, data: rows });
    } catch (e) { return next(e); }
    finally { await db.close(); }
  });

  return r;
}
