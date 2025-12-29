import { applyPagination, connectDb, type Db } from '../../shared/db/odbc.js';
import { INVOICING_TABLES } from './invoicing.tables.js';

function colsCsv(cols: readonly string[]) {
  return cols.join(', ');
}

export async function listInvoices(limit = 200, offset = 0) {
  const db = await connectDb();
  try {
    const t = INVOICING_TABLES.header.table;
    const cols = colsCsv(INVOICING_TABLES.header.columns);
    const sql = applyPagination(
      `SELECT ${cols} FROM ${t} ORDER BY InvoiceDate DESC, InvoiceID DESC`,
      { limit, offset }
    );
    return await db.query(sql);
  } finally { await db.close(); }
}

export async function listInvoiceDetails(invoiceId: string, limit = 500, offset = 0) {
  const db = await connectDb();
  try {
    const t = INVOICING_TABLES.detail.table;
    const cols = colsCsv(INVOICING_TABLES.detail.columns);
    const sql = applyPagination(
      `SELECT ${cols} FROM ${t} WHERE InvoiceID = ?`,
      { limit, offset }
    );
    return await db.query(sql, [invoiceId]);
  } finally { await db.close(); }
}

export async function createInvoiceHeader(payload: Record<string, any>, db?: Db) {
  const localDb = db ?? await connectDb();
  try {
    const t = INVOICING_TABLES.header.table;
    const allowed = INVOICING_TABLES.header.columns;
    const cols = allowed.filter(c => payload[c] !== undefined);
    const vals = cols.map(c => payload[c]);
    const placeholders = cols.map(_ => '?').join(',');
    if (!cols.length) return 0;
    return await localDb.exec(`INSERT INTO ${t} (${cols.join(',')}) VALUES (${placeholders})`, vals);
  } finally {
    if (!db) await localDb.close();
  }
}

export async function createInvoiceDetail(payload: Record<string, any>, db?: Db) {
  const localDb = db ?? await connectDb();
  try {
    const t = INVOICING_TABLES.detail.table;
    const allowed = INVOICING_TABLES.detail.columns;
    const cols = allowed.filter(c => payload[c] !== undefined);
    const vals = cols.map(c => payload[c]);
    const placeholders = cols.map(_ => '?').join(',');
    if (!cols.length) return 0;
    return await localDb.exec(`INSERT INTO ${t} (${cols.join(',')}) VALUES (${placeholders})`, vals);
  } finally {
    if (!db) await localDb.close();
  }
}
