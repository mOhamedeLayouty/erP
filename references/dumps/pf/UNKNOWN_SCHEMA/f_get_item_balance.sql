-- PF: UNKNOWN_SCHEMA.f_get_item_balance
-- proc_id: 380
-- generated_at: 2025-12-29T13:53:28.802Z

create function DBA.f_get_item_balance( in as_item varchar(50),in an_center integer,in an_location integer,in an_store integer )  /* @parameter_name parameter_type [= default_value], ... */
returns numeric(20,7)
begin
  declare ldc_credit decimal(20,7);
  declare ldc_debit decimal(20,7);
  declare ldc_return decimal(20,7);
  declare ldc_trans_from decimal(20,7);
  declare ldc_trans_to decimal(20,7);
  declare ldc_BgBal decimal(20,7);
  declare ldc_bal decimal(20,7);
  declare ldd_date date;
  declare ldt_time time;
  // 
  select sc_balance.bg_balance,
    sc_balance.bg_date,
    sc_balance.bg_time
    into ldc_BgBal,ldd_date,ldt_time
    from sc_balance
    where(sc_balance.item_id = as_item)
    and(sc_balance.service_center = an_center)
    and(sc_balance.location_id = an_location)
    and(sc_balance.store_id = an_store);
  set ldd_date = IsNull(ldd_date,'1900-01-01');
  set ldt_time = IsNull(ldt_time,'0001');
  //Credit
  select Sum(sc_credit_detail.qty)
    into ldc_credit from sc_credit_detail
      ,sc_credit_header
    where(sc_credit_detail.credit_header = sc_credit_header.credit_header)
    and(sc_credit_header.service_center = sc_credit_detail.service_center)
    and(sc_credit_detail.location_id = sc_credit_header.location_id)
    and((sc_credit_detail.item_id = as_item)
    and(sc_credit_header.store_id = an_store)
    and(sc_credit_header.service_center = an_center)
    and(sc_credit_header.location_id = an_location)
    and(credit_date > ldd_date or(credit_date = ldd_date and trans_time > ldt_time)));
  //Debit
  select sum(sc_debit_detail.qty)
    into ldc_debit from sc_debit_detail
      ,sc_debit_header
    where(sc_debit_detail.debit_header = sc_debit_header.debit_header)
    and(sc_debit_header.service_center = sc_debit_detail.service_center)
    and(sc_debit_header.location_id = sc_debit_detail.location_id)
    and((sc_debit_detail.item_id = as_item)
    and(sc_debit_header.store_id = an_store)
    and(sc_debit_header.service_center = an_center)
    and(sc_debit_header.location_id = an_location)
    and(debit_date > ldd_date or(debit_date = ldd_date and trans_time > ldt_time)));
  //Return
  select sum(sc_ret_detail.qty)
    into ldc_return from sc_ret_detail
      ,sc_ret_header
    where(sc_ret_detail.credit_header = sc_ret_header.credit_header)
    and(sc_ret_header.service_center = sc_ret_detail.service_center)
    and(sc_ret_header.location_id = sc_ret_detail.location_id)
    and((sc_ret_detail.item_id = as_item)
    and(sc_ret_header.store_id = an_store)
    and(sc_ret_header.service_center = an_center)
    and(sc_ret_header.location_id = an_location)
    and(credit_date > ldd_date or(credit_date = ldd_date and trans_time > ldt_time)));
  //trans from
  select Sum(sc_transfer_detail.qty)
    into ldc_trans_from from sc_transfer_detail
      ,sc_transfer_header
    where(sc_transfer_detail.credit_header = sc_transfer_header.credit_header)
    and(sc_transfer_header.service_center = sc_transfer_detail.service_center)
    and(sc_transfer_header.location_id = sc_transfer_detail.location_id)
    and((sc_transfer_detail.item_id = as_item)
    and(sc_transfer_header.store_id = an_store)
    and(sc_transfer_header.service_center = an_center)
    and(sc_transfer_header.location_id = an_location)
    and(credit_date > ldd_date or(credit_date = ldd_date and trans_time > ldt_time)));
  //Trans to 
  select Sum(sc_transfer_detail.qty)
    into ldc_trans_to from sc_transfer_detail
      ,sc_transfer_header
    where(sc_transfer_detail.credit_header = sc_transfer_header.credit_header)
    and(sc_transfer_header.service_center = sc_transfer_detail.service_center)
    and(sc_transfer_header.location_id = sc_transfer_detail.location_id)
    and(sc_transfer_header.arrival_flag = 'Y')
    and((sc_transfer_detail.item_id = as_item)
    and(sc_transfer_header.store_id_to = an_store)
    and(sc_transfer_header.service_center = an_center)
    and(sc_transfer_header.location_id_to = an_location)
    and(credit_date > ldd_date or(credit_date = ldd_date and trans_time > ldt_time)));
  //
  set ldc_BgBal = IsNull(ldc_BgBal,0);
  set ldc_credit = IsNull(ldc_credit,0);
  set ldc_debit = IsNull(ldc_debit,0);
  set ldc_return = IsNull(ldc_return,0);
  set ldc_trans_from = IsNull(ldc_trans_from,0);
  set ldc_trans_to = IsNull(ldc_trans_to,0);
  set ldc_bal = (ldc_credit+ldc_return+ldc_trans_to)-(ldc_debit+ldc_trans_from);
  set ldc_bal = ldc_bal+ldc_BgBal;
  set ldc_bal = IsNull(ldc_bal,0);
  return ldc_bal
end
