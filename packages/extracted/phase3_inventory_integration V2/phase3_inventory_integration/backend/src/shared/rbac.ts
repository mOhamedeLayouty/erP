import type { RequestHandler } from 'express';

export type PermissionGuardFactory = (permissionKey: string) => RequestHandler;

/**
 * Phase 3 rule (per project agreement):
 * - Users & permissions are deferred to the end of the project.
 * - RBAC is fully bypassed until module reviews are complete.
 *
 * IMPORTANT:
 * - Keep this disabled in production unless explicitly approved.
 */
export const permissionGuard: PermissionGuardFactory = (permissionKey) => {
  void permissionKey;
  return (_req, _res, next) => next();
};
