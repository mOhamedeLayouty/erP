-- TRIGGER: DBA.tr_sc_ret_header
-- ON TABLE: DBA.sc_ret_header
-- generated_at: 2025-12-29T13:52:33.690Z

create trigger tr_sc_ret_header after insert order 1 on
//V1.1 add location to where
DBA.sc_ret_header
referencing new as new_name
for each row /* WHEN( search_condition ) */
begin
  declare @ret_header varchar(10);
  declare @request_header varchar(10);
  set @ret_header = new_name.credit_header;
  set @request_header = new_name.request_header;
  if @request_header is not null then
    update DBA.sc_ret_request_header set DBA.sc_ret_request_header.return_header = @ret_header
      where DBA.sc_ret_request_header.credit_header = @request_header
      and DBA.sc_ret_request_header.service_center = new_name.service_center
      and DBA.sc_ret_request_header.location_id = new_name.location_id
  end if
end
