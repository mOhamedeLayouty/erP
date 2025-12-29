-- VIEW: DBA.sc_items_cost_price
-- generated_at: 2025-12-29T14:36:30.551Z
-- object_id: 14108
-- table_id: 1414
-- source_via: SYS.SYSVIEW(view_object_id=object_id)

create view DBA.sc_items_cost_price /* view_column_name, ... */
  as select max(isnull(sc_balance.price,0)) as price,
    sc_balance.item_id,
    sc_balance.service_center
    from dba.sc_balance as sc_balance,dba.sc_balance as a
    where sc_balance.item_id = a.item_id and sc_balance.service_center = a.service_center
    group by sc_balance.item_id,sc_balance.service_center
