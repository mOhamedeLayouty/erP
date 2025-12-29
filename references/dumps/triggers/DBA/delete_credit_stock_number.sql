-- TRIGGER: DBA.delete_credit_stock_number
-- ON TABLE: DBA.car_credit_detail
-- generated_at: 2025-12-29T13:52:33.680Z

create trigger delete_credit_stock_number after delete order 1 on DBA.car_credit_detail
referencing old as old_row
for each row begin
  update vehicle set stock_number = null where vehicle.vin = old_row.vin
    and vehicle.brand = old_row.brand
end
