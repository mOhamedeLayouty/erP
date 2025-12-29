import { connectDb } from '../../shared/db/odbc.js';
import { badRequest } from '../../shared/errors.js';

const T = {
  // requests
  issue_h_req: 'DBA.sc_debit_header_request',
  issue_d_req: 'DBA.sc_debit_detail_request',
  ret_h_req: 'DBA.sc_ret_request_header',
  ret_d_req: 'DBA.sc_ret_request_detail',

  // posted docs
  issue_h: 'DBA.sc_debit_header',
  issue_d: 'DBA.sc_debit_detail',
  ret_h: 'DBA.sc_credit_header',
  ret_d: 'DBA.sc_credit_detail',

  // stock & lost sales
  balance: 'DBA.sc_balance',
  lost_sales: 'DBA.sc_lost_sales'
};

async function nextId(db: any, table: string, idCol: string, sc: number, loc: number) {
  const rows = await db.query(
    `SELECT COALESCE(MAX(${idCol}), 0) + 1 AS next_id FROM ${table} WHERE service_center=? AND location_id=?`,
    [sc, loc]
  );
  return Number((rows?.[0] as any)?.next_id ?? 1);
}

async function nextDetailId(db: any, table: string, idCol: string, headerCol: string, headerId: number, sc: number, loc: number) {
  const rows = await db.query(
    `SELECT COALESCE(MAX(${idCol}), 0) + 1 AS next_id FROM ${table} WHERE ${headerCol}=? AND service_center=? AND location_id=?`,
    [headerId, sc, loc]
  );
  return Number((rows?.[0] as any)?.next_id ?? 1);
}

async function getOnHand(db: any, store_id: number, item_id: string, sc: number, loc: number) {
  const rows = await db.query(
    `SELECT balance FROM ${T.balance} WHERE store_id=? AND item_id=? AND service_center=? AND location_id=?`,
    [store_id, item_id, sc, loc]
  );
  const bal = rows?.[0]?.balance;
  return typeof bal === 'number' ? bal : Number(bal ?? 0);
}

async function insertLostSales(
  db: any,
  request_no: string,
  item_id: string,
  required: number,
  on_hand: number,
  price: number | null,
  notes: string | null,
  user: string,
  sc: number,
  loc: number,
  voucherId?: string | null
) {
  await db.exec(
    `INSERT INTO ${T.lost_sales}
     (request_no, item_id, required, on_hand, seriousness, notes, "user", date_required, time_required, price, service_center, location_id, VoucherID)
     VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)`,
    [
      request_no,
      item_id,
      required,
      on_hand,
      'Y',
      notes ?? null,
      user,
      new Date(),
      new Date(),
      price ?? null,
      sc,
      loc,
      voucherId ?? null
    ]
  );
}

export async function postIssueRequest(debit_header_request: number, actorUser: string) {
  if (!debit_header_request) throw badRequest('debit_header_request required');

  const db = await connectDb();
  const sc = 1;
  const loc = 1;

  try {
    const hdrRows = await db.query<any>(
      `SELECT * FROM ${T.issue_h_req} WHERE debit_header=? AND service_center=? AND location_id=?`,
      [debit_header_request, sc, loc]
    );
    const hdr = hdrRows?.[0];
    if (!hdr) throw badRequest('Issue request header not found');

    if (String(hdr.post_flag ?? '').toLowerCase() === 'y') {
      return { already_posted: true, debit_header: null, posted_lines: 0, rejected_lines: 0 };
    }

    const det = await db.query<any>(
      `SELECT * FROM ${T.issue_d_req} WHERE debit_header=? AND service_center=? AND location_id=? ORDER BY debit_detail ASC`,
      [debit_header_request, sc, loc]
    );

    const rejected = det.filter((d: any) => Number(d.status ?? 0) === 2);
    const accepted = det.filter((d: any) => Number(d.status ?? 0) !== 2 && Number(d.qty ?? 0) > 0 && String(d.item_id ?? '').length);

    if (!accepted.length) throw badRequest('No accepted lines to post');

    const newDebitHeader = await nextId(db, T.issue_h, 'debit_header', sc, loc);

    await db.exec(
      `INSERT INTO ${T.issue_h} (debit_header, store_id, notes, debit_date, status, joborderid, post_flag, service_center, location_id, trans_time)
       VALUES (?,?,?,?,?,?,?,?,?,?)`,
      [
        newDebitHeader,
        Number(hdr.store_id),
        (hdr.notes ?? null),
        hdr.debit_date ?? new Date(),
        0,
        hdr.joborderid ?? null,
        'N',
        sc,
        loc,
        new Date()
      ]
    );

    let posted_lines = 0;
    for (const line of accepted) {
      const debit_detail = await nextDetailId(db, T.issue_d, 'debit_detail', 'debit_header', newDebitHeader, sc, loc);
      await db.exec(
        `INSERT INTO ${T.issue_d} (debit_detail, debit_header, item_id, qty, price, notes, status, service_center, location_id)
         VALUES (?,?,?,?,?,?,?,?,?)`,
        [
          debit_detail,
          newDebitHeader,
          line.item_id,
          Number(line.qty),
          (line.price ?? null),
          (line.notes ?? null),
          0,
          sc,
          loc
        ]
      );
      posted_lines += 1;
    }

    // rejected -> lost sales
    let rejected_lines = 0;
    for (const line of rejected) {
      const item_id = String(line.item_id ?? '');
      if (!item_id) continue;
      const required = Number(line.qty ?? 0);
      const on_hand = await getOnHand(db, Number(hdr.store_id), item_id, sc, loc);
      const note = String(line.notes ?? '') || 'REFUSED_REASON:lost_of_sales';
      await insertLostSales(
        db,
        String(debit_header_request).slice(0, 10),
        item_id,
        required,
        on_hand,
        line.price ?? null,
        note,
        actorUser,
        sc,
        loc,
        String(hdr.joborderid ?? '') || null
      );
      rejected_lines += 1;
    }

    await db.exec(
      `UPDATE ${T.issue_h_req}
       SET post_flag='y', status=1,
           notes = CASE
             WHEN notes IS NULL OR notes='' THEN ?
             ELSE (notes || ' | ' || ?)
           END
       WHERE debit_header=? AND service_center=? AND location_id=?`,
      [
        `POSTED_TO:sc_debit_header=${newDebitHeader}`,
        `POSTED_TO:sc_debit_header=${newDebitHeader}`,
        debit_header_request,
        sc,
        loc
      ]
    );

    return { debit_header: newDebitHeader, posted_lines, rejected_lines };
  } finally {
    await db.close();
  }
}

