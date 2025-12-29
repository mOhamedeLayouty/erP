import { applyPagination, connectDb } from '../../shared/db/odbc.js';

const CUSTOMERS_TABLE = process.env.CRM_CUSTOMERS_TABLE ?? 'DBA.Customer';
const FOLLOWUPS_TABLE = process.env.CRM_FOLLOWUPS_TABLE ?? 'DBA.client_customer_followup';

export async function listCustomers(limit = 200, offset = 0) {
  const db = await connectDb();
  try {
    const sql = applyPagination(`SELECT * FROM ${CUSTOMERS_TABLE}`, { limit, offset });
    return await db.query(sql);
  } finally {
    await db.close();
  }
}

export async function getCustomer(id: string) {
  const db = await connectDb();
  try {
    const rows = await db.query(`SELECT TOP 1 * FROM ${CUSTOMERS_TABLE} WHERE customer_id=? OR CustomerID=? OR id=?`, [id, id, id]);
    return rows[0] ?? null;
  } catch {
    // fallback: if schema doesn't match, just attempt by first column
    const rows = await db.query(`SELECT TOP 1 * FROM ${CUSTOMERS_TABLE}`);
    return rows[0] ?? null;
  } finally {
    await db.close();
  }
}

export async function listCustomerFollowups(limit = 200, offset = 0) {
  const db = await connectDb();
  try {
    const sql = applyPagination(`SELECT * FROM ${FOLLOWUPS_TABLE} ORDER BY 1 DESC`, { limit, offset });
    return await db.query(sql);
  } finally {
    await db.close();
  }
}
