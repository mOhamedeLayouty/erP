import odbc from 'odbc';
import { AppError } from '../errors.js';

export type DbParam = string | number | null | Date;

export type Db = {
  query<T = any>(sql: string, params?: DbParam[]): Promise<T[]>;
  exec(sql: string, params?: DbParam[]): Promise<number>;
  close(): Promise<void>;
};

export type PaginationOptions = {
  limit?: number;
  offset?: number;
  defaultLimit?: number;
  maxLimit?: number;
};

const DEFAULT_LIMIT = 100;
const DEFAULT_MAX_LIMIT = 500;

function normalizePagination(options: PaginationOptions = {}) {
  const maxLimit = options.maxLimit ?? DEFAULT_MAX_LIMIT;
  const rawLimit = options.limit ?? options.defaultLimit ?? DEFAULT_LIMIT;
  const limit = Math.min(Math.max(rawLimit, 1), maxLimit);
  const offset = Math.max(options.offset ?? 0, 0);
  return { limit, offset };
}

export function applyPagination(sql: string, options: PaginationOptions = {}) {
  const { limit, offset } = normalizePagination(options);
  const selectMatch = /^\s*select\s+/i;
  if (!selectMatch.test(sql)) return sql;

  if (offset > 0) {
    return sql.replace(selectMatch, `SELECT TOP ${limit} START AT ${offset + 1} `);
  }
  return sql.replace(selectMatch, `SELECT TOP ${limit} `);
}

function shouldLogSql() {
  return ['1', 'true', 'yes', 'on'].includes(String(process.env.SQL_LOG ?? '').toLowerCase());
}

function formatSqlLog(sql: string, params: DbParam[]) {
  if (!params.length) return sql;
  return `${sql} | params=${JSON.stringify(params)}`;
}

export async function connectDb(): Promise<Db> {
  const connStr = process.env.ODBC_CONNECTION_STRING;
  if (!connStr) throw new AppError('DB_CONFIG', 500, 'ODBC_CONNECTION_STRING is not set');
  const connection = await odbc.connect(connStr);
  return {
    async query<T = any>(sql: string, params: DbParam[] = []) {
      if (shouldLogSql()) console.info(`[SQL] ${formatSqlLog(sql, params)}`);
      // node-odbc typings are strict; at runtime SQL Anywhere driver accepts nulls too.
      const result = await (connection as any).query(sql, params as any);
      return result as unknown as T[];
    },
    async exec(sql: string, params: DbParam[] = []) {
      if (shouldLogSql()) console.info(`[SQL] ${formatSqlLog(sql, params)}`);
      const result: any = await (connection as any).query(sql, params as any);
      return Number(result?.count ?? result?.affectedRows ?? 0);
    },
    async close() { await connection.close(); }
  };
}

export async function withDb<T>(fn: (db: Db) => Promise<T>): Promise<T> {
  const db = await connectDb();
  try {
    return await fn(db);
  } finally {
    await db.close();
  }
}

export async function withTransaction<T>(fn: (db: Db) => Promise<T>): Promise<T> {
  return withDb(async (db) => {
    await db.exec('BEGIN TRANSACTION');
    try {
      const result = await fn(db);
      await db.exec('COMMIT');
      return result;
    } catch (err) {
      try { await db.exec('ROLLBACK'); } catch {}
      throw err;
    }
  });
}
