-- VIEW: DBA.v_vehicles_transactions
-- generated_at: 2025-12-29T14:36:30.561Z
-- object_id: 14136
-- table_id: 1417
-- source_via: SYS.SYSVIEW(view_object_id=object_id)

create view DBA.v_vehicles_transactions( vehicle_id,vin,store_id,credit_date,trans_time,trans_type ) as
  select car_credit_detail.vehicle_id,car_credit_detail.vin,car_credit_header.store_id,car_credit_header.credit_date,
    car_credit_header.trans_time,
    1 as trans_type
    from DBA.car_credit_detail
      ,DBA.car_credit_header
    where(car_credit_detail.credit_header = car_credit_header.credit_header) and(
    car_credit_detail.log_stock = car_credit_header.log_stock) and
    not car_credit_detail.vin = 
    any(select car_transfer_detail.vin from DBA.car_transfer_detail where car_transfer_detail.vehicle_id = car_credit_detail.vehicle_id and car_transfer_detail.arrived = 1) union
  select car_debit_detail.vehicle_id,car_debit_detail.vin,car_debit_header.store_id,car_debit_header.debit_date,car_debit_header.trans_time,
    2 as trans_type
    from DBA.car_debit_detail
      ,DBA.car_debit_header
    where(car_debit_detail.log_stock = car_debit_header.log_stock) and(
    car_debit_header.debit_header = car_debit_detail.debit_header) union
  select car_transfer_detail.vehicle_id,car_transfer_detail.vin,
    car_transfer_header.store_id,
    car_transfer_header.credit_date,car_transfer_header.trans_time,
    3 as trans_type
    from DBA.car_transfer_detail
      ,DBA.car_transfer_header
    where(car_transfer_detail.credit_header = car_transfer_header.credit_header) and(
    car_transfer_header.log_stock = car_transfer_detail.log_stock) and car_transfer_detail.arrived = 0 union
  select car_transfer_detail.vehicle_id,car_transfer_detail.vin,
    car_transfer_header.store_id_to,
    car_transfer_header.credit_date,car_transfer_header.trans_time,
    4 as trans_type
    from DBA.car_transfer_detail
      ,DBA.car_transfer_header
    where(car_transfer_detail.credit_header = car_transfer_header.credit_header) and(
    car_transfer_header.log_stock = car_transfer_detail.log_stock) and car_transfer_detail.arrived = 1
    order by 1 asc,
    3 asc,
    4 asc,
    5 asc,
    6 asc
