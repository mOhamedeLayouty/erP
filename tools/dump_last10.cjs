/* tools/dump_last10.cjs
   SQL Anywhere "last 10 rows" dumper (schema-aware), outputs UTF-8 txt files.
   Fixes:
   - Quote schema/table/column identifiers (handles reserved words, weird names).
   - Fallback column discovery via SYS tables if INFORMATION_SCHEMA fails.
   - Better error logging per table.
*/
const fs = require('node:fs');
const path = require('node:path');
const odbc = require('odbc');

const OUT_DIR = path.join(process.cwd(), 'dumps', 'last10');
const LIMIT = Number(process.env.DUMP_LIMIT || 10);

function qIdent(name) {
  return `"${String(name).replace(/"/g, '""')}"`;
}

function ensureDir(p) {
  fs.mkdirSync(p, { recursive: true });
}

function safeStringify(v) {
  return JSON.stringify(
    v,
    (_k, val) => {
      if (typeof val === 'bigint') return val.toString();
      if (Buffer.isBuffer(val)) return val.toString('base64');
      return val;
    },
    2
  );
}

function pickOrderColumn(columns) {
  const prefer = [
    'entry_date', 'created_at', 'create_date', 'createdon', 'created_on',
    'updated_at', 'update_date', 'updatedon', 'updated_on',
    'post_date', 'post_time', 'trx_date', 'trx_time',
    'date', 'time',
    'id', 'audit_id'
  ];

  const lower = columns.map((c) => String(c).toLowerCase());

  for (const p of prefer) {
    const idx = lower.indexOf(p);
    if (idx >= 0) return columns[idx];
  }

  const idIdx = lower.findIndex((c) => c.endsWith('_id'));
  if (idIdx >= 0) return columns[idIdx];

  const dateIdx = lower.findIndex((c) => c.includes('date'));
  if (dateIdx >= 0) return columns[dateIdx];

  return null;
}

async function getUserTables(db) {
  // list BASE tables only (exclude SYS)
  const sql = `
    SELECT
      u.user_name AS table_schema,
      t.table_name
    FROM SYS.SYSTABLE t
    JOIN SYS.SYSUSER u ON u.user_id = t.creator
    WHERE
      t.table_type = 'BASE'
      AND u.user_name NOT IN ('SYS')
      AND t.table_name NOT LIKE 'SYS%'
    ORDER BY u.user_name, t.table_name
  `;
  return await db.query(sql);
}

async function getColumnsFromInfoSchema(db, schema, table) {
  const sql = `
    SELECT column_name
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE table_schema = ? AND table_name = ?
    ORDER BY ordinal_position
  `;
  const rows = await db.query(sql, [schema, table]);
  return rows.map((r) => r.column_name);
}

async function getColumnsFromSys(db, schema, table) {
  // Fallback using SYS tables
  const sql = `
    SELECT c.column_name
    FROM SYS.SYSCOLUMN c
    JOIN SYS.SYSTABLE t ON t.table_id = c.table_id
    JOIN SYS.SYSUSER u ON u.user_id = t.creator
    WHERE u.user_name = ? AND t.table_name = ?
    ORDER BY c.column_id
  `;
  const rows = await db.query(sql, [schema, table]);
  return rows.map((r) => r.column_name);
}

async function getColumns(db, schema, table) {
  try {
    const cols = await getColumnsFromInfoSchema(db, schema, table);
    if (cols && cols.length) return cols;
  } catch (_) {
    // ignore, fallback
  }
  const cols2 = await getColumnsFromSys(db, schema, table);
  return cols2;
}

async function dumpOneTable(db, schema, table) {
  const columns = await getColumns(db, schema, table);
  const orderCol = pickOrderColumn(columns);

  // ALWAYS quote schema/table/column
  const fq = `${qIdent(schema)}.${qIdent(table)}`;
  let rows;

  if (orderCol) {
    const orderExpr = qIdent(orderCol);
    try {
      rows = await db.query(`SELECT TOP ${LIMIT} * FROM ${fq} ORDER BY ${orderExpr} DESC`);
    } catch (e) {
      // fallback no order
      rows = await db.query(`SELECT TOP ${LIMIT} * FROM ${fq}`);
    }
  } else {
    rows = await db.query(`SELECT TOP ${LIMIT} * FROM ${fq}`);
  }

  return { columns, orderCol, rows };
}

(async () => {
  try {
    ensureDir(OUT_DIR);

    const connStr = process.env.ODBC_CONNECTION_STRING;
    if (!connStr) {
      console.error('FATAL: ODBC_CONNECTION_STRING is missing in environment/.env');
      process.exit(1);
    }

    const db = await odbc.connect(connStr);

    const tables = await getUserTables(db);

    const indexLines = [];
    indexLines.push(`# dump_last10`);
    indexLines.push(`# generated_at: ${new Date().toISOString()}`);
    indexLines.push(`# limit: ${LIMIT}`);
    indexLines.push(``);

    for (const t of tables) {
      const schema = t.table_schema;
      const table = t.table_name;

      const dir = path.join(OUT_DIR, schema);
      ensureDir(dir);

      const filePath = path.join(dir, `${table}.txt`);

      try {
        const { columns, orderCol, rows } = await dumpOneTable(db, schema, table);

        const header = [];
        header.push(`TABLE: ${schema}.${table}`);
        header.push(`ORDER_BY: ${orderCol || '(none)'}`);
        header.push(`COLUMNS: ${columns.join(', ')}`);
        header.push(`ROWS: ${rows.length}`);
        header.push(`---`);
        header.push(safeStringify(rows));

        fs.writeFileSync(filePath, header.join('\n') + '\n', { encoding: 'utf8' });

        indexLines.push(`OK  ${schema}.${table}  ->  dumps/last10/${schema}/${table}.txt`);
      } catch (e) {
        const msg = e?.message ? String(e.message) : String(e);
        const stack = e?.stack ? String(e.stack) : '';
        fs.writeFileSync(
          filePath,
          `TABLE: ${schema}.${table}\nERROR:\n${msg}\n\nSTACK:\n${stack}\n`,
          { encoding: 'utf8' }
        );
        indexLines.push(`ERR ${schema}.${table}  ->  dumps/last10/${schema}/${table}.txt`);
      }
    }

    fs.writeFileSync(path.join(OUT_DIR, `_index.txt`), indexLines.join('\n') + '\n', { encoding: 'utf8' });

    await db.close();

    console.log(`DONE: wrote ${tables.length} table dumps to: ${OUT_DIR}`);
    console.log(`INDEX: ${path.join(OUT_DIR, '_index.txt')}`);
  } catch (err) {
    console.error('FATAL:', err);
    process.exit(1);
  }
})();
