import { connectDb } from '../../shared/db/odbc.js';
import { INVOICING_TABLES } from './invoicing.tables.js';
function colsCsv(cols) {
    return cols.join(', ');
}
export async function listInvoices(limit = 200) {
    const db = await connectDb();
    try {
        const t = INVOICING_TABLES.header.table;
        const cols = colsCsv(INVOICING_TABLES.header.columns);
        return await db.query(`SELECT TOP ${limit} ${cols} FROM ${t} ORDER BY InvoiceDate DESC, InvoiceID DESC`);
    }
    finally {
        await db.close();
    }
}
export async function listInvoiceDetails(invoiceId, limit = 500) {
    const db = await connectDb();
    try {
        const t = INVOICING_TABLES.detail.table;
        const cols = colsCsv(INVOICING_TABLES.detail.columns);
        return await db.query(`SELECT TOP ${limit} ${cols} FROM ${t} WHERE InvoiceID = ?`, [invoiceId]);
    }
    finally {
        await db.close();
    }
}
export async function createInvoiceHeader(payload) {
    const db = await connectDb();
    try {
        const t = INVOICING_TABLES.header.table;
        const allowed = INVOICING_TABLES.header.columns;
        const cols = allowed.filter(c => payload[c] !== undefined);
        const vals = cols.map(c => payload[c]);
        const placeholders = cols.map(_ => '?').join(',');
        if (!cols.length)
            return 0;
        return await db.exec(`INSERT INTO ${t} (${cols.join(',')}) VALUES (${placeholders})`, vals);
    }
    finally {
        await db.close();
    }
}
export async function createInvoiceDetail(payload) {
    const db = await connectDb();
    try {
        const t = INVOICING_TABLES.detail.table;
        const allowed = INVOICING_TABLES.detail.columns;
        const cols = allowed.filter(c => payload[c] !== undefined);
        const vals = cols.map(c => payload[c]);
        const placeholders = cols.map(_ => '?').join(',');
        if (!cols.length)
            return 0;
        return await db.exec(`INSERT INTO ${t} (${cols.join(',')}) VALUES (${placeholders})`, vals);
    }
    finally {
        await db.close();
    }
}
