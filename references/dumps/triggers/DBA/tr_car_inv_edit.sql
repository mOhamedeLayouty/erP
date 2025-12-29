-- TRIGGER: DBA.tr_car_inv_edit
-- ON TABLE: DBA.car_invoice_header
-- generated_at: 2025-12-29T13:52:33.692Z

create trigger tr_car_inv_edit after update of invoice_date
order 1 on DBA.car_invoice_header
referencing new as new_rec
for each row /* REFERENCING OLD AS old_name NEW AS new_name */
/* WHEN( search_condition ) */
begin
  if new_rec.delete_flag = 'N' then
    update dba.car_debit_header as d
      set d.debit_date = new_rec.invoice_date
      where d.store_id = new_rec.log_store and d.debit_header = new_rec.debit_order
  end if
end
