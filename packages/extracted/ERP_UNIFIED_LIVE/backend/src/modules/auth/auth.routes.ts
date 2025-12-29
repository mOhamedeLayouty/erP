import { Router } from 'express';
import type { PermissionGuardFactory } from '../../shared/rbac.js';
import * as jwt from 'jsonwebtoken';
import { validateBody } from '../../shared/validation.js';
import { z } from 'zod';
import { login, refresh } from './user-auth.service.js';

const devMintSchema = z.object({
  user_id: z.string().min(1),
  user_name: z.string().optional(),
  roles: z.array(z.string().min(1)).min(1)
});

const loginSchema = z.object({
  user_name: z.string().min(1),
  password: z.string().min(1)
});

const refreshSchema = z.object({
  refresh_token: z.string().min(1)
});

export function authRouter(guard: PermissionGuardFactory) {
  const r = Router();

  r.post('/login', validateBody(loginSchema), async (req, res, next) => {
    try {
      const { user_name, password } = req.body as any;
      const data = await login(user_name, password);
      return res.json({ ok: true, data });
    } catch (e) { return next(e); }
  });

  r.post('/refresh', validateBody(refreshSchema), async (req, res, next) => {
    try {
      const { refresh_token } = req.body as any;
      const data = refresh(refresh_token);
      return res.json({ ok: true, data });
    } catch (e) { return next(e); }
  });

  // Dev/testing only – disabled by default
  r.post('/token', guard('auth.token'), validateBody(devMintSchema), async (req, res, next) => {
    try {
      const enabled = (process.env.ENABLE_DEV_TOKEN ?? 'false').toLowerCase() === 'true';
      if (!enabled) return res.status(404).json({ ok: false, code: 'DISABLED', message: 'Endpoint disabled' });

      const payload = req.body as any;
      const token = jwt.sign(payload, process.env.JWT_SECRET ?? 'change_me', {
        issuer: process.env.JWT_ISSUER,
        audience: process.env.JWT_AUDIENCE,
        expiresIn: '12h'
      });
      return res.json({ ok: true, token });
    } catch (e) { return next(e); }
  });

  return r;
}
