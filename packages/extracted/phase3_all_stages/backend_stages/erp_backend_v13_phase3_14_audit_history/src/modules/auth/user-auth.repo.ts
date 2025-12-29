import { connectDb } from '../../shared/db/odbc.js';

const USER_TABLE = process.env.USER_TABLE ?? '';
const COL_ID = process.env.USER_COL_ID ?? '';
const COL_NAME = process.env.USER_COL_NAME ?? '';
const COL_PASSWORD = process.env.USER_COL_PASSWORD ?? '';
const COL_ACTIVE = process.env.USER_COL_ACTIVE ?? '';
const COL_ROLE = process.env.USER_COL_ROLE ?? '';

export type UserRow = Record<string, any>;

function requireField(v: string, label: string) {
  if (!v) throw new Error(`Auth not configured: missing ${label}`);
  return v;
}

export async function getUserByLogin(userName: string): Promise<UserRow | null> {
  const t = requireField(USER_TABLE, 'USER_TABLE');
  const cName = requireField(COL_NAME, 'USER_COL_NAME');

  const cols = [COL_ID, COL_NAME, COL_PASSWORD, COL_ACTIVE, COL_ROLE].filter(Boolean);
  const selectCols = cols.length ? cols.join(', ') : '*';

  const db = await connectDb();
  try {
    const rows = await db.query<UserRow>(
      `SELECT TOP 1 ${selectCols} FROM ${t} WHERE ${cName} = ?`,
      [userName]
    );
    return rows[0] ?? null;
  } finally {
    await db.close();
  }
}
