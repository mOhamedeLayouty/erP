-- PF: UNKNOWN_SCHEMA.SP_GetVehiclePM
-- proc_id: 431
-- generated_at: 2025-12-29T13:53:28.816Z

create procedure DBA.SP_GetVehiclePM( in @eqpt_id varchar(50),in @current_km integer default 0 ) 
/* RESULT( column_name column_type, ... ) */
begin
  select ws_eqpt.vin_no,
    ws_eqpt.pm_base_date,
    ws_eqpt.pm_base_km,
    isnull(ws_eqpt.purchase_date,'1900-01-01') as purchase_date,
    ws_catalogdetail.interval_days,
    ws_catalogdetail.interval_km,
    (select customer.customer_name_a from customer where ws_eqptlinksite.siteid = customer.customer_id) as customer_name_a,
    (select customer.customer_name_e from customer where ws_eqptlinksite.siteid = customer.customer_id) as customer_name_e,
    (select customer.GSM from customer where ws_eqptlinksite.siteid = customer.customer_id) as mobile,
    (select ws_operation.OpertationID from ws_operation where ws_catalogdetail.operationid = ws_operation.opertationid and ws_catalogdetail.service_center = ws_operation.service_center) as op_id,
    (select ws_operation.operationcode from ws_operation where ws_catalogdetail.operationid = ws_operation.opertationid and ws_catalogdetail.service_center = ws_operation.service_center) as op_code,
    (select ws_operation.Family from ws_operation where ws_catalogdetail.operationid = ws_operation.opertationid and ws_catalogdetail.service_center = ws_operation.service_center) as op_family,
    (select ws_operation.longdes_a from ws_operation where ws_catalogdetail.operationid = ws_operation.opertationid and ws_catalogdetail.service_center = ws_operation.service_center) as op_name,
    (select ws_operation.longdes_e from ws_operation where ws_catalogdetail.operationid = ws_operation.opertationid and ws_catalogdetail.service_center = ws_operation.service_center) as op_name_e,
    convert(date,(select min(starttime) from ws_reception where ws_reception.eqptid = ws_eqpt.eqpt_id and ws_reception.service_center = ws_eqpt.service_center)) as first_visit,
    convert(date,(select max(starttime) from ws_reception where ws_reception.eqptid = ws_eqpt.eqpt_id and ws_reception.service_center = ws_eqpt.service_center)) as last_visit,
    isnull((select max(eqptkm) from ws_reception where ws_reception.eqptid = ws_eqpt.eqpt_id and ws_reception.service_center = ws_eqpt.service_center),0) as last_km,
    datediff(day,ws_eqpt.purchase_date,convert(date,(GETDATE()))) as car_usedDays,
    (last_km/car_usedDays)*(datediff(day,convert(date,last_visit),convert(date,(GETDATE()))))+last_km as calc_km,
    (case @current_km when 0 then calc_km else @current_km end) as current_km,
    isnull(isnull(ws_eqpt.pm_base_date,ws_eqpt.purchase_date),'1900-01-01') as ld_date,
    isnull(ws_eqpt.pm_base_km,0) as pm_base_km,
    isnull((select max(ws_reception.eqptkm) from ws_reception,ws_receptionoperation
      where ws_reception.receptionid = ws_receptionoperation.receptionid and ws_reception.service_center = ws_receptionoperation.service_center and ws_reception.location_id = ws_receptionoperation.location_id
      and ws_reception.eqptid = ws_eqpt.eqpt_id and ws_reception.service_center = ws_eqpt.service_center
      and ws_receptionoperation.operationid = ws_catalogdetail.OperationID and ws_receptionoperation.service_center = ws_catalogdetail.service_center),0) as last_km_op,
    convert(date,(select max(ws_reception.starttime) from ws_reception,ws_receptionoperation
      where ws_reception.receptionid = ws_receptionoperation.receptionid and ws_reception.service_center = ws_receptionoperation.service_center and ws_reception.location_id = ws_receptionoperation.location_id
      and ws_reception.eqptid = ws_eqpt.eqpt_id and ws_reception.service_center = ws_eqpt.service_center
      and ws_receptionoperation.operationid = ws_catalogdetail.OperationID and ws_receptionoperation.service_center = ws_catalogdetail.service_center)) as last_visit_op,
    convert(date,DATEADD(day,isnull(ws_catalogdetail.interval_days,0),isnull(last_visit_op,ld_date))) as exp_visit_op,
    Isnull(last_km_op,pm_base_km)+isnull(ws_catalogdetail.interval_km,0) as exp_km_op,
    isnull((case when datediff(day,exp_visit_op,convert(date,(GETDATE()))) < 0 then 0 else datediff(day,exp_visit_op,convert(date,(GETDATE()))) end),0) as delay_days,
    isnull((case when(current_km-last_km_op-(exp_km_op-last_km_op)) < 0 then 0 else(current_km-last_km_op-(exp_km_op-last_km_op)) end),0) as delay_km
    from ws_eqpt
      ,ws_eqpt_category
      ,ws_catalogdetail
      ,ws_eqptlinksite
    where(ws_eqpt_category.category_id = ws_eqpt.category_id)
    and(ws_eqpt_category.service_center = ws_eqpt.service_center)
    and(ws_eqpt_category.catalogid = ws_catalogdetail.catalogid)
    and(ws_eqpt_category.service_center = ws_catalogdetail.service_center)
    and(ws_eqptlinksite.eqptid = ws_eqpt.eqpt_id) /* and (op_family='S') */
    and(ws_eqpt.eqpt_id = @eqpt_id)
    and(ws_catalogdetail.interval_days > 0 or ws_catalogdetail.interval_km > 0)
end
