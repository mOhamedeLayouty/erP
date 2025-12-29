-- TRIGGER: DBA.tu_ws_sales
-- ON TABLE: DBA.ws_sales_installment_doc
-- generated_at: 2025-12-29T13:52:33.683Z

create trigger tu_ws_sales after update order 1 on
DBA.ws_sales_installment_doc
referencing old as old_vin new as new_vin
for each row
begin
  if old_vin.eqpt_id <> new_vin.eqpt_id then
    update vehicle set vehicle_status = 0 where vehicle.vin = old_vin.eqpt_id
  end if
end
