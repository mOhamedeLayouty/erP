import type { RequestHandler } from 'express';
import type { ZodSchema } from 'zod';
import { badRequest } from './errors.js';

export function validateBody(schema: ZodSchema): RequestHandler {
  return (req, _res, next) => {
    const parsed = schema.safeParse(req.body);
    if (!parsed.success) return next(badRequest('Validation failed', parsed.error.flatten()));
    req.body = parsed.data;
    return next();
  };
}