export async function postReturnRequest(credit_header_request: number, actorUser: string) {
  if (!credit_header_request) throw badRequest('credit_header_request required');

  const db = await connectDb();
  const sc = 1;
  const loc = 1;

  try {
    const hdrRows = await db.query<any>(
      `SELECT * FROM ${T.ret_h_req} WHERE credit_header=? AND service_center=? AND location_id=?`,
      [credit_header_request, sc, loc]
    );
    const hdr = hdrRows?.[0];
    if (!hdr) throw badRequest('Return request header not found');

    if (String(hdr.post_flag ?? '').toLowerCase() === 'y') {
      return { already_posted: true, credit_header: null, posted_lines: 0, rejected_lines: 0 };
    }

    const det = await db.query<any>(
      `SELECT * FROM ${T.ret_d_req} WHERE credit_header=? AND service_center=? AND location_id=? ORDER BY credit_detail ASC`,
      [credit_header_request, sc, loc]
    );

    const rejected = det.filter((d: any) => Number(d.status ?? 0) === 2);
    const accepted = det.filter((d: any) => Number(d.status ?? 0) !== 2 && Number(d.qty ?? 0) > 0 && String(d.item_id ?? '').length);

    if (!accepted.length) throw badRequest('No accepted lines to post');

    const newCreditHeader = await nextId(db, T.ret_h, 'credit_header', sc, loc);

    await db.exec(
      `INSERT INTO ${T.ret_h} (credit_header, store_id, credit_date, notes, post_flag, service_center, location_id)
       VALUES (?,?,?,?,?,?,?)`,
      [
        newCreditHeader,
        Number(hdr.store_id),
        hdr.credit_date ?? new Date(),
        (hdr.notes ?? null),
        'N',
        sc,
        loc
      ]
    );

    let posted_lines = 0;
    for (const line of accepted) {
      const credit_detail = await nextDetailId(db, T.ret_d, 'credit_detail', 'credit_header', newCreditHeader, sc, loc);
      await db.exec(
        `INSERT INTO ${T.ret_d} (credit_detail, credit_header, item_id, qty, price, notes, service_center, location_id)
         VALUES (?,?,?,?,?,?,?,?)`,
        [
          credit_detail,
          newCreditHeader,
          line.item_id,
          Number(line.qty),
          (line.price ?? null),
          (line.notes ?? null),
          sc,
          loc
        ]
      );
      posted_lines += 1;
    }

    // rejected -> lost sales (same rule for now)
    let rejected_lines = 0;
    for (const line of rejected) {
      const item_id = String(line.item_id ?? '');
      if (!item_id) continue;
      const required = Number(line.qty ?? 0);
      const on_hand = await getOnHand(db, Number(hdr.store_id), item_id, sc, loc);
      const note = String(line.notes ?? '') || 'REFUSED_REASON:lost_of_sales';
      await insertLostSales(
        db,
        String(credit_header_request).slice(0, 10),
        item_id,
        required,
        on_hand,
        line.price ?? null,
        note,
        actorUser,
        sc,
        loc,
        String(hdr.joborderid ?? '') || null
      );
      rejected_lines += 1;
    }

    await db.exec(
      `UPDATE ${T.ret_h_req}
       SET post_flag='y', status=1,
           notes = CASE
             WHEN notes IS NULL OR notes='' THEN ?
             ELSE (notes || ' | ' || ?)
           END
       WHERE credit_header=? AND service_center=? AND location_id=?`,
      [
        `POSTED_TO:sc_credit_header=${newCreditHeader}`,
        `POSTED_TO:sc_credit_header=${newCreditHeader}`,
        credit_header_request,
        sc,
        loc
      ]
    );

    return { credit_header: newCreditHeader, posted_lines, rejected_lines };
  } finally {
    await db.close();
  }
}
