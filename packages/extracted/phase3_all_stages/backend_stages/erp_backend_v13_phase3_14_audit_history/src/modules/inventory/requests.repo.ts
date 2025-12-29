import { connectDb } from '../../shared/db/odbc.js';
import { badRequest } from '../../shared/errors.js';

const T = {
  issue_h: 'DBA.sc_debit_header_request',
  issue_d: 'DBA.sc_debit_detail_request',
  ret_h: 'DBA.sc_ret_request_header',
  ret_d: 'DBA.sc_ret_request_detail'
};

export type RequestStatus = 0 | 1 | 2; // 0=pending, 1=approved, 2=rejected
export type LineStatus = 0 | 1 | 2; // 0=pending, 1=approved, 2=rejected
export type RejectReason = 'lost_of_sales';

function buildRejectNote(reason: RejectReason, note?: string) {
  const base = `REFUSED_REASON:${reason}`;
  const extra = note ? `;NOTE:${note}` : '';
  return base + extra;
}

type FilterArgs = {
  store_id?: number;
  joborderid?: string;
  status?: RequestStatus;
  post_flag?: 'y'|'n';
  from?: string; // YYYY-MM-DD
  to?: string;   // YYYY-MM-DD
  limit?: number;
};

function buildWhere(filters: FilterArgs, dateCol: string) {
  const where: string[] = [];
  const params: any[] = [];

  if (filters.store_id) { where.push('store_id=?'); params.push(filters.store_id); }
  if (filters.joborderid) { where.push('joborderid=?'); params.push(filters.joborderid); }
  if (typeof filters.status !== 'undefined') { where.push('status=?'); params.push(filters.status); }
  if (filters.post_flag) { where.push('post_flag=?'); params.push(filters.post_flag); }

  if (filters.from) { where.push(`${dateCol} >= ?`); params.push(new Date(filters.from)); }
  if (filters.to) {
    const d = new Date(filters.to);
    d.setDate(d.getDate() + 1);
    where.push(`${dateCol} < ?`); params.push(d);
  }

  const clause = where.length ? ('WHERE ' + where.join(' AND ')) : '';
  return { clause, params };
}

export async function listIssueRequests(limit = 200) {
  const db = await connectDb();
  try {
    return await db.query<any>(
      `SELECT TOP ${Number(limit)} * FROM ${T.issue_h} ORDER BY debit_header DESC`
    );
  } finally { await db.close(); }
}

export async function listReturnRequests(limit = 200) {
  const db = await connectDb();
  try {
    return await db.query<any>(
      `SELECT TOP ${Number(limit)} * FROM ${T.ret_h} ORDER BY credit_header DESC`
    );
  } finally { await db.close(); }
}

export async function listIssueRequestsFiltered(filters: FilterArgs) {
  const db = await connectDb();
  try {
    const lim = Number(filters.limit ?? 200);
    const { clause, params } = buildWhere(filters, 'debit_date');
    return await db.query<any>(
      `SELECT TOP ${lim} * FROM ${T.issue_h} ${clause} ORDER BY debit_header DESC`,
      params
    );
  } finally { await db.close(); }
}

export async function listReturnRequestsFiltered(filters: FilterArgs) {
  const db = await connectDb();
  try {
    const lim = Number(filters.limit ?? 200);
    const { clause, params } = buildWhere(filters, 'credit_date');
    return await db.query<any>(
      `SELECT TOP ${lim} * FROM ${T.ret_h} ${clause} ORDER BY credit_header DESC`,
      params
    );
  } finally { await db.close(); }
}

export async function getIssueDetails(debit_header: number) {
  if (!debit_header) throw badRequest('debit_header required');
  const db = await connectDb();
  try {
    return await db.query<any>(
      `SELECT * FROM ${T.issue_d} WHERE debit_header=? ORDER BY debit_detail ASC`,
      [debit_header]
    );
  } finally { await db.close(); }
}

