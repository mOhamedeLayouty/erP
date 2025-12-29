import { connectDb } from '../../shared/db/odbc.js';

const T_CUSTOMER = 'DBA.Customer';
const T_EQPT = 'DBA.ws_Eqpt';

export async function listCustomers(limit = 200) {
  const db = await connectDb();
  try {
    return await db.query(
      `SELECT TOP ${limit} customer_id, customer_name_a, customer_name_e, GSM, email, address FROM ${T_CUSTOMER} ORDER BY customer_id`
    );
  } finally { await db.close(); }
}

export async function createCustomer(input: any, actor_user_id: string) {
  // Insert only if columns exist; otherwise reject safely
  // Required baseline
  const cols = ['BusPhone', 'CardExpiryDate', 'CardNumber', 'Commission', 'CustomerSerial', 'GSM', 'GSM2', 'GSM3', 'HomePhone', 'Invoice_delivery_add', 'IsNotify', 'NotifyLanguageId', 'VWClub', 'abbreviation', 'acc_no', 'active', 'add_recieve_check', 'address', 'address2', 'annual_income', 'birthdate', 'blacklist', 'branch_code', 'building_number', 'business_address', 'business_city', 'business_region', 'car_acc_no', 'car_credit_flag', 'car_credit_limit', 'car_due_days', 'car_o_bal', 'card_type', 'category', 'city_id', 'commercial_register', 'company_field', 'company_name', 'contact_person', 'contact_person_email', 'contact_person_mobile', 'contact_person_phone', 'corp_code', 'country_id', 'credit_flag', 'credit_limit', 'cust_segment_id', 'customer_age', 'customer_id', 'customer_name_a', 'customer_name_e', 'customer_ref', 'customer_type', 'due_days', 'edit_pc', 'edit_user', 'email', 'employees_number', 'expiration_date', 'extra_notes', 'family_members_no', 'fax', 'file_tax', 'fixedtype_id', 'floor', 'gender', 'governorate_id', 'hobbies', 'home_area', 'housing_category', 'housing_type', 'id_exp', 'id_isssue_place', 'id_no', 'id_type', 'job_another_income', 'job_bank', 'job_company_name', 'job_department', 'job_hire_date', 'job_ibn', 'job_manager_mob', 'job_manager_name', 'job_other_finance', 'job_salary_date', 'job_salary_type', 'landmark', 'lic_val_from', 'lic_val_to', 'license_no', 'marital_status', 'mobile2', 'monthly_payment', 'nationality_code', 'no_children', 'non_taxable', 'o_bal', 'office_ph1', 'office_ph2', 'online_password', 'partner', 'phone_ext', 'po_box', 'position', 'postal_code', 'preferred_address_mailing', 'preferred_language_correspondence', 'preferred_magazines', 'product_delivery_add', 'reason', 'room', 'sales_rep', 'salestax_registration', 'service_center', 'sp_code', 'sp_id', 'street_name', 'tax_office_name', 'type', 'type_code', 'user_id', 'user_name', 'vend_code'];
  const needed = ['customer_id'];
  for (const k of needed) {
    if (!cols.includes(k)) throw new Error('Locked schema mismatch: missing ' + k);
  }

  // Build dynamic insert using allowed columns
  const allowed = ['customer_id','customer_name_a','customer_name_e','GSM','email','address','user_id','entry_date'];
  const use = allowed.filter(c => cols.includes(c) && (c === 'customer_id' || input[c] !== undefined || c === 'user_id' || c === 'entry_date'));
  const placeholders = use.map(_ => '?').join(',');
  const values = use.map(c => c === 'user_id' ? actor_user_id : (c === 'entry_date' ? null : (input[c] ?? null)));

  const db = await connectDb();
  try {
    const sql = `INSERT INTO ${T_CUSTOMER} (${use.join(',')}) VALUES (${placeholders})`;
    // entry_date if present in schema and null: set CURRENT TIMESTAMP via SQL
    // If entry_date included, replace its placeholder with CURRENT TIMESTAMP
    let finalSql = sql;
    if (use.includes('entry_date')) {
      // crude replace: last occurrence of ? for entry_date
      const parts = finalSql.split('?');
      // find index
      const idx = use.indexOf('entry_date');
      // rebuild with CURRENT TIMESTAMP at that position
      let q = 0;
      finalSql = '';
      for (let i=0;i<use.length;i++) {
        finalSql += (i===0 ? '' : ',');
      }
      // rebuild properly
      const colsPart = use.join(',');
      const valsPart = use.map(c => c==='entry_date' ? 'CURRENT TIMESTAMP' : '?').join(',');
      finalSql = `INSERT INTO ${T_CUSTOMER} (${colsPart}) VALUES (${valsPart})`;
      // remove entry_date from values
      const v2 = use.filter(c=>c!=='entry_date').map(c => c==='user_id' ? actor_user_id : (input[c] ?? null));
      return await db.exec(finalSql, v2);
    }
    return await db.exec(finalSql, values);
  } finally { await db.close(); }
}

export async function listEquipment(limit = 200) {
  const db = await connectDb();
  try {
    return await db.query(
      `SELECT TOP ${limit} eqpt_id, licence_no, vin_no, year, eqpt_number, service_center FROM ${T_EQPT} ORDER BY eqpt_id`
    );
  } finally { await db.close(); }
}
