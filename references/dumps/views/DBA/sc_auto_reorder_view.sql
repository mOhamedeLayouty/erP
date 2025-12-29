-- VIEW: DBA.sc_auto_reorder_view
-- generated_at: 2025-12-29T14:36:30.550Z
-- object_id: 14245
-- table_id: 1425
-- source_via: SYS.SYSVIEW(view_object_id=object_id)

create view DBA.sc_auto_reorder_view /* view_column_name, ... */
  as select distinct sc_auto_reorder.item_id,
    sc_auto_reorder.service_center,
    sc_auto_reorder.qty,
    sc_auto_reorder.price,
    sc_auto_reorder.chck,
    sc_auto_reorder.lost_qty,
    sc_auto_reorder.sold_qty,
    sc_auto_reorder.last_receive,
    sc_auto_reorder.last_sold,
    sc_auto_reorder.on_hand,
    sc_auto_reorder.vendor_price,
    sc_auto_reorder.back_order,
    sc_auto_reorder.on_order,
    sc_auto_reorder.location_id,
    sc_auto_reorder.ord_factor,
    sc_auto_reorder.po_qty,
    sc_auto_reorder.from_date,
    sc_auto_reorder.to_date,
    sc_auto_reorder.no_month,
    sc_auto_reorder.lead_time,
    sc_auto_reorder.safety_stock_time,
    sc_item.item_grp_code,
    sc_balance.price as cost_price,
    sc_item.item_group_id,
    sc_auto_reorder.sold_ws,
    sc_auto_reorder.sold_oc,
    sc_auto_reorder.sold_stl
    from DBA.sc_auto_reorder
      ,DBA.sc_item
      ,DBA.sc_balance
    where(sc_auto_reorder.item_id = sc_item.item_id) and(
    sc_auto_reorder.service_center = sc_item.service_center) and(
    sc_auto_reorder.item_id = sc_balance.item_id) and(
    sc_auto_reorder.service_center = sc_balance.service_center) and(
    sc_auto_reorder.location_id = sc_balance.location_id)
    and DBA.sc_auto_reorder.qty > 0 and DBA.sc_auto_reorder.ord_factor >= 1 and(
    sc_balance.store_id = (select min(sc_balance.store_id) from DBA.sc_balance where(sc_auto_reorder.service_center = sc_balance.service_center) and(
      sc_auto_reorder.location_id = sc_balance.location_id)))
