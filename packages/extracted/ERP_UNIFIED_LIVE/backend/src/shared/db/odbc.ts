import odbc from 'odbc';
import { AppError } from '../errors.js';

export type DbParam = string | number | null | Date;

export type Db = {
  query<T = any>(sql: string, params?: DbParam[]): Promise<T[]>;
  exec(sql: string, params?: DbParam[]): Promise<number>;
  close(): Promise<void>;
};

export async function connectDb(): Promise<Db> {
  const connStr = process.env.ODBC_CONNECTION_STRING;
  if (!connStr) throw new AppError('DB_CONFIG', 500, 'ODBC_CONNECTION_STRING is not set');
  const connection = await odbc.connect(connStr);
  return {
    async query<T = any>(sql: string, params: DbParam[] = []) {
      // node-odbc typings are strict; at runtime SQL Anywhere driver accepts nulls too.
      const result = await (connection as any).query(sql, params as any);
      return result as unknown as T[];
    },
    async exec(sql: string, params: DbParam[] = []) {
      const result: any = await (connection as any).query(sql, params as any);
      return Number(result?.count ?? result?.affectedRows ?? 0);
    },
    async close() { await connection.close(); }
  };
}
