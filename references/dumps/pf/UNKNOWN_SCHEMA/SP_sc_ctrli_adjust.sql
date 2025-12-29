-- PF: UNKNOWN_SCHEMA.SP_sc_ctrli_adjust
-- proc_id: 435
-- generated_at: 2025-12-29T13:53:28.817Z

create procedure DBA.SP_sc_ctrli_adjust()
begin
  declare @store_id integer;
  declare @service_center integer;
  declare @location_id integer;
  declare err_notfound exception for sqlstate value '02000';
  declare cur_all dynamic scroll cursor for select store_id,service_center,location_id from DBA.sc_store;
  open cur_all;
  MyLoop: loop
    fetch next cur_all into @store_id,@service_center,@location_id;
    if sqlstate = err_notfound or @store_id is null then
      leave MyLoop
    end if;
    update sc_balance
      ,sc_item
      ,sc_store set sc_balance.balance = DBA.f_get_item_balance_date(sc_balance.item_id,sc_balance.service_center,sc_balance.location_id,sc_balance.store_id)
      where(sc_balance.item_id = sc_item.item_id)
      and(sc_balance.service_center = sc_item.service_center)
      and(sc_balance.store_id = sc_store.store_id)
      and(sc_balance.service_center = sc_store.service_center)
      and(sc_balance.location_id = sc_store.location_id)
      and(sc_store.service_center = sc_item.service_center)
      and(sc_balance.balance <> DBA.f_get_item_balance_date(sc_balance.item_id,sc_balance.service_center,sc_balance.location_id,sc_balance.store_id))
      and sc_balance.service_center = @service_center
      and sc_balance.location_id = @location_id
      and sc_balance.store_id = @store_id
  end loop MyLoop;
  close cur_all
end
