-- TRIGGER: DBA.modify_pay
-- ON TABLE: DBA.car_receipt_detail
-- generated_at: 2025-12-29T13:52:33.682Z

create trigger modify_pay.modify_pay after update order 2 on
DBA.car_receipt_detail
referencing old as old_tbl new as new_tbl
for each row
begin
  declare BaseAmount numeric;
  declare DiffAmount numeric;
  declare OldAmount numeric;
  declare NewAmount numeric;
  select vehicle_sales_payments.paid_amount
    into BaseAmount from vehicle_sales_payments
    where(vehicle_sales_payments.order_code = new_tbl.sales_order_code)
    and(vehicle_sales_payments.log_store = new_tbl.log_store)
    and(vehicle_sales_payments.payment_no = new_tbl.payment_no);
  set OldAmount = old_tbl.payment_amount;
  set OldAmount = ISNull(OldAmount,0,OldAmount);
  set NewAmount = new_tbl.payment_amount;
  set DiffAmount = NewAmount-OldAmount;
  set BaseAmount = BaseAmount+DiffAmount;
  update vehicle_sales_payments
    set paid_amount = BaseAmount
    where(vehicle_sales_payments.order_code = new_tbl.sales_order_code)
    and(vehicle_sales_payments.log_store = new_tbl.log_store)
    and(vehicle_sales_payments.payment_no = new_tbl.payment_no)
end
