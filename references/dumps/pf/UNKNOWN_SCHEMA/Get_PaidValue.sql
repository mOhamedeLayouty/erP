-- PF: UNKNOWN_SCHEMA.Get_PaidValue
-- proc_id: 374
-- generated_at: 2025-12-29T13:53:28.800Z

create function --------------------------------------------------------------
DBA.Get_PaidValue( in @as_vehicle_id varchar(10),in @vin varchar(50),in @brand integer default 1 )  /* [IN] parameter_name parameter_type [DEFAULT default_value], ... */
returns integer --Ver V1.4  02-12-2014
on exception resume
begin
  declare @paid decimal(12,2);
  declare @paid1 decimal(12,2);
  declare @paid3 decimal(12,2);
  declare @paid2 integer;
  select distinct(select sum(payment_amount) from car_receipt_header,car_receipt_detail
        left outer join ws_sales_installment_doc
        on(car_receipt_detail.sales_order_log_store = ws_sales_installment_doc.log_store)
        and(car_receipt_detail.sales_order_code = ws_sales_installment_doc.order_code)
        and(car_receipt_detail.brand = ws_sales_installment_doc.brand)
      where(car_receipt_header.receipt_id = car_receipt_detail.receipt_id)
      and(car_receipt_detail.log_store = car_receipt_header.log_store)
      and ws_sales_installment_doc.vehicle_id = @as_vehicle_id
      and ws_sales_installment_doc.eqpt_id = @vin and ws_sales_installment_doc.brand = @brand
      and car_receipt_header.receipt_type <> 'R'
      and ws_sales_installment_doc.delete_flag <> 'Y')
    -(select isnull(sum(car_refund_header.refund_amount),0) from car_refund_header,car_refund_detail
        left outer join ws_sales_installment_doc
        on(car_refund_detail.log_store = ws_sales_installment_doc.log_store)
        and(car_refund_detail.invoice_no = ws_sales_installment_doc.order_code)
        and(car_refund_detail.brand = ws_sales_installment_doc.brand)
      where(car_refund_header.refund_id = car_refund_detail.refund_id)
      and(car_refund_detail.log_store = car_refund_header.log_store)
      and ws_sales_installment_doc.vehicle_id = @as_vehicle_id
      and ws_sales_installment_doc.eqpt_id = @vin and ws_sales_installment_doc.brand = @brand
      and car_refund_header.refund_type <> 'R'
      and ws_sales_installment_doc.delete_flag <> 'Y') as sc,
    (select sum(payment_amount) from car_receipt_header,car_receipt_detail
        left outer join vehicle_reservation
        on(car_receipt_detail.sales_order_log_store = vehicle_reservation.log_store)
        and(car_receipt_detail.sales_order_code = vehicle_reservation.id)
        and(car_receipt_detail.brand = vehicle_reservation.brand)
        left outer join ws_sales_installment_doc
        on(reservation_code = vehicle_reservation.id)
        and(vehicle_reservation.log_store = ws_sales_installment_doc.log_store)
        and(vehicle_reservation.brand = ws_sales_installment_doc.brand)
      where(car_receipt_header.receipt_id = car_receipt_detail.receipt_id)
      and(car_receipt_detail.log_store = car_receipt_header.log_store)
      and ws_sales_installment_doc.eqpt_id = @vin and ws_sales_installment_doc.vehicle_id = @as_vehicle_id and ws_sales_installment_doc.brand = @brand
      and car_receipt_header.receipt_type = 'R'
      and ws_sales_installment_doc.delete_flag <> 'Y')
    -(select isnull(sum(isnull(car_refund_header.refund_amount,0)),0) from car_refund_header,car_refund_detail
        left outer join vehicle_reservation
        on(car_refund_detail.log_store = vehicle_reservation.log_store)
        and(invoice_no = vehicle_reservation.id)
        and(car_refund_detail.brand = vehicle_reservation.brand)
        left outer join ws_sales_installment_doc
        on(reservation_code = vehicle_reservation.id)
        and(vehicle_reservation.log_store = ws_sales_installment_doc.log_store)
        and(vehicle_reservation.brand = ws_sales_installment_doc.brand)
      where(car_refund_header.refund_id = car_refund_detail.refund_id)
      and(car_refund_detail.log_store = car_refund_header.log_store)
      and ws_sales_installment_doc.eqpt_id = @vin and ws_sales_installment_doc.vehicle_id = @as_vehicle_id and ws_sales_installment_doc.brand = @brand
      and car_refund_header.refund_type = 'R'
      and ws_sales_installment_doc.delete_flag <> 'Y') as sm,
    isnull(sc,0,sc)+isnull(sm,0,sm) into @paid1,@paid2,@paid
    from about;
  select isnull(sum(paid_amount),0,sum(paid_amount))
    into @paid3 from car_bank_order join ws_sales_installment_doc
      on(sale_order = ws_sales_installment_doc.order_code)
      and(car_bank_order.sale_order_log_store = ws_sales_installment_doc.log_store)
      and(car_bank_order.brand = ws_sales_installment_doc.brand)
    where ws_sales_installment_doc.eqpt_id = @vin and ws_sales_installment_doc.vehicle_id = @as_vehicle_id and ws_sales_installment_doc.brand = @brand;
  select cash_price into @paid1 from ws_sales_installment_doc where eqpt_id = @vin and vehicle_id = @as_vehicle_id
    and ws_sales_installment_doc.brand = @brand and delete_flag <> 'Y';
  set @paid = @paid+@paid3;
  if @paid1 > (@paid) then
    set @paid2 = 0
  else
    set @paid2 = 1
  end if;
  return @paid2
end
