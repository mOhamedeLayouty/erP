-- VIEW: DBA.month_balance_view
-- generated_at: 2025-12-29T14:36:30.544Z
-- object_id: 14069
-- table_id: 1410
-- source_via: SYS.SYSVIEW(view_object_id=object_id)

create view DBA.month_balance_view( item_id,rate,b_date,service_center,location_id ) 
  as select distinct sc_month_balance.item_id,
    SUM(sc_month_balance.rate) as rate,
    sc_month_balance.b_date,
    sc_month_balance.service_center,
    sc_month_balance.location_id
    from DBA.sc_month_balance
    group by sc_month_balance.item_id,
    sc_month_balance.b_date,
    sc_month_balance.service_center,
    sc_month_balance.location_id
