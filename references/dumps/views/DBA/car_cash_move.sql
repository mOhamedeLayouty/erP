-- VIEW: DBA.car_cash_move
-- generated_at: 2025-12-29T14:36:30.523Z
-- object_id: 19840
-- table_id: 1440
-- source_via: SYS.SYSVIEW(view_object_id=object_id)

create view DBA.car_cash_move( doc_no,receipt_date,exp_type,customer_name_a,receipt_amount,pay_cyy,ccy,ccy_id,income,cash_id,Cash_type,receipt_type,log_store,brand ) as
  --V1.2 remove join with detail in car_receipt to get advanced pay.
  --V1.3 avoid receipt with pay type 'T'(sattlement vendor invoice)
  --V1.4
  --V1.5 add currency_id column and rate
  --V1.6 add cash_type column[bank/cash]
  select distinct
    cast(car_receipt_header.doc_no as varchar(20)),
    car_receipt_header.receipt_date,' Income ' as exp_type,
    customer.customer_name_a,
    car_receipt_header.receipt_amount*isnull(car_receipt_header.curr_rate,cur.rate),
    car_receipt_header.receipt_amount as pay_cyy,
    cur.name as ccy,
    cur.curr_id as ccy_id,
    1 as income,
    car_receipt_header.cash_id,
    (select car_cash.bank_flag from DBA.car_cash where car_cash.cash_id = car_receipt_header.cash_id) as Cash_type,
    car_receipt_header.paymenttype,
    car_receipt_header.log_store,
    car_receipt_header.brand
    from DBA.car_receipt_header
      ,DBA.customer,Ledger.cur
    where(car_receipt_header.customer_id = customer.customer_id)
    and(car_receipt_header.receipt_currency = cur.curr_id and cur.company_code = DBA.f_get_about('gl_company_code')) and(car_receipt_header.paymenttype not in( 'S','T' ) )
    and(car_receipt_header.delete_flag = 'N' or car_receipt_header.delete_flag is null) union
  //------------------------------------------------------
  select distinct car_doc_son_rec.doc_t_num,
    car_doc_son_rec.doc_date,
    (select distinct account.acc_name from ledger.account where car_doc_son_rec.hld_acc = account.acc_no and car_doc_son_rec.company_code = ledger.account.company_code),
    car_doc_son_rec.doc_rem,
    car_doc_son_rec.doc_tot,
    car_doc_son_rec.curr_sub_tot,
    cur.name,
    cur.curr_id as ccy_id,
    2 as expense,
    car_doc_son_rec.acc_rec,
    (select car_cash.bank_flag from DBA.car_cash where car_cash.cash_id = car_doc_son_rec.acc_rec) as Cash_type,
    car_doc_son_rec.doc_tot_type,
    car_doc_son_rec.log_store,
    car_doc_son_rec.brand
    from DBA.car_doc_son_rec
      ,Ledger.cur
    where(car_doc_son_rec.curr_id = cur.curr_id and cur.company_code = DBA.f_get_about('gl_company_code'))
    and(car_doc_son_rec.doc_type in( '1','DB','DD','DS','DC','EM' ) ) union
  //----------------------------------------------------------------------------------
  select distinct car_doc_son_rec.doc_t_num,
    car_doc_son_rec.doc_date,
    (select distinct account.acc_name from ledger.account where car_doc_son_rec.hld_acc = account.acc_no and car_doc_son_rec.company_code = ledger.account.company_code),
    car_doc_son_rec.doc_rem,
    car_doc_son_rec.doc_tot,
    car_doc_son_rec.curr_sub_tot,
    cur.name,
    cur.curr_id as ccy_id,
    3 as add_to_cash,
    car_doc_son_rec.acc_rec,
    (select car_cash.bank_flag from DBA.car_cash where car_cash.cash_id = car_doc_son_rec.acc_rec) as Cash_type,
    car_doc_son_rec.doc_tot_type,
    car_doc_son_rec.log_store,
    car_doc_son_rec.brand
    from DBA.car_doc_son_rec
      ,Ledger.cur
    where(car_doc_son_rec.curr_id = cur.curr_id and cur.company_code = DBA.f_get_about('gl_company_code'))
    and(car_doc_son_rec.doc_type in( '2','CR','CC','CS','E' ) ) union
  //---------------------------------------------------------------------------------
  select distinct car_doc_son_rec.doc_t_num,
    car_doc_son_rec.doc_date,
    dbs_s_employe.emp_name_e,
    car_doc_son_rec.doc_rem,
    car_doc_son_rec.doc_tot,
    car_doc_son_rec.curr_sub_tot,
    cur.name,
    cur.curr_id as ccy_id,
    4 as expense_resp,
    car_doc_son_rec.acc_rec,
    (select car_cash.bank_flag from DBA.car_cash where car_cash.cash_id = car_doc_son_rec.acc_rec) as Cash_type,
    car_doc_son_rec.doc_tot_type,
    car_doc_son_rec.log_store,
    car_doc_son_rec.brand
    from DBA.car_doc_son_rec
      ,hr.dbs_s_employe
      ,Ledger.cur
    where(car_doc_son_rec.resp_user = dbs_s_employe.emp_code)
    and(car_doc_son_rec.curr_id = cur.curr_id and cur.company_code = DBA.f_get_about('gl_company_code'))
    and(car_doc_son_rec.doc_type = '3') union
  //-------------------------------------------------------------------------------------------
  select distinct car_doc_son_rec.doc_t_num,
    car_doc_son_rec.doc_date,
    dbs_s_employe.emp_name_e,
    car_doc_son_rec.doc_rem,
    car_doc_son_rec.doc_tot,
    car_doc_son_rec.curr_sub_tot,
    cur.name,
    cur.curr_id as ccy_id,
    5 as add_to_cash_resp,
    car_doc_son_rec.acc_rec,
    (select car_cash.bank_flag from DBA.car_cash where car_cash.cash_id = car_doc_son_rec.acc_rec) as Cash_type,
    car_doc_son_rec.doc_tot_type,
    car_doc_son_rec.log_store,
    car_doc_son_rec.brand
    from DBA.car_doc_son_rec
      ,hr.dbs_s_employe
      ,Ledger.cur
    where(car_doc_son_rec.resp_user = dbs_s_employe.emp_code)
    and(car_doc_son_rec.curr_id = cur.curr_id and cur.company_code = DBA.f_get_about('gl_company_code'))
    and(car_doc_son_rec.doc_type = '4') union
  select distinct
    cast(car_refund_header.refund_id as varchar(20)),
    car_refund_header.refund_date,' Refund ' as exp_type,
    customer.customer_name_a,
    car_refund_header.refund_amount*isnull(car_refund_header.curr_rate,cur.rate),
    car_refund_header.refund_amount as pay_cyy,
    cur.name as ccy,
    cur.curr_id as ccy_id,
    6 as refund,
    car_refund_header.cash_id,
    (select car_cash.bank_flag from DBA.car_cash where car_cash.cash_id = car_refund_header.cash_id) as Cash_type,
    car_refund_header.paymenttype,
    car_refund_header.log_store,
    car_refund_header.brand
    from DBA.car_refund_header
      ,DBA.customer,Ledger.cur
    where(car_refund_header.customer_id = customer.customer_id)
    and(car_refund_header.refund_currency = cur.curr_id and cur.company_code = DBA.f_get_about('gl_company_code'))
    and(car_refund_header.delete_flag = 'N' or car_refund_header.delete_flag is null)
