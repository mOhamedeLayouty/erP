-- VIEW: DBA.v_detail_revenue
-- generated_at: 2025-12-29T14:36:30.554Z
-- object_id: 21634
-- table_id: 1452
-- source_via: SYS.SYSVIEW(view_object_id=object_id)

create view DBA.v_detail_revenue /* view_column_name, ... */
  as select ws_invoicetype.name_e as invoicetype_name_e,
    ws_invoicetype.name_a as invoicetype_name_a,
    ws_invoiceheader.chargable as chargable,
    ws_invoiceheader.status as status,
    ws_invoiceheader.invoicedate as invoicedate,
    ws_invoiceheader.invoiceno as invoiceno,
    ws_invoiceheader.joborder_id as inv_joborder_id,
    ws_invoiceheader.receptionist as receptionist,
    ws_eqpt.vin_no as eqpt_vin,
    ws_invoiceheader.debit_header as inv_debit_header,
    ws_invoiceheader.invoice_nature as invoice_nature,
    ws_invoiceheader.itemdiscount as itemdiscount,
    ws_invoiceheader.OilDiscount as OilDiscount,
    ws_invoiceheader.LaborDiscount as LaborDiscount,
    ws_invoiceheader.DeleteFlag as DeleteFlag,
    customer.customer_name_a as customer_name_a,
    customer.customer_name_e as customer_name_e,
    isnull((select top 1 ledger.cur.rate from ledger.cur where(ws_invoiceheader.currency_id = ledger.cur.curr_id)),1) as rate,
    (ws_invoicedetail.qty*ws_invoicedetail.price)*rate as SP,
    (((case ws_InvoiceDetail.non_discounted when 'N' then ws_invoicedetail.qty*ws_invoicedetail.price else 0 end)*(case ws_invoicedetail.itemType when 'O' then OilDiscount else itemdiscount end))/100)*rate as SP_discounted,
    (ws_invoicedetail.price)*rate as OP,
    ((ws_invoicedetail.price*LaborDiscount)/100)*rate as OP_discounted,
    ws_invoicedetail.InvoiceID,
    ws_invoicedetail.invoicetype,
    ws_invoicedetail.service_center,
    ws_invoicedetail.location_id,
    ws_invoicedetail.Flag,
    ws_invoicedetail.ItemID,
    ws_invoicedetail.Qty,
    ws_invoicedetail.Price,
    ws_invoicedetail.itemtype,
    ws_invoicedetail.OperationType,
    sc_item.item_group_id as item_group_id,
    sc_item.item_grp_code as item_grp_code,
    sc_item.item_grp_code3 as item_grp_code3,
    sc_item.item_grp_code4 as item_grp_code4,
    sc_item.item_grp_code5 as item_grp_code5,
    sc_item.item_grp_code6 as item_grp_code6,
    (select sum(sc_debit_detail.item_cost*sc_debit_detail.qty)/sum(sc_debit_detail.qty)
      from DBA.sc_debit_detail,DBA.sc_debit_header
      where(sc_debit_header.debit_header = sc_debit_detail.debit_header)
      and(sc_debit_detail.service_center = sc_debit_header.service_center)
      and(sc_debit_detail.location_id = sc_debit_header.location_id)
      and(ws_invoicedetail.itemid = sc_debit_detail.item_id)
      and(ws_invoicedetail.InvoiceType = sc_debit_detail.invoicetype)
      and(ws_invoicedetail.service_center = sc_debit_detail.service_center)
      and(ws_invoicedetail.location_id = sc_debit_detail.location_id)
      and(sc_debit_header.debit_header = inv_debit_header and inv_joborder_id is null)) as Cost_Price1,
    (select sum(sc_debit_detail.item_cost*sc_debit_detail.qty)/sum(sc_debit_detail.qty)
      from DBA.sc_debit_detail,DBA.sc_debit_header
      where(sc_debit_header.debit_header = sc_debit_detail.debit_header)
      and(sc_debit_detail.service_center = sc_debit_header.service_center)
      and(sc_debit_detail.location_id = sc_debit_header.location_id)
      and(ws_invoicedetail.itemid = sc_debit_detail.item_id)
      and(ws_invoicedetail.InvoiceType = sc_debit_detail.invoicetype)
      and(ws_invoicedetail.service_center = sc_debit_detail.service_center)
      and(ws_invoicedetail.location_id = sc_debit_detail.location_id)
      and(sc_debit_header.joborderid = inv_joborder_id and inv_joborder_id is not null)) as Cost_Price2,
    (case when inv_joborder_id is null then Cost_Price1 else Cost_Price2 end) as Cost_Price
    from DBA.ws_invoicedetail left outer join dba.sc_item on ws_invoicedetail.itemid = sc_item.item_id and ws_invoicedetail.service_center = sc_item.service_center
      ,DBA.ws_invoiceheader left outer join dba.customer on ws_invoiceheader.customerid = customer.customer_id
      left outer join dba.ws_eqpt on ws_invoiceheader.eqptid = ws_eqpt.eqpt_id and ws_invoiceheader.service_center = ws_eqpt.service_center
      ,DBA.ws_invoicetype
    where(ws_invoiceheader.invoicetype = ws_invoicetype.invoicetypeid)
    and(ws_invoiceheader.service_center = ws_invoicetype.service_center)
    and(ws_invoiceheader.invoiceid = ws_invoicedetail.invoiceid)
    and(ws_invoiceheader.invoicetype = ws_invoicedetail.invoicetype)
    and(ws_invoiceheader.service_center = ws_invoicedetail.service_center)
    and(ws_invoiceheader.location_id = ws_invoicedetail.location_id)
    and(ws_invoicedetail.invoicetype = ws_invoicetype.invoicetypeid)
    and(ws_invoicedetail.service_center = ws_invoicetype.service_center)
    and(Isnull(deleteflag,'N') = 'N')
    and((chargable = 'Y' and status <> 'P') or chargable = 'N')
