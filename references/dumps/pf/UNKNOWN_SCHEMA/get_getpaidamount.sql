-- PF: UNKNOWN_SCHEMA.get_getpaidamount
-- proc_id: 375
-- generated_at: 2025-12-29T13:53:28.800Z

create function DBA.get_getpaidamount( in @as_vehicle_id varchar(10),in @vin varchar(50),in @brand integer default 1,in @fdate date default '1900-01-01',in @tdate date default today() ) 
returns decimal(12,2)
--Ver 1.4 02-12-2014
--Ver 1.3 11-11-2009 
--Ver return paidvalue by vin carrency
--Ver 1.4 avoid bank
--Ver 1.5 get rate from specified ledger comapnay
--Ver 1.6 handling vin is null or vin with multi order
--Ver 1.7 rate =0
--Ver 1.8 return paidvalue by vin carrency
--Ver 1.9 error for more currencies
--Ver 2.0 remove Bank Order from paid amount
--Ver 2.1 top(1) from rate 
--Ver 2.2 add date to function
--Ver 2.3 avoid refund for advanced payement
--Ver 2.4 Add sales_order_log_store col for Refund table and link with it.
--Ver 2.5 subtract refund amount from car_refund_detail not header.
--Ver 2.6 avoid deleted reciepts in car_receipt_header
--Ver 2.7 avoid deleted refund reciepts in car_refund_header
begin
  declare @paid decimal(12,2);
  declare @paid1 decimal(12,2);
  declare @paid3 decimal(12,2);
  declare @paid2 integer;
  declare @car_rate decimal(12,2);
  select distinct(select sum(payment_amount*isnull((select rate from ledger.cur where curr_id = receipt_currency and company_code = convert(integer,DBA.f_get_about('gl_company_code'))),1)) from car_receipt_header,car_receipt_detail
        left outer join ws_sales_installment_doc
        on(car_receipt_detail.sales_order_log_store = ws_sales_installment_doc.log_store)
        and(car_receipt_detail.sales_order_code = ws_sales_installment_doc.order_code)
        and(car_receipt_detail.brand = ws_sales_installment_doc.brand)
      where(car_receipt_header.receipt_id = car_receipt_detail.receipt_id) and(car_receipt_header.receipt_date >= @fdate and car_receipt_header.receipt_date <= @tdate) /**/
      and(car_receipt_detail.log_store = car_receipt_header.log_store)
      and ws_sales_installment_doc.vehicle_id = @as_vehicle_id
      and ws_sales_installment_doc.eqpt_id = @vin and ws_sales_installment_doc.brand = @brand
      and car_receipt_header.receipt_type <> 'R'
      and ws_sales_installment_doc.delete_flag <> 'Y'
      and car_receipt_header.delete_flag <> 'Y')
    -(select isnull(sum(car_refund_detail.refund_amount*isnull((select rate from ledger.cur where curr_id = refund_currency and company_code = convert(integer,DBA.f_get_about('gl_company_code'))),1)),0) from car_refund_header,car_refund_detail
        left outer join ws_sales_installment_doc
        on(car_refund_detail.sales_order_log_store = ws_sales_installment_doc.log_store)
        and(car_refund_detail.invoice_no = ws_sales_installment_doc.order_code)
        and(car_refund_detail.brand = ws_sales_installment_doc.brand)
      where(car_refund_header.refund_id = car_refund_detail.refund_id) and(car_refund_header.refund_date >= @fdate and car_refund_header.refund_date <= @tdate) /**/
      and(car_refund_detail.log_store = car_refund_header.log_store)
      and ws_sales_installment_doc.vehicle_id = @as_vehicle_id
      and ws_sales_installment_doc.eqpt_id = @vin and ws_sales_installment_doc.brand = @brand
      and car_refund_header.refund_type not in( 'R','A' ) 
      and car_refund_header.delete_flag <> 'Y'
      and ws_sales_installment_doc.delete_flag <> 'Y') as sc,
    (select sum(payment_amount*isnull((select rate from ledger.cur where curr_id = receipt_currency and company_code = convert(integer,DBA.f_get_about('gl_company_code'))),1)) from car_receipt_header,car_receipt_detail
        left outer join vehicle_reservation
        on(car_receipt_detail.sales_order_log_store = vehicle_reservation.log_store)
        and(car_receipt_detail.sales_order_code = vehicle_reservation.id)
        and(car_receipt_detail.brand = vehicle_reservation.brand)
        left outer join ws_sales_installment_doc
        on(reservation_code = vehicle_reservation.id)
        and(vehicle_reservation.log_store = ws_sales_installment_doc.log_store)
        and(vehicle_reservation.brand = ws_sales_installment_doc.brand)
      where(car_receipt_header.receipt_id = car_receipt_detail.receipt_id) and(car_receipt_header.receipt_date >= @fdate and car_receipt_header.receipt_date <= @tdate) /**/
      and(car_receipt_detail.log_store = car_receipt_header.log_store)
      and ws_sales_installment_doc.vehicle_id = @as_vehicle_id
      and ws_sales_installment_doc.eqpt_id = @vin and ws_sales_installment_doc.brand = @brand
      and car_receipt_header.receipt_type = 'R'
      and ws_sales_installment_doc.delete_flag <> 'Y'
      and car_receipt_header.delete_flag <> 'Y')
    -(select isnull(sum(isnull(car_refund_detail.refund_amount,0)*isnull((select rate from ledger.cur where curr_id = refund_currency and company_code = convert(integer,DBA.f_get_about('gl_company_code'))),1)),0) from car_refund_header,car_refund_detail
        left outer join vehicle_reservation
        on(car_refund_detail.sales_order_log_store = vehicle_reservation.log_store)
        and(invoice_no = vehicle_reservation.id)
        and(car_refund_detail.brand = vehicle_reservation.brand)
        left outer join ws_sales_installment_doc
        on(reservation_code = vehicle_reservation.id)
        and(vehicle_reservation.log_store = ws_sales_installment_doc.log_store)
        and(vehicle_reservation.brand = ws_sales_installment_doc.brand)
      where(car_refund_header.refund_id = car_refund_detail.refund_id) and(car_refund_header.refund_date >= @fdate and car_refund_header.refund_date <= @tdate) /**/
      and(car_refund_detail.log_store = car_refund_header.log_store)
      and ws_sales_installment_doc.vehicle_id = @as_vehicle_id
      and ws_sales_installment_doc.eqpt_id = @vin and ws_sales_installment_doc.brand = @brand
      and car_refund_header.refund_type = 'R'
      and car_refund_header.delete_flag <> 'Y'
      and ws_sales_installment_doc.delete_flag <> 'Y') as sm,
    isnull(sc,0,sc)+isnull(sm,0,sm) into @paid1,@paid2,@paid
    from about;
  /*
select isnull(sum(paid_amount),0,sum(paid_amount))
into @paid3 from car_bank_order join ws_sales_installment_doc
on(sale_order = ws_sales_installment_doc.order_code)
and(car_bank_order.sale_order_log_store = ws_sales_installment_doc.log_store)
and(car_bank_order.brand = ws_sales_installment_doc.brand)
where ws_sales_installment_doc.vehicle_id = @as_vehicle_id
and ws_sales_installment_doc.eqpt_id = @vin and ws_sales_installment_doc.brand = @brand;
*/
  select top 1 cash_price into @paid1 from ws_sales_installment_doc where eqpt_id = @vin and vehicle_id = @as_vehicle_id
    and ws_sales_installment_doc.brand = @brand
    and delete_flag <> 'Y' order by sale_date desc;
  select top 1 rate into @car_rate from ledger.cur,vehicle where curr_id = vehicle.sell_currency
    and vehicle.brand = @brand and vehicle.vin = @vin and vehicle_id = @as_vehicle_id and company_code = convert(integer,DBA.f_get_about('gl_company_code'));
  set @paid = @paid; //+@paid3
  if @car_rate is null then
    set @car_rate = 1
  end if;
  set @paid = @paid/@car_rate;
  return @paid
end
