/* tools/dump_views.cjs
   SQL Anywhere: dump view definitions per schema, UTF-8 txt files.
*/
const fs = require('node:fs');
const path = require('node:path');
const odbc = require('odbc');

const OUT_DIR = path.join(process.cwd(), 'dumps', 'views');

function ensureDir(p) { fs.mkdirSync(p, { recursive: true }); }
function safeWrite(p, s) { fs.writeFileSync(p, s, { encoding: 'utf8' }); }

async function listViews(db) {
  // INFORMATION_SCHEMA.VIEWS usually works
  const sql = `
    SELECT table_schema AS view_schema,
           table_name   AS view_name,
           view_definition
    FROM INFORMATION_SCHEMA.VIEWS
    WHERE table_schema NOT IN ('SYS')
    ORDER BY table_schema, table_name
  `;
  return await db.query(sql);
}

(async () => {
  try {
    ensureDir(OUT_DIR);

    const connStr = process.env.ODBC_CONNECTION_STRING;
    if (!connStr) throw new Error('ODBC_CONNECTION_STRING missing');
    const db = await odbc.connect(connStr);

    const views = await listViews(db);

    const indexLines = [];
    indexLines.push(`# dump_views`);
    indexLines.push(`# generated_at: ${new Date().toISOString()}`);
    indexLines.push(``);

    for (const v of views) {
      const schema = String(v.view_schema);
      const name = String(v.view_name);
      const defn = v.view_definition;

      const dir = path.join(OUT_DIR, schema);
      ensureDir(dir);

      const filePath = path.join(dir, `${name}.view.sql`);

      try {
        const lines = [];
        lines.push(`-- VIEW: ${schema}.${name}`);
        lines.push(`-- generated_at: ${new Date().toISOString()}`);
        lines.push(``);

        if (!defn || String(defn).trim().length === 0) {
          lines.push(`-- (definition not found in INFORMATION_SCHEMA.VIEWS)`);
          lines.push(``);
        } else {
          lines.push(String(defn).trim());
          lines.push(``);
        }

        safeWrite(filePath, lines.join('\n'));
        indexLines.push(`OK  ${schema}.${name} -> dumps/views/${schema}/${name}.view.sql`);
      } catch (e) {
        const msg = e?.message ? String(e.message) : String(e);
        safeWrite(filePath, `-- VIEW: ${schema}.${name}\n-- ERROR:\n-- ${msg}\n`);
        indexLines.push(`ERR ${schema}.${name} -> dumps/views/${schema}/${name}.view.sql`);
      }
    }

    safeWrite(path.join(OUT_DIR, `_index.txt`), indexLines.join('\n') + '\n');

    await db.close();

    console.log(`DONE: wrote ${views.length} view dumps to: ${OUT_DIR}`);
    console.log(`INDEX: ${path.join(OUT_DIR, '_index.txt')}`);
  } catch (err) {
    console.error('FATAL:', err);
    process.exit(1);
  }
})();
