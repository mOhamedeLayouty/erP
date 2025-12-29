-- VIEW: DBA.sc_items_transaction
-- generated_at: 2025-12-29T14:36:30.553Z
-- object_id: 14147
-- table_id: 1419
-- source_via: SYS.SYSVIEW(view_object_id=object_id)

create view DBA.sc_items_transaction as /* view_column_name, ... */
  //V1.1 add new column
  //V1.2 add item_cost to get cost in date  
  //Credit
  select sc_item.item_id as item_id,
    sc_item.sparepart as sparepart,
    sc_item.item_name as item_name,
    sc_item.item_price as item_price,
    sc_credit_header.credit_header as trans_id,
    sc_credit_detail.credit_detail as detial_id,
    sc_credit_detail.item_cost as item_cost,
    sc_credit_detail.price as trans_cost,
    sc_credit_detail.price as trans_price,
    sc_credit_detail.qty as trans_qty,
    sc_credit_header.credit_date as trans_date,
    sc_credit_header.trans_time as trans_time,
    'CR' as trans_type,
    0 as debit_order,
    sc_credit_header.service_center as center_id,
    sc_credit_header.location_id as location_id,
    sc_credit_header.Store_id as store_id,
    0 as location_id_to,
    0 as store_id_to,
    '' as arrival_flag
    from DBA.sc_credit_detail
      ,DBA.sc_credit_header,DBA.sc_item
    where(sc_credit_detail.credit_header = sc_credit_header.credit_header) and(
    sc_credit_detail.service_center = sc_credit_header.service_center) and(
    sc_credit_detail.location_id = sc_credit_header.location_id) and(
    sc_credit_detail.item_id = sc_item.item_id) and(
    sc_credit_detail.service_center = sc_item.service_center) union
  //debit
  select sc_item.item_id as item_id,
    sc_item.sparepart as sparepart,
    sc_item.item_name as item_name,
    sc_item.item_price as item_price,
    sc_debit_header.debit_header as trans_id,
    sc_debit_detail.debit_detail as detial_id,
    sc_debit_detail.item_cost as item_cost,
    sc_debit_detail.item_cost as trans_cost,
    sc_debit_detail.price as trans_price,
    sc_debit_detail.qty as trans_qty,
    sc_debit_header.debit_date as trans_date,
    sc_debit_header.trans_time as trans_time,
    'DB' as trans_type,
    0 as debit_order,
    sc_debit_header.service_center as center_id,
    sc_debit_header.location_id as location_id,
    sc_debit_header.Store_id as store_id,
    0 as location_id_to,
    0 as store_id_to,
    '' as arrival_flag
    from DBA.sc_debit_detail
      ,DBA.sc_debit_header,DBA.sc_item
    where(sc_debit_detail.debit_header = sc_debit_header.debit_header) and(
    sc_debit_detail.service_center = sc_debit_header.service_center) and(
    sc_debit_detail.location_id = sc_debit_header.location_id) and(
    sc_debit_detail.item_id = sc_item.item_id) and(
    sc_debit_detail.service_center = sc_item.service_center) union
  //Return
  select sc_item.item_id as item_id,
    sc_item.sparepart as sparepart,
    sc_item.item_name as item_name,
    sc_item.item_price as item_price,
    sc_ret_header.credit_header as trans_id,
    sc_ret_detail.credit_detail as detail_id,
    sc_ret_detail.item_cost as item_cost,
    sc_ret_detail.cost_price as trans_cost,
    sc_ret_detail.price as trans_price,
    sc_ret_detail.qty as trans_qty,
    sc_ret_header.credit_date as trans_date,
    sc_ret_header.trans_time as trans_time,
    'RT' as trans_type,
    sc_ret_header.debit_header as debit_order,
    sc_ret_header.service_center as center_id,
    sc_ret_header.location_id as location_id,
    sc_ret_header.Store_id as store_id,
    0 as location_id_to,
    0 as store_id_to,
    '' as arrival_flag
    from DBA.sc_ret_detail
      ,DBA.sc_ret_header,DBA.sc_item
    where(sc_ret_detail.credit_header = sc_ret_header.credit_header) and(
    sc_ret_detail.service_center = sc_ret_header.service_center) and(
    sc_ret_detail.location_id = sc_ret_header.location_id) and(
    sc_ret_detail.item_id = sc_item.item_id) and(
    sc_ret_detail.service_center = sc_item.service_center) union
  //Transfer
  select sc_item.item_id as item_id,
    sc_item.sparepart as sparepart,
    sc_item.item_name as item_name,
    sc_item.item_price as item_price,
    sc_transfer_header.credit_header as trans_id,
    sc_transfer_detail.credit_detail as detail_id,
    sc_transfer_detail.item_cost as item_cost,
    sc_transfer_detail.price as trans_cost,
    sc_transfer_detail.price as trans_price,
    sc_transfer_detail.qty as trans_qty,
    sc_transfer_header.credit_date as trans_date,
    sc_transfer_header.trans_time as trans_time,
    'INTr' as trans_type,
    0 as debit_order,
    sc_transfer_header.service_center as center_id,
    sc_transfer_header.location_id as location_id,
    sc_transfer_header.Store_id as store_id,
    sc_transfer_header.location_id_to as location_id_to,
    sc_transfer_header.store_id_to as store_id_to,
    sc_transfer_header.arrival_flag as arrival_flag
    from DBA.sc_transfer_detail
      ,DBA.sc_transfer_header,DBA.sc_item
    where(sc_transfer_detail.credit_header = sc_transfer_header.credit_header) and(
    sc_transfer_detail.service_center = sc_transfer_header.service_center) and(
    sc_transfer_detail.location_id = sc_transfer_header.location_id) and(
    sc_transfer_detail.item_id = sc_item.item_id) and(
    sc_transfer_detail.service_center = sc_item.service_center)
