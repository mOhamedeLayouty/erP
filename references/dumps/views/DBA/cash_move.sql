-- VIEW: DBA.cash_move
-- generated_at: 2025-12-29T14:36:30.524Z
-- object_id: 38078
-- table_id: 1498
-- source_via: SYS.SYSVIEW(view_object_id=object_id)

create view /////////////////////////////////////////
  DBA.cash_move( receiptno,paymentdate,exp_type,customer_name_a,customer_name_e,paymentamount,pay_cyy,ccy,income,cash_id,paymenttype,service_center,location_id,supported_documents ) as
  -- change currency to be from ledger  
  -- V1.1 customer name for paid on invoice  
  -- V1.2 add english customer name  
  -- V1.3 get currency name from ledger.curr in receipt as doc_son_rec  
  -- V1.4 show doc_rem in case we choose a vendor  
  -- V1.5 show doc_rem in case we choose an employee  
  -- V1.6 add supported_documents column from doc_son_rec
  -- 1st block: ws_receiptdetail (no supported_documents, so use NULL)
  select distinct
    cast(ws_receiptdetail.receiptno as varchar(20)),
    ws_receiptdetail.paymentdate,
    ' Income ' as exp_type,
    customer.customer_name_a,
    customer.customer_name_e,
    ws_receiptdetail.paymentamount,
    ws_receiptdetail.paymentamount as pay_cyy,
    (select top 1 cur.name
      from Ledger.cur
      where cur.rate = 1
      and cur.company_code = DBA.f_get_about('gl_company_code')) as ccy,
    1 as income,
    ws_receiptdetail.cash_id,
    ws_receiptdetail.paymenttype,
    ws_receiptdetail.service_center,
    ws_receiptdetail.location_id,
    null as supported_documents
    from DBA.ws_receipt
      ,DBA.ws_receiptdetail
      ,DBA.customer
    where ws_receiptdetail.receipt_id = ws_receipt.receipt_id
    and ws_receiptdetail.service_center = ws_receipt.service_center
    and ws_receiptdetail.main_location_id = ws_receipt.location_id
    and ws_receipt.custid = customer.customer_id
    and(ws_receiptdetail.delete_flag = 'N' or ws_receiptdetail.delete_flag is null) union
  -- 2nd block: doc_son_rec (type = '1')
  select distinct
    doc_son_rec.doc_t_num,
    doc_son_rec.doc_date,
    (select distinct account.acc_name
      from ledger.account
      where doc_son_rec.hld_code = account.acc_no
      and doc_son_rec.company_code = ledger.account.company_code),
    (case doc_son_rec.doc_detail_type
    when 1 then doc_son_rec.doc_rem
    when 3 then doc_son_rec.doc_rem
    when 4 then doc_son_rec.doc_rem
    else(select customer.customer_name_a
        from DBA.customer
        where customer.customer_id = doc_son_rec.customer_id)
    end),
    (case doc_son_rec.doc_detail_type
    when 1 then doc_son_rec.doc_rem
    when 3 then doc_son_rec.doc_rem
    when 4 then doc_son_rec.doc_rem
    else(select customer.customer_name_e
        from DBA.customer
        where customer.customer_id = doc_son_rec.customer_id)
    end),
    doc_son_rec.doc_tot,
    doc_son_rec.curr_sub_tot,
    ledger.cur.name,
    2 as expense,
    doc_son_rec.acc_rec,
    doc_son_rec.customer_flag,
    doc_son_rec.service_center,
    doc_son_rec.location_id,
    doc_son_rec.supported_documents
    from DBA.doc_son_rec
      ,ledger.cur
    where doc_son_rec.curr_id = ledger.cur.curr_id
    and doc_son_rec.doc_type = '1' union
  -- 3rd block: doc_son_rec (type = '2')
  select distinct
    doc_son_rec.doc_t_num,
    doc_son_rec.doc_date,
    (select distinct account.acc_name
      from ledger.account
      where doc_son_rec.hld_code = account.acc_no
      and doc_son_rec.company_code = ledger.account.company_code),
    (case doc_son_rec.doc_detail_type
    when 1 then doc_son_rec.doc_rem
    when 3 then doc_son_rec.doc_rem
    when 4 then doc_son_rec.doc_rem
    else(select customer.customer_name_a
        from DBA.customer
        where customer.customer_id = doc_son_rec.customer_id)
    end),
    (case doc_son_rec.doc_detail_type
    when 1 then doc_son_rec.doc_rem
    when 3 then doc_son_rec.doc_rem
    when 4 then doc_son_rec.doc_rem
    else(select customer.customer_name_e
        from DBA.customer
        where customer.customer_id = doc_son_rec.customer_id)
    end),
    doc_son_rec.doc_tot,
    doc_son_rec.curr_sub_tot,
    ledger.cur.name,
    3 as add_to_cash,
    doc_son_rec.acc_rec,
    doc_son_rec.customer_flag,
    doc_son_rec.service_center,
    doc_son_rec.location_id,
    doc_son_rec.supported_documents
    from DBA.doc_son_rec
      ,ledger.cur
    where doc_son_rec.curr_id = ledger.cur.curr_id
    and doc_son_rec.doc_type = '2' union
  -- 4th block: doc_son_rec + dbs_s_employe (type = '3')
  select distinct
    doc_son_rec.doc_t_num,
    doc_son_rec.doc_date,
    dbs_s_employe.emp_name_e,
    doc_son_rec.doc_rem,
    doc_son_rec.doc_rem,
    doc_son_rec.doc_tot,
    doc_son_rec.curr_sub_tot,
    ledger.cur.name,
    4 as expense_resp,
    doc_son_rec.acc_rec,
    doc_son_rec.customer_flag,
    doc_son_rec.service_center,
    doc_son_rec.location_id,
    doc_son_rec.supported_documents
    from DBA.doc_son_rec
      ,hr.dbs_s_employe
      ,ledger.cur
    where doc_son_rec.resp_user = dbs_s_employe.emp_code
    and doc_son_rec.curr_id = ledger.cur.curr_id
    and doc_son_rec.doc_type = '3' union
  -- 5th block: doc_son_rec + dbs_s_employe (type = '4')
  select distinct
    doc_son_rec.doc_t_num,
    doc_son_rec.doc_date,
    dbs_s_employe.emp_name_e,
    doc_son_rec.doc_rem,
    doc_son_rec.doc_rem,
    doc_son_rec.doc_tot,
    doc_son_rec.curr_sub_tot,
    ledger.cur.name,
    5 as add_to_cash_resp,
    doc_son_rec.acc_rec,
    doc_son_rec.customer_flag,
    doc_son_rec.service_center,
    doc_son_rec.location_id,
    doc_son_rec.supported_documents
    from DBA.doc_son_rec
      ,hr.dbs_s_employe
      ,ledger.cur
    where doc_son_rec.resp_user = dbs_s_employe.emp_code
    and doc_son_rec.curr_id = ledger.cur.curr_id
    and doc_son_rec.doc_type = '4'
