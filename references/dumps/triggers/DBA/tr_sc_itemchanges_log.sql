-- TRIGGER: DBA.tr_sc_itemchanges_log
-- ON TABLE: DBA.sc_item
-- generated_at: 2025-12-29T13:52:33.691Z

create trigger tr_sc_itemchanges_log after update of item_sell_way,item_percent,item_price,
official_price order 1 on DBA.sc_item
referencing old as old_item new as new_item
for each row
/* WHEN( search_condition ) */
--V2.0 add new column(item_sell_way,item_percent,official_price)
begin
  insert into sc_itemchanges_log
    ( log_date,
    item_id,
    old_sell_way,
    new_sell_way,
    old_percent,
    new_percent,
    old_price,
    new_price,
    old_official_price,
    new_official_price,
    log_user,
    log_pc,
    service_center ) values
    ( new_item.edit_date,
    new_item.item_id,
    old_item.item_sell_way,
    new_item.item_sell_way,
    old_item.item_percent,
    new_item.item_percent,
    old_item.item_price,
    new_item.item_price,
    old_item.official_price,
    new_item.official_price,
    new_item.edit_user,
    new_item.edit_pc,
    new_item.service_center ) 
end
