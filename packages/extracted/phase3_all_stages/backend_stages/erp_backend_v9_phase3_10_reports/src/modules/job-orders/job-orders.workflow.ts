import { connectDb } from '../../shared/db/odbc.js';
import { badRequest } from '../../shared/errors.js';

const T_JOB = 'DBA.ws_JobOrder';

type Transition = { from: string[]; to: string; updates: string[]; };

// We keep statuses as-is (strings) because locked DB may contain Arabic/legacy codes.
// This is "soft workflow": validate transitions if current status is present, else allow.
const TRANSITIONS: Record<string, Transition> = {
  start:   { from: ['NEW','new','0',''], to: 'IN_PROGRESS', updates: ['StartTime = COALESCE(StartTime, CURRENT TIMESTAMP)'] },
  finish:  { from: ['IN_PROGRESS','in_progress'], to: 'DONE', updates: ['EndTime = COALESCE(EndTime, CURRENT TIMESTAMP)'] },
  cancel:  { from: ['NEW','IN_PROGRESS','DONE',''], to: 'CANCELLED', updates: ['DeleteFlag = 1', 'DeleteTime = CURRENT TIMESTAMP'] },
  control_ok: { from: ['DONE','IN_PROGRESS','NEW',''], to: 'CONTROL_OK', updates: ['control_ok = 1', 'control_date = CURRENT TIMESTAMP'] },
  stock_approve: { from: ['DONE','CONTROL_OK',''], to: 'STOCK_APPROVED', updates: ['stock_approved = 1'] }
};

export async function getJob(jobOrderId: string) {
  const db = await connectDb();
  try {
    const rows = await db.query<any>(`SELECT TOP 1 * FROM ${T_JOB} WHERE JobOrderID = ?`, [jobOrderId]);
    return rows[0] ?? null;
  } finally { await db.close(); }
}

function normalizeStatus(v: any): string {
  if (v == null) return '';
  return String(v).trim();
}

export async function applyTransition(jobOrderId: string, action: keyof typeof TRANSITIONS) {
  if (!jobOrderId) throw badRequest('JobOrderID is required');
  const tr = TRANSITIONS[action];
  if (!tr) throw badRequest('Unknown action');

  const current = await getJob(jobOrderId);
  if (!current) throw badRequest('Job order not found');

  const cur = normalizeStatus(current.OrderStatus);

  // If current status is not in known set, we allow but still set to target to avoid blocking legacy data.
  const allow = tr.from.includes(cur) || !cur;

  if (!allow) {
    throw badRequest(`Invalid transition from "${cur}" using action "${action}"`);
  }

  const sets = ['OrderStatus = ?'].concat(tr.updates).join(', ');
  const db = await connectDb();
  try {
    const affected = await db.exec(
      `UPDATE ${T_JOB} SET ${sets} WHERE JobOrderID = ?`,
      [tr.to, jobOrderId]
    );
    return affected;
  } finally { await db.close(); }
}
