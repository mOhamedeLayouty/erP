-- TRIGGER: DBA.tr_sc_buyorder_header
-- ON TABLE: DBA.sc_buy_order_header
-- generated_at: 2025-12-29T13:52:33.688Z

create trigger tr_sc_buyorder_header after insert order 1 on
//V1.1 add location id to where
DBA.sc_buy_order_header
referencing new as new_name
for each row /* WHEN( search_condition ) */
begin
  declare @buy_header varchar(10);
  declare @requisition_header varchar(10);
  set @buy_header = new_name.buy_header;
  set @requisition_header = new_name.requisition_header;
  if @requisition_header is not null then
    update DBA.sc_requisition_header set DBA.sc_requisition_header.buy_header = @buy_header
      where DBA.sc_requisition_header.requisition_header = @requisition_header
      and DBA.sc_requisition_header.service_center = new_name.service_center
      and DBA.sc_requisition_header.location_id = new_name.location_id
  end if
end
