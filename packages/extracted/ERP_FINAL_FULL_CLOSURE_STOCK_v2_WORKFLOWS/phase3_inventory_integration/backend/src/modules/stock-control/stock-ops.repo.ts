import { connectDb } from '../../shared/db/odbc.js';
import { AppError } from '../../shared/errors.js';

function nowDateTime() {
  const d = new Date();
  // SQL Anywhere accepts ISO-ish strings; keep seconds.
  return d.toISOString().slice(0, 19).replace('T', ' ');
}

async function begin(db: any) { await db.exec('BEGIN TRANSACTION'); }
async function commit(db: any) { await db.exec('COMMIT'); }
async function rollback(db: any) { try { await db.exec('ROLLBACK'); } catch { /* ignore */ } }

async function lastIdentity(db: any): Promise<number> {
  // SQL Anywhere: @@identity
  const r = await db.query<{ id: number }>('SELECT @@identity AS id');
  const id = Number(r?.[0]?.id ?? 0);
  if (!id) throw new AppError('DB_IDENTITY', 500, 'Failed to read @@identity after insert');
  return id;
}

export type POLine = {
  item_id: string;
  qty: number;
  price?: number;
  exp?: string | null;
  notes?: string | null;
  service_center?: string | null;
  location_id?: any;
};

export type POHeaderInput = {
  vend_code: string;
  store_id: string;
  manual_number?: string | null;
  order_date?: string | null;
  exp_date?: string | null;
  notes?: string | null;
  shipment_method?: string | null;
  order_type?: string | null;
  order_no?: string | null;
  service_center?: string | null;
  location_id?: any;
  status_id?: any;
  order_by?: string | null;
  entry_user?: string | null;
  trans_location?: any;
};

export async function createPurchaseOrder(input: POHeaderInput, lines: POLine[]) {
  if (!input?.vend_code) throw new AppError('VALIDATION', 400, 'vend_code is required');
  if (!input?.store_id) throw new AppError('VALIDATION', 400, 'store_id is required');
  if (!Array.isArray(lines) || lines.length === 0) throw new AppError('VALIDATION', 400, 'lines is required');

  const db = await connectDb();
  try {
    await begin(db);

    const orderDate = input.order_date ?? nowDateTime();
    const entryDate = nowDateTime();

    // Insert header (omit buy_header to use identity)
    await db.exec(
      `INSERT INTO DBA.sc_buy_order_header
        (vend_code, store_id, manual_number, order_date, exp_date, notes, shipment_method, order_type, order_no,
         service_center, approved, location_id, status_id, order_by, entry_user, entry_date, trans_location)
       VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)`,
      [
        input.vend_code,
        input.store_id,
        input.manual_number ?? null,
        orderDate,
        input.exp_date ?? null,
        input.notes ?? null,
        input.shipment_method ?? null,
        input.order_type ?? null,
        input.order_no ?? null,
        input.service_center ?? null,
        0,
        input.location_id ?? null,
        input.status_id ?? null,
        input.order_by ?? null,
        input.entry_user ?? null,
        entryDate,
        input.trans_location ?? null,
      ],
    );

    const buy_header = await lastIdentity(db);

    for (const ln of lines) {
      if (!ln.item_id) throw new AppError('VALIDATION', 400, 'line.item_id is required');
      if (ln.qty === undefined || ln.qty === null) throw new AppError('VALIDATION', 400, 'line.qty is required');

      await db.exec(
        `INSERT INTO DBA.sc_buy_order_detail
          (buy_header, item_id, qty, price, exp, notes, service_center, approved, location_id)
         VALUES (?,?,?,?,?,?,?,?,?)`,
        [
          buy_header,
          ln.item_id,
          Number(ln.qty),
          ln.price ?? null,
          ln.exp ?? null,
          ln.notes ?? null,
          ln.service_center ?? input.service_center ?? null,
          0,
          ln.location_id ?? input.location_id ?? null,
        ],
      );
    }

    await commit(db);
    return { ok: true, buy_header };
  } catch (e) {
    await rollback(db);
    throw e;
  } finally {
    await db.close();
  }
}

