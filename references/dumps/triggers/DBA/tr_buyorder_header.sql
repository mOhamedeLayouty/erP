-- TRIGGER: DBA.tr_buyorder_header
-- ON TABLE: DBA.car_buy_order_header
-- generated_at: 2025-12-29T13:52:33.686Z

create trigger tr_buyorder_header after insert order 1 on
DBA.car_buy_order_header
referencing new as new_name
for each row /* WHEN( search_condition ) */
begin
  declare @buy_header varchar(10);
  declare @requisition_header varchar(10);
  set @buy_header = new_name.buy_header;
  set @requisition_header = new_name.requisition_header;
  if @requisition_header is not null then
    update DBA.car_requisition_header set DBA.car_requisition_header.buy_header = @buy_header
      where DBA.car_requisition_header.requisition_header = @requisition_header
  end if
end //----------------------------------------------------------
/*
ALTER TRIGGER "tr_buyorder_details" AFTER INSERT
ORDER 1 ON "DBA"."car_buy_order_detail"
REFERENCING NEW AS new_name
FOR EACH ROW /* WHEN( search_condition ) */
BEGIN
declare @buy_header varchar(10);
declare @requisition_header varchar(10); 
set @buy_header=new_name.buy_header;
set @requisition_header=new_name.requisition_header;
if @requisition_header is not null then
update "DBA"."car_requisition_header" set "DBA"."car_requisition_header".buy_header = @buy_header 
where "DBA"."car_requisition_header".requisition_header =@requisition_header ;
end if
END
*/
