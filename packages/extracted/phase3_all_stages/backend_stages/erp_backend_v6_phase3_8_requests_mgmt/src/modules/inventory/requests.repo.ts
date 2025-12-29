import { connectDb } from '../../shared/db/odbc.js';
import { badRequest } from '../../shared/errors.js';

const T = {
  issue_h: 'DBA.sc_debit_header_request',
  issue_d: 'DBA.sc_debit_detail_request',
  ret_h: 'DBA.sc_ret_request_header',
  ret_d: 'DBA.sc_ret_request_detail'
};

export type RequestStatus = 0 | 1 | 2; // 0=pending, 1=approved, 2=rejected

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
