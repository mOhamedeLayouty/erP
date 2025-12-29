import { connectDb } from '../../shared/db/odbc.js';
import { INVENTORY_TABLES } from './inventory.tables.js';
function colsCsv(cols) {
    return cols.join(', ');
}
export async function listStores(limit = 200) {
    const db = await connectDb();
    try {
        // Use SELECT * for demo robustness: some deployments use different store tables/columns.
        // (Front-end renders columns dynamically.)
        const t = INVENTORY_TABLES.stores.table;
        return await db.query(`SELECT TOP ${limit} * FROM ${t}`);
    }
    finally {
        await db.close();
    }
}
export async function listItems(limit = 200) {
    const db = await connectDb();
    try {
        const t = INVENTORY_TABLES.items.table;
        return await db.query(`SELECT TOP ${limit} * FROM ${t}`);
    }
    finally {
        await db.close();
    }
}
export async function listTransfers(limit = 200) {
    const db = await connectDb();
    try {
        const t = INVENTORY_TABLES.transfer_header.table;
        const cols = colsCsv(INVENTORY_TABLES.transfer_header.columns);
        return await db.query(`SELECT TOP ${limit} ${cols} FROM ${t}`);
    }
    finally {
        await db.close();
    }
}
export async function listTransferDetails(limit = 500) {
    const db = await connectDb();
    try {
        const t = INVENTORY_TABLES.transfer_detail.table;
        const cols = colsCsv(INVENTORY_TABLES.transfer_detail.columns);
        return await db.query(`SELECT TOP ${limit} ${cols} FROM ${t}`);
    }
    finally {
        await db.close();
    }
}
/**
 * Generic insert for transfer header/detail.
 * NOTE:
 * - No schema changes
 * - Uses only known locked columns (from reload.sql)
 */
export async function createTransferHeader(payload) {
    const db = await connectDb();
    try {
        const t = INVENTORY_TABLES.transfer_header.table;
        const allowed = INVENTORY_TABLES.transfer_header.columns;
        const cols = allowed.filter(c => payload[c] !== undefined);
        const vals = cols.map(c => payload[c]);
        const placeholders = cols.map(_ => '?').join(',');
        if (!cols.length)
            return 0;
        const sql = `INSERT INTO ${t} (${cols.join(',')}) VALUES (${placeholders})`;
        return await db.exec(sql, vals);
    }
    finally {
        await db.close();
    }
}
export async function createTransferDetail(payload) {
    const db = await connectDb();
    try {
        const t = INVENTORY_TABLES.transfer_detail.table;
        const allowed = INVENTORY_TABLES.transfer_detail.columns;
        const cols = allowed.filter(c => payload[c] !== undefined);
        const vals = cols.map(c => payload[c]);
        const placeholders = cols.map(_ => '?').join(',');
        if (!cols.length)
            return 0;
        const sql = `INSERT INTO ${t} (${cols.join(',')}) VALUES (${placeholders})`;
        return await db.exec(sql, vals);
    }
    finally {
        await db.close();
    }
}
