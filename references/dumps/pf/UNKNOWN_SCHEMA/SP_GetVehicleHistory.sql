-- PF: UNKNOWN_SCHEMA.SP_GetVehicleHistory
-- proc_id: 432
-- generated_at: 2025-12-29T13:53:28.816Z

create procedure DBA.SP_GetVehicleHistory( in @eqpt_id varchar(50) ) 
/* RESULT( column_name column_type, ... ) */
begin
  select distinct ws_joborder.joborderid,
    ws_joborder.voucherid,
    ws_joborder.eqptid,
    ws_joborder.customerid,
    ws_joborder.orderstatus,
    ws_joborder.ordertype,
    ws_joborder.starttime,
    ws_joborder.control_comment,
    ws_joborder.jobdate,
    ws_joborder.out_date,
    customer.customer_id,
    ws_reception.eqptkm,
    ws_joborder.DeleteFlag,
    ws_joborder.control_ok,
    ws_reception.service_center,
    ws_reception.location_id,
    ws_joborder.deletereason,
    ws_joborder.control_comment2,
    ws_joborder.control_comment3,
    ws_reception.notes,
    customer.customer_name_a,
    customer.customer_name_e,
    ws_eqpt.vin_no,
    customer.gsm,ws_reception.Receptionist,
    (select location_name_a from DBA.ws_center_location where location_id = ws_reception.location_id) as location_name
    from ws_joborder
      ,customer
      ,ws_eqpt
      ,ws_reception
    where(ws_joborder.customerid = customer.customer_id)
    and(ws_eqpt.eqpt_id = ws_joborder.eqptid)
    and(ws_joborder.voucherid = ws_reception.receptionid)
    and(ws_joborder.service_center = ws_reception.service_center)
    and(ws_joborder.location_id = ws_reception.location_id)
    and(ws_joborder.deleteflag <> 'Y')
    and(ws_eqpt.eqpt_id = @eqpt_id)
end
