-- PF: UNKNOWN_SCHEMA.f_item_sales
-- proc_id: 391
-- generated_at: 2025-12-29T13:53:28.805Z

create function DBA.f_item_sales( in as_item varchar(50),in ad_fdate date,in ad_tdate date,in an_center integer,in ai_type integer default 0 ) 
returns numeric(20,7)
/*
ai_type=0 all sales , 1 over counter ,2 JO ,3 sattlement
--V2.0 separte over counter and WS sales by argument
*/
begin
  declare an_amount numeric(20,7);
  declare an_result1 numeric(20,7);
  declare an_result2 numeric(20,7);
  if ai_type = 0 then /*All Sales----------------------------------------------------------*/
    /*Debit*/
    select isnull(sum(qty),0)
      into an_result1 from sc_debit_detail,sc_debit_header,sc_item
      where(sc_debit_header.debit_header = sc_debit_detail.debit_header)
      and(sc_debit_header.service_center = sc_debit_detail.service_center)
      and(sc_debit_header.location_id = sc_debit_detail.location_id)
      and(sc_item.item_id = sc_debit_detail.item_id)
      and(sc_item.service_center = sc_debit_header.service_center)
      and(sc_debit_header.trans_id = 1)
      and(sc_item.item_id = as_item)
      and(sc_item.service_center = an_center)
      and(sc_debit_header.service_center = an_center)
      and(sc_debit_header.debit_date >= ad_fdate)
      and(sc_debit_header.debit_date <= ad_tdate);
    /*Return*/
    select isnull(sum(qty),0)
      into an_result2 from sc_ret_detail,sc_ret_header,sc_item
      where(sc_ret_header.credit_header = sc_ret_detail.credit_header)
      and(sc_ret_header.service_center = sc_ret_detail.service_center)
      and(sc_ret_header.location_id = sc_ret_detail.location_id)
      and sc_item.item_id = sc_ret_detail.item_id
      and sc_item.service_center = sc_ret_header.service_center
      and sc_item.item_id = as_item
      and sc_item.service_center = an_center
      and sc_ret_header.service_center = an_center
      and sc_ret_header.credit_date >= ad_fdate
      and sc_ret_header.credit_date <= ad_tdate
  elseif ai_type = 1 then /*Over Counter--------------------------------------------------------------------*/
    /*Debit*/
    select isnull(sum(qty),0)
      into an_result1 from sc_debit_detail,sc_debit_header,sc_item
      where(sc_debit_header.debit_header = sc_debit_detail.debit_header)
      and(sc_debit_header.service_center = sc_debit_detail.service_center)
      and(sc_debit_header.location_id = sc_debit_detail.location_id)
      and(sc_item.item_id = sc_debit_detail.item_id)
      and(sc_item.service_center = sc_debit_header.service_center)
      and(sc_debit_header.trans_id = 1)
      and(sc_debit_header.joborderid is null or sc_debit_header.joborderid = '')
      and(sc_item.item_id = as_item)
      and(sc_item.service_center = an_center)
      and(sc_debit_header.service_center = an_center)
      and(sc_debit_header.debit_date >= ad_fdate)
      and(sc_debit_header.debit_date <= ad_tdate);
    /*Return*/
    select isnull(sum(qty),0)
      into an_result2 from sc_ret_detail,sc_ret_header,sc_item,sc_debit_header
      where(sc_ret_header.credit_header = sc_ret_detail.credit_header)
      and(sc_ret_header.service_center = sc_ret_detail.service_center)
      and(sc_ret_header.location_id = sc_ret_detail.location_id)
      and(sc_ret_header.debit_header = sc_debit_header.debit_header)
      and(sc_ret_header.service_center = sc_debit_header.service_center)
      and(sc_ret_header.debit_location = sc_debit_header.location_id)
      and(sc_debit_header.joborderid is null or sc_debit_header.joborderid = '')
      and sc_item.item_id = sc_ret_detail.item_id
      and sc_item.service_center = sc_ret_header.service_center
      and sc_item.item_id = as_item
      and sc_item.service_center = an_center
      and sc_ret_header.service_center = an_center
      and sc_ret_header.credit_date >= ad_fdate
      and sc_ret_header.credit_date <= ad_tdate
  elseif ai_type = 2 then /*WS sales--------------------------------------------------------------------*/
    /*Debit*/
    select isnull(sum(qty),0)
      into an_result1 from sc_debit_detail,sc_debit_header,sc_item
      where(sc_debit_header.debit_header = sc_debit_detail.debit_header)
      and(sc_debit_header.service_center = sc_debit_detail.service_center)
      and(sc_debit_header.location_id = sc_debit_detail.location_id)
      and(sc_item.item_id = sc_debit_detail.item_id)
      and(sc_item.service_center = sc_debit_header.service_center)
      and(sc_debit_header.trans_id = 1)
      and(sc_debit_header.joborderid is not null and sc_debit_header.joborderid <> '')
      and(sc_item.item_id = as_item)
      and(sc_item.service_center = an_center)
      and(sc_debit_header.service_center = an_center)
      and(sc_debit_header.debit_date >= ad_fdate)
      and(sc_debit_header.debit_date <= ad_tdate);
    /*Return*/
    select isnull(sum(qty),0)
      into an_result2 from sc_ret_detail,sc_ret_header,sc_item,sc_debit_header
      where(sc_ret_header.credit_header = sc_ret_detail.credit_header)
      and(sc_ret_header.service_center = sc_ret_detail.service_center)
      and(sc_ret_header.location_id = sc_ret_detail.location_id)
      and(sc_ret_header.debit_header = sc_debit_header.debit_header)
      and(sc_ret_header.service_center = sc_debit_header.service_center)
      and(sc_ret_header.debit_location = sc_debit_header.location_id)
      and(sc_debit_header.joborderid is not null or sc_debit_header.joborderid <> '')
      and sc_item.item_id = sc_ret_detail.item_id
      and sc_item.service_center = sc_ret_header.service_center
      and sc_item.item_id = as_item
      and sc_item.service_center = an_center
      and sc_ret_header.service_center = an_center
      and sc_ret_header.credit_date >= ad_fdate
      and sc_ret_header.credit_date <= ad_tdate
  elseif ai_type = 3 then /*Sattlement------------------------------------------------------------*/
    /*Debit*/
    select isnull(sum(qty),0)
      into an_result1 from sc_debit_detail,sc_debit_header,sc_item
      where(sc_debit_header.debit_header = sc_debit_detail.debit_header)
      and(sc_debit_header.service_center = sc_debit_detail.service_center)
      and(sc_debit_header.location_id = sc_debit_detail.location_id)
      and(sc_item.item_id = sc_debit_detail.item_id)
      and(sc_item.service_center = sc_debit_header.service_center)
      and(sc_debit_header.trans_id not in( 1,3 ) )
      and(sc_item.item_id = as_item)
      and(sc_item.service_center = an_center)
      and(sc_debit_header.service_center = an_center)
      and(sc_debit_header.debit_date >= ad_fdate)
      and(sc_debit_header.debit_date <= ad_tdate);
    /*Return*/
    set an_result2 = 0
  end if;
  /*------------------------------------------------------------------------------------------------------------------------------------------*/
  set an_amount = an_result1-an_result2;
  set an_amount = IsNull(an_amount,0);
  return an_amount
end
