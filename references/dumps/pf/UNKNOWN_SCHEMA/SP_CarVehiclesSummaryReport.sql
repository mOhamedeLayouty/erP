-- PF: UNKNOWN_SCHEMA.SP_CarVehiclesSummaryReport
-- proc_id: 433
-- generated_at: 2025-12-29T13:53:28.817Z

create procedure DBA.SP_CarVehiclesSummaryReport( @Brand integer default 1 )  /* [IN | OUT | INOUT] parameter_name parameter_type [DEFAULT default_value], ... */
/* RESULT( column_name column_type, ... ) */
begin
  select ws_eqpt_category.description_e as Code_e,
    ws_eqpt_category.description_a as Code_a,
    (select vechile_model.model_description_e
      from vechile_model
      where(vechile_model.model_code = ws_eqpt_category.vehicle_model)
      and(vechile_model.make_code = ws_eqpt_category.vehicle_make)
      and(vechile_model.brand = ws_eqpt_category.brand)) as Model_e,
    (select vechile_model.model_description_a
      from vechile_model
      where(vechile_model.model_code = ws_eqpt_category.vehicle_model)
      and(vechile_model.make_code = ws_eqpt_category.vehicle_make)
      and(vechile_model.brand = ws_eqpt_category.brand)) as Model_a,
    ws_color.name_e as Color_e,
    ws_color.name_a as Color_a,
    (select count(car_credit_detail.vin)
      from car_credit_detail,vehicle
      where vehicle.vin = car_credit_detail.vin
      and vehicle.vehicle_id = car_credit_detail.vehicle_id
      and vehicle.category_id = ws_eqpt_category.category_id
      and vehicle.vehicle_make = ws_eqpt_category.vehicle_make
      and vehicle.vehicle_model = ws_eqpt_category.vehicle_model
      and vehicle.color = ws_color.colorid
      and vehicle.log_store = car_credit_detail.log_stock
      and not car_credit_detail.vehicle_id = any(select distinct ws_sales_installment_doc.vehicle_id
        from ws_sales_installment_doc
        where ws_sales_installment_doc.eqpt_id is not null
        /* vehicle.stock_number = ws_sales_installment_doc.log_store  and*/
        and ws_sales_installment_doc.delete_flag = 'N')) as Available,
    (select count(vehicle.vin)
      from vehicle
      where vehicle.category_id = ws_eqpt_category.category_id
      and vehicle.vehicle_make = ws_eqpt_category.vehicle_make
      and vehicle.vehicle_model = ws_eqpt_category.vehicle_model
      and vehicle.color = ws_color.colorid
      and not vehicle.vehicle_id = any(select distinct car_credit_detail.vehicle_id
        from car_credit_detail
        where car_credit_detail.vin is not null
        and vehicle.log_store = car_credit_detail.log_stock)) as InPort,
    case when(select sum(car_buy_order_detail.qty)
      from car_buy_order_detail
      where car_buy_order_detail.eqpt_category_code = ws_eqpt_category.category_id
      and car_buy_order_detail.make = ws_eqpt_category.vehicle_make
      and car_buy_order_detail.model_code = ws_eqpt_category.vehicle_model
      and car_buy_order_detail.color = ws_color.colorid) is null then 0
    else
      (select sum(car_buy_order_detail.qty)
        from car_buy_order_detail
        where car_buy_order_detail.eqpt_category_code = ws_eqpt_category.category_id
        and car_buy_order_detail.make = ws_eqpt_category.vehicle_make
        and car_buy_order_detail.model_code = ws_eqpt_category.vehicle_model
        and car_buy_order_detail.color = ws_color.colorid)
    end as OnOrder,
    (select count(vehicle.vin)
      from car_buy_order_detail,vehicle
      where DBA.vehicle.log_store = DBA.car_buy_order_detail.log_store
      and DBA.vehicle.po_detail = DBA.car_buy_order_detail.buy_detail
      and DBA.car_buy_order_detail.buy_header = DBA.vehicle.po
      and car_buy_order_detail.color = ws_color.colorid
      and vehicle.vehicle_make = ws_eqpt_category.vehicle_make
      and vehicle.vehicle_model = ws_eqpt_category.vehicle_model
      and vehicle.category_id = ws_eqpt_category.category_id
      and vehicle.po is not null) as Purchase,
    (select count(vehicle_reservation.id)
      from vehicle_reservation
      where vehicle_reservation.car_make = ws_eqpt_category.vehicle_make
      and vehicle_reservation.car_model = ws_eqpt_category.vehicle_model
      and vehicle_reservation.color = ws_color.colorid
      and not vehicle_reservation.id
       = any(select distinct ws_sales_installment_doc.reservation_code
        from ws_sales_installment_doc
        where ws_sales_installment_doc.reservation_code is not null
        and vehicle_reservation.log_store = ws_sales_installment_doc.log_store)
      and delete_flag is null) as Reserved,
    (select count(ws_sales_installment_doc.eqpt_id)
      from ws_sales_installment_doc join vehicle on vehicle.vin = eqpt_id and vehicle.vehicle_id = ws_sales_installment_doc.vehicle_id
      where vehicle.vehicle_make = ws_eqpt_category.vehicle_make
      and vehicle.vehicle_model = ws_eqpt_category.vehicle_model
      and vehicle.color = ws_color.colorid and vehicle.vehicle_status <> 2) as d,
    Available+InPort+Purchase+Reserved+d+OnOrder as CountAll
    from ws_eqpt_category
      ,ws_color
    where ws_eqpt_category.category_id is not null and(CountAll > 0)
end
