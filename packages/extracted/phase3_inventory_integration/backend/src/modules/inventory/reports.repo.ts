import { connectDb } from '../../shared/db/odbc.js';
import { badRequest } from '../../shared/errors.js';

const T = {
  lost: 'DBA.sc_lost_sales',
  balance: 'DBA.sc_balance',
  item: 'DBA.inv_item',
  store: 'DBA.store_data',
  debit_h: 'DBA.sc_debit_header',
  debit_d: 'DBA.sc_debit_detail',
  credit_h: 'DBA.sc_credit_header',
  credit_d: 'DBA.sc_credit_detail'
};

export async function listLostSales(limit = 200) {
  const db = await connectDb();
  try {
    return await db.query<any>(
      `SELECT TOP ${Number(limit)} * FROM ${T.lost} ORDER BY entry_date DESC`
    );
  } finally { await db.close(); }
}

export async function listBalances(limit = 200) {
  const db = await connectDb();
  try {
    return await db.query<any>(
      `SELECT TOP ${Number(limit)} * FROM ${T.balance}`
    );
  } finally { await db.close(); }
}

export async function getItemCard(store_id: number, item_id: string, limit = 200) {
  if (!store_id) throw badRequest('store_id required');
  if (!item_id) throw badRequest('item_id required');

  const db = await connectDb();
  try {
    // NOTE: schema locked. We produce a simple "card" from posted debit/credit details.
    const debits = await db.query<any>(
      `SELECT TOP ${Number(limit)}
         'ISSUE' AS trx_type,
         h.debit_date AS trx_date,
         h.debit_header AS doc_no,
         d.item_id,
         d.qty AS qty_out,
         0 AS qty_in,
         d.price,
         d.notes
       FROM ${T.debit_d} d
       JOIN ${T.debit_h} h ON h.debit_header = d.debit_header
       WHERE h.store_id=? AND d.item_id=?
       ORDER BY h.debit_date DESC`,
      [store_id, item_id]
    );

    const credits = await db.query<any>(
      `SELECT TOP ${Number(limit)}
         'RETURN' AS trx_type,
         h.credit_date AS trx_date,
         h.credit_header AS doc_no,
         d.item_id,
         0 AS qty_out,
         d.qty AS qty_in,
         d.price,
         d.notes
       FROM ${T.credit_d} d
       JOIN ${T.credit_h} h ON h.credit_header = d.credit_header
       WHERE h.store_id=? AND d.item_id=?
       ORDER BY h.credit_date DESC`,
      [store_id, item_id]
    );

    const combined = [...debits, ...credits].sort((a,b) => {
      const da = new Date(a.trx_date).getTime();
      const dbt = new Date(b.trx_date).getTime();
      return dbt - da;
    }).slice(0, limit);

    return combined;
  } finally { await db.close(); }
}

export async function getPostedIssue(debit_header: number) {
  if (!debit_header) throw badRequest('debit_header required');
  const db = await connectDb();
  try {
    const header = await db.query<any>(`SELECT * FROM ${T.debit_h} WHERE debit_header=?`, [debit_header]);
    const details = await db.query<any>(`SELECT * FROM ${T.debit_d} WHERE debit_header=? ORDER BY debit_detail`, [debit_header]);
    return { header: header?.[0] ?? null, details };
  } finally { await db.close(); }
}

export async function getPostedReturn(credit_header: number) {
  if (!credit_header) throw badRequest('credit_header required');
  const db = await connectDb();
  try {
    const header = await db.query<any>(`SELECT * FROM ${T.credit_h} WHERE credit_header=?`, [credit_header]);
    const details = await db.query<any>(`SELECT * FROM ${T.credit_d} WHERE credit_header=? ORDER BY credit_detail`, [credit_header]);
    return { header: header?.[0] ?? null, details };
  } finally { await db.close(); }
}
