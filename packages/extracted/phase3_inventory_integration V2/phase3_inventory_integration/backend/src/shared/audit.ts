import fs from 'node:fs';
import path from 'node:path';
import type { RequestHandler } from 'express';

export type AuditEvent = {
  ts: string;
  user_id?: string;
  user_name?: string;
  method: string;
  path: string;
  ip?: string;
  status?: number;
  request_id?: string;
  body?: unknown;
};

function ensureDir(p: string) {
  if (!fs.existsSync(p)) fs.mkdirSync(p, { recursive: true });
}

export function fileAuditSink(filePath = './logs/audit.ndjson') {
  const abs = path.isAbsolute(filePath) ? filePath : path.join(process.cwd(), filePath);
  ensureDir(path.dirname(abs));

  return (ev: AuditEvent) => {
    fs.appendFileSync(abs, JSON.stringify(ev) + '\n', 'utf8');
  };
}

export function auditMiddleware(): RequestHandler {
  const sinkPath = process.env.AUDIT_FILE_PATH ?? './logs/audit.ndjson';
  const sink = fileAuditSink(sinkPath);

  return (req, res, next) => {
    // log only mutating requests
    const method = req.method.toUpperCase();
    if (['GET', 'HEAD', 'OPTIONS'].includes(method)) return next();

    const started = new Date();
    res.on('finish', () => {
      const ev: AuditEvent = {
        ts: started.toISOString(),
        user_id: req.user?.user_id,
        user_name: req.user?.user_name,
        method,
        path: req.path,
        ip: req.ip,
        status: res.statusCode,
        body: req.body
      };
      try { sink(ev); } catch { /* ignore */ }
    });

    return next();
  };
}
