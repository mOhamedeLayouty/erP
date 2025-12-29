-- PF: UNKNOWN_SCHEMA.SP_GetCarTodayKPI
-- proc_id: 446
-- generated_at: 2025-12-29T13:53:28.821Z

create procedure DBA.SP_GetCarTodayKPI( in @brandId integer default 1,in @storeId integer default 1,in @FDate date default today(),in @TDate date default today() ) 
/* RESULT( column_name column_type, ... ) */
begin
  select store_id,
    store_name,
    store_name_e,
    //No or Reservation 
    isnull((select count(id) from vehicle_reservation
      where(isnull(delete_flag,'N') = 'N')
      and convert(date,reservation_date) between @FDate and @TDate
      and(brand = @brandId or @brandId = 0)
      and(log_store = car_store.store_id)),0) as reservation_count,
    //No or SaleOrder_notapproval 
    isnull((select count(order_code) from ws_sales_installment_doc
      where(isnull(delete_flag,'N') = 'N')
      and isnull(approval,'N') = 'N'
      and convert(date,sale_date) between @FDate and @TDate
      and(ws_sales_installment_doc.brand = @brandId or @brandId = 0)
      and(ws_sales_installment_doc.log_store = car_store.store_id)),0) as salesorder_notapproved_count,
    //No or SaleOrder_approval 
    isnull((select count(order_code) from ws_sales_installment_doc
      where(isnull(delete_flag,'N') = 'N')
      and isnull(approval,'N') = 'Y'
      and convert(date,sale_date) between @FDate and @TDate
      and(ws_sales_installment_doc.brand = @brandId or @brandId = 0)
      and(ws_sales_installment_doc.log_store = car_store.store_id)),0) as salesorder_approved_count,
    //available_cars_count
    isnull((select count() from vehicle where(vehicle_status <> 2)
      and(isnull(stock_number,vehicle.log_store) = car_store.store_id)),0) as available_cars_count,
    //available_cars_cost
    isnull((select sum(cost) from vehicle where(vehicle_status <> 2)
      and(isnull(stock_number,vehicle.log_store) = car_store.store_id)),0) as available_cars_cost,
    //available_cars_price
    isnull((select sum(selling_price) from vehicle where(vehicle_status <> 2)
      and(isnull(stock_number,vehicle.log_store) = car_store.store_id)),0) as available_cars_price
    from car_store
    where(store_id = @storeId or @storeId = 0)
end
