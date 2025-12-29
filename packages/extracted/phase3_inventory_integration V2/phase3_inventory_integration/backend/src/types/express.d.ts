import type { JwtUser } from '../shared/auth.js';

declare global {
  namespace Express {
    interface Request {
      user?: JwtUser;
    }
  }
}

export {};
