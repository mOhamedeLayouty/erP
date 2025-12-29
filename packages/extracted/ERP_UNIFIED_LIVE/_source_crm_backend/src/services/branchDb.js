const path = require("path");
const fs = require("fs");
const odbc = require("odbc");

const branchesPath = path.join(__dirname, "..", "..", "branches.json");

function readBranches() {
  const raw = fs.readFileSync(branchesPath, "utf-8");
  const json = JSON.parse(raw);
  const map = new Map();
  for (const sc of (json.service_centers || [])) {
    map.set(Number(sc.service_center), sc);
  }
  return { json, map };
}

let cached = null;
function getBranchRegistry() {
  if (!cached) cached = readBranches();
  return cached;
}

async function getDbForServiceCenter(serviceCenter) {
  const { map } = getBranchRegistry();
  const rec = map.get(Number(serviceCenter));
  if (!rec) {
    const err = new Error(`Unknown service_center: ${serviceCenter}`);
    err.statusCode = 400;
    err.publicMessage = `Unknown service_center: ${serviceCenter}`;
    throw err;
  }

  const conn = await odbc.connect(rec.odbc_connection_string);
  return {
    serviceCenter: Number(serviceCenter),
    name: rec.name,
    conn,
    async close() {
      try { await conn.close(); } catch {}
    }
  };
}

function listServiceCenters() {
  const { json } = getBranchRegistry();
  return (json.service_centers || []).map(x => ({
    service_center: Number(x.service_center),
    name: x.name
  }));
}

module.exports = { getDbForServiceCenter, listServiceCenters };
