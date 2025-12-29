-- VIEW: DBA.v_items_debit_return
-- generated_at: 2025-12-29T14:36:30.556Z
-- object_id: 21498
-- table_id: 1451
-- source_via: SYS.SYSVIEW(view_object_id=object_id)

create view DBA.v_items_debit_return as /* view_column_name, ... */
  select sc_item.item_id,
    sc_item.sparepart,
    sc_item.description,
    sc_item.description_e,
    sc_item.itemtype,
    sc_item.item_group_id,
    sc_item.item_grp_code,
    sc_item.item_grp_code3,
    sc_item.item_grp_code4,
    sc_item.item_grp_code5,
    sc_item.item_grp_code6,
    sc_debit_detail.price,
    sc_debit_detail.qty,
    sc_debit_detail.item_cost,
    sc_debit_detail.invoicetype,
    1 as trans_type,
    sc_debit_header.debit_type as debit_type,
    sc_debit_header.trans_id as debit_trans_id,
    sc_debit_header.debit_header as trans_no,
    sc_debit_header.credit_manual_number as manual_no,
    sc_debit_header.debit_date as trans_date,
    sc_debit_header.debit_header,
    sc_debit_header.debit_date as debit_date,
    sc_debit_header.joborderid,
    customer.customer_id,
    customer.customer_name_a,
    customer.customer_name_e,
    sc_debit_header.customer_name,
    ws_InvoiceType.name_e,
    ws_InvoiceType.name_a,
    DBA.f_get_about('stock_only') as stock_only,
    sc_debit_header.service_center,
    sc_debit_header.location_id,
    sc_debit_header.store_id,
    (select top 1 ws_joborder.eqptid from DBA.ws_joborder where ws_joborder.joborderid = sc_debit_header.joborderid
      and ws_joborder.service_center = sc_debit_header.service_center and ws_joborder.location_id = sc_debit_header.location_id) as eqptid
    from DBA.sc_debit_header left outer join DBA.customer on sc_debit_header.cus_code = customer.customer_id
      ,DBA.sc_debit_detail
      ,DBA.sc_store
      ,DBA.sc_item,DBA.ws_InvoiceType
    where(sc_debit_detail.debit_header = sc_debit_header.debit_header)
    and(sc_debit_detail.service_center = sc_debit_header.service_center)
    and(sc_debit_detail.location_id = sc_debit_header.location_id)
    and(sc_store.store_id = sc_debit_header.store_id)
    and(sc_store.service_center = sc_debit_header.service_center)
    and(sc_store.location_id = sc_debit_header.location_id)
    and(sc_debit_detail.service_center = sc_item.service_center)
    and(sc_debit_detail.item_id = sc_item.item_id)
    and(ws_InvoiceType.InvoiceTypeID = sc_debit_detail.invoicetype)
    and(ws_InvoiceType.service_center = sc_debit_detail.service_center) union
  select sc_item.item_id,
    sc_item.sparepart,
    sc_item.description,
    sc_item.description_e,
    sc_item.itemtype,
    sc_item.item_group_id,
    sc_item.item_grp_code,
    sc_item.item_grp_code3,
    sc_item.item_grp_code4,
    sc_item.item_grp_code5,
    sc_item.item_grp_code6,
    sc_ret_detail.price,
    sc_ret_detail.qty,
    sc_ret_detail.cost_price,
    sc_ret_detail.invoicetype,
    2 as trans_type,
    sc_debit_header.debit_type as debit_type,
    sc_debit_header.trans_id as debit_trans_id,
    sc_ret_header.credit_header as trans_no,
    sc_ret_header.manual_number as manual_no,
    sc_ret_header.credit_date as trans_date,
    sc_debit_header.debit_header,
    sc_debit_header.debit_date as debit_date,
    sc_debit_header.joborderid,
    customer.customer_id,
    customer.customer_name_a,
    customer.customer_name_e,
    sc_debit_header.customer_name,
    ws_invoicetype.name_e,
    ws_invoicetype.name_a,
    DBA.f_get_about('stock_only') as stock_only,
    sc_ret_header.service_center,
    sc_ret_header.location_id,
    sc_ret_header.store_id,
    (select top 1 ws_joborder.eqptid from DBA.ws_joborder where ws_joborder.joborderid = sc_debit_header.joborderid
      and ws_joborder.service_center = sc_debit_header.service_center and ws_joborder.location_id = sc_debit_header.location_id) as eqptid
    from DBA.sc_debit_header left outer join DBA.customer on sc_debit_header.cus_code = customer.customer_id
      ,DBA.sc_ret_detail
      ,DBA.sc_ret_header
      ,DBA.sc_store
      ,DBA.ws_invoicetype
      ,DBA.sc_item
    where(sc_ret_detail.credit_header = sc_ret_header.credit_header)
    and(sc_ret_detail.service_center = sc_ret_header.service_center)
    and(sc_ret_detail.location_id = sc_ret_header.location_id)
    and(sc_ret_header.store_id = sc_store.store_id)
    and(sc_ret_header.service_center = sc_store.service_center)
    and(sc_ret_header.location_id = sc_store.location_id)
    and(ws_invoicetype.invoicetypeid = sc_ret_detail.invoicetype)
    and(ws_invoicetype.service_center = sc_ret_detail.service_center)
    and(sc_ret_detail.item_id = sc_item.item_id)
    and(sc_item.service_center = sc_ret_detail.service_center)
    and(sc_ret_header.debit_header = sc_debit_header.debit_header)
    and(sc_ret_header.service_center = sc_debit_header.service_center)
    and(sc_ret_header.debit_location = sc_debit_header.location_id)
