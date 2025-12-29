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

// line-level updates
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
