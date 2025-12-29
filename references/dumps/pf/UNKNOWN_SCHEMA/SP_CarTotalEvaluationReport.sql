-- PF: UNKNOWN_SCHEMA.SP_CarTotalEvaluationReport
-- proc_id: 429
-- generated_at: 2025-12-29T13:53:28.815Z

create procedure DBA.SP_CarTotalEvaluationReport( in an_type integer default 1 ) 
begin
  if an_type = 1 then
    select distinct
      vechile_model.model_description_e as description_e,
      vehicle_year as year,
      (select count() from vehicle as V where isnull(V.vehicle_status,0) = 0 and isnull(V.vehicle_hold,0) <> 1
        and V.vehicle_make = vehicle.vehicle_make and V.vehicle_model = vehicle.vehicle_model
        and V.vehicle_year = vehicle.vehicle_year) as Available,
      (select count() from vehicle as V where isnull(V.vehicle_status,0) = 4 and isnull(V.vehicle_hold,0) <> 1
        and V.vehicle_make = vehicle.vehicle_make and V.vehicle_model = vehicle.vehicle_model
        and V.vehicle_year = vehicle.vehicle_year) as Reserved,
      (select count() from vehicle as V where isnull(V.vehicle_hold,0) = 1
        and V.vehicle_make = vehicle.vehicle_make and V.vehicle_model = vehicle.vehicle_model
        and V.vehicle_year = vehicle.vehicle_year) as holded
      from vehicle left outer join vechile_model
        on vehicle.vehicle_model = vechile_model.model_code
        and vehicle.vehicle_make = vechile_model.make_code
        ,ws_eqpt_category
      where(ws_eqpt_category.category_id = vehicle.category_id)
      and(ws_eqpt_category.vehicle_make = vehicle.vehicle_make)
      and(ws_eqpt_category.vehicle_model = vehicle.vehicle_model)
      and(isnull(vehicle.vehicle_status,0) in( 0,4 ) or isnull(vehicle.vehicle_hold,0) = 1)
      order by vechile_model.model_description_e asc,vehicle_year asc
  else
    select distinct
      ws_eqpt_category.description_e as description_e,
      vehicle_year as year,
      (select count() from vehicle as V where isnull(V.vehicle_status,0) = 0 and isnull(V.vehicle_hold,0) <> 1
        and V.vehicle_make = vehicle.vehicle_make and V.vehicle_model = vehicle.vehicle_model
        and V.vehicle_year = vehicle.vehicle_year and V.category_id = vehicle.category_id) as Available,
      (select count() from vehicle as V where isnull(V.vehicle_status,0) = 4 and isnull(V.vehicle_hold,0) <> 1
        and V.vehicle_make = vehicle.vehicle_make and V.vehicle_model = vehicle.vehicle_model
        and V.vehicle_year = vehicle.vehicle_year and V.category_id = vehicle.category_id) as Reserved,
      (select count() from vehicle as V where isnull(V.vehicle_hold,0) = 1
        and V.vehicle_make = vehicle.vehicle_make and V.vehicle_model = vehicle.vehicle_model
        and V.vehicle_year = vehicle.vehicle_year and V.category_id = vehicle.category_id) as holded
      from vehicle left outer join vechile_model
        on vehicle.vehicle_model = vechile_model.model_code
        and vehicle.vehicle_make = vechile_model.make_code
        ,ws_eqpt_category
      where(ws_eqpt_category.category_id = vehicle.category_id)
      and(ws_eqpt_category.vehicle_make = vehicle.vehicle_make)
      and(ws_eqpt_category.vehicle_model = vehicle.vehicle_model)
      and(isnull(vehicle.vehicle_status,0) in( 0,4 ) or isnull(vehicle.vehicle_hold,0) = 1)
      order by ws_eqpt_category.description_e asc,vehicle_year asc
  end if
end
