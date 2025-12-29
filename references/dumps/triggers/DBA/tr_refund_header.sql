-- TRIGGER: DBA.tr_refund_header
-- ON TABLE: DBA.car_refund_header
-- generated_at: 2025-12-29T13:52:33.686Z

create trigger tr_refund_header after insert order 1 on
DBA.car_refund_header
referencing new as new_name
for each row /* WHEN( search_condition ) */
begin
  declare @refund_id varchar(10);
  declare @request_id varchar(10);
  declare @log_store integer;
  declare @brand integer;
  set @refund_id = new_name.refund_id;
  set @request_id = new_name.request_id;
  set @log_store = new_name.log_store;
  set @brand = new_name.brand;
  if @request_id is not null then
    update DBA.car_request_refund_header set DBA.car_request_refund_header.done_refund_id = @refund_id
      where DBA.car_request_refund_header.refund_id = @request_id
      and DBA.car_request_refund_header.log_store = @log_store
      and DBA.car_request_refund_header.brand = @brand
  end if
end
