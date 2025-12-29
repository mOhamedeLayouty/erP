import fs from 'node:fs';
import path from 'node:path';
import odbc from 'odbc';

const OUTPUT_DIR = path.resolve('reference');
const OUTPUT_FILE = path.join(OUTPUT_DIR, 'dump_last10_all_tables.txt');

if (!fs.existsSync(OUTPUT_DIR)) {
  fs.mkdirSync(OUTPUT_DIR, { recursive: true });
}

const connStr = process.env.ODBC_CONNECTION_STRING;
if (!connStr) {
  console.error('❌ ODBC_CONNECTION_STRING not set');
  process.exit(1);
}

const IGNORED_TABLES = [
  // حط أي جداول سيستم تحب تستبعدها هنا
];

function detectOrderColumn(columns) {
  const candidates = [
    'id',
    'created_at',
    'createdon',
    'created_date',
    'entry_date',
    'date',
    'time',
    'timestamp'
  ];
  return columns.find(c =>
    candidates.some(k => c.toLowerCase().includes(k))
  );
}

(async () => {
  const db = await odbc.connect(connStr);
  const out = fs.createWriteStream(OUTPUT_FILE, { flags: 'w' });

  try {
    const tables = await db.query(`
      SELECT table_name
      FROM SYS.SYSTABLE
      WHERE creator = 'DBA'
        AND table_type = 'BASE'
    `);

    for (const t of tables) {
      const table = `DBA.${t.table_name}`;
      if (IGNORED_TABLES.includes(table)) continue;

      out.write(`\n\n==============================\n`);
      out.write(`TABLE: ${table}\n`);
      out.write(`==============================\n`);

      try {
        const cols = await db.query(`
          SELECT column_name
          FROM INFORMATION_SCHEMA.COLUMNS
          WHERE table_name = ?
        `, [t.table_name]);

        const colNames = cols.map(c => c.column_name);
        const orderCol = detectOrderColumn(colNames);

        const sql = orderCol
          ? `SELECT TOP 10 * FROM ${table} ORDER BY ${orderCol} DESC`
          : `SELECT TOP 10 * FROM ${table}`;

        const rows = await db.query(sql);

        rows.forEach(r => {
          out.write(JSON.stringify(r, null, 2) + '\n');
        });

      } catch (e) {
        out.write(`⚠️ ERROR reading table ${table}: ${e.message}\n`);
      }
    }

    console.log(`✅ Dump created: ${OUTPUT_FILE}`);
  } finally {
    out.close();
    await db.close();
  }
})();
