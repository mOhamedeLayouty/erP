import odbc from 'odbc';
import { AppError } from '../errors.js';

export type Db = {
  query<T = any>(sql: string, params?: unknown[]): Promise<T[]>;
  exec(sql: string, params?: unknown[]): Promise<number>;
  close(): Promise<void>;
};

export async function connectDb(): Promise<Db> {
  const connStr = process.env.ODBC_CONNECTION_STRING;
  if (!connStr) throw new AppError('DB_CONFIG', 500, 'ODBC_CONNECTION_STRING is not set');
  const connection = await odbc.connect(connStr);
  return {
    async query<T = any>(sql: string, params: unknown[] = []) {
      const result = await connection.query(sql, params);
      return result as unknown as T[];
    },
    async exec(sql: string, params: unknown[] = []) {
      const result: any = await connection.query(sql, params);
      return Number(result?.count ?? result?.affectedRows ?? 0);
    },
    async close() { await connection.close(); }
  };
}
