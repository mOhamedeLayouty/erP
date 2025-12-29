import { badRequest } from './errors.js';
export function validateBody(schema) {
    return (req, _res, next) => {
        const parsed = schema.safeParse(req.body);
        if (!parsed.success)
            return next(badRequest('Validation failed', parsed.error.flatten()));
        req.body = parsed.data;
        return next();
    };
}
