import { connectDb } from '../../shared/db/connectDb.js';

export type AuditAction =
  | 'HEADER_APPROVE' | 'HEADER_REJECT' | 'HEADER_POST' | 'HEADER_UNPOST' | 'HEADER_SYNC'
  | 'LINE_APPROVE' | 'LINE_REJECT'
  | 'BULK_APPROVE_ALL' | 'BULK_REJECT';

export type AuditEntity = 'ISSUE' | 'RETURN';

export type AuditRow = {
  audit_id: number;
  entity: AuditEntity;
  header_id: number;
  line_id?: number | null;
  action: AuditAction;
  reason?: string | null;
  note?: string | null;
  actor?: string | null;
  at_time: string;
};

export async function insertAudit(row: Omit<AuditRow, 'audit_id'|'at_time'>) {
  const db = await connectDb();
  try {
    await db.execute(
      `INSERT INTO inv_request_audit(entity, header_id, line_id, action, reason, note, actor, at_time)
       VALUES(?,?,?,?,?,?,?, CURRENT TIMESTAMP)`,
      [row.entity, row.header_id, row.line_id ?? null, row.action, row.reason ?? null, row.note ?? null, row.actor ?? null]
    );
  } finally {
    await db.close();
  }
}

export async function listAudit(entity: AuditEntity, header_id: number) {
  const db = await connectDb();
  try {
    const rows = await db.query<AuditRow>(
      `SELECT audit_id, entity, header_id, line_id, action, reason, note, actor, CAST(at_time AS VARCHAR(50)) AS at_time
       FROM inv_request_audit
       WHERE entity=? AND header_id=?
       ORDER BY audit_id DESC`,
      [entity, header_id]
    );
    return rows;
  } finally {
    await db.close();
  }
}
