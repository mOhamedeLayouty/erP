import odbc from 'odbc';
import { AppError } from '../errors.js';

// Keep params flexible for ODBC driver typing differences (Windows/SQLAnywhere).
export type DbParam = string | number | Date | null;

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
      // node-odbc typings are strict; runtime accepts wider params.
      const result = await (connection.query as any)(sql, params);
      return result as unknown as T[];
    },

    async exec(sql: string, params: DbParam[] = []) {
      const result: any = await (connection.query as any)(sql, params);
      return Number(result?.count ?? result?.affectedRows ?? 0);
    },

    async close() {
      await connection.close();
    }
  };
}
