import jwt from 'jsonwebtoken';
import { unauthorized } from './errors.js';
export const authMiddleware = (req, _res, next) => {
    const header = req.headers.authorization;
    if (!header?.startsWith('Bearer '))
        return next(unauthorized());
    const token = header.slice('Bearer '.length);
    try {
        const payload = jwt.verify(token, process.env.JWT_SECRET ?? 'change_me', {
            issuer: process.env.JWT_ISSUER,
            audience: process.env.JWT_AUDIENCE
        });
        if (!payload?.user_id || !Array.isArray(payload.roles))
            return next(unauthorized('Invalid token payload'));
        req.user = payload;
        return next();
    }
    catch {
        return next(unauthorized());
    }
};
