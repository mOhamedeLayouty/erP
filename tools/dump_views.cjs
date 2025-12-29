/* tools/dump_views.cjs
   SQL Anywhere: dump views definitions (schema-aware), UTF-8 txt files.
   - Enumerates views via SYS.SYSTABLE (table_type = 'VIEW')
   - Tries to fetch definition via SYS.SYSVIEW.view_def using object_id / view_object_id
   - Robust: introspects SYS columns and uses fallbacks if schema differs
*/
const fs = require('node:fs');
const path = require('node:path');
const odbc = require('odbc');

const OUT_DIR = path.join(process.cwd(), 'dumps', 'views');

function ensureDir(p) {
  fs.mkdirSync(p, { recursive: true });
}

function qIdent(name) {
  return `"${String(name).replace(/"/g, '""')}"`;
}

async function getSysTableColumns(db, sysTableName) {
  // returns [column_name, ...] for SYS.<sysTableName>
  const sql = `
    SELECT c.column_name
    FROM SYS.SYSCOLUMN c
    JOIN SYS.SYSTABLE t ON t.table_id = c.table_id
    JOIN SYS.SYSUSER u ON u.user_id = t.creator
    WHERE u.user_name='SYS' AND t.table_name=?
    ORDER BY c.column_id
  `;
  const rows = await db.query(sql, [sysTableName]);
  return rows.map(r => String(r.column_name));
}

function hasCol(cols, name) {
  const low = cols.map(c => String(c).toLowerCase());
  return low.includes(String(name).toLowerCase());
}

async function listViews(db, systableCols) {
  // We prefer to read schema(owner) from SYSUSER via SYSTABLE.creator
  // Keep it compatible: only use columns that exist.
  // SYSTABLE almost always has: table_name, table_type, creator, table_id
  const selectParts = [];
  selectParts.push(`u.user_name AS view_schema`);
  selectParts.push(`t.table_name AS view_name`);
  if (hasCol(systableCols, 'table_id')) selectParts.push(`t.table_id AS table_id`);
  if (hasCol(systableCols, 'object_id')) selectParts.push(`t.object_id AS object_id`);

  const sql = `
    SELECT ${selectParts.join(', ')}
    FROM SYS.SYSTABLE t
    JOIN SYS.SYSUSER u ON u.user_id = t.creator
    WHERE t.table_type = 'VIEW'
      AND u.user_name NOT IN ('SYS')
      AND t.table_name NOT LIKE 'SYS%'
    ORDER BY u.user_name, t.table_name
  `;
  return await db.query(sql);
}

