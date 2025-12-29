-- PF: UNKNOWN_SCHEMA.get_paid_quotation
-- proc_id: 379
-- generated_at: 2025-12-29T13:53:28.801Z

create function DBA.get_paid_quotation( in @quotation_header varchar(50),in @brand integer default 1 ) 
returns decimal(12,2)
--Ver 1.0 Created
--Ver 1.1 prevent store link
begin
  declare @paid decimal(12,2);
  declare @paid1 decimal(12,2);
  declare @paid3 decimal(12,2);
  declare @paid2 integer;
  declare @car_rate decimal(12,2);
  select distinct(select sum(payment_amount*isnull((select rate from ledger.cur where curr_id = receipt_currency),1))
      from car_receipt_detail,car_receipt_header
        left outer join car_quotation_header
        on(car_receipt_header.quotation_header = car_quotation_header.quotation_header)
        and(car_receipt_header.brand = car_quotation_header.brand)
      where(car_receipt_header.receipt_id = car_receipt_detail.receipt_id)
      and(car_receipt_detail.log_store = car_receipt_header.log_store)
      and car_quotation_header.quotation_header = @quotation_header and car_quotation_header.brand = @brand
      and car_receipt_header.receipt_type <> 'R')
    -(select isnull(sum(car_refund_header.refund_amount*isnull((select rate from ledger.cur where curr_id = refund_currency),1)),0)
      from car_refund_detail,car_refund_header
        left outer join car_quotation_header
        on(car_refund_header.quotation_header = car_quotation_header.quotation_header)
        and(car_refund_header.brand = car_quotation_header.brand)
      where(car_refund_header.refund_id = car_refund_detail.refund_id)
      and(car_refund_detail.log_store = car_refund_header.log_store)
      and car_quotation_header.quotation_header = @quotation_header and car_quotation_header.brand = @brand
      and car_refund_header.refund_type <> 'R') as sc,
    (select sum(payment_amount*isnull((select rate from ledger.cur where curr_id = receipt_currency),1))
      from car_receipt_header,car_receipt_detail
        left outer join vehicle_reservation
        on(car_receipt_detail.sales_order_code = vehicle_reservation.id)
        and(car_receipt_detail.brand = vehicle_reservation.brand)
        left outer join car_quotation_header
        on(car_quotation_header.quotation_header = vehicle_reservation.quotation_header)
        and(vehicle_reservation.brand = car_quotation_header.brand)
      where(car_receipt_header.receipt_id = car_receipt_detail.receipt_id)
      and(car_receipt_detail.log_store = car_receipt_header.log_store)
      and car_quotation_header.quotation_header = @quotation_header
      and car_quotation_header.brand = @brand
      and car_receipt_header.receipt_type = 'R')
    -(select isnull(sum(isnull(car_refund_header.refund_amount,0)*isnull((select rate from ledger.cur where curr_id = refund_currency),1)),0)
      from car_refund_header,car_refund_detail
        left outer join vehicle_reservation
        on(invoice_no = vehicle_reservation.id)
        and(car_refund_detail.brand = vehicle_reservation.brand)
        left outer join car_quotation_header
        on(car_quotation_header.quotation_header = vehicle_reservation.quotation_header)
        and(vehicle_reservation.brand = car_quotation_header.brand)
      where(car_refund_header.refund_id = car_refund_detail.refund_id)
      and(car_refund_detail.log_store = car_refund_header.log_store)
      and car_quotation_header.quotation_header = @quotation_header
      and car_quotation_header.brand = @brand
      and car_refund_header.refund_type = 'R') as sm,
    isnull(sc,0,sc)+isnull(sm,0,sm) into @paid1,@paid2,@paid
    from about;
  select isnull(sum(paid_amount),0,sum(paid_amount))
    into @paid3 from car_bank_order join car_quotation_header
      on(car_bank_order.quotation_header = car_quotation_header.quotation_header)
      and(car_bank_order.brand = car_quotation_header.brand)
    where car_quotation_header.quotation_header = @quotation_header
    and car_quotation_header.brand = @brand;
  select distinct sum(cash_price) into @paid1 from ws_sales_installment_doc where quotation_header = @quotation_header
    and ws_sales_installment_doc.brand = @brand and delete_flag <> 'Y';
  -- select rate into @car_rate from ledger.cur,vehicle where curr_id = vehicle.sell_currency and vehicle.brand = @brand and vehicle.vin = @vin;
  set @paid = @paid+@paid3;
  /* if @car_rate is null then
set @car_rate=1
end if;
set @paid=@paid/@car_rate;
*/
  return @paid
end
