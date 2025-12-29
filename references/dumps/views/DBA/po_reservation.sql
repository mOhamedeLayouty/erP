-- VIEW: DBA.po_reservation
-- generated_at: 2025-12-29T14:36:30.547Z
-- object_id: 14096
-- table_id: 1413
-- source_via: SYS.SYSVIEW(view_object_id=object_id)

create view DBA.po_reservation /* view_column_name, ... */
  as select distinct DBA.car_buy_order_header.buy_header,
    DBA.car_buy_order_header.order_date,
    DBA.car_buy_order_detail.qty as qty,car_buy_order_detail.buy_detail,
    (select count() from DBA.vehicle
      where vehicle.po = DBA.car_buy_order_detail.buy_header
      and DBA.car_buy_order_detail.buy_detail = vehicle.po_detail
      and vehicle.vehicle_make = car_buy_order_detail.make
      and vehicle.vehicle_model = car_buy_order_detail.model_code
      and vehicle.log_store = car_buy_order_detail.log_store
      and car_buy_order_detail.eqpt_category_code = vehicle.category_id) as v_count,
    qty-v_count as av,
    DBA.car_buy_order_detail.make,
    DBA.car_buy_order_detail.model_code,
    DBA.car_buy_order_detail.color,
    car_buy_order_detail.eqpt_category_code,
    car_buy_order_detail.log_store as store
    from DBA.car_buy_order_detail
      join DBA.car_buy_order_header
      on DBA.car_buy_order_detail.buy_header = DBA.car_buy_order_header.buy_header
      and DBA.car_buy_order_header.log_store = DBA.car_buy_order_detail.log_store and av > 0
