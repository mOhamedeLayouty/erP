-- TRIGGER: DBA.items_secial_price_hist_trig_d
-- ON TABLE: DBA.items_secial_price
-- generated_at: 2025-12-29T13:52:33.684Z

create trigger items_secial_price_hist_trig_d after delete order 1 on
DBA.items_secial_price
referencing old as old_name
for each row /* REFERENCING OLD AS old_name */
/* WHEN( search_condition ) */
begin
  insert into items_secial_price_hist( sp_id,item_id,service_center,
    special_price,user_id,trans_type ) values
    ( old_name.sp_id,old_name.item_id,old_name.service_center,old_name.special_price,
    old_name.user_id,'D' ) 
end
