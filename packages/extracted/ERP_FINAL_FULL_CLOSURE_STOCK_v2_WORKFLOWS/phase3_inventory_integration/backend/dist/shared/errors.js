export class AppError extends Error {
    code;
    status;
    details;
    constructor(code, status, message, details) {
        super(message);
        this.code = code;
        this.status = status;
        this.details = details;
    }
}
export const badRequest = (m, d) => new AppError('BAD_REQUEST', 400, m, d);
export const unauthorized = (m = 'Unauthorized') => new AppError('UNAUTHORIZED', 401, m);
export const forbidden = (m = 'Forbidden') => new AppError('FORBIDDEN', 403, m);