export async function setPurchaseOrderApproved(buy_header: number, approved: number, approved_by?: string | null) {
  const db = await connectDb();
  try {
    const entryDate = nowDateTime();
    await db.exec(
      `UPDATE DBA.sc_buy_order_header
       SET approved=?, approved_by=?, edit_user=?, edit_date=?
       WHERE buy_header=?`,
      [approved ? 1 : 0, approved_by ?? null, approved_by ?? null, entryDate, buy_header],
    );
    return { ok: true };
  } finally {
    await db.close();
  }
}

export type ReceiptHeaderInput = {
  store_id: string;
  vend_code?: string | null;
  manual_number?: string | null;
  credit_date?: string | null;
  notes?: string | null;
  buy_headr?: number | null; // link to PO header
  service_center?: string | null;
  location_id?: any;
  user_name?: string | null;
  sales_tax?: any;
  trade_tax?: any;
  discount_percent?: any;
  discount_amount?: any;
  addedtax?: any;
  trans_location?: any;
};

export type ReceiptLine = {
  item_id: string;
  qty: number;
  price?: number;
  exp?: string | null;
  notes?: string | null;
  service_center?: string | null;
  location_id?: any;
  official_price?: any;
  discount_percent?: any;
  discount_amount?: any;
  non_discounted?: any;
  item_cost?: any;
};

export async function createReceipt(input: ReceiptHeaderInput, lines: ReceiptLine[]) {
  if (!input?.store_id) throw new AppError('VALIDATION', 400, 'store_id is required');
  if (!Array.isArray(lines) || lines.length === 0) throw new AppError('VALIDATION', 400, 'lines is required');

  const db = await connectDb();
  try {
    await begin(db);
    const creditDate = input.credit_date ?? nowDateTime();
    const transTime = nowDateTime();

    await db.exec(
      `INSERT INTO DBA.sc_credit_header
        (store_id, vend_code, manual_number, credit_date, notes, buy_headr, post_flag,
         trans_time, service_center, location_id, user_name, sales_tax, trade_tax,
         discount_percent, discount_amount, addedtax, trans_location)
       VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)`,
      [
        input.store_id,
        input.vend_code ?? null,
        input.manual_number ?? null,
        creditDate,
        input.notes ?? null,
        input.buy_headr ?? null,
        0,
        transTime,
        input.service_center ?? null,
        input.location_id ?? null,
        input.user_name ?? null,
        input.sales_tax ?? null,
        input.trade_tax ?? null,
        input.discount_percent ?? null,
        input.discount_amount ?? null,
        input.addedtax ?? null,
        input.trans_location ?? null,
      ],
    );

    const credit_header = await lastIdentity(db);

    for (const ln of lines) {
      if (!ln.item_id) throw new AppError('VALIDATION', 400, 'line.item_id is required');
      if (ln.qty === undefined || ln.qty === null) throw new AppError('VALIDATION', 400, 'line.qty is required');

      await db.exec(
        `INSERT INTO DBA.sc_credit_detail
          (credit_header, item_id, qty, price, exp, notes, service_center, location_id,
           official_price, discount_percent, discount_amount, non_discounted, buy_header, item_cost)
         VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)`,
        [
          credit_header,
          ln.item_id,
          Number(ln.qty),
          ln.price ?? null,
          ln.exp ?? null,
          ln.notes ?? null,
          ln.service_center ?? input.service_center ?? null,
          ln.location_id ?? input.location_id ?? null,
          ln.official_price ?? null,
          ln.discount_percent ?? null,
          ln.discount_amount ?? null,
          ln.non_discounted ?? null,
          input.buy_headr ?? null,
          ln.item_cost ?? null,
        ],
      );
    }

    await commit(db);
    return { ok: true, credit_header };
  } catch (e) {
    await rollback(db);
    throw e;
  } finally {
    await db.close();
  }
}

