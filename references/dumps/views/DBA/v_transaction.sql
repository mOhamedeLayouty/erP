-- VIEW: DBA.v_transaction
-- generated_at: 2025-12-29T14:36:30.558Z
-- object_id: 14143
-- table_id: 1418
-- source_via: SYS.SYSVIEW(view_object_id=object_id)

create view DBA.v_transaction( vehicle_id,vin,credit_date ) as select vehicle.vehicle_id,vehicle.vin,(select first car_transfer_header.credit_date
      from DBA.car_transfer_detail
        ,DBA.car_transfer_header
      where DBA.car_transfer_detail.credit_header = car_transfer_header.credit_header and(
      car_transfer_header.log_stock = DBA.car_transfer_detail.log_stock)
      and car_transfer_detail.arrived = 1 and vehicle.vin = DBA.car_transfer_detail.vin and vehicle.vehicle_id = DBA.car_transfer_detail.vehicle_id
      order by car_transfer_header.credit_date desc) from DBA.vehicle
