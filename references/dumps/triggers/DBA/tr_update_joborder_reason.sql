-- TRIGGER: DBA.tr_update_joborder_reason
-- ON TABLE: DBA.ws_JobOrderEmployee
-- generated_at: 2025-12-29T13:52:33.686Z

create trigger tr_update_joborder_reason after update of reason_id
order 1 on DBA.ws_JobOrderEmployee
referencing new as new_name
for each row
begin
  declare @reason integer;
  declare @center_id integer;
  declare @location_id integer;
  declare @joborder_id varchar(50);
  set @reason = new_name.reason_id;
  set @center_id = new_name.service_center;
  set @location_id = new_name.location_id;
  set @joborder_id = new_name.joborderid;
  if @reason is not null then
    update ws_joborder
      set reasonid = @reason
      where(ws_joborder.joborderid = @joborder_id)
      and(ws_joborder.service_center = @center_id)
      and(ws_joborder.location_id = @location_id)
  end if
end
