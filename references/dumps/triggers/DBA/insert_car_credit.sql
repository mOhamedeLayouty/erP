-- TRIGGER: DBA.insert_car_credit
-- ON TABLE: DBA.car_credit_detail
-- generated_at: 2025-12-29T13:52:33.679Z

create trigger insert_car_credit after insert on
DBA.car_credit_detail
referencing new as new_row
for each row
begin
  update vehicle set stock_number = new_row.log_stock where vehicle.vin = new_row.vin
end
