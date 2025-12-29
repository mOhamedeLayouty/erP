import { connectDb } from '../../shared/db/odbc.js';
import { badRequest } from '../../shared/errors.js';
const T_HDR = 'DBA.car_transfer_header';
const T_DTL = 'DBA.car_transfer_detail';
const POST_COL = 'post_flag';
export async function postTransfer(transferId) {
    if (!transferId)
        throw badRequest('transferId is required');
    const db = await connectDb();
    try {
        const hdr = await db.query(`SELECT TOP 1 * FROM ${T_HDR} WHERE 1=1 AND ${infer_id_col()} = ?`, [transferId]);
        if (!hdr[0])
            throw badRequest('transfer header not found');
        const dtl = await db.query(`SELECT TOP 1 * FROM ${T_DTL} WHERE 1=1 AND ${infer_fk_col()} = ?`, [transferId]);
        if (!dtl[0])
            throw badRequest('transfer has no details');
        if (!POST_COL) {
            // No column to mark posted in locked schema; treat as validated-only
            return { affected: 0, mode: 'validated_only' };
        }
        const affected = await db.exec(`UPDATE ${T_HDR} SET ${POST_COL} = 1 WHERE ${infer_id_col()} = ?`, [transferId]);
        return { affected, mode: 'marked' };
    }
    finally {
        await db.close();
    }
}
function infer_id_col() {
    // best-effort: common header PKs
    const cols = ["credit_header", "trans_id", "manual_number", "notes", "store_id", "vend_code", "credit_date", "debit_header", "store_id_to", "trans_time", "log_stock", "brand", "edit_user", "post_flag"];
    const low = cols.map((c) => c.toLowerCase());
    const cands = ['transferid', 'voucherid', 'id', 'headerid', 'docid'];
    for (const c of cands) {
        const idx = low.indexOf(c);
        if (idx >= 0)
            return cols[idx];
    }
    // fallback: first column
    return cols[0] ?? '1';
}
function infer_fk_col() {
    const cols = ["credit_detail", "credit_header", "vin", "log_stock", "arrived", "km_out", "km_in", "brand", "cert_no", "arrival_date", "arrival_time", "vehicle_id", "cost"];
    const low = cols.map((c) => c.toLowerCase());
    const cands = ['transferid', 'voucherid', 'headerid', 'docid', 'id'];
    for (const c of cands) {
        const idx = low.indexOf(c);
        if (idx >= 0)
            return cols[idx];
    }
    return cols[0] ?? '1';
}
