import { connectDb } from '../../shared/db/connectDb.js';
export async function insertAudit(row) {
    const db = await connectDb();
    try {
        await db.execute(`INSERT INTO inv_request_audit(entity, header_id, line_id, action, reason, note, actor, at_time)
       VALUES(?,?,?,?,?,?,?, CURRENT TIMESTAMP)`, [row.entity, row.header_id, row.line_id ?? null, row.action, row.reason ?? null, row.note ?? null, row.actor ?? null]);
    }
    finally {
        await db.close();
    }
}
export async function listAudit(entity, header_id) {
    const db = await connectDb();
    try {
        const rows = await db.query(`SELECT audit_id, entity, header_id, line_id, action, reason, note, actor, CAST(at_time AS VARCHAR(50)) AS at_time
       FROM inv_request_audit
       WHERE entity=? AND header_id=?
       ORDER BY audit_id DESC`, [entity, header_id]);
        return rows;
    }
    finally {
        await db.close();
    }
}
