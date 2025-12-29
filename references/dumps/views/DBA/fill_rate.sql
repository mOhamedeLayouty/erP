-- VIEW: DBA.fill_rate
-- generated_at: 2025-12-29T14:36:30.536Z
-- object_id: 14112
-- table_id: 1415
-- source_via: SYS.SYSVIEW(view_object_id=object_id)

create view DBA.fill_rate as /* view_column_name, ... */
  select count(ws_receptionoperationitem.itemid) as no_pp,
    year(ws_reception.starttime) as year,
    month(ws_reception.starttime) as month,
    ws_reception.service_center,
    ws_reception.location_id,ws_reception.receptionid,
    1 as typ
    from DBA.ws_reception
      ,DBA.ws_receptionoperationitem
    where(ws_reception.receptionid = ws_receptionoperationitem.receptionid) and(
    ws_reception.service_center = ws_receptionoperationitem.service_center) and(
    ws_reception.location_id = ws_receptionoperationitem.location_id)
    group by ws_reception.starttime,ws_reception.service_center,
    ws_reception.location_id,ws_reception.receptionid union
  select count(sc_debit_detail.item_id),
    year(ws_reception.starttime) as year,
    month(ws_reception.starttime) as month,
    ws_reception.service_center,
    ws_reception.location_id,ws_reception.receptionid,
    2 as typ
    from DBA.ws_reception
      ,DBA.ws_receptionoperationitem
      ,DBA.sc_debit_detail
      ,DBA.sc_debit_header
    where(ws_reception.receptionid = ws_receptionoperationitem.receptionid) and(
    ws_reception.service_center = ws_receptionoperationitem.service_center) and(
    ws_reception.location_id = ws_receptionoperationitem.location_id) and(
    sc_debit_header.debit_header = sc_debit_detail.debit_header) and(
    sc_debit_header.service_center = sc_debit_detail.service_center) and(
    sc_debit_header.location_id = sc_debit_detail.location_id) and(
    ws_reception.receptionid = sc_debit_header.joborderid) and(
    ws_reception.service_center = sc_debit_header.service_center) and(
    ws_reception.location_id = sc_debit_header.location_id) and(
    ws_receptionoperationitem.itemid = sc_debit_detail.item_id) and(
    ws_receptionoperationitem.service_center = sc_debit_detail.service_center) and(
    ws_receptionoperationitem.location_id = sc_debit_detail.location_id)
    group by ws_reception.starttime,ws_reception.service_center,
    ws_reception.location_id,ws_reception.receptionid
