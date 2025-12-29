-- TRIGGER: DBA.tr_ws_joborder_editdate
-- ON TABLE: DBA.ws_JobOrder
-- generated_at: 2025-12-29T13:52:33.693Z

create trigger //
tr_ws_joborder_editdate after update order 1 on
DBA.ws_JobOrder
referencing old as old_rec new as new_rec
for each row
begin
  update DBA.ws_JobOrder set editdate = now()
    where joborderid = new_rec.joborderid
    and service_center = new_rec.service_center and location_id = new_rec.location_id
end
