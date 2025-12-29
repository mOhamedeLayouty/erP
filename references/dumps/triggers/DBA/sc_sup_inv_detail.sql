-- TRIGGER: DBA.sc_sup_inv_detail
-- ON TABLE: DBA.sc_sup_inv_detail
-- generated_at: 2025-12-29T13:52:33.685Z

create trigger sc_sup_inv_detail after insert,delete,update order 1 on
DBA.sc_sup_inv_detail
referencing new as new_name
for each row /* REFERENCING OLD AS old_name NEW AS new_name */
/* WHEN( search_condition ) */
begin
  declare @buy_header varchar(12);
  declare @inv_header integer;
  declare @buy_status varchar(1);
  declare @service_center integer;
  declare loc_id integer;
  declare @inv_count integer;
  declare @buy_count integer;
  declare @inv_qty integer;
  declare @buy_qty integer;
  set @buy_header = new_name.buy_header;
  set @inv_header = new_name.inv_header;
  set @service_center = new_name.service_center;
  set loc_id = new_name.location_id;
  set @buy_status = isnull((select po_closed from sc_buy_order_header
      where sc_buy_order_header.buy_header = @buy_header
      and sc_buy_order_header.service_center = @service_center
      and sc_buy_order_header.location_id = loc_id),'N');
  if @buy_status = 'N' then //Still Open
    set @buy_count = isnull((select Count(sc_buy_order_detail.item_id)
        from sc_buy_order_detail
        where sc_buy_order_detail.buy_header = @buy_header
        and sc_buy_order_detail.service_center = @service_center
        and sc_buy_order_detail.location_id = loc_id),0);
    set @inv_count = isnull((select Count(sc_sup_inv_detail.item_id)
        from sc_sup_inv_detail
        where sc_sup_inv_detail.buy_header = @buy_header
        and sc_sup_inv_detail.service_center = @service_center
        and sc_sup_inv_detail.location_id = loc_id),0);
    if @inv_count >= @buy_count then //Add all buy order items
      set @buy_qty = isnull((select sum(sc_buy_order_detail.qty)
          from sc_buy_order_detail
          where sc_buy_order_detail.buy_header = @buy_header
          and sc_buy_order_detail.service_center = @service_center
          and sc_buy_order_detail.location_id = loc_id),0);
      set @inv_qty = isnull((select sum(sc_sup_inv_detail.qty)
          from sc_sup_inv_detail
          where sc_sup_inv_detail.buy_header = @buy_header
          and sc_sup_inv_detail.service_center = @service_center
          and sc_sup_inv_detail.location_id = loc_id),0);
      if @inv_qty >= @buy_qty then //Add all buy order qty
        update sc_buy_order_header set po_closed = 'Y' from sc_buy_order_header
          where sc_buy_order_header.buy_header = @buy_header
          and sc_buy_order_header.service_center = @service_center
          and sc_buy_order_header.location_id = loc_id
      end if
    end if
  end if
end