export async function postReceipt(credit_header: number, user_name?: string | null) {
  const db = await connectDb();
  try {
    const t = nowDateTime();
    await db.exec(
      `UPDATE DBA.sc_credit_header
       SET post_flag=1, user_name=COALESCE(?, user_name), trans_time=?
       WHERE credit_header=?`,
      [user_name ?? null, t, credit_header],
    );
    return { ok: true };
  } finally {
    await db.close();
  }
}

export type IssueHeaderInput = {
  store_id: string;
  debit_date?: string | null;
  notes?: string | null;
  debit_type?: string | null; // e.g. WS/SALE/ADJ
  cus_code?: string | null;
  customer_name?: string | null;
  joborderid?: any;
  service_center?: string | null;
  location_id?: any;
  user_name?: string | null;
  request_no?: any;
  trans_flag?: any;
  trans_time?: string | null;
};

export type IssueLine = {
  item_id: string;
  qty: number;
  price?: number;
  exp?: string | null;
  notes?: string | null;
  status?: any;
  service_center?: string | null;
  location_id?: any;
  official_price?: any;
  item_cost?: any;
  official_cost?: any;
};

export async function createIssue(input: IssueHeaderInput, lines: IssueLine[]) {
  if (!input?.store_id) throw new AppError('VALIDATION', 400, 'store_id is required');
  if (!Array.isArray(lines) || lines.length === 0) throw new AppError('VALIDATION', 400, 'lines is required');

  const db = await connectDb();
  try {
    await begin(db);
    const debitDate = input.debit_date ?? nowDateTime();
    const transTime = nowDateTime();

    await db.exec(
      `INSERT INTO DBA.sc_debit_header
        (store_id, debit_date, notes, debit_type, cus_code, customer_name, joborderid,
         post_flag, service_center, location_id, user_name, request_no, trans_flag, trans_time, status)
       VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)`,
      [
        input.store_id,
        debitDate,
        input.notes ?? null,
        input.debit_type ?? null,
        input.cus_code ?? null,
        input.customer_name ?? null,
        input.joborderid ?? null,
        0,
        input.service_center ?? null,
        input.location_id ?? null,
        input.user_name ?? null,
        input.request_no ?? null,
        input.trans_flag ?? null,
        transTime,
        input['status'] ?? null,
      ],
    );

    const debit_header = await lastIdentity(db);

    for (const ln of lines) {
      await db.exec(
        `INSERT INTO DBA.sc_debit_detail
          (debit_header, item_id, qty, price, exp, notes, status, service_center, location_id,
           official_price, item_cost, official_cost)
         VALUES (?,?,?,?,?,?,?,?,?,?,?,?)`,
        [
          debit_header,
          ln.item_id,
          Number(ln.qty),
          ln.price ?? null,
          ln.exp ?? null,
          ln.notes ?? null,
          ln.status ?? null,
          ln.service_center ?? input.service_center ?? null,
          ln.location_id ?? input.location_id ?? null,
          ln.official_price ?? null,
          ln.item_cost ?? null,
          ln.official_cost ?? null,
        ],
      );
    }

    await commit(db);
    return { ok: true, debit_header };
  } catch (e) {
    await rollback(db);
    throw e;
  } finally {
    await db.close();
  }
}

export async function postIssue(debit_header: number, user_name?: string | null) {
  const db = await connectDb();
  try {
    const t = nowDateTime();
    await db.exec(
      `UPDATE DBA.sc_debit_header
       SET post_flag=1, user_name=COALESCE(?, user_name), confirm_date=COALESCE(confirm_date, ?)
       WHERE debit_header=?`,
      [user_name ?? null, t, debit_header],
    );
    return { ok: true };
  } finally {
    await db.close();
  }
}

export type TransferHeaderInput = {
  from_store_id: string;
  to_location_id: any;
  credit_date?: string | null;
  notes?: string | null;
  service_center?: string | null;
  location_id?: any;
  user_name?: string | null;
};

export type TransferLine = {
  item_id: string;
  qty: number;
  price?: number;
  exp?: string | null;
  notes?: string | null;
  service_center?: string | null;
  location_id?: any;
  official_price?: any;
  item_cost?: any;
};

