-- PF: UNKNOWN_SCHEMA.SP_GetWSRevenueDetails
-- proc_id: 428
-- generated_at: 2025-12-29T13:53:28.815Z

create procedure DBA.SP_GetWSRevenueDetails( in @center integer default 1,in @location integer default 1,in @FDate date default today(),in @TDate date default today() ) 
/* RESULT( column_name column_type, ... ) */
begin
  select Invoice.invoicedate,
    isnull((select Sum(ws_invoicedetail.price*ws_invoicedetail.qty)
      from ws_invoicedetail
        ,ws_invoiceheader
        ,ws_invoicetype
      where(ws_invoicedetail.invoiceid = ws_invoiceheader.invoiceid)
      and(ws_invoicedetail.service_center = ws_invoiceheader.service_center)
      and(ws_invoicedetail.location_id = ws_invoiceheader.location_id)
      and(ws_invoicedetail.invoicetype = ws_invoiceheader.invoicetype)
      and(ws_invoicetype.invoicetypeid = ws_invoiceheader.invoicetype)
      and(ws_invoicetype.service_center = ws_invoiceheader.service_center)
      and(ws_invoiceheader.invoicedate = Invoice.invoicedate)
      and(ws_invoiceheader.service_center = @center)
      and(ws_invoiceheader.location_id = @location)
      and(ws_invoiceheader.status <> 'P')
      and(ws_invoiceheader.invoice_nature = 'O')
      and(isnull(ws_invoiceheader.deleteflag,'N') = 'N')
      and(ws_invoiceheader.joborder_id is null or ws_invoiceheader.joborder_id = '')
      and(ws_invoicetype.chargable = 'Y') and(ws_invoicetype.category <> 5)
      and(ws_invoicedetail.flag = 'I')
      and(ws_invoicedetail.itemtype = 'O')
      and(ws_invoicedetail.non_taxable <> 'Y')),0) as Cash_Oil,
    isnull((select Sum(ws_invoicedetail.price*ws_invoicedetail.qty)
      from ws_invoicedetail
        ,ws_invoiceheader
        ,ws_invoicetype
      where(ws_invoicedetail.invoiceid = ws_invoiceheader.invoiceid)
      and(ws_invoicedetail.service_center = ws_invoiceheader.service_center)
      and(ws_invoicedetail.location_id = ws_invoiceheader.location_id)
      and(ws_invoicedetail.invoicetype = ws_invoiceheader.invoicetype)
      and(ws_invoicetype.invoicetypeid = ws_invoiceheader.invoicetype)
      and(ws_invoicetype.service_center = ws_invoiceheader.service_center)
      and(ws_invoiceheader.invoicedate = Invoice.invoicedate)
      and(ws_invoiceheader.service_center = @center)
      and(ws_invoiceheader.location_id = @location)
      and(ws_invoiceheader.status <> 'P')
      and(ws_invoiceheader.invoice_nature = 'O')
      and(isnull(ws_invoiceheader.deleteflag,'N') = 'N')
      and(ws_invoiceheader.joborder_id is null or ws_invoiceheader.joborder_id = '')
      and(ws_invoicetype.chargable = 'Y') and(ws_invoicetype.category <> 5)
      and(ws_invoicedetail.flag = 'I')
      and(ws_invoicedetail.itemtype = 'O')
      and(ws_invoicedetail.non_taxable = 'Y')),0) as Cash_Oil_nontax,
    isnull((select Sum(ws_invoicedetail.price*ws_invoicedetail.qty)
      from ws_invoicedetail
        ,ws_invoiceheader
        ,ws_invoicetype
      where(ws_invoicedetail.invoiceid = ws_invoiceheader.invoiceid)
      and(ws_invoicedetail.service_center = ws_invoiceheader.service_center)
      and(ws_invoicedetail.location_id = ws_invoiceheader.location_id)
      and(ws_invoicedetail.invoicetype = ws_invoiceheader.invoicetype)
      and(ws_invoicetype.invoicetypeid = ws_invoiceheader.invoicetype)
      and(ws_invoicetype.service_center = ws_invoiceheader.service_center)
      and(ws_invoiceheader.invoicedate = Invoice.invoicedate)
      and(ws_invoiceheader.service_center = @center)
      and(ws_invoiceheader.location_id = @location)
      and(ws_invoiceheader.status <> 'P')
      and(ws_invoiceheader.invoice_nature = 'O')
      and(isnull(ws_invoiceheader.deleteflag,'N') = 'N')
      and(ws_invoiceheader.joborder_id is not null or ws_invoiceheader.joborder_id <> '')
      and(ws_invoicetype.chargable = 'Y') and(ws_invoicetype.category <> 5)
      and(ws_invoicedetail.flag = 'I')
      and(ws_invoicedetail.itemtype = 'O')
      and(ws_invoicedetail.non_taxable <> 'Y')),0) as Job_Oil,
    isnull((select Sum(ws_invoicedetail.price*ws_invoicedetail.qty)
      from ws_invoicedetail
        ,ws_invoiceheader
        ,ws_invoicetype
      where(ws_invoicedetail.invoiceid = ws_invoiceheader.invoiceid)
      and(ws_invoicedetail.service_center = ws_invoiceheader.service_center)
      and(ws_invoicedetail.location_id = ws_invoiceheader.location_id)
      and(ws_invoicedetail.invoicetype = ws_invoiceheader.invoicetype)
      and(ws_invoicetype.invoicetypeid = ws_invoiceheader.invoicetype)
      and(ws_invoicetype.service_center = ws_invoiceheader.service_center)
      and(ws_invoiceheader.invoicedate = Invoice.invoicedate)
      and(ws_invoiceheader.service_center = @center)
      and(ws_invoiceheader.location_id = @location)
      and(ws_invoiceheader.status <> 'P')
      and(ws_invoiceheader.invoice_nature = 'O')
      and(isnull(ws_invoiceheader.deleteflag,'N') = 'N')
      and(ws_invoiceheader.joborder_id is not null or ws_invoiceheader.joborder_id <> '')
      and(ws_invoicetype.chargable = 'Y') and(ws_invoicetype.category <> 5)
      and(ws_invoicedetail.flag = 'I')
      and(ws_invoicedetail.itemtype = 'O')
      and(ws_invoicedetail.non_taxable = 'Y')),0) as Job_Oil_nontax,
    isnull((select Sum(ws_invoicedetail.price*ws_invoicedetail.qty)
      from ws_invoicedetail
        ,ws_invoiceheader
        ,ws_invoicetype
      where(ws_invoicedetail.invoiceid = ws_invoiceheader.invoiceid)
      and(ws_invoicedetail.service_center = ws_invoiceheader.service_center)
      and(ws_invoicedetail.location_id = ws_invoiceheader.location_id)
      and(ws_invoicedetail.invoicetype = ws_invoiceheader.invoicetype)
      and(ws_invoicetype.invoicetypeid = ws_invoiceheader.invoicetype)
      and(ws_invoicetype.service_center = ws_invoiceheader.service_center)
      and(ws_invoiceheader.invoicedate = Invoice.invoicedate)
      and(ws_invoiceheader.service_center = @center)
      and(ws_invoiceheader.location_id = @location)
      and(ws_invoiceheader.status <> 'P')
      and(ws_invoiceheader.invoice_nature = 'O')
      and(isnull(ws_invoiceheader.deleteflag,'N') = 'N')
      and(ws_invoiceheader.joborder_id is null or ws_invoiceheader.joborder_id = '')
      and(ws_invoicetype.chargable = 'Y') and(ws_invoicetype.category <> 5)
      and(ws_invoicedetail.flag = 'I')
      and(ws_invoicedetail.itemtype in( 'S','V' ) )),0) as Cash_SP,
    isnull((select Sum(ws_invoicedetail.price*ws_invoicedetail.qty)
      from ws_invoicedetail
        ,ws_invoiceheader
        ,ws_invoicetype
      where(ws_invoicedetail.invoiceid = ws_invoiceheader.invoiceid)
      and(ws_invoicedetail.service_center = ws_invoiceheader.service_center)
      and(ws_invoicedetail.location_id = ws_invoiceheader.location_id)
      and(ws_invoicedetail.invoicetype = ws_invoiceheader.invoicetype)
      and(ws_invoicetype.invoicetypeid = ws_invoiceheader.invoicetype)
      and(ws_invoicetype.service_center = ws_invoiceheader.service_center)
      and(ws_invoiceheader.invoicedate = Invoice.invoicedate)
      and(ws_invoiceheader.service_center = @center)
      and(ws_invoiceheader.location_id = @location)
      and(ws_invoiceheader.status <> 'P')
      and(ws_invoiceheader.invoice_nature = 'O')
      and(isnull(ws_invoiceheader.deleteflag,'N') = 'N')
      and(ws_invoiceheader.joborder_id is not null or ws_invoiceheader.joborder_id <> '')
      and(ws_invoicetype.chargable = 'Y') and(ws_invoicetype.category <> 5)
      and(ws_invoicedetail.flag = 'I')
      and(isnull(ws_invoicedetail.operationtype,'O') <> 'P')
      and(ws_invoicedetail.itemtype in( 'S','V' ) )),0) as Job_repair_SP,
    isnull((select Sum(ws_invoicedetail.price*ws_invoicedetail.qty)
      from ws_invoicedetail
        ,ws_invoiceheader
        ,ws_invoicetype
      where(ws_invoicedetail.invoiceid = ws_invoiceheader.invoiceid)
      and(ws_invoicedetail.service_center = ws_invoiceheader.service_center)
      and(ws_invoicedetail.location_id = ws_invoiceheader.location_id)
      and(ws_invoicedetail.invoicetype = ws_invoiceheader.invoicetype)
      and(ws_invoicetype.invoicetypeid = ws_invoiceheader.invoicetype)
      and(ws_invoicetype.service_center = ws_invoiceheader.service_center)
      and(ws_invoiceheader.invoicedate = Invoice.invoicedate)
      and(ws_invoiceheader.service_center = @center)
      and(ws_invoiceheader.location_id = @location)
      and(ws_invoiceheader.status <> 'P')
      and(ws_invoiceheader.invoice_nature = 'O')
      and(isnull(ws_invoiceheader.deleteflag,'N') = 'N')
      and(ws_invoiceheader.joborder_id is not null or ws_invoiceheader.joborder_id <> '')
      and(ws_invoicetype.chargable = 'Y') and(ws_invoicetype.category <> 5)
      and(ws_invoicedetail.flag = 'I')
      and(isnull(ws_invoicedetail.operationtype,'O') = 'P')
      and(ws_invoicedetail.itemtype in( 'S','V' ) )),0) as Job_body_SP,
    //Total SP/Oil
    (Cash_Oil+Cash_Oil_nontax+Job_Oil+Job_Oil_nontax+Cash_sp+Job_repair_SP+Job_body_SP) as Total_SP_Oil,
    isnull((select Sum(ws_invoicedetail.price)
      from ws_invoicedetail
        ,ws_invoiceheader
        ,ws_invoicetype
      where(ws_invoicedetail.invoiceid = ws_invoiceheader.invoiceid)
      and(ws_invoicedetail.service_center = ws_invoiceheader.service_center)
      and(ws_invoicedetail.location_id = ws_invoiceheader.location_id)
      and(ws_invoicedetail.invoicetype = ws_invoiceheader.invoicetype)
      and(ws_invoicetype.invoicetypeid = ws_invoiceheader.invoicetype)
      and(ws_invoicetype.service_center = ws_invoiceheader.service_center)
      and(ws_invoiceheader.invoicedate = Invoice.invoicedate)
      and(ws_invoiceheader.service_center = @center)
      and(ws_invoiceheader.location_id = @location)
      and(ws_invoiceheader.status <> 'P')
      and(ws_invoiceheader.invoice_nature = 'O')
      and(isnull(ws_invoiceheader.deleteflag,'N') = 'N')
      and(ws_invoiceheader.joborder_id is not null or ws_invoiceheader.joborder_id <> '')
      and(ws_invoicetype.chargable = 'Y') and(ws_invoicetype.category <> 5)
      and(ws_invoicedetail.flag = 'O')
      and(ws_invoicedetail.operationtype not in( 'B','P' ) )),0) as Repair_OP,
    isnull((select Sum(ws_invoicedetail.price)
      from ws_invoicedetail
        ,ws_invoiceheader
        ,ws_invoicetype
      where(ws_invoicedetail.invoiceid = ws_invoiceheader.invoiceid)
      and(ws_invoicedetail.service_center = ws_invoiceheader.service_center)
      and(ws_invoicedetail.location_id = ws_invoiceheader.location_id)
      and(ws_invoicedetail.invoicetype = ws_invoiceheader.invoicetype)
      and(ws_invoicetype.invoicetypeid = ws_invoiceheader.invoicetype)
      and(ws_invoicetype.service_center = ws_invoiceheader.service_center)
      and(ws_invoiceheader.invoicedate = Invoice.invoicedate)
      and(ws_invoiceheader.service_center = @center)
      and(ws_invoiceheader.location_id = @location)
      and(ws_invoiceheader.status <> 'P')
      and(ws_invoiceheader.invoice_nature = 'O')
      and(isnull(ws_invoiceheader.deleteflag,'N') = 'N')
      and(ws_invoiceheader.joborder_id is not null or ws_invoiceheader.joborder_id <> '')
      and(ws_invoicetype.chargable = 'Y') and(ws_invoicetype.category <> 5)
      and(ws_invoicedetail.flag = 'O')
      and(ws_invoicedetail.operationtype = 'B')),0) as body_OP,
    isnull((select Sum(ws_invoicedetail.price)
      from ws_invoicedetail
        ,ws_invoiceheader
        ,ws_invoicetype
      where(ws_invoicedetail.invoiceid = ws_invoiceheader.invoiceid)
      and(ws_invoicedetail.service_center = ws_invoiceheader.service_center)
      and(ws_invoicedetail.location_id = ws_invoiceheader.location_id)
      and(ws_invoicedetail.invoicetype = ws_invoiceheader.invoicetype)
      and(ws_invoicetype.invoicetypeid = ws_invoiceheader.invoicetype)
      and(ws_invoicetype.service_center = ws_invoiceheader.service_center)
      and(ws_invoiceheader.invoicedate = Invoice.invoicedate)
      and(ws_invoiceheader.service_center = @center)
      and(ws_invoiceheader.location_id = @location)
      and(ws_invoiceheader.status <> 'P')
      and(ws_invoiceheader.invoice_nature = 'O')
      and(isnull(ws_invoiceheader.deleteflag,'N') = 'N')
      and(ws_invoiceheader.joborder_id is not null or ws_invoiceheader.joborder_id <> '')
      and(ws_invoicetype.chargable = 'Y') and(ws_invoicetype.category <> 5)
      and(ws_invoicedetail.flag = 'O')
      and(ws_invoicedetail.operationtype = 'P')),0) as paint_OP,
    //Total repair/Labour
    (repair_op+body_op+paint_op) as Total_OP,
    isnull((select Sum(ws_invoiceheader.labordiscount_amount)
      from ws_invoiceheader
        ,ws_invoicetype
      where(ws_invoicetype.invoicetypeid = ws_invoiceheader.invoicetype)
      and(ws_invoicetype.service_center = ws_invoiceheader.service_center)
      and(ws_invoiceheader.invoicedate = Invoice.invoicedate)
      and(ws_invoiceheader.service_center = @center)
      and(ws_invoiceheader.location_id = @location)
      and(ws_invoiceheader.status <> 'P')
      and(ws_invoiceheader.invoice_nature = 'O')
      and(isnull(ws_invoiceheader.deleteflag,'N') = 'N')
      and(ws_invoicetype.chargable = 'Y')),0) as labor_discount,
    isnull((select Sum(ws_invoiceheader.dicount_amount)
      from ws_invoiceheader
        ,ws_invoicetype
      where(ws_invoicetype.invoicetypeid = ws_invoiceheader.invoicetype)
      and(ws_invoicetype.service_center = ws_invoiceheader.service_center)
      and(ws_invoiceheader.invoicedate = Invoice.invoicedate)
      and(ws_invoiceheader.service_center = @center)
      and(ws_invoiceheader.location_id = @location)
      and(ws_invoiceheader.status <> 'P')
      and(ws_invoiceheader.invoice_nature = 'O')
      and(isnull(ws_invoiceheader.deleteflag,'N') = 'N')
      and(ws_invoicetype.chargable = 'Y')),0) as item_discount,
    //Total discount
    (labor_discount+item_discount) as Total_Discount,
    isnull((select Sum((ws_invoicedetail.price*ISNull(ws_invoicedetail.qty,1))*(ws_invoiceheader.stax_value/100))
      from ws_invoicedetail
        ,ws_invoiceheader
        ,ws_invoicetype
      where(ws_invoicedetail.invoiceid = ws_invoiceheader.invoiceid)
      and(ws_invoicedetail.service_center = ws_invoiceheader.service_center)
      and(ws_invoicedetail.location_id = ws_invoiceheader.location_id)
      and(ws_invoicedetail.invoicetype = ws_invoiceheader.invoicetype)
      and(ws_invoicetype.invoicetypeid = ws_invoiceheader.invoicetype)
      and(ws_invoicetype.service_center = ws_invoiceheader.service_center)
      and(ws_invoiceheader.invoicedate = Invoice.invoicedate)
      and(ws_invoiceheader.service_center = @center)
      and(ws_invoiceheader.location_id = @location)
      and(ws_invoiceheader.status <> 'P')
      and(ws_invoiceheader.invoice_nature = 'O')
      and(isnull(ws_invoiceheader.deleteflag,'N') = 'N')
      and(ws_invoiceheader.non_taxable <> 'Y')
      and(ws_invoicetype.chargable = 'Y')
      and(ws_invoicedetail.non_taxable <> 'Y')),0) as Sales_tax,
    isnull((select Sum((ws_invoicedetail.price*ISNull(ws_invoicedetail.qty,1))*.001)
      from ws_invoicedetail
        ,ws_invoiceheader
        ,ws_invoicetype
      where(ws_invoicedetail.invoiceid = ws_invoiceheader.invoiceid)
      and(ws_invoicedetail.service_center = ws_invoiceheader.service_center)
      and(ws_invoicedetail.location_id = ws_invoiceheader.location_id)
      and(ws_invoicedetail.invoicetype = ws_invoiceheader.invoicetype)
      and(ws_invoicetype.invoicetypeid = ws_invoiceheader.invoicetype)
      and(ws_invoicetype.service_center = ws_invoiceheader.service_center)
      and(ws_invoiceheader.invoicedate = Invoice.invoicedate)
      and(ws_invoiceheader.service_center = @center)
      and(ws_invoiceheader.location_id = @location)
      and(ws_invoiceheader.status <> 'P')
      and(ws_invoiceheader.invoice_nature = 'O')
      and(isnull(ws_invoiceheader.deleteflag,'N') = 'N')
      and(ws_invoiceheader.addedtax = 'Y')
      and(ws_invoicetype.chargable = 'Y')
      and(ws_invoicedetail.non_addedtax <> 'Y')),0) as added_tax,
    isnull((select Sum((ws_invoicedetail.price*ISNull(ws_invoicedetail.qty,1))*.005)
      from ws_invoicedetail
        ,ws_invoiceheader
        ,ws_invoicetype
      where(ws_invoicedetail.invoiceid = ws_invoiceheader.invoiceid)
      and(ws_invoicedetail.service_center = ws_invoiceheader.service_center)
      and(ws_invoicedetail.location_id = ws_invoiceheader.location_id)
      and(ws_invoicedetail.invoicetype = ws_invoiceheader.invoicetype)
      and(ws_invoicetype.invoicetypeid = ws_invoiceheader.invoicetype)
      and(ws_invoicetype.service_center = ws_invoiceheader.service_center)
      and(ws_invoiceheader.invoicedate = Invoice.invoicedate)
      and(ws_invoiceheader.service_center = @center)
      and(ws_invoiceheader.location_id = @location)
      and(ws_invoiceheader.status <> 'P')
      and(ws_invoiceheader.invoice_nature = 'O')
      and(isnull(ws_invoiceheader.deleteflag,'N') = 'N')
      and(ws_invoiceheader.salestax = 'Y')
      and(ws_invoicetype.chargable = 'Y')
      and(ws_invoicedetail.non_addedtax <> 'Y')),0) as trad_tax,
    (sales_tax+added_tax+trad_tax) as Total_Tax,
    isnull((select Sum(ws_invoicedetail.price)
      from ws_invoicedetail
        ,ws_invoiceheader
        ,ws_invoicetype
      where(ws_invoicedetail.invoiceid = ws_invoiceheader.invoiceid)
      and(ws_invoicedetail.service_center = ws_invoiceheader.service_center)
      and(ws_invoicedetail.location_id = ws_invoiceheader.location_id)
      and(ws_invoicedetail.invoicetype = ws_invoiceheader.invoicetype)
      and(ws_invoicetype.invoicetypeid = ws_invoiceheader.invoicetype)
      and(ws_invoicetype.service_center = ws_invoiceheader.service_center)
      and(ws_invoiceheader.invoicedate = Invoice.invoicedate)
      and(ws_invoiceheader.service_center = @center)
      and(ws_invoiceheader.location_id = @location)
      and(ws_invoiceheader.invoice_nature = 'O')
      and(isnull(ws_invoiceheader.deleteflag,'N') = 'N')
      and(ws_invoicetype.category = 5)
      and(ws_invoicedetail.flag = 'O')),0) as warrenty_OP,
    isnull((select Sum(ws_invoicedetail.price*ws_invoicedetail.qty)
      from ws_invoicedetail
        ,ws_invoiceheader
        ,ws_invoicetype
      where(ws_invoicedetail.invoiceid = ws_invoiceheader.invoiceid)
      and(ws_invoicedetail.service_center = ws_invoiceheader.service_center)
      and(ws_invoicedetail.location_id = ws_invoiceheader.location_id)
      and(ws_invoicedetail.invoicetype = ws_invoiceheader.invoicetype)
      and(ws_invoicetype.invoicetypeid = ws_invoiceheader.invoicetype)
      and(ws_invoicetype.service_center = ws_invoiceheader.service_center)
      and(ws_invoiceheader.invoicedate = Invoice.invoicedate)
      and(ws_invoiceheader.service_center = @center)
      and(ws_invoiceheader.location_id = @location)
      and(ws_invoiceheader.invoice_nature = 'O')
      and(isnull(ws_invoiceheader.deleteflag,'N') = 'N')
      and(ws_invoicetype.category = 5)
      and(ws_invoicedetail.flag = 'I')
      and(ws_invoicedetail.itemtype = 'S')),0) as warrenty_SP,
    isnull((select Sum(ws_invoicedetail.price*ws_invoicedetail.qty)
      from ws_invoicedetail
        ,ws_invoiceheader
        ,ws_invoicetype
      where(ws_invoicedetail.invoiceid = ws_invoiceheader.invoiceid)
      and(ws_invoicedetail.service_center = ws_invoiceheader.service_center)
      and(ws_invoicedetail.location_id = ws_invoiceheader.location_id)
      and(ws_invoicedetail.invoicetype = ws_invoiceheader.invoicetype)
      and(ws_invoicetype.invoicetypeid = ws_invoiceheader.invoicetype)
      and(ws_invoicetype.service_center = ws_invoiceheader.service_center)
      and(ws_invoiceheader.invoicedate = Invoice.invoicedate)
      and(ws_invoiceheader.service_center = @center)
      and(ws_invoiceheader.location_id = @location)
      and(ws_invoiceheader.invoice_nature = 'O')
      and(isnull(ws_invoiceheader.deleteflag,'N') = 'N')
      and(ws_invoicetype.category = 5)
      and(ws_invoicedetail.flag = 'I')
      and(ws_invoicedetail.itemtype = 'O')),0) as warrenty_Oil
    from ws_invoiceheader as Invoice
    where(Invoice.invoicedate between @FDate and @TDate)
    and(Invoice.service_center = @center)
    and(Invoice.location_id = @location)
    group by invoicedate
end
