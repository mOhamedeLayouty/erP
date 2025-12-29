import { connectDb, type Db } from '../../shared/db/odbc.js';

type IssueReturnLine = {
  item_id: string;
  qty: number;
  price?: number;
  notes?: string;
};

type CreateRequestArgs = {
  joborderid: string;
  store_id: number;
  notes?: string;
  user_name?: string;
  service_center?: number;
  location_id?: number;
  lines: IssueReturnLine[];
};

const T = {
  debit_h: 'DBA.sc_debit_header_request',
  debit_d: 'DBA.sc_debit_detail_request',
  credit_h: 'DBA.sc_ret_request_header',
  credit_d: 'DBA.sc_ret_request_detail'
};

async function nextHeaderId(db: Db, table: string, idCol: string, sc: number, loc: number) {
  const rows = await db.query<{ next_id: number }>(
    `SELECT COALESCE(MAX(${idCol}), 0) + 1 AS next_id FROM ${table} WHERE service_center=? AND location_id=?`,
    [sc, loc]
  );
  return Number((rows?.[0] as any)?.next_id ?? 1);
}

async function nextDetailId(db: Db, table: string, idCol: string, headerCol: string, headerId: number, sc: number, loc: number) {
  const rows = await db.query<{ next_id: number }>(
    `SELECT COALESCE(MAX(${idCol}), 0) + 1 AS next_id FROM ${table} WHERE ${headerCol}=? AND service_center=? AND location_id=?`,
    [headerId, sc, loc]
  );
  return Number((rows?.[0] as any)?.next_id ?? 1);
}

export async function createIssueRequest(args: CreateRequestArgs) {
  const db = await connectDb();
  const sc = args.service_center ?? 1;
  const loc = args.location_id ?? 1;

  try {
    const debit_header = await nextHeaderId(db, T.debit_h, 'debit_header', sc, loc);

    // header (minimal locked columns)
    await db.exec(
      `INSERT INTO ${T.debit_h} (debit_header, store_id, notes, debit_date, status, joborderid, post_flag, request_created, service_center, location_id)
       VALUES (?,?,?,?,?,?,?,?,?,?)`,
      [
        debit_header,
        args.store_id,
        args.notes ?? null,
        new Date(),
        0,
        args.joborderid,
        'n',
        'y',
        sc,
        loc
      ]
    );

    // details
    let affected = 0;
    for (const line of args.lines) {
      const debit_detail = await nextDetailId(db, T.debit_d, 'debit_detail', 'debit_header', debit_header, sc, loc);
      affected += await db.exec(
        `INSERT INTO ${T.debit_d} (debit_detail, debit_header, item_id, qty, price, notes, service_center, location_id)
         VALUES (?,?,?,?,?,?,?,?)`,
        [
          debit_detail,
          debit_header,
          line.item_id,
          line.qty,
          line.price ?? null,
          line.notes ?? null,
          sc,
          loc
        ]
      );
    }

    return { debit_header, lines_affected: affected };
  } finally {
    await db.close();
  }
}

export async function createReturnRequest(args: CreateRequestArgs) {
  const db = await connectDb();
  const sc = args.service_center ?? 1;
  const loc = args.location_id ?? 1;

  try {
    const credit_header = await nextHeaderId(db, T.credit_h, 'credit_header', sc, loc);

    await db.exec(
      `INSERT INTO ${T.credit_h} (credit_header, store_id, credit_date, notes, joborderid, user_name, post_flag, status, service_center, location_id)
       VALUES (?,?,?,?,?,?,?,?,?,?)`,
      [
        credit_header,
        args.store_id,
        new Date(),
        args.notes ?? null,
        args.joborderid,
        args.user_name ?? 'SYSTEM',
        'n',
        0,
        sc,
        loc
      ]
    );

    let affected = 0;
    for (const line of args.lines) {
      const credit_detail = await nextDetailId(db, T.credit_d, 'credit_detail', 'credit_header', credit_header, sc, loc);
      affected += await db.exec(
        `INSERT INTO ${T.credit_d} (credit_detail, credit_header, item_id, qty, price, notes, service_center, location_id)
         VALUES (?,?,?,?,?,?,?,?)`,
        [
          credit_detail,
          credit_header,
          line.item_id,
          line.qty,
          line.price ?? null,
          line.notes ?? null,
          sc,
          loc
        ]
      );
    }

    return { credit_header, lines_affected: affected };
  } finally {
    await db.close();
  }
}
