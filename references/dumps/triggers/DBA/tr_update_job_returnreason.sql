-- TRIGGER: DBA.tr_update_job_returnreason
-- ON TABLE: DBA.ws_returntojob_reason
-- generated_at: 2025-12-29T13:52:33.692Z

create trigger tr_update_job_returnreason after insert order 1 on
DBA.ws_returntojob_reason
referencing new as new_rec
for each row
begin
  update DBA.ws_JobOrder
    set return_comment = new_rec.reason,
    return_count = isnull(return_count,0)+1,
    return_date = new_rec.return_date where DBA.ws_JobOrder.VoucherID = new_rec.joborder_id
    and DBA.ws_JobOrder.service_center = new_rec.service_center
    and DBA.ws_JobOrder.location_id = new_rec.location_id
end
