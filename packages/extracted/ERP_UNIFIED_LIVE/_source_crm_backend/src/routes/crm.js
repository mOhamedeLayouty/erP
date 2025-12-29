const express = require("express");
const { buildInsert, buildUpdate, quoteIdent, fullTableSql } = require("../db/crud");

const router = express.Router();

const CUSTOMER_TABLE = process.env.CRM_CUSTOMER_TABLE || "DBA.Customer";
const CALLS_TABLE = process.env.CRM_CALLS_TABLE || "CRM.calls";
const CALL_HISTORY_TABLE = process.env.CRM_CALL_HISTORY_TABLE || "CRM.client_call_history";

const CUSTOMER_PK = process.env.CRM_CUSTOMER_PK || "customer_id";
const CALLS_PK = process.env.CRM_CALLS_PK || "call_id";
const CALL_HISTORY_PK = process.env.CRM_CALL_HISTORY_PK || "history_id";

function parsePagination(req) {
  const page = Math.max(1, Number(req.query.page || 1));
  const pageSize = Math.min(200, Math.max(1, Number(req.query.pageSize || 50)));
  return { page, pageSize, offset: (page - 1) * pageSize };
}

// Customers
router.get("/customers", async (req, res, next) => {
  const { page, pageSize, offset } = parsePagination(req);

  let db;
  try {
    db = await req.getDb();
    const tableSql = fullTableSql(CUSTOMER_TABLE);

    const rows = await db.conn.query(
      `SELECT * FROM ${tableSql} ORDER BY ${quoteIdent(CUSTOMER_PK)} DESC LIMIT ? OFFSET ?`,
      [pageSize, offset]
    );

    res.json({ page, pageSize, rows });
  } catch (e) {
    next(e);
  } finally {
    if (db) await db.close();
  }
});

router.get("/customers/:customerId", async (req, res, next) => {
  const customerId = req.params.customerId;
  let db;
  try {
    db = await req.getDb();
    const tableSql = fullTableSql(CUSTOMER_TABLE);
    const rows = await db.conn.query(
      `SELECT * FROM ${tableSql} WHERE ${quoteIdent(CUSTOMER_PK)} = ?`,
      [customerId]
    );
    if (!rows.length) return res.status(404).json({ error: { message: "Customer not found" } });
    res.json(rows[0]);
  } catch (e) {
    next(e);
  } finally {
    if (db) await db.close();
  }
});

router.post("/customers", async (req, res, next) => {
  let db;
  try {
    db = await req.getDb();
    const { sql, values } = await buildInsert(db.conn, CUSTOMER_TABLE, req.body || {});
    await db.conn.query(sql, values);
    res.status(201).json({ ok: true });
  } catch (e) {
    next(e);
  } finally {
    if (db) await db.close();
  }
});

router.put("/customers/:customerId", async (req, res, next) => {
  const customerId = req.params.customerId;
  let db;
  try {
    db = await req.getDb();
    const { sql, values } = await buildUpdate(db.conn, CUSTOMER_TABLE, CUSTOMER_PK, customerId, req.body || {});
    await db.conn.query(sql, values);
    res.json({ ok: true });
  } catch (e) {
    next(e);
  } finally {
    if (db) await db.close();
  }
});

router.delete("/customers/:customerId", async (req, res, next) => {
  const customerId = req.params.customerId;
  let db;
  try {
    db = await req.getDb();
    const tableSql = fullTableSql(CUSTOMER_TABLE);
    await db.conn.query(`DELETE FROM ${tableSql} WHERE ${quoteIdent(CUSTOMER_PK)} = ?`, [customerId]);
    res.json({ ok: true });
  } catch (e) {
    next(e);
  } finally {
    if (db) await db.close();
  }
});

// Calls for a customer
router.get("/customers/:customerId/calls", async (req, res, next) => {
  const customerId = req.params.customerId;
  const { page, pageSize, offset } = parsePagination(req);

  let db;
  try {
    db = await req.getDb();
    const tableSql = fullTableSql(CALLS_TABLE);

    const fk = process.env.CRM_CALLS_CUSTOMER_FK;
    if (fk) {
      const rows = await db.conn.query(
        `SELECT * FROM ${tableSql} WHERE ${quoteIdent(fk)} = ? ORDER BY ${quoteIdent(CALLS_PK)} DESC LIMIT ? OFFSET ?`,
        [customerId, pageSize, offset]
      );
      return res.json({ page, pageSize, rows });
    }

    const rows = await db.conn.query(
      `SELECT * FROM ${tableSql} ORDER BY ${quoteIdent(CALLS_PK)} DESC LIMIT ? OFFSET ?`,
      [pageSize, offset]
    );
    res.json({ page, pageSize, rows, note: "Set CRM_CALLS_CUSTOMER_FK to filter by customer." });
  } catch (e) {
    next(e);
  } finally {
    if (db) await db.close();
  }
});

router.post("/customers/:customerId/calls", async (req, res, next) => {
  let db;
  try {
    db = await req.getDb();
    const customerId = req.params.customerId;
    const fk = process.env.CRM_CALLS_CUSTOMER_FK;

    const payload = { ...(req.body || {}) };
    if (fk) payload[fk] = customerId;

    const { sql, values } = await buildInsert(db.conn, CALLS_TABLE, payload);
    await db.conn.query(sql, values);
    res.status(201).json({ ok: true });
  } catch (e) {
    next(e);
  } finally {
    if (db) await db.close();
  }
});

router.put("/calls/:callId", async (req, res, next) => {
  let db;
  try {
    db = await req.getDb();
    const callId = req.params.callId;
    const { sql, values } = await buildUpdate(db.conn, CALLS_TABLE, CALLS_PK, callId, req.body || {});
    await db.conn.query(sql, values);
    res.json({ ok: true });
  } catch (e) {
    next(e);
  } finally {
    if (db) await db.close();
  }
});

// Call history
router.get("/calls/:callId/history", async (req, res, next) => {
  let db;
  try {
    db = await req.getDb();
    const callId = req.params.callId;
    const tableSql = fullTableSql(CALL_HISTORY_TABLE);

    const fk = process.env.CRM_CALL_HISTORY_CALL_FK;
    if (fk) {
      const rows = await db.conn.query(
        `SELECT * FROM ${tableSql} WHERE ${quoteIdent(fk)} = ? ORDER BY ${quoteIdent(CALL_HISTORY_PK)} DESC`,
        [callId]
      );
      return res.json({ rows });
    }

    const rows = await db.conn.query(
      `SELECT * FROM ${tableSql} ORDER BY ${quoteIdent(CALL_HISTORY_PK)} DESC LIMIT 200`
    );
    res.json({ rows, note: "Set CRM_CALL_HISTORY_CALL_FK to filter by call." });
  } catch (e) {
    next(e);
  } finally {
    if (db) await db.close();
  }
});

router.post("/calls/:callId/history", async (req, res, next) => {
  let db;
  try {
    db = await req.getDb();
    const callId = req.params.callId;
    const fk = process.env.CRM_CALL_HISTORY_CALL_FK;

    const payload = { ...(req.body || {}) };
    if (fk) payload[fk] = callId;

    const { sql, values } = await buildInsert(db.conn, CALL_HISTORY_TABLE, payload);
    await db.conn.query(sql, values);
    res.status(201).json({ ok: true });
  } catch (e) {
    next(e);
  } finally {
    if (db) await db.close();
  }
});

module.exports = router;
