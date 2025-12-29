-- PF: UNKNOWN_SCHEMA.f_lost_item_status
-- proc_id: 385
-- generated_at: 2025-12-29T13:53:28.803Z

create function DBA.f_lost_item_status( in as_item varchar(50),in an_center integer,in an_location integer,in ad_date date ) 
returns char(45)
begin
  declare as_status varchar(5);
  select distinct 'buy'
    into as_status from sc_buy_order_detail
      ,sc_buy_order_header
    where(sc_buy_order_detail.buy_header = sc_buy_order_header.buy_header)
    and(sc_buy_order_detail.service_center = sc_buy_order_header.service_center)
    and(sc_buy_order_detail.location_id = sc_buy_order_header.location_id)
    and((sc_buy_order_detail.item_id = as_item)
    and(sc_buy_order_header.order_date >= ad_date)
    and(sc_buy_order_header.service_center = an_center)
    and(sc_buy_order_header.location_id = an_location));
  select distinct 'cr'
    into as_status from sc_credit_detail
      ,sc_credit_header
    where(sc_credit_detail.credit_header = sc_credit_header.credit_header)
    and(sc_credit_detail.service_center = sc_credit_header.service_center)
    and(sc_credit_detail.location_id = sc_credit_header.location_id)
    and((sc_credit_detail.item_id = as_item)
    and(sc_credit_detail.service_center = an_center)
    and(sc_credit_detail.location_id = an_location)
    and(sc_credit_header.credit_date >= ad_date));
  set as_status = IsNull(as_status,'none');
  return(as_status)
end
