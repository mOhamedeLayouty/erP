import { applyPagination, connectDb } from '../../shared/db/odbc.js';

export async function listDbAuditRows(tableName: string, limit = 200, offset = 0) {
  const db = await connectDb();
  try {
    const sql = applyPagination(`SELECT * FROM ${tableName} ORDER BY 1 DESC`, { limit, offset });
    return await db.query(sql);
  } finally {
    await db.close();
  }
}
