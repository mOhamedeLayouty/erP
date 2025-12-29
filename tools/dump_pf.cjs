/* tools/dump_pf.cjs
   SQL Anywhere: dump Procedures/Functions definitions from SYS.SYSPROCEDURE, UTF-8.
   Robust against different column names (no proc_type dependency).
*/
const fs = require('node:fs');
const path = require('node:path');
const odbc = require('odbc');

const OUT_DIR = path.join(process.cwd(), 'dumps', 'pf');

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

(async () => {
  try {
    ensureDir(OUT_DIR);

    const connStr = process.env.ODBC_CONNECTION_STRING;
    if (!connStr) throw new Error('ODBC_CONNECTION_STRING missing');

    const db = await odbc.connect(connStr);

    const procCols = await getSysCols(db, 'SYS', 'SYSPROCEDURE');

    const colName   = pick(procCols, ['proc_name', 'procedure_name', 'name']);
    const colId     = pick(procCols, ['proc_id', 'procedure_id', 'id', 'object_id']);
    const colOwner  = pick(procCols, ['creator', 'owner', 'user_id', 'creator_id']); // might not exist
    const colDefn   = pick(procCols, ['proc_defn', 'definition', 'text', 'proc_definition', 'source']);
    const colRemark = pick(procCols, ['remarks', 'remark', 'comment']);

    // pull rows
    const rows = await db.query(`SELECT * FROM SYS.SYSPROCEDURE`);

    // map creator id to username if possible
    let userMap = new Map();
    try {
      const users = await db.query(`SELECT user_id, user_name FROM SYS.SYSUSER`);
      for (const u of users) userMap.set(Number(u.user_id), String(u.user_name));
    } catch {}

    const indexLines = [];
    indexLines.push(`# dump_pf`);
    indexLines.push(`# generated_at: ${new Date().toISOString()}`);
    indexLines.push(`# SYS.SYSPROCEDURE cols: ${procCols.join(', ')}`);
    indexLines.push('');

    for (const r of rows) {
      const name = colName ? r[colName] : (r.proc_name ?? r.name ?? 'UNKNOWN_PROC');
      const id = colId ? r[colId] : null;

      let owner = 'UNKNOWN_SCHEMA';
      if (colOwner && r[colOwner] != null) {
        const v = r[colOwner];
        const n = Number(v);
        owner = Number.isFinite(n) ? (userMap.get(n) ?? owner) : String(v);
      }

      const dir = path.join(OUT_DIR, owner);
      ensureDir(dir);

      const safeFile = String(name).replace(/[\\/:*?"<>|]/g, '_');
      const filePath = path.join(dir, `${safeFile}.sql`);

      try {
        let defn = '';
        if (colDefn) defn = toText(r[colDefn]);

        // Fallback: try helper by name if exists
        if (!defn && name) {
          try {
            const ddl = await db.query(`SELECT sa_get_proc_definition(?) AS defn`, [String(name)]);
            defn = toText(ddl?.[0]?.defn);
          } catch {}
        }

        const out = [];
        out.push(`-- PF: ${owner}.${String(name)}`);
        if (id != null) out.push(`-- proc_id: ${id}`);
        out.push(`-- generated_at: ${new Date().toISOString()}`);
        if (colRemark && r[colRemark]) out.push(`-- remark: ${toText(r[colRemark])}`);
        out.push('');

        if (!defn) {
          out.push(`-- (definition not found)`);
          out.push('');
        } else {
          out.push(defn.trim());
          out.push('');
        }

        fs.writeFileSync(filePath, out.join('\n'), { encoding: 'utf8' });
        indexLines.push(`OK  ${owner}.${String(name)}  ->  dumps/pf/${owner}/${safeFile}.sql`);
      } catch (e) {
        const msg = e?.message ? String(e.message) : String(e);
        fs.writeFileSync(filePath, `-- PF: ${owner}.${String(name)}\n-- ERROR:\n-- ${msg}\n`, { encoding: 'utf8' });
        indexLines.push(`ERR ${owner}.${String(name)}  ->  dumps/pf/${owner}/${safeFile}.sql`);
      }
    }

    fs.writeFileSync(path.join(OUT_DIR, `_index.txt`), indexLines.join('\n') + '\n', { encoding: 'utf8' });

    await db.close();

    console.log(`DONE: wrote ${rows.length} proc/function dumps to: ${OUT_DIR}`);
    console.log(`INDEX: ${path.join(OUT_DIR, '_index.txt')}`);
  } catch (err) {
    console.error('FATAL:', err);
    process.exit(1);
  }
})();
