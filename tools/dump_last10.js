#!/usr/bin/env node

/**
 * Dump “last 10” rows from all tables in selected schemas.
 *
 * NOTE:
 * - Without a reliable primary key, “last” is best-effort.
 * - We try ORDER BY 1 DESC first (often works when first column is an ID).
 * - If that fails, we fallback to a plain SELECT TOP 10 *.
 *
 * Environment:
 *   ODBC_CONNECTION_STRING  (required)
 *   DUMP_SCHEMAS            (default: DBA,CRM)
 *   DUMP_OUT               (default: ./db_last10_dump.txt)
 */

const fs = require('fs');
const path = require('path');

function nowIso() {
  return new Date().toISOString();
}

function safeString(v) {
  if (v === null || v === undefined) return '';
  if (typeof v === 'object') {
    // Buffers / dates / objects
    if (Buffer.isBuffer(v)) return `<Buffer len=${v.length}>`;
    if (v instanceof Date) return v.toISOString();
    try {
      return JSON.stringify(v);
    } catch {
      return String(v);
    }
  }
  return String(v);
}

async function main() {
  const connStr = process.env.ODBC_CONNECTION_STRING;
  if (!connStr) {
    console.error('ERROR: Missing ODBC_CONNECTION_STRING');
    process.exit(1);
  }

  const odbc = require('odbc');

  const schemas = (process.env.DUMP_SCHEMAS || 'DBA,CRM')
    .split(',')
    .map((s) => s.trim())
    .filter(Boolean);

  const outPath = path.resolve(process.env.DUMP_OUT || './db_last10_dump.txt');
  const outDir = path.dirname(outPath);
  fs.mkdirSync(outDir, { recursive: true });

  const c = await odbc.connect(connStr);
  try {
    const header = [
      `# ERP DB dump (TOP 10 per table)`,
      `# time: ${nowIso()}`,
      `# schemas: ${schemas.join(', ')}`,
      `# WARNING: order is best-effort; if no ORDER BY possible results may be nondeterministic`,
      ''
    ].join('\n');
    fs.writeFileSync(outPath, header, 'utf8');

    // Get table list
    const placeholders = schemas.map(() => '?').join(',');
    const tables = await c.query(
      `SELECT table_schema, table_name
         FROM INFORMATION_SCHEMA.TABLES
        WHERE table_type = 'BASE TABLE'
          AND table_schema IN (${placeholders})
        ORDER BY table_schema, table_name`,
      schemas
    );

    for (const t of tables) {
      const schema = t.table_schema;
      const name = t.table_name;
      const full = `${schema}.${name}`;

      fs.appendFileSync(outPath, `\n\n## ${full}\n`, 'utf8');

      let rows;
      try {
        rows = await c.query(`SELECT TOP 10 * FROM ${full} ORDER BY 1 DESC`);
      } catch (e1) {
        fs.appendFileSync(outPath, `# NOTE: ORDER BY 1 DESC failed -> fallback to unordered TOP 10\n`, 'utf8');
        try {
          rows = await c.query(`SELECT TOP 10 * FROM ${full}`);
        } catch (e2) {
          fs.appendFileSync(outPath, `# ERROR: failed to query table: ${safeString(e2?.message || e2)}\n`, 'utf8');
          continue;
        }
      }

      if (!rows || rows.length === 0) {
        fs.appendFileSync(outPath, `# empty\n`, 'utf8');
        continue;
      }

      // Columns
      const cols = Object.keys(rows[0]).filter((k) => !['statement', 'parameters', 'return', 'count', 'columns'].includes(k));
      fs.appendFileSync(outPath, cols.join('\t') + '\n', 'utf8');
      for (const r of rows) {
        const line = cols.map((cname) => safeString(r[cname]).replace(/\r?\n/g, ' ')).join('\t');
        fs.appendFileSync(outPath, line + '\n', 'utf8');
      }
    }

    console.log(`OK: wrote ${outPath}`);
  } finally {
    try { await c.close(); } catch {}
  }
}

main().catch((e) => {
  console.error('FATAL:', e);
  process.exit(1);
});
