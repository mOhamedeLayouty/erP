import odbc from 'odbc';
import { AppError } from '../errors.js';
export async function connectDb() {
    const connStr = process.env.ODBC_CONNECTION_STRING;
    if (!connStr)
        throw new AppError('DB_CONFIG', 500, 'ODBC_CONNECTION_STRING is not set');
    const connection = await odbc.connect(connStr);
    return {
        async query(sql, params = []) {
            const result = await connection.query(sql, params);
            return result;
        },
        async exec(sql, params = []) {
            const result = await connection.query(sql, params);
            return Number(result?.count ?? result?.affectedRows ?? 0);
        },
        async close() { await connection.close(); }
    };
}
