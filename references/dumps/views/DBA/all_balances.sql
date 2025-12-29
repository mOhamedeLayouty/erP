-- VIEW: DBA.all_balances
-- generated_at: 2025-12-29T14:36:30.513Z
-- object_id: 14065
-- table_id: 1409
-- source_via: SYS.SYSVIEW(view_object_id=object_id)

create view DBA.all_balances( item_id,balance,service_center ) as select distinct sc_balance.item_id,sum(sc_balance.balance) as balance,sc_balance.service_center
    from DBA.sc_balance
    group by sc_balance.item_id,sc_balance.service_center
