import { connectDb } from '../../shared/db/odbc.js';

const EMPLOYEES_TABLE = process.env.HR_EMPLOYEES_TABLE ?? 'DBA.dbs_s_employe';
const ATTENDANCE_TABLE = process.env.HR_ATTENDANCE_TABLE ?? 'DBA.attendance';
const VACATIONS_TABLE = process.env.HR_VACATIONS_TABLE ?? 'DBA.emp_vacations';

export async function listEmployees(limit = 200) {
  const db = await connectDb();
  try {
    return await db.query(`SELECT TOP ${limit} * FROM ${EMPLOYEES_TABLE}`);
  } finally {
    await db.close();
  }
}

export async function listAttendance(limit = 200) {
  const db = await connectDb();
  try {
    return await db.query(`SELECT TOP ${limit} * FROM ${ATTENDANCE_TABLE} ORDER BY 1 DESC`);
  } finally {
    await db.close();
  }
}

export async function listVacations(limit = 200) {
  const db = await connectDb();
  try {
    return await db.query(`SELECT TOP ${limit} * FROM ${VACATIONS_TABLE} ORDER BY 1 DESC`);
  } finally {
    await db.close();
  }
}
