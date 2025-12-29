/* tools/dump_keys.cjs
   SQL Anywhere: dump PK/UK/FK + indexes per table (schema-aware), UTF-8 txt files.
   Style matches dump_last10 (SYS tables enumeration + identifier quoting + robust fallbacks)
*/
const fs = require('node:fs');
const path = require('node:path');
const odbc = require('odbc');

const OUT_DIR = path.join(process.cwd(), 'dumps', 'keys');

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

async function getUserTables(db) {
  // include table_id for SYS-based index queries
  const sql = `
    SELECT
      u.user_name AS table_schema,
      t.table_name,
      t.table_id
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
    if (cols?.length) return cols;
  } catch {}
  return await getColumnsFromSys(db, schema, table);
}

// ---------- constraints (PK/UK/FK) using INFORMATION_SCHEMA (best) + SYS fallback ----------
async function getPK_UK_fromInfoSchema(db, schema, table) {
  const sql = `
    SELECT
      tc.constraint_type,
      tc.constraint_name,
      kcu.column_name,
      kcu.ordinal_position
    FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
    JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu
      ON kcu.constraint_name = tc.constraint_name
     AND kcu.table_schema = tc.table_schema
     AND kcu.table_name = tc.table_name
    WHERE
      tc.table_schema = ?
      AND tc.table_name = ?
      AND tc.constraint_type IN ('PRIMARY KEY', 'UNIQUE')
    ORDER BY tc.constraint_type, tc.constraint_name, kcu.ordinal_position
  `;
  return await db.query(sql, [schema, table]);
}

async function getFK_fromInfoSchema(db, schema, table) {
  // FK cols + referenced table/cols (via unique_constraint_name mapping)
  const sql = `
    SELECT
      rc.constraint_name                 AS fk_name,
      fk.table_schema                    AS fk_schema,
      fk.table_name                      AS fk_table,
      fk.column_name                     AS fk_column,
      fk.ordinal_position                AS fk_ordinal,
      pk.table_schema                    AS pk_schema,
      pk.table_name                      AS pk_table,
      pk.column_name                     AS pk_column,
      pk.ordinal_position                AS pk_ordinal
    FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS rc
    JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE fk
      ON fk.constraint_name = rc.constraint_name
    JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE pk
      ON pk.constraint_name = rc.unique_constraint_name
     AND pk.ordinal_position = fk.ordinal_position
    WHERE
      fk.table_schema = ?
      AND fk.table_name = ?
    ORDER BY rc.constraint_name, fk.ordinal_position
  `;
  return await db.query(sql, [schema, table]);
}

async function getPK_UK_FK(db, schema, table) {
  const out = { pk: null, unique: [], fk: [] };

  // 1) Try INFORMATION_SCHEMA
  try {
    const pkuk = await getPK_UK_fromInfoSchema(db, schema, table);
    const pkMap = new Map();
    const ukMap = new Map();

    for (const r of pkuk) {
      const type = String(r.constraint_type);
      const name = String(r.constraint_name);
      const col = String(r.column_name);
      if (type === 'PRIMARY KEY') {
        if (!pkMap.has(name)) pkMap.set(name, []);
        pkMap.get(name).push(col);
      } else if (type === 'UNIQUE') {
        if (!ukMap.has(name)) ukMap.set(name, []);
        ukMap.get(name).push(col);
      }
    }

    // assume single PK constraint (typical); if multiple, keep first
    if (pkMap.size) {
      const [name, cols] = pkMap.entries().next().value;
      out.pk = { name, columns: cols };
    }

    for (const [name, cols] of ukMap.entries()) {
      out.unique.push({ name, columns: cols });
    }

    try {
      const fkRows = await getFK_fromInfoSchema(db, schema, table);
      const fkMap = new Map();

      for (const r of fkRows) {
        const fkName = String(r.fk_name);
        if (!fkMap.has(fkName)) {
          fkMap.set(fkName, {
            name: fkName,
            from: { schema: String(r.fk_schema), table: String(r.fk_table), columns: [] },
            to: { schema: String(r.pk_schema), table: String(r.pk_table), columns: [] }
          });
        }
        fkMap.get(fkName).from.columns.push(String(r.fk_column));
        fkMap.get(fkName).to.columns.push(String(r.pk_column));
      }

      out.fk = Array.from(fkMap.values());
    } catch {
      // FK optional; keep empty if fails
    }

    return out;
  } catch {
    // ignore and fallback below
  }

  // 2) SYS fallback (PK/UK/FK might be hard to normalize across versions)
  // We'll dump raw SYS rows if info_schema fails so you at least have a reference.
  try {
    const raw = {};
    // constraints (often in SYS.SYSCONSTRAINT / SYS.SYSFK / SYS.SYSFKEY, varies)
    // We'll just try a couple common ones and ignore failures.
    try {
      raw.sysconstraint = await db.query(
        `SELECT * FROM SYS.SYSCONSTRAINT WHERE table_object = ${qIdent(schema)}.${qIdent(table)}`
      );
    } catch {}
    try { raw.sysfk = await db.query(`SELECT * FROM SYS.SYSFK`); } catch {}
    try { raw.sysfkey = await db.query(`SELECT * FROM SYS.SYSFKEY`); } catch {}
    return { ...out, sys_fallback: raw };
  } catch {
    return out;
  }
}

// ---------- Indexes from SYS tables (needs table_id) ----------
async function getIndexesFromSys(db, table_id) {
  // We’ll collect:
  // - SYS.SYSIDX rows for that table
  // - SYS.SYSIDXCOL + SYS.SYSCOLUMN to list columns for each index
  const idxRows = await db.query(`SELECT * FROM SYS.SYSIDX WHERE table_id = ?`, [table_id]);

  let idxCols = [];
  try {
    idxCols = await db.query(
      `
      SELECT
        i.index_id,
        i.index_name,
        c.column_name,
        ic.sequence
      FROM SYS.SYSIDX i
      JOIN SYS.SYSIDXCOL ic ON ic.index_id = i.index_id
      JOIN SYS.SYSCOLUMN c ON c.column_id = ic.column_id AND c.table_id = i.table_id
      WHERE i.table_id = ?
      ORDER BY i.index_id, ic.sequence
      `,
      [table_id]
    );
  } catch {
    // fallback if "sequence" differs
    try {
      idxCols = await db.query(
        `
        SELECT
          i.index_id,
          i.index_name,
          c.column_name,
          ic.column_id
        FROM SYS.SYSIDX i
        JOIN SYS.SYSIDXCOL ic ON ic.index_id = i.index_id
        JOIN SYS.SYSCOLUMN c ON c.column_id = ic.column_id AND c.table_id = i.table_id
        WHERE i.table_id = ?
        ORDER BY i.index_id, ic.column_id
        `,
        [table_id]
      );
    } catch {
      idxCols = [];
    }
  }

  // group columns by index_id
  const map = new Map();
  for (const r of idxRows) {
    map.set(r.index_id, { meta: r, columns: [] });
  }
  for (const r of idxCols) {
    if (!map.has(r.index_id)) map.set(r.index_id, { meta: { index_id: r.index_id, index_name: r.index_name }, columns: [] });
    map.get(r.index_id).columns.push(String(r.column_name));
  }

  return Array.from(map.values()).map((x) => ({
    index_id: x.meta.index_id,
    index_name: x.meta.index_name,
    // try to expose uniqueness if column exists
    is_unique: x.meta.is_unique ?? x.meta.unique ?? x.meta['unique'] ?? null,
    columns: x.columns,
    meta: x.meta
  }));
}

async function dumpOneTable(db, schema, table, table_id) {
  const columns = await getColumns(db, schema, table);
  const constraints = await getPK_UK_FK(db, schema, table);

  let indexes = [];
  try {
    indexes = await getIndexesFromSys(db, table_id);
  } catch {
    indexes = [];
  }

  return { columns, constraints, indexes };
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
    indexLines.push(`# dump_keys`);
    indexLines.push(`# generated_at: ${new Date().toISOString()}`);
    indexLines.push(``);

    for (const t of tables) {
      const schema = t.table_schema;
      const table = t.table_name;
      const table_id = t.table_id;

      const dir = path.join(OUT_DIR, schema);
      ensureDir(dir);

      const filePath = path.join(dir, `${table}.txt`);

      try {
        const { columns, constraints, indexes } = await dumpOneTable(db, schema, table, table_id);

        const lines = [];
        lines.push(`TABLE: ${schema}.${table}`);
        lines.push(`COLUMNS(${columns.length}): ${columns.join(', ')}`);
        lines.push(``);

        lines.push(`PRIMARY_KEY:`);
        if (constraints.pk) {
          lines.push(`  name: ${constraints.pk.name}`);
          lines.push(`  columns: ${constraints.pk.columns.join(', ')}`);
        } else {
          lines.push(`  (none)`);
        }
        lines.push(``);

        lines.push(`UNIQUE_CONSTRAINTS:`);
        if (constraints.unique?.length) {
          for (const u of constraints.unique) {
            lines.push(`  - ${u.name}: ${u.columns.join(', ')}`);
          }
        } else {
          lines.push(`  (none)`);
        }
        lines.push(``);

        lines.push(`FOREIGN_KEYS:`);
        if (constraints.fk?.length) {
          for (const fk of constraints.fk) {
            lines.push(`  - ${fk.name}`);
            lines.push(`    from: ${fk.from.schema}.${fk.from.table} (${fk.from.columns.join(', ')})`);
            lines.push(`    to:   ${fk.to.schema}.${fk.to.table} (${fk.to.columns.join(', ')})`);
          }
        } else {
          lines.push(`  (none or not readable via INFORMATION_SCHEMA)`);
        }
        lines.push(``);

        lines.push(`INDEXES:`);
        if (indexes?.length) {
          for (const ix of indexes) {
            lines.push(`  - ${ix.index_name} (unique: ${ix.is_unique})`);
            lines.push(`    columns: ${ix.columns?.length ? ix.columns.join(', ') : '(unknown)'}`);
          }
        } else {
          lines.push(`  (none or not readable via SYS.SYSIDX*)`);
        }

        // keep raw fallback if we had to use SYS for constraints
        if (constraints.sys_fallback) {
          lines.push(``);
          lines.push(`SYS_FALLBACK_RAW:`);
          lines.push(safeStringify(constraints.sys_fallback));
        }

        fs.writeFileSync(filePath, lines.join('\n') + '\n', { encoding: 'utf8' });
        indexLines.push(`OK  ${schema}.${table}  ->  dumps/keys/${schema}/${table}.txt`);
      } catch (e) {
        const msg = e?.message ? String(e.message) : String(e);
        const stack = e?.stack ? String(e.stack) : '';
        fs.writeFileSync(filePath, `TABLE: ${schema}.${table}\nERROR:\n${msg}\n\nSTACK:\n${stack}\n`, { encoding: 'utf8' });
        indexLines.push(`ERR ${schema}.${table}  ->  dumps/keys/${schema}/${table}.txt`);
      }
    }

    fs.writeFileSync(path.join(OUT_DIR, `_index.txt`), indexLines.join('\n') + '\n', { encoding: 'utf8' });

    await db.close();

    console.log(`DONE: wrote ${tables.length} table key dumps to: ${OUT_DIR}`);
    console.log(`INDEX: ${path.join(OUT_DIR, '_index.txt')}`);
  } catch (err) {
    console.error('FATAL:', err);
    process.exit(1);
  }
})();