async function tryGetViewDef(db, viewSchema, viewName, systableRow, systableCols, sysviewCols, sysprocCols) {
  // 1) Best case: SYSTABLE has object_id AND SYSVIEW has view_object_id/view_def
  if (hasCol(systableCols, 'object_id') && hasCol(sysviewCols, 'view_object_id') && hasCol(sysviewCols, 'view_def')) {
    try {
      const objectId = systableRow.object_id;
      const r = await db.query(`SELECT view_def FROM SYS.SYSVIEW WHERE view_object_id = ?`, [objectId]);
      const def = r?.[0]?.view_def;
      if (def) return { def: String(def), source: 'SYS.SYSVIEW(view_object_id=object_id)' };
    } catch {}
  }

  // 2) Fallback: join SYS.SYSOBJECT (if exists) using object_name + owner
  // (نستكشف الأعمدة بدل ما نفترض)
  try {
    const sysobjectCols = await getSysTableColumns(db, 'SYSOBJECT');
    const hasObjectName = hasCol(sysobjectCols, 'object_name');
    const hasOwnerId = hasCol(sysobjectCols, 'owner');
    const hasObjectId = hasCol(sysobjectCols, 'object_id');

    if (hasObjectName && hasObjectId && hasCol(sysviewCols, 'view_object_id') && hasCol(sysviewCols, 'view_def')) {
      // try match by name (and owner if available)
      if (hasOwnerId) {
        // Need owner id for schema
        // owner is usually a user_id, we can map schema -> user_id via SYSUSER
        const u = await db.query(`SELECT user_id FROM SYS.SYSUSER WHERE user_name=?`, [viewSchema]);
        const ownerId = u?.[0]?.user_id;
        if (ownerId !== undefined) {
          const r = await db.query(
            `
            SELECT v.view_def
            FROM SYS.SYSVIEW v
            JOIN SYS.SYSOBJECT o ON o.object_id = v.view_object_id
            WHERE o.object_name = ? AND o.owner = ?
            `,
            [viewName, ownerId]
          );
          const def = r?.[0]?.view_def;
          if (def) return { def: String(def), source: 'SYS.SYSVIEW + SYSOBJECT(object_name+owner)' };
        }
      }

      // try match by name only
      const r2 = await db.query(
        `
        SELECT v.view_def
        FROM SYS.SYSVIEW v
        JOIN SYS.SYSOBJECT o ON o.object_id = v.view_object_id
        WHERE o.object_name = ?
        `,
        [viewName]
      );
      const def2 = r2?.[0]?.view_def;
      if (def2) return { def: String(def2), source: 'SYS.SYSVIEW + SYSOBJECT(object_name)' };
    }
  } catch {}

  // 3) Very old migrations: no view source preserved (common). Return null.
  return { def: null, source: '(not found)' };
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

    const systableCols = await getSysTableColumns(db, 'SYSTABLE');
    const sysviewCols = await getSysTableColumns(db, 'SYSVIEW');
    const sysprocCols = await getSysTableColumns(db, 'SYSPROCEDURE');

    const views = await listViews(db, systableCols);

    const indexLines = [];
    indexLines.push(`# dump_views`);
    indexLines.push(`# generated_at: ${new Date().toISOString()}`);
    indexLines.push(``);
    indexLines.push(`# SYS.SYSTABLE cols: ${systableCols.join(', ')}`);
    indexLines.push(`# SYS.SYSVIEW cols: ${sysviewCols.join(', ')}`);
    indexLines.push(`# SYS.SYSPROCEDURE cols: ${sysprocCols.join(', ')}`);
    indexLines.push(``);

    for (const v of views) {
      const schema = v.view_schema;
      const name = v.view_name;

      const dir = path.join(OUT_DIR, schema);
      ensureDir(dir);

      const filePath = path.join(dir, `${name}.sql`);

      try {
        const { def, source } = await tryGetViewDef(db, schema, name, v, systableCols, sysviewCols, sysprocCols);

        const lines = [];
        lines.push(`-- VIEW: ${schema}.${name}`);
        lines.push(`-- generated_at: ${new Date().toISOString()}`);
        if (v.object_id !== undefined) lines.push(`-- object_id: ${v.object_id}`);
        if (v.table_id !== undefined) lines.push(`-- table_id: ${v.table_id}`);
        lines.push(`-- source_via: ${source}`);
        lines.push(``);
        if (def) {
          lines.push(def.trimEnd());
          lines.push('');
        } else {
          lines.push(`-- (definition not found)`);
          lines.push(`-- Notes: if this DB was migrated from older Sybase builds, some views may not have preserved source.`);
          lines.push('');
        }

        fs.writeFileSync(filePath, lines.join('\n'), { encoding: 'utf8' });
        indexLines.push(`OK  ${schema}.${name}  ->  dumps/views/${schema}/${name}.sql`);
      } catch (e) {
        const msg = e?.message ? String(e.message) : String(e);
        const stack = e?.stack ? String(e.stack) : '';
        fs.writeFileSync(filePath, `-- VIEW: ${schema}.${name}\n-- ERROR:\n-- ${msg}\n\n-- STACK:\n${stack}\n`, { encoding: 'utf8' });
        indexLines.push(`ERR ${schema}.${name}  ->  dumps/views/${schema}/${name}.sql`);
      }
    }

    fs.writeFileSync(path.join(OUT_DIR, `_index.txt`), indexLines.join('\n') + '\n', { encoding: 'utf8' });

    await db.close();

    console.log(`DONE: wrote ${views.length} view dumps to: ${OUT_DIR}`);
    console.log(`INDEX: ${path.join(OUT_DIR, '_index.txt')}`);
  } catch (err) {
    console.error('FATAL:', err);
    process.exit(1);
  }
})();
