import { connectDb } from '../../shared/db/odbc.js';
const T_JOB = 'DBA.ws_JobOrder';
const LIST_COLS = ["JobOrderID", "JobDate", "CustomerID", "EqptID", "OrderStatus", "StartTime", "EndTime", "out_date", "control_ok", "stock_approved", "user_id", "service_center", "location_id", "ReasonID", "notes"];
export async function listJobOrders(limit = 200) {
    const db = await connectDb();
    try {
        const cols = LIST_COLS.join(', ');
        return await db.query(`SELECT TOP ${limit} ${cols} FROM ${T_JOB} ORDER BY JobDate DESC, JobOrderID DESC`);
    }
    finally {
        await db.close();
    }
}
