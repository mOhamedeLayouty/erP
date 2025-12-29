const cache = new Map();

async function getTableColumns(conn, fullTableName) {
  const key = fullTableName.toLowerCase();
  if (cache.has(key)) return cache.get(key);

  let schema = null;
  let table = fullTableName;
  if (fullTableName.includes(".")) {
    const parts = fullTableName.split(".");
    schema = parts[0];
    table = parts[1];
  }

  const sql = schema
    ? `SELECT column_name FROM INFORMATION_SCHEMA.COLUMNS WHERE table_schema = ? AND table_name = ?`
    : `SELECT column_name FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = ?`;

  const params = schema ? [schema, table] : [table];
  const rows = await conn.query(sql, params);
  const cols = rows.map(r => (r.column_name || r.COLUMN_NAME)).filter(Boolean);

  if (!cols.length) {
    const err = new Error(`Could not read columns for table: ${fullTableName}`);
    err.statusCode = 500;
    err.publicMessage = `Metadata error for table: ${fullTableName}`;
    throw err;
  }

  cache.set(key, cols);
  return cols;
}

module.exports = { getTableColumns };
