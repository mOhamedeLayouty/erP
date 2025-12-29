import { connectDb } from '../../shared/db/odbc.js';

const T_JOB = 'DBA.ws_JobOrder';

export async function listJobOrders(limit = 200) {
  const db = await connectDb();
  try {
    return await db.query(
      `SELECT TOP ${limit} JobOrderID, JobDate, CustomerID, EqptID, OrderStatus, user_id, service_center, location_id FROM ${T_JOB} ORDER BY JobDate DESC, JobOrderID DESC`
    );
  } finally { await db.close(); }
}