export async function getReturnDetails(credit_header: number) {
  if (!credit_header) throw badRequest('credit_header required');
  const db = await connectDb();
  try {
    return await db.query<any>(
      `SELECT * FROM ${T.ret_d} WHERE credit_header=? ORDER BY credit_detail ASC`,
      [credit_header]
    );
  } finally { await db.close(); }
}

export async function setIssueStatus(debit_header: number, status: RequestStatus, post_flag?: 'y'|'n') {
  if (!debit_header) throw badRequest('debit_header required');
  const db = await connectDb();
  try {
    const hasPost = typeof post_flag !== 'undefined';
    const sql = hasPost
      ? `UPDATE ${T.issue_h} SET status=?, post_flag=? WHERE debit_header=?`
      : `UPDATE ${T.issue_h} SET status=? WHERE debit_header=?`;
    const params = hasPost ? [status, post_flag, debit_header] : [status, debit_header];
    const affected = await db.exec(sql, params);
    return { affected };
  } finally { await db.close(); }
}

export async function setReturnStatus(credit_header: number, status: RequestStatus, post_flag?: 'y'|'n') {
  if (!credit_header) throw badRequest('credit_header required');
  const db = await connectDb();
  try {
    const hasPost = typeof post_flag !== 'undefined';
    const sql = hasPost
      ? `UPDATE ${T.ret_h} SET status=?, post_flag=? WHERE credit_header=?`
      : `UPDATE ${T.ret_h} SET status=? WHERE credit_header=?`;
    const params = hasPost ? [status, post_flag, credit_header] : [status, credit_header];
    const affected = await db.exec(sql, params);
    return { affected };
  } finally { await db.close(); }
}

export async function setIssueLineStatus(debit_header: number, debit_detail: number, status: LineStatus, reason?: RejectReason, note?: string) {
  if (!debit_header) throw badRequest('debit_header required');
  if (!debit_detail) throw badRequest('debit_detail required');
  const db = await connectDb();
  try {
    const hasReason = status === 2 && !!reason;
    const affected = await db.exec(
      `UPDATE ${T.issue_d}
       SET status=?,
           notes = CASE
             WHEN ?=1 THEN
               CASE WHEN notes IS NULL OR notes='' THEN ? ELSE (notes || ' | ' || ?) END
             ELSE notes
           END
       WHERE debit_header=? AND debit_detail=?`,
      [
        status,
        hasReason ? 1 : 0,
        hasReason ? buildRejectNote(reason!, note) : '',
        hasReason ? buildRejectNote(reason!, note) : '',
        debit_header,
        debit_detail
      ]
    );
    return { affected };
  } finally { await db.close(); }
}

export async function setReturnLineStatus(credit_header: number, credit_detail: number, status: LineStatus, reason?: RejectReason, note?: string) {
  if (!credit_header) throw badRequest('credit_header required');
  if (!credit_detail) throw badRequest('credit_detail required');
  const db = await connectDb();
  try {
    const hasReason = status === 2 && !!reason;
    const affected = await db.exec(
      `UPDATE ${T.ret_d}
       SET status=?,
           notes = CASE
             WHEN ?=1 THEN
               CASE WHEN notes IS NULL OR notes='' THEN ? ELSE (notes || ' | ' || ?) END
             ELSE notes
           END
       WHERE credit_header=? AND credit_detail=?`,
      [
        status,
        hasReason ? 1 : 0,
        hasReason ? buildRejectNote(reason!, note) : '',
        hasReason ? buildRejectNote(reason!, note) : '',
        credit_header,
        credit_detail
      ]
    );
    return { affected };
  } finally { await db.close(); }
}

export async function approveAllIssueLines(debit_header: number) {
  if (!debit_header) throw badRequest('debit_header required');
  const db = await connectDb();
  try {
    const affected = await db.exec(
      `UPDATE ${T.issue_d} SET status=1 WHERE debit_header=? AND COALESCE(status,0)<>2`,
      [debit_header]
    );
    return { affected };
  } finally { await db.close(); }
}