export async function createTransfer(input: TransferHeaderInput, lines: TransferLine[]) {
  if (!input?.from_store_id) throw new AppError('VALIDATION', 400, 'from_store_id is required');
  if (input.to_location_id === undefined || input.to_location_id === null)
    throw new AppError('VALIDATION', 400, 'to_location_id is required');
  if (!Array.isArray(lines) || lines.length === 0) throw new AppError('VALIDATION', 400, 'lines is required');

  const db = await connectDb();
  try {
    await begin(db);
    const creditDate = input.credit_date ?? nowDateTime();
    const transTime = nowDateTime();

    // Transfers modeled as credit_header + credit_detail + sc_transfer_detail (destination)
    await db.exec(
      `INSERT INTO DBA.sc_credit_header
        (store_id, credit_date, notes, post_flag, trans_time, service_center, location_id, user_name)
       VALUES (?,?,?,?,?,?,?,?)`,
      [
        input.from_store_id,
        creditDate,
        input.notes ?? null,
        0,
        transTime,
        input.service_center ?? null,
        input.location_id ?? null,
        input.user_name ?? null,
      ],
    );
    const credit_header = await lastIdentity(db);

    for (const ln of lines) {
      await db.exec(
        `INSERT INTO DBA.sc_credit_detail
          (credit_header, item_id, qty, price, exp, notes, service_center, location_id, official_price, item_cost)
         VALUES (?,?,?,?,?,?,?,?,?,?)`,
        [
          credit_header,
          ln.item_id,
          Number(ln.qty),
          ln.price ?? null,
          ln.exp ?? null,
          ln.notes ?? null,
          ln.service_center ?? input.service_center ?? null,
          ln.location_id ?? input.location_id ?? null,
          ln.official_price ?? null,
          ln.item_cost ?? null,
        ],
      );
      const credit_detail = await lastIdentity(db);

      await db.exec(
        `INSERT INTO DBA.sc_transfer_detail
          (credit_header, credit_detail, item_id, qty, price, notes, exp, service_center, location_id, location_id_to, official_price, item_cost)
         VALUES (?,?,?,?,?,?,?,?,?,?,?,?)`,
        [
          credit_header,
          credit_detail,
          ln.item_id,
          Number(ln.qty),
          ln.price ?? null,
          ln.notes ?? null,
          ln.exp ?? null,
          ln.service_center ?? input.service_center ?? null,
          ln.location_id ?? input.location_id ?? null,
          input.to_location_id,
          ln.official_price ?? null,
          ln.item_cost ?? null,
        ],
      );
    }

    await commit(db);
    return { ok: true, credit_header };
  } catch (e) {
    await rollback(db);
    throw e;
  } finally {
    await db.close();
  }
}

export async function postTransfer(credit_header: number, user_name?: string | null) {
  // Same as postReceipt for transfer credit doc
  return postReceipt(credit_header, user_name);
}

export async function getBalance(store_id?: string, item_id?: string, location_id?: any, service_center?: any, limit = 500) {
  const db = await connectDb();
  try {
    const where: string[] = [];
    const params: any[] = [];
    if (store_id) { where.push('store_id=?'); params.push(store_id); }
    if (item_id) { where.push('item_id=?'); params.push(item_id); }
    if (location_id !== undefined && location_id !== null && location_id !== '') { where.push('location_id=?'); params.push(location_id); }
    if (service_center !== undefined && service_center !== null && service_center !== '') { where.push('service_center=?'); params.push(service_center); }

    const sql = `SELECT TOP ${Math.min(Math.max(Number(limit) || 100, 1), 5000)}
      store_id, item_id, location_id, service_center, balance, actual, price, official_price, bg_balance, bg_price, bg_date
      FROM DBA.sc_balance
      ${where.length ? 'WHERE ' + where.join(' AND ') : ''}
      ORDER BY store_id, item_id`;
    const rows = await db.query(sql, params);
    return { ok: true, rows };
  } finally { await db.close(); }
}
