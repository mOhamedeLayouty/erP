const { getTableColumns } = require("./metadata");

function quoteIdent(name) {
  return `"${name}"`;
}

function parseFullTable(fullTableName) {
  if (fullTableName.includes(".")) {
    const [schema, table] = fullTableName.split(".");
    return { schema, table };
  }
  return { schema: null, table: fullTableName };
}

function fullTableSql(fullTableName) {
  const { schema, table } = parseFullTable(fullTableName);
  return schema ? `${quoteIdent(schema)}.${quoteIdent(table)}` : quoteIdent(table);
}

async function buildInsert(conn, fullTableName, payload) {
  const cols = await getTableColumns(conn, fullTableName);
  const keys = Object.keys(payload);

  const invalid = keys.filter(k => !cols.includes(k));
  if (invalid.length) {
    const err = new Error(`Unknown columns: ${invalid.join(", ")}`);
    err.statusCode = 400;
    err.publicMessage = `Unknown columns: ${invalid.join(", ")}`;
    throw err;
  }

  if (!keys.length) {
    const err = new Error("Empty payload");
    err.statusCode = 400;
    err.publicMessage = "Empty payload";
    throw err;
  }

  const colSql = keys.map(quoteIdent).join(", ");
  const placeholders = keys.map(() => "?").join(", ");
  const values = keys.map(k => payload[k]);

  const sql = `INSERT INTO ${fullTableSql(fullTableName)} (${colSql}) VALUES (${placeholders})`;
  return { sql, values };
}

async function buildUpdate(conn, fullTableName, pkName, pkValue, payload) {
  const cols = await getTableColumns(conn, fullTableName);
  const keys = Object.keys(payload).filter(k => k !== pkName);

  const invalid = keys.filter(k => !cols.includes(k));
  if (invalid.length) {
    const err = new Error(`Unknown columns: ${invalid.join(", ")}`);
    err.statusCode = 400;
    err.publicMessage = `Unknown columns: ${invalid.join(", ")}`;
    throw err;
  }

  if (!keys.length) {
    const err = new Error("Empty payload");
    err.statusCode = 400;
    err.publicMessage = "Empty payload";
    throw err;
  }

  const setSql = keys.map(k => `${quoteIdent(k)} = ?`).join(", ");
  const values = keys.map(k => payload[k]);
  values.push(pkValue);

  const sql = `UPDATE ${fullTableSql(fullTableName)} SET ${setSql} WHERE ${quoteIdent(pkName)} = ?`;
  return { sql, values };
}

module.exports = { quoteIdent, fullTableSql, buildInsert, buildUpdate };
