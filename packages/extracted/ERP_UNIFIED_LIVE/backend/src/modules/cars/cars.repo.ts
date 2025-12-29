import { connectDb } from '../../shared/db/odbc.js';

const VEHICLES_TABLE = process.env.CARS_VEHICLES_TABLE ?? 'DBA.vehicle';
const CUSTOMERS_TABLE = process.env.CARS_CUSTOMERS_TABLE ?? 'DBA.customer';
const SALES_DOCS_TABLE = process.env.CARS_SALES_DOCS_TABLE ?? 'DBA.ws_sales_installment_doc';

export async function listVehicles(limit = 200) {
  const db = await connectDb();
  try {
    return await db.query(`SELECT TOP ${limit} * FROM ${VEHICLES_TABLE}`);
  } finally {
    await db.close();
  }
}

export async function listCarCustomers(limit = 200) {
  const db = await connectDb();
  try {
    return await db.query(`SELECT TOP ${limit} * FROM ${CUSTOMERS_TABLE}`);
  } finally {
    await db.close();
  }
}

export async function listSalesDocs(limit = 200) {
  const db = await connectDb();
  try {
    return await db.query(`SELECT TOP ${limit} * FROM ${SALES_DOCS_TABLE} ORDER BY 1 DESC`);
  } finally {
    await db.close();
  }
}
