import { applyPagination, connectDb } from '../../shared/db/odbc.js';

const T_JOB = 'DBA.ws_JobOrder';
const LIST_COLS = ["JobOrderID", "JobDate", "CustomerID", "EqptID", "OrderStatus", "StartTime", "EndTime", "out_date", "control_ok", "stock_approved", "user_id", "service_center", "location_id", "ReasonID", "notes"];

export async function listJobOrders(limit = 200, offset = 0) {
  const db = await connectDb();
  try {
    const cols = LIST_COLS.join(', ');
    const sql = applyPagination(
      `SELECT ${cols} FROM ${T_JOB} ORDER BY JobDate DESC, JobOrderID DESC`,
      { limit, offset }
    );
    return await db.query(sql);
  } finally { await db.close(); }
}

export async function createJobOrder(input: {
  JobOrderID: string;
  CustomerID?: string;
  EqptID?: string;
  OrderType?: string;
  OrderStatus?: string;
  notes?: string;
  service_center?: number | null;
  location_id?: number | null;
  sales_rep?: string | null;
  actor_user_id: string;
}) {
  const db = await connectDb();
  try {
    const p = input;
    return await db.exec(
      `INSERT INTO ${T_JOB} (
         JobOrderID, JobDate, CustomerID, EqptID, OrderType, OrderStatus, notes, user_id, entry_date, service_center, location_id, sales_rep
       ) VALUES (
         ?, CURRENT DATE, ?, ?, ?, ?, ?, ?, CURRENT TIMESTAMP,
         COALESCE(?, 1), COALESCE(?, 1), ?
       )`,
      [
        p.JobOrderID,
        p.CustomerID ?? null,
        p.EqptID ?? null,
        p.OrderType ?? null,
        p.OrderStatus ?? 'NEW',
        p.notes ?? null,
        p.actor_user_id ?? 'SYSTEM',
        p.service_center ?? null,
        p.location_id ?? null,
        p.sales_rep ?? null
      ]
    );
  } finally { await db.close(); }
}
