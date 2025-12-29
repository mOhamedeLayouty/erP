-- TRIGGER: DBA.sc_credit_header_trig_i
-- ON TABLE: DBA.sc_credit_header
-- generated_at: 2025-12-29T13:52:33.682Z

create trigger sc_credit_header_trig_i after insert order 1 on
DBA.sc_credit_header
referencing new as new_name
for each row
/* REFERENCING NEW AS new_name */
/* WHEN( search_condition ) */
//V1.1 prevent close PO
begin
  declare @buy_header varchar(12);
  declare @inv_header integer;
  declare @service_cen integer;
  declare @loc_id integer;
  set @buy_header = new_name.buy_headr;
  set @inv_header = new_name.inv_header;
  set @service_cen = new_name.service_center;
  set @loc_id = new_name.location_id;
  //add from letter then close Buy order close
  /*
if @buy_header is not null then
update sc_buy_order_header set po_closed = 'Y' from sc_buy_order_header
where sc_buy_order_header.buy_header = @buy_header
and sc_buy_order_header.service_center = @service_cen
and sc_buy_order_header.location_id = @loc_id
end if;
*/
  //add from invoice then close invoice and its orders
  if @inv_header is not null then
    //invoice
    update sc_sup_inv_header set inv_closed = 'Y'
      where sc_sup_inv_header.inv_header = @inv_header
      and sc_sup_inv_header.service_center = @service_cen
      and sc_sup_inv_header.location_id = @loc_id
  //orders of this invoice
  /*
update sc_buy_order_header set po_closed = 'Y' from sc_buy_order_header
where sc_buy_order_header.service_center = @service_cen
and sc_buy_order_header.location_id = @loc_id
and sc_buy_order_header.buy_header
= any((select distinct buy_header from DBA.sc_sup_inv_detail
where inv_header = @inv_header
and service_center = @service_cen
and location_id = @loc_id))
*/
  end if
end
