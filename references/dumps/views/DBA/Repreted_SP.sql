-- VIEW: DBA.Repreted_SP
-- generated_at: 2025-12-29T14:36:30.548Z
-- object_id: 14092
-- table_id: 1412
-- source_via: SYS.SYSVIEW(view_object_id=object_id)

create view DBA.Repreted_SP as select sc_item.service_center,
    sc_item.sparepart,
    Count(sc_item.sparepart)
    from DBA.sc_item
    group by sc_item.sparepart,
    sc_item.service_center having(
    Count(sc_item.sparepart) > 1)
