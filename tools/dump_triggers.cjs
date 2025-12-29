/* tools/dump_triggers.cjs
   SQL Anywhere: dump TRIGGER definitions, UTF-8 txt files.
*/
const fs = require('node:fs');
const path = require('node:path');
const odbc = require('odbc');

const OUT_DIR = path.join(process.cwd(), 'dumps', 'triggers');

function ensureDir(p) { fs.mkdirSync(p, { recursive: true }); }
function qIdent(name) { return `"${String(name).replace(/"/g, '""')}"`; }

function toText(v) {
  if (v == null) return '';
  if (Buffer.isBuffer(v)) return v.toString('utf8');
  return String(v);
}

async function getSysCols(db, schema, table) {
  const sql = `
    SELECT c.column_name
    FROM SYS.SYSCOLUMN c
    JOIN SYS.SYSTABLE t ON t.table_id = c.table_id
    JOIN SYS.SYSUSER  u ON u.user_id = t.creator
    WHERE u.user_name = ? AND t.table_name = ?
    ORDER BY c.column_id
  `;
  const rows = await db.query(sql, [schema, table]);
  return rows.map(r => String(r.column_name));
}

function pick(cols, candidates) {
  const set = new Set(cols.map(c => c.toLowerCase()));
  for (const c of candidates) if (set.has(c.toLowerCase())) return c;
  return null;
}

async function listUserTables(db) {
  const sql = `
    SELECT u.user_name AS table_schema, t.table_name, t.table_id
    FROM SYS.SYSTABLE t
    JOIN SYS.SYSUSER u ON u.user_id = t.creator
    WHERE t.table_type = 'BASE'
      AND u.user_name NOT IN ('SYS')
      AND t.table_name NOT LIKE 'SYS%'
    ORDER BY u.user_name, t.table_name
  `;
  return await db.query(sql);
}

(async () => {
  try {
    ensureDir(OUT_DIR);

    const connStr = process.env.ODBC_CONNECTION_STRING;
    if (!connStr) throw new Error('ODBC_CONNECTION_STRING missing');

    const db = await odbc.connect(connStr);

    const trigCols = await getSysCols(db, 'SYS', 'SYSTRIGGER');
    const colTrigName = pick(trigCols, ['trigger_name', 'name', 'trig_name']);
    const colTrigId   = pick(trigCols, ['trigger_id', 'id', 'object_id']);
    const colTableId  = pick(trigCols, ['table_id', 'base_table_id', 'tname_id']);
    const colDefn     = pick(trigCols, ['trigger_defn', 'definition', 'text', 'trig_defn']);

    const tables = await listUserTables(db);

    const indexLines = [];
    indexLines.push(`# dump_triggers`);
    indexLines.push(`# generated_at: ${new Date().toISOString()}`);
    indexLines.push(`# SYS.SYSTRIGGER cols: ${trigCols.join(', ')}`);
    indexLines.push('');

    // Build map table_id -> schema.table
    const tableMap = new Map();
    for (const t of tables) tableMap.set(Number(t.table_id), { schema: t.table_schema, table: t.table_name });

    // List triggers (best effort)
    let triggers = [];
    try {
      triggers = await db.query(`SELECT * FROM SYS.SYSTRIGGER`);
    } catch (e) {
      throw new Error(`Cannot read SYS.SYSTRIGGER: ${e?.message ?? e}`);
    }

    for (const tr of triggers) {
      const trigName = colTrigName ? tr[colTrigName] : tr.trigger_name ?? tr.name ?? 'UNKNOWN_TRIGGER';
      const baseTableId = colTableId ? tr[colTableId] : null;

      const base = baseTableId != null ? tableMap.get(Number(baseTableId)) : null;
      const schema = base?.schema ?? 'UNKNOWN_SCHEMA';
      const table = base?.table ?? 'UNKNOWN_TABLE';

      const dir = path.join(OUT_DIR, schema);
      ensureDir(dir);

      const safeFile = String(trigName).replace(/[\\/:*?"<>|]/g, '_');
      const filePath = path.join(dir, `${safeFile}.sql`);

      try {
        let defn = '';
        if (colDefn) defn = toText(tr[colDefn]);

        // Fallback: try server helper if available
        if (!defn && colTrigName) {
          try {
            const ddl = await db.query(`SELECT sa_get_trigger_definition(?) AS defn`, [String(trigName)]);
            defn = toText(ddl?.[0]?.defn);
          } catch {}
        }

        const out = [];
        out.push(`-- TRIGGER: ${schema}.${String(trigName)}`);
        out.push(`-- ON TABLE: ${schema}.${table}`);
        out.push(`-- generated_at: ${new Date().toISOString()}`);
        out.push('');

        if (!defn) {
          out.push(`-- (definition not found)`);
          out.push('');
        } else {
          out.push(defn.trim());
          out.push('');
        }

        fs.writeFileSync(filePath, out.join('\n'), { encoding: 'utf8' });
        indexLines.push(`OK  ${schema}.${String(trigName)}  ->  dumps/triggers/${schema}/${safeFile}.sql`);
      } catch (e) {
        const msg = e?.message ? String(e.message) : String(e);
        fs.writeFileSync(filePath, `-- TRIGGER: ${schema}.${String(trigName)}\n-- ERROR:\n-- ${msg}\n`, { encoding: 'utf8' });
        indexLines.push(`ERR ${schema}.${String(trigName)}  ->  dumps/triggers/${schema}/${safeFile}.sql`);
      }
    }

    fs.writeFileSync(path.join(OUT_DIR, `_index.txt`), indexLines.join('\n') + '\n', { encoding: 'utf8' });

    await db.close();

    console.log(`DONE: wrote ${triggers.length} trigger dumps to: ${OUT_DIR}`);
    console.log(`INDEX: ${path.join(OUT_DIR, '_index.txt')}`);
  } catch (err) {
    console.error('FATAL:', err);
    process.exit(1);
  }
})();
