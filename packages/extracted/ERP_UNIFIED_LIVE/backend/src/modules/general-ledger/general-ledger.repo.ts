import { connectDb } from '../../shared/db/odbc.js';

const ACCOUNTS_TABLE = process.env.GL_ACCOUNTS_TABLE ?? 'DBA.account';
const LEDGER_TABLE = process.env.GL_LEDGER_TABLE ?? 'DBA.ledger';
const JOURNALS_TABLE = process.env.GL_JOURNALS_TABLE ?? 'DBA.jrnl_son';
const BUDGETS_TABLE = process.env.GL_BUDGETS_TABLE ?? 'DBA.budget';

export async function listAccounts(limit = 200) {
  const db = await connectDb();
  try {
    return await db.query(`SELECT TOP ${limit} * FROM ${ACCOUNTS_TABLE}`);
  } finally {
    await db.close();
  }
}

export async function listLedgers(limit = 200) {
  const db = await connectDb();
  try {
    return await db.query(`SELECT TOP ${limit} * FROM ${LEDGER_TABLE} ORDER BY 1 DESC`);
  } finally {
    await db.close();
  }
}

export async function listJournals(limit = 200) {
  const db = await connectDb();
  try {
    return await db.query(`SELECT TOP ${limit} * FROM ${JOURNALS_TABLE} ORDER BY 1 DESC`);
  } finally {
    await db.close();
  }
}

export async function listBudgets(limit = 200) {
  const db = await connectDb();
  try {
    return await db.query(`SELECT TOP ${limit} * FROM ${BUDGETS_TABLE} ORDER BY 1 DESC`);
  } finally {
    await db.close();
  }
}
