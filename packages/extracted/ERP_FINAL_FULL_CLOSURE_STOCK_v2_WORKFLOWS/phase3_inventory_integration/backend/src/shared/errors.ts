export class AppError extends Error {
  constructor(
    public readonly code: string,
    public readonly status: number,
    message: string,
    public readonly details?: unknown
  ) {
    super(message);
  }
}

export const badRequest = (m: string, d?: unknown) =>
  new AppError('BAD_REQUEST', 400, m, d);

export const unauthorized = (m = 'Unauthorized') =>
  new AppError('UNAUTHORIZED', 401, m);

export const forbidden = (m = 'Forbidden') =>
  new AppError('FORBIDDEN', 403, m);

export const notFound = (m = 'Not found') =>
  new AppError('NOT_FOUND', 404, m);
