-- PF: UNKNOWN_SCHEMA.f_get_item_balance_view
-- proc_id: 381
-- generated_at: 2025-12-29T13:53:28.802Z

create function DBA.f_get_item_balance_view( in as_item varchar(50),in an_center integer,in an_location integer,in an_store integer )  /* @parameter_name parameter_type [= default_value], ... */
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
  select Sum(sc_items_transaction.trans_qty)
    into ldc_credit from sc_items_transaction
    where((sc_items_transaction.item_id = as_item)
    and(sc_items_transaction.store_id = an_store)
    and(sc_items_transaction.center_id = an_center)
    and(sc_items_transaction.location_id = an_location) and(trans_type = 'CR')
    and(trans_date > ldd_date or(trans_date = ldd_date and trans_time > ldt_time)));
  //Debit
  select sum(sc_items_transaction.trans_qty)
    into ldc_debit from sc_items_transaction
    where((sc_items_transaction.item_id = as_item)
    and(sc_items_transaction.store_id = an_store)
    and(sc_items_transaction.center_id = an_center)
    and(sc_items_transaction.location_id = an_location) and(trans_type = 'DB')
    and(trans_date > ldd_date or(trans_date = ldd_date and trans_time > ldt_time)));
  //Return
  select sum(sc_items_transaction.trans_qty)
    into ldc_return from sc_items_transaction
    where((sc_items_transaction.item_id = as_item)
    and(sc_items_transaction.store_id = an_store)
    and(sc_items_transaction.center_id = an_center)
    and(sc_items_transaction.location_id = an_location) and(trans_type = 'RT')
    and(trans_date > ldd_date or(trans_date = ldd_date and trans_time > ldt_time)));
  //trans from
  select Sum(sc_items_transaction.trans_qty)
    into ldc_trans_from from sc_items_transaction
    where((sc_items_transaction.item_id = as_item)
    and(sc_items_transaction.store_id = an_store)
    and(sc_items_transaction.center_id = an_center)
    and(sc_items_transaction.location_id = an_location) and(trans_type = 'INTr')
    and(trans_date > ldd_date or(trans_date = ldd_date and trans_time > ldt_time)));
  //Trans to 
  select Sum(sc_items_transaction.trans_qty)
    into ldc_trans_to from sc_items_transaction
    where((sc_items_transaction.item_id = as_item)
    and(sc_items_transaction.store_id_to = an_store)
    and(sc_items_transaction.arrival_flag = 'Y')
    and(sc_items_transaction.center_id = an_center)
    and(sc_items_transaction.location_id_to = an_location) and(trans_type = 'INTr')
    and(trans_date > ldd_date or(trans_date = ldd_date and trans_time > ldt_time)));
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
