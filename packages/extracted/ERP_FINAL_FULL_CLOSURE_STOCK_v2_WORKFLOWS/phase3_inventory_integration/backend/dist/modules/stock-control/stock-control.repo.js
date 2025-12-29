import { connectDb } from '../../shared/db/odbc.js';
import { badRequest, notFound } from '../../shared/errors.js';
import { STOCK_CONTROL_TABLES } from './stock-control.tables.js';
function qualify(table) {
    // If already qualified, keep it.
    if (table.includes('.'))
        return table;
    // Stock control tables are in DBA in our Sybase SQL Anywhere layout.
    return `DBA.${table}`;
}
function assertLimit(n, def = 200) {
    const v = Number(n ?? def);
    if (!Number.isFinite(v) || v <= 0)
        return def;
    return Math.min(Math.floor(v), 1000);
}
export async function listRows(tableKey, limit) {
    const table = qualify(STOCK_CONTROL_TABLES[tableKey]);
    const top = assertLimit(limit, 200);
    const db = await connectDb();
    try {
        // SQL Anywhere supports TOP <n>
        return await db.query(`SELECT TOP ${top} * FROM ${table}`);
    }
    finally {
        await db.close();
    }
}
export async function getTableColumns(tableKey) {
    const tableName = STOCK_CONTROL_TABLES[tableKey];
    const db = await connectDb();
    try {
        // Try INFORMATION_SCHEMA first (SQL Anywhere supports it in most setups)
        try {
            const rows = await db.query(`SELECT column_name FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = ? ORDER BY ordinal_position`, [tableName]);
            if (rows?.length)
                return rows.map((r) => r.column_name);
        }
        catch {
            // ignore and try SYS catalog
        }
        // Fallback: SYS catalog
        const rows2 = await db.query(`SELECT c.column_name
       FROM SYS.SYSCOLUMN c
       JOIN SYS.SYSTABLE t ON t.table_id = c.table_id
       WHERE t.table_name = ?
       ORDER BY c.column_id`, [tableName]);
        if (rows2?.length)
            return rows2.map((r) => r.column_name);
        throw notFound(`Cannot resolve columns for table: ${tableName}`);
    }
    finally {
        await db.close();
    }
}
function sanitizeKeys(obj, allowedColumns) {
    const allow = new Set(allowedColumns.map((c) => c.toLowerCase()));
    const out = {};
    for (const [k, v] of Object.entries(obj ?? {})) {
        if (allow.has(k.toLowerCase()))
            out[k] = v;
    }
    return out;
}
export async function insertRow(tableKey, payload) {
    const cols = await getTableColumns(tableKey);
    const clean = sanitizeKeys(payload, cols);
    const keys = Object.keys(clean);
    if (!keys.length)
        throw badRequest('No valid columns provided for insert');
    const table = qualify(STOCK_CONTROL_TABLES[tableKey]);
    const placeholders = keys.map(() => '?').join(',');
    const sql = `INSERT INTO ${table} (${keys.join(',')}) VALUES (${placeholders})`;
    const params = keys.map((k) => clean[k]);
    const db = await connectDb();
    try {
        const affected = await db.exec(sql, params);
        return { affected };
    }
    finally {
        await db.close();
    }
}
export async function updateRow(tableKey, pkColumn, pkValue, payload) {
    if (!pkColumn)
        throw badRequest('pkColumn is required');
    const cols = await getTableColumns(tableKey);
    const clean = sanitizeKeys(payload, cols);
    const keys = Object.keys(clean).filter((k) => k.toLowerCase() !== pkColumn.toLowerCase());
    if (!keys.length)
        throw badRequest('No valid columns provided for update');
    const table = qualify(STOCK_CONTROL_TABLES[tableKey]);
    const sets = keys.map((k) => `${k} = ?`).join(', ');
    const sql = `UPDATE ${table} SET ${sets} WHERE ${pkColumn} = ?`;
    const params = [...keys.map((k) => clean[k]), pkValue];
    const db = await connectDb();
    try {
        const affected = await db.exec(sql, params);
        return { affected };
    }
    finally {
        await db.close();
    }
}
export async function deleteRow(tableKey, pkColumn, pkValue) {
    if (!pkColumn)
        throw badRequest('pkColumn is required');
    const table = qualify(STOCK_CONTROL_TABLES[tableKey]);
    const db = await connectDb();
    try {
        const affected = await db.exec(`DELETE FROM ${table} WHERE ${pkColumn} = ?`, [pkValue]);
        return { affected };
    }
    finally {
        await db.close();
    }
}
