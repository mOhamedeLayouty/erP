-- PF: UNKNOWN_SCHEMA.f_get_cust_balance
-- proc_id: 384
-- generated_at: 2025-12-29T13:53:28.803Z

create function DBA.f_get_cust_balance( in as_cust varchar(50),in an_center integer default 1,in an_location integer default 1,in as_type char(1) default 'B' )  /* @parameter_name parameter_type [= default_value], ... */
returns numeric(20,7)
//V1.2 add Return
//V1.3 add pull from cash on invoice
//V1.4 add Open balance and paid on open balance
//V1.5 add pay on multible invoice &Get return from Returned Invoice instead Return Order
//V1.6 error handling in debit of performa invoice
//V1.7 add option to get not collected checks and performa invoice
//V1.8 remove credit2 repeated
//V1.9 change in getting not invoiced debits or performa invoice
//V2.0 only get charged invoiced for performa or debit
//V2.1 get chargable Voucher
begin
  declare ldc_credit1 decimal(20,7);
  declare ldc_credit2 decimal(20,7);
  declare ldc_credit3 decimal(20,7);
  declare ldc_debit1 decimal(20,7);
  declare ldc_debit2 decimal(20,7);
  declare ldc_debit3 decimal(20,7);
  declare ldc_return decimal(20,7);
  declare ldc_obal decimal(20,7);
  declare ldc_bal decimal(20,7);
  declare ldc_notsattle1 decimal(20,7);
  declare ldc_notsattle2 decimal(20,7);
  if as_type = 'B' then
    //Credit1 (add to cash on invoice,recipt ,advanced payement,multi invoice)
    select isnull(sum(amount),0)
      into ldc_credit1 from DBA.erp_account_transaction
      where rec_type in( 'AD','REC','AP','mAD' ) 
      and cust_code = as_cust
      and isnull((select first status from checks where module = 'WS'
        and checks.receipt_id = DBA.erp_account_transaction.rec_no
        and checks.customer_id = DBA.erp_account_transaction.cust_code
        and isnull(checks.doc_type,'2') = '2'
        and checks.service_center = DBA.erp_account_transaction.service_center
        and checks.location_id = location_id),'P') in( 'P','C' ) ;
    //Credit2 Cash //Add to Cash on invoice ,Multi invoice
    /* select isnull(sum(amount),0)
into ldc_credit2 from DBA.erp_account_transaction
where rec_type in( 'AD','mAD' ) 
and cust_code = as_cust
and isnull((select first status from checks where module = 'WS'
and checks.doc_t_num = DBA.erp_account_transaction.rec_no
and checks.customer_id = DBA.erp_account_transaction.cust_code
and checks.doc_type = '2'
and checks.service_center = DBA.erp_account_transaction.service_center
and checks.location_id = location_id),'P') in( 'P','C' ) ;*/
    //Credit3 //add to cash on Open Balance
    select isnull(sum(amount),0)
      into ldc_credit3 from DBA.erp_account_transaction
      where rec_type in( 'OB' ) 
      and cust_code = as_cust;
    //Debit1 final invoice & Cash pull from Cash on Invoice 
    select isnull(sum(amount),0)
      into ldc_debit1 from DBA.erp_account_transaction
      where rec_type in( 'INV','VOC','AW' ) 
      and cust_code = as_cust;
    //Debit2 with performa invoice  
    select sum(sc_debit_detail.price*sc_debit_detail.qty)
      into ldc_debit2 from sc_debit_header,sc_debit_detail,ws_invoicetype
      where(sc_debit_detail.debit_header = sc_debit_header.debit_header)
      and(sc_debit_detail.service_center = sc_debit_header.service_center)
      and(sc_debit_detail.location_id = sc_debit_header.location_id)
      and(sc_debit_detail.service_center = ws_invoicetype.service_center)
      and(sc_debit_detail.invoicetype = ws_invoicetype.invoicetypeid)
      and(ws_invoicetype.chargable = 'Y')
      and(sc_debit_header.cus_code = as_cust)
      and isnull((select top 1 ws_invoiceheader.status from ws_invoiceheader
        where((sc_debit_header.debit_header = ws_invoiceheader.debit_header and ws_invoiceheader.joborder_id is null)
        or(sc_debit_header.joborderid = ws_invoiceheader.joborder_id and ws_invoiceheader.joborder_id is not null))
        and sc_debit_header.service_center = ws_invoiceheader.service_center
        and sc_debit_header.location_id = ws_invoiceheader.location_id
        and isnull(ws_invoiceheader.invoice_nature,'O') <> 'R'),'P') = 'P';
    //Return
    /* select sum(sc_ret_detail.price*sc_ret_detail.qty)
into ldc_return from sc_ret_detail
,sc_ret_header
,sc_debit_header
where(sc_ret_detail.credit_header = sc_ret_header.credit_header)
and(sc_ret_detail.service_center = sc_ret_header.service_center)
and(sc_ret_detail.location_id = sc_ret_header.location_id)
and(sc_ret_header.debit_header = sc_debit_header.debit_header)
and(sc_ret_header.service_center = sc_debit_header.service_center)
and(sc_ret_header.location_id = sc_debit_header.location_id)
and(sc_debit_header.cus_code = as_cust);*/
    select isnull(sum(amount),0)
      into ldc_return from DBA.erp_account_transaction
      where rec_type in( 'RIN' ) 
      and cust_code = as_cust;
    //Open Balance
    select o_bal
      into ldc_obal from Customer where customer_id = as_cust;
    set ldc_credit1 = IsNull(ldc_credit1,0);
    set ldc_credit2 = IsNull(ldc_credit2,0);
    set ldc_credit3 = IsNull(ldc_credit3,0);
    set ldc_debit1 = IsNull(ldc_debit1,0);
    set ldc_debit2 = IsNull(ldc_debit2,0);
    set ldc_return = IsNull(ldc_return,0);
    set ldc_obal = IsNull(ldc_obal,0);
    set ldc_bal = ldc_credit1+ldc_credit2+ldc_credit3+ldc_return-(ldc_debit1+ldc_debit2);
    set ldc_bal = ldc_bal+ldc_obal;
    set ldc_bal = IsNull(ldc_bal,0);
    return ldc_bal
  elseif as_type = 'C' then
    select credit_limit
      into ldc_bal from Customer where customer_id = as_cust;
    set ldc_bal = IsNull(ldc_bal,0);
    return ldc_bal
  elseif as_type = 'N' then
    //
    select isnull(sum(amount),0)
      into ldc_notsattle1 from DBA.erp_account_transaction
      where rec_type in( 'AD','REC','AP','mAD' ) 
      and cust_code = as_cust
      and isnull((select first status from checks where module = 'WS'
        and checks.receipt_id = DBA.erp_account_transaction.rec_no
        and checks.customer_id = DBA.erp_account_transaction.cust_code
        and isnull(checks.doc_type,'2') = '2'
        and checks.service_center = DBA.erp_account_transaction.service_center
        and checks.location_id = location_id),'P') not in( 'P','C' ) ;
    //
    select sum(sc_debit_detail.price*sc_debit_detail.qty)
      into ldc_notsattle2 from sc_debit_header,sc_debit_detail,ws_invoicetype
      where(sc_debit_detail.debit_header = sc_debit_header.debit_header)
      and(sc_debit_detail.service_center = sc_debit_header.service_center)
      and(sc_debit_detail.location_id = sc_debit_header.location_id)
      and(sc_debit_detail.service_center = ws_invoicetype.service_center)
      and(sc_debit_detail.invoicetype = ws_invoicetype.invoicetypeid)
      and(ws_invoicetype.chargable = 'Y')
      and(sc_debit_header.cus_code = as_cust)
      and isnull((select top 1 ws_invoiceheader.status from ws_invoiceheader
        where((sc_debit_header.debit_header = ws_invoiceheader.debit_header and ws_invoiceheader.joborder_id is null)
        or(sc_debit_header.joborderid = ws_invoiceheader.joborder_id and ws_invoiceheader.joborder_id is not null))
        and sc_debit_header.service_center = ws_invoiceheader.service_center
        and sc_debit_header.location_id = ws_invoiceheader.location_id
        and isnull(ws_invoiceheader.invoice_nature,'O') <> 'R'),'P') = 'P';
    set ldc_bal = IsNull(ldc_notsattle1,0)+IsNull(ldc_notsattle2,0);
    return ldc_bal
  end if
end
