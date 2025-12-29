import type { RequestHandler } from 'express';
import fs from 'node:fs';
import path from 'node:path';
import { forbidden } from './errors.js';

type PermissionsConfig = { roles: Record<string, string[]> };

function loadPermissions(): PermissionsConfig {
  const p = process.env.PERMISSIONS_JSON_PATH ?? './config/permissions.json';
  const abs = path.isAbsolute(p) ? p : path.join(process.cwd(), p);
  return JSON.parse(fs.readFileSync(abs, 'utf-8')) as PermissionsConfig;
}

export type PermissionGuardFactory = (permissionKey: string) => RequestHandler;

export const permissionGuard: PermissionGuardFactory = (permissionKey) => {
  const cfg = loadPermissions();
  return (req, _res, next) => {
    const roles = req.user?.roles ?? [];
    const allowed = roles.some((r) => {
      const perms = cfg.roles[r] ?? [];
      return perms.includes('*') || perms.includes(permissionKey);
    });
    if (!allowed) return next(forbidden(`Missing permission: ${permissionKey}`));
    return next();
  };
};
