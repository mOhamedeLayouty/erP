-- TRIGGER: DBA.delete_pay
-- ON TABLE: DBA.car_receipt_detail
-- generated_at: 2025-12-29T13:52:33.681Z

create trigger delete_pay.delete_pay after delete order 3 on
DBA.car_receipt_detail
referencing old as old_tbl
for each row
begin
  declare BaseAmount numeric;
  declare OldAmount numeric;
  select vehicle_sales_payments.paid_amount
    into BaseAmount from vehicle_sales_payments
    where(vehicle_sales_payments.order_code = old_tbl.sales_order_code)
    and(vehicle_sales_payments.log_store = old_tbl.log_store)
    and(vehicle_sales_payments.payment_no = old_tbl.payment_no);
  set OldAmount = old_tbl.payment_amount;
  set BaseAmount = BaseAmount-OldAmount;
  update vehicle_sales_payments
    set paid_amount = BaseAmount
    where(vehicle_sales_payments.order_code = old_tbl.sales_order_code)
    and(vehicle_sales_payments.log_store = old_tbl.log_store)
    and(vehicle_sales_payments.payment_no = old_tbl.payment_no)
end