export async function approveAllReturnLines(credit_header: number) {
  if (!credit_header) throw badRequest('credit_header required');
  const db = await connectDb();
  try {
    const affected = await db.exec(
      `UPDATE ${T.ret_d} SET status=1 WHERE credit_header=? AND COALESCE(status,0)<>2`,
      [credit_header]
    );
    return { affected };
  } finally { await db.close(); }
}

export async function rejectIssueLines(debit_header: number, debit_details: number[], reason: RejectReason, note?: string) {
  if (!debit_header) throw badRequest('debit_header required');
  if (!Array.isArray(debit_details) || !debit_details.length) throw badRequest('line_ids required');
  let affected = 0;
  for (const d of debit_details) {
    const r = await setIssueLineStatus(debit_header, Number(d), 2, reason, note);
    affected += Number(r.affected ?? 0);
  }
  return { affected };
}

export async function rejectReturnLines(credit_header: number, credit_details: number[], reason: RejectReason, note?: string) {
  if (!credit_header) throw badRequest('credit_header required');
  if (!Array.isArray(credit_details) || !credit_details.length) throw badRequest('line_ids required');
  let affected = 0;
  for (const d of credit_details) {
    const r = await setReturnLineStatus(credit_header, Number(d), 2, reason, note);
    affected += Number(r.affected ?? 0);
  }
  return { affected };
}

export type LineStats = { total: number; approved: number; rejected: number; pending: number };

async function getLineStats(table: string, headerCol: string, headerId: number): Promise<LineStats> {
  const db = await connectDb();
  try {
    const rows = await db.query<any>(
      `SELECT
         COUNT(*) AS total,
         SUM(CASE WHEN COALESCE(status,0)=1 THEN 1 ELSE 0 END) AS approved,
         SUM(CASE WHEN COALESCE(status,0)=2 THEN 1 ELSE 0 END) AS rejected,
         SUM(CASE WHEN COALESCE(status,0)=0 THEN 1 ELSE 0 END) AS pending
       FROM ${table}
       WHERE ${headerCol}=?`,
      [headerId]
    );
    const r = rows?.[0] || {};
    return {
      total: Number(r.total ?? 0),
      approved: Number(r.approved ?? 0),
      rejected: Number(r.rejected ?? 0),
      pending: Number(r.pending ?? 0)
    };
  } finally { await db.close(); }
}

export async function getIssueLineStats(debit_header: number): Promise<LineStats> {
  if (!debit_header) throw badRequest('debit_header required');
  return await getLineStats(T.issue_d, 'debit_header', debit_header);
}

export async function getReturnLineStats(credit_header: number): Promise<LineStats> {
  if (!credit_header) throw badRequest('credit_header required');
  return await getLineStats(T.ret_d, 'credit_header', credit_header);
}

export async function syncIssueHeaderStatusFromLines(debit_header: number) {
  const stats = await getIssueLineStats(debit_header);
  let newStatus: RequestStatus = 0;
  if (stats.total > 0 && stats.rejected === stats.total) newStatus = 2;
  else if (stats.pending === 0 && stats.approved > 0) newStatus = 1;
  else newStatus = 0;

  await setIssueStatus(debit_header, newStatus);
  return { status: newStatus, stats };
}

export async function syncReturnHeaderStatusFromLines(credit_header: number) {
  const stats = await getReturnLineStats(credit_header);
  let newStatus: RequestStatus = 0;
  if (stats.total > 0 && stats.rejected === stats.total) newStatus = 2;
  else if (stats.pending === 0 && stats.approved > 0) newStatus = 1;
  else newStatus = 0;

  await setReturnStatus(credit_header, newStatus);
  return { status: newStatus, stats };
}
