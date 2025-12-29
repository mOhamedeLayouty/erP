-- TRIGGER: DBA.insert_pay
-- ON TABLE: DBA.car_receipt_detail
-- generated_at: 2025-12-29T13:52:33.681Z

create trigger insert_pay.insert_pay after insert order 1 on
DBA.car_receipt_detail
referencing new as new_tbl
for each row
begin
  declare BaseAmount numeric;
  declare PaidAmount numeric;
  declare PaidDate date;
  select vehicle_sales_payments.paid_amount
    into BaseAmount from vehicle_sales_payments
    where(vehicle_sales_payments.order_code = new_tbl.sales_order_code)
    and(vehicle_sales_payments.log_store = new_tbl.log_store)
    and(vehicle_sales_payments.payment_no = new_tbl.payment_no);
  select car_receipt_header.receipt_date
    into PaidDate from car_receipt_header
    where(car_receipt_header.receipt_id = new_tbl.receipt_id)
    and(car_receipt_header.log_store = new_tbl.log_store);
  set BaseAmount = IsNull(BaseAmount,0,BaseAmount);
  set PaidAmount = new_tbl.payment_amount;
  set BaseAmount = BaseAmount+PaidAmount;
  update vehicle_sales_payments
    set paid_amount = BaseAmount
    where(vehicle_sales_payments.order_code = new_tbl.sales_order_code)
    and(vehicle_sales_payments.log_store = new_tbl.log_store)
    and(vehicle_sales_payments.payment_no = new_tbl.payment_no);
  update vehicle_sales_payments
    set paid_date = PaidDate
    where(vehicle_sales_payments.order_code = new_tbl.sales_order_code)
    and(vehicle_sales_payments.log_store = new_tbl.log_store)
    and(vehicle_sales_payments.payment_no = new_tbl.payment_no)
end
