import type { RequestHandler } from 'express';
import jwt from 'jsonwebtoken';
import { unauthorized } from './errors.js';

export type JwtUser = { user_id: string; user_name?: string; roles: string[]; };

declare global {
  namespace Express { interface Request { user?: JwtUser; } }
}

export const authMiddleware: RequestHandler = (req, _res, next) => {
  const header = req.headers.authorization;
  if (!header?.startsWith('Bearer ')) return next(unauthorized());
  const token = header.slice('Bearer '.length);
  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET ?? 'change_me', {
      issuer: process.env.JWT_ISSUER,
      audience: process.env.JWT_AUDIENCE
    }) as JwtUser;

    if (!payload?.user_id || !Array.isArray(payload.roles)) return next(unauthorized('Invalid token payload'));
    req.user = payload;
    return next();
  } catch { return next(unauthorized()); }
};
