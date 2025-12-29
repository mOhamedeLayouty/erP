import { AppError } from './errors.js';
import { logger } from './logger.js';
export const errorHandler = (err, req, res, _next) => {
    if (err instanceof AppError) {
        return res.status(err.status).json({ ok: false, code: err.code, message: err.message, details: err.details });
    }
    logger.error({ err, path: req.path }, 'Unhandled error');
    return res.status(500).json({ ok: false, code: 'INTERNAL', message: 'Internal Server Error' });
};
