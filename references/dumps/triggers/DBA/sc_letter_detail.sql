-- TRIGGER: DBA.sc_letter_detail
-- ON TABLE: DBA.sc_letter_of_credit_detail
-- generated_at: 2025-12-29T13:52:33.685Z

create trigger sc_letter_detail after insert order 1 on
DBA.sc_letter_of_credit_detail
referencing new as new_name
for each row
//V1.1 also close orders of invoices if added to letter
//V1.2 Prevent close PO
/* REFERENCING NEW AS new_name */
/* WHEN( search_condition ) */
begin
  declare @inv_header varchar(12);
  declare @service_cen integer;
  declare @loc_id integer;
  set @inv_header = new_name.inv_header;
  set @service_cen = new_name.service_center;
  set @loc_id = new_name.location_id;
  if @inv_header is not null then
    //close invoice
    update sc_sup_inv_header set inv_closed = 'Y'
      where sc_sup_inv_header.inv_header = @inv_header
      and sc_sup_inv_header.service_center = @service_cen
      and sc_sup_inv_header.location_id = @loc_id
  //Close its orders
  /*
update sc_buy_order_header set po_closed = 'Y' from sc_buy_order_header
where sc_buy_order_header.service_center = @service_cen
and sc_buy_order_header.location_id = @loc_id
and sc_buy_order_header.buy_header = 
any((select distinct buy_header from DBA.sc_sup_inv_detail
where inv_header = @inv_header
and service_center = @service_cen
and location_id = @loc_id));
*/
  end if
end
