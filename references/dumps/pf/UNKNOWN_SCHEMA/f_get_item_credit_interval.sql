-- PF: UNKNOWN_SCHEMA.f_get_item_credit_interval
-- proc_id: 451
-- generated_at: 2025-12-29T13:53:28.822Z

create function DBA.f_get_item_credit_interval( in as_item varchar(50),in an_center integer,in an_location integer,in an_store integer,in ad_fdate datetime default today(),in ad_tdate datetime default today() ) 
returns numeric(20,7)
--V1.0 get credit in interval
begin
  declare ldc_credit decimal(20,7);
  declare ldc_return decimal(20,7);
  declare ldc_trans_to decimal(20,7);
  declare ldc_bal decimal(20,7);
  // 
  //Credit
  select Sum(sc_credit_detail.qty)
    into ldc_credit from sc_credit_detail
      ,sc_credit_header
    where(sc_credit_detail.credit_header = sc_credit_header.credit_header)
    and(sc_credit_header.service_center = sc_credit_detail.service_center)
    and(sc_credit_detail.location_id = sc_credit_header.location_id)
    and(sc_credit_detail.item_id = as_item)
    and(sc_credit_header.store_id = an_store or an_store = 0)
    and(sc_credit_header.service_center = an_center)
    and(sc_credit_header.location_id = an_location)
    and(Datetime(credit_date+trans_time) >= ad_fdate)
    and(Datetime(credit_date+trans_time) <= ad_tdate);
  //Return
  select sum(sc_ret_detail.qty)
    into ldc_return from sc_ret_detail
      ,sc_ret_header
    where(sc_ret_detail.credit_header = sc_ret_header.credit_header)
    and(sc_ret_header.service_center = sc_ret_detail.service_center)
    and(sc_ret_header.location_id = sc_ret_detail.location_id)
    and(sc_ret_detail.item_id = as_item)
    and(sc_ret_header.store_id = an_store or an_store = 0)
    and(sc_ret_header.service_center = an_center)
    and(sc_ret_header.location_id = an_location)
    and(Datetime(credit_date+trans_time) >= ad_fdate)
    and(Datetime(credit_date+trans_time) <= ad_tdate);
  //Trans to 
  select Sum(sc_transfer_detail.qty)
    into ldc_trans_to from sc_transfer_detail
      ,sc_transfer_header
    where(sc_transfer_detail.credit_header = sc_transfer_header.credit_header)
    and(sc_transfer_header.service_center = sc_transfer_detail.service_center)
    and(sc_transfer_header.location_id = sc_transfer_detail.location_id)
    and(sc_transfer_header.arrival_flag = 'Y')
    and(sc_transfer_detail.item_id = as_item)
    and(sc_transfer_header.store_id_to = an_store or an_store = 0)
    and(sc_transfer_header.service_center = an_center)
    and(sc_transfer_header.location_id_to = an_location)
    and(Datetime(credit_date+trans_time) >= ad_fdate)
    and(Datetime(credit_date+trans_time) <= ad_tdate);
  //
  set ldc_credit = IsNull(ldc_credit,0);
  set ldc_return = IsNull(ldc_return,0);
  set ldc_trans_to = IsNull(ldc_trans_to,0);
  set ldc_bal = (ldc_credit+ldc_return+ldc_trans_to);
  set ldc_bal = IsNull(ldc_bal,0);
  return ldc_bal
end
