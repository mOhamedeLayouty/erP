-- VIEW: DBA.v_incom_ana
-- generated_at: 2025-12-29T14:36:30.555Z
-- object_id: 14993
-- table_id: 1438
-- source_via: SYS.SYSVIEW(view_object_id=object_id)

create view DBA.v_incom_ana( inv_year,inv_month,value,inv_type,inv_id,service_center,location_id ) as
  //V1.0
  //V1.1 add consumable
  //V1.2 split SP to overcounter and on Job
  //V1.3 handling ahmed fox error of adding rate 
  //V1.4 subtract oil discount
  //only get original invoice
  //V1.5 sub return invoice
  //v1.6 edit sub return invoice in "ws" case by adding missing brackets      
  select distinct datepart(year,ws_invoiceheader.invoicedate) as inv_year,
    datepart(month,ws_invoiceheader.invoicedate) as inv_month,
    (case ws_invoiceheader.invoice_nature when 'R' then
      (sum(isnull(ws_invoiceheader.laborprice*curr.rate,0))
      -sum(((isnull(ws_invoiceheader.laborprice*curr.rate,0))*(isnull(ws_invoiceheader.labordiscount*curr.rate,0)))/100))*-1
    else
      (sum(isnull(ws_invoiceheader.laborprice*curr.rate,0))
      -sum(((isnull(ws_invoiceheader.laborprice*curr.rate,0))*(isnull(ws_invoiceheader.labordiscount*curr.rate,0)))/100))
    end) as Labor,
    1 as inv_type,
    ws_invoicetype.InvoiceTypeID as inv_id,
    ws_invoiceheader.service_center,
    ws_invoiceheader.location_id
    from DBA.ws_invoiceheader,DBA.ws_invoicetype,ledger.cur as curr
    where(curr.curr_id = isnull(ws_invoiceheader.currency_id,DBA.f_get_about('LocalCurrency'))) and(curr.company_code = DBA.f_get_about('gl_company_code'))
    and(ws_invoiceheader.invoicetype = ws_invoicetype.invoicetypeid)
    and(ws_invoiceheader.service_center = ws_invoicetype.service_center)
    and(ws_invoiceheader.status <> 'P')
    and(isnull(ws_invoiceheader.deleteflag,'N') = 'N')
    group by inv_year,inv_month,ws_invoiceheader.invoice_nature,ws_invoiceheader.service_center,inv_id,ws_invoiceheader.location_id union
  ----------------------------------------------------------------------------------------------------------
  select distinct datepart(year,ws_invoiceheader.invoicedate) as inv_year,
    datepart(month,ws_invoiceheader.invoicedate) as inv_month,
    (case ws_invoiceheader.invoice_nature when 'R' then
      (sum(isnull(ws_invoiceheader.oilprice*curr.rate,0))
      -sum(((isnull(ws_invoiceheader.oilprice*curr.rate,0))*(isnull(ws_invoiceheader.OilDiscount*curr.rate,0)))/100))*-1
    else
      (sum(isnull(ws_invoiceheader.oilprice*curr.rate,0))
      -sum(((isnull(ws_invoiceheader.oilprice*curr.rate,0))*(isnull(ws_invoiceheader.OilDiscount*curr.rate,0)))/100))
    end) as Oil,
    2 as inv_type,
    ws_invoicetype.InvoiceTypeID as inv_id,
    ws_invoiceheader.service_center,
    ws_invoiceheader.location_id
    from DBA.ws_invoiceheader,DBA.ws_invoicetype,ledger.cur as curr
    where(curr.curr_id = isnull(ws_invoiceheader.currency_id,DBA.f_get_about('LocalCurrency'))) and(curr.company_code = DBA.f_get_about('gl_company_code'))
    and(ws_invoiceheader.invoicetype = ws_invoicetype.invoicetypeid)
    and(ws_invoiceheader.service_center = ws_invoicetype.service_center)
    and(ws_invoiceheader.status <> 'P')
    and(isnull(ws_invoiceheader.deleteflag,'N') = 'N')
    group by inv_year,inv_month,ws_invoiceheader.invoice_nature,ws_invoiceheader.service_center,inv_id,ws_invoiceheader.location_id union
  --------------------------------------------------------------------------------------------------  
  select distinct datepart(year,ws_invoiceheader.invoicedate) as inv_year,
    datepart(month,ws_invoiceheader.invoicedate) as inv_month,
    (case ws_invoiceheader.invoice_nature when 'R' then
      sum(isnull(ws_invoiceheader.outserviceprice*curr.rate,0))*-1
    else
      sum(isnull(ws_invoiceheader.outserviceprice*curr.rate,0))
    end) as OutService,
    3 as inv_type,
    ws_invoicetype.InvoiceTypeID as inv_id,
    ws_invoiceheader.service_center,
    ws_invoiceheader.location_id
    from DBA.ws_invoiceheader,DBA.ws_invoicetype,ledger.cur as curr
    where(curr.curr_id = isnull(ws_invoiceheader.currency_id,DBA.f_get_about('LocalCurrency'))) and(curr.company_code = DBA.f_get_about('gl_company_code'))
    and(ws_invoiceheader.invoicetype = ws_invoicetype.invoicetypeid)
    and(ws_invoiceheader.service_center = ws_invoicetype.service_center)
    and(ws_invoiceheader.status <> 'P')
    and(isnull(ws_invoiceheader.deleteflag,'N') = 'N')
    group by inv_year,inv_month,ws_invoiceheader.invoice_nature,ws_invoiceheader.service_center,inv_id,ws_invoiceheader.location_id union
  --------------------------------------------------------------------------------------------------
  select distinct datepart(year,ws_invoiceheader.invoicedate) as inv_year,
    datepart(month,ws_invoiceheader.invoicedate) as inv_month,
    (case ws_invoiceheader.invoice_nature when 'R' then
      (sum(isnull(ws_invoiceheader.itemprice*curr.rate,0))-sum(((isnull(ws_invoiceheader.itemprice*curr.rate,0))*(isnull(ws_invoiceheader.itemdiscount*curr.rate,0)))/100))*-1
    else
      (sum(isnull(ws_invoiceheader.itemprice*curr.rate,0))-sum(((isnull(ws_invoiceheader.itemprice*curr.rate,0))*(isnull(ws_invoiceheader.itemdiscount*curr.rate,0)))/100))
    end) as SparePart,
    4 as inv_type,
    ws_invoicetype.InvoiceTypeID as inv_id,
    ws_invoiceheader.service_center,
    ws_invoiceheader.location_id
    from DBA.ws_invoiceheader,DBA.ws_invoicetype,ledger.cur as curr
    where(curr.curr_id = isnull(ws_invoiceheader.currency_id,DBA.f_get_about('LocalCurrency'))) and(curr.company_code = DBA.f_get_about('gl_company_code'))
    and(ws_invoiceheader.invoicetype = ws_invoicetype.invoicetypeid)
    and(ws_invoiceheader.service_center = ws_invoicetype.service_center)
    and(ws_invoiceheader.status <> 'P') and(ws_invoiceheader.joborder_id is null or ws_invoiceheader.joborder_id = '')
    and(isnull(ws_invoiceheader.deleteflag,'N') = 'N')
    group by inv_year,inv_month,ws_invoiceheader.invoice_nature,ws_invoiceheader.service_center,inv_id,ws_invoiceheader.location_id union
  --------------------------------------------------------------------------------------------------
  select distinct datepart(year,ws_invoiceheader.invoicedate) as inv_year,
    datepart(month,ws_invoiceheader.invoicedate) as inv_month,
    (case ws_invoiceheader.invoice_nature when 'R' then
      (sum(isnull(ws_invoiceheader.itemprice*curr.rate,0))-sum(((isnull(ws_invoiceheader.itemprice*curr.rate,0))*(isnull(ws_invoiceheader.itemdiscount*curr.rate,0)))/100))*-1
    else
      (sum(isnull(ws_invoiceheader.itemprice*curr.rate,0))-sum(((isnull(ws_invoiceheader.itemprice*curr.rate,0))*(isnull(ws_invoiceheader.itemdiscount*curr.rate,0)))/100))
    end) as SparePart,
    5 as inv_type,
    ws_invoicetype.InvoiceTypeID as inv_id,
    ws_invoiceheader.service_center,
    ws_invoiceheader.location_id
    from DBA.ws_invoiceheader,DBA.ws_invoicetype,ledger.cur as curr
    where(curr.curr_id = isnull(ws_invoiceheader.currency_id,DBA.f_get_about('LocalCurrency'))) and(curr.company_code = DBA.f_get_about('gl_company_code'))
    and(ws_invoiceheader.invoicetype = ws_invoicetype.invoicetypeid)
    and(ws_invoiceheader.service_center = ws_invoicetype.service_center)
    and(ws_invoiceheader.status <> 'P') and(ws_invoiceheader.joborder_id is not null and ws_invoiceheader.joborder_id <> '')
    and(isnull(ws_invoiceheader.deleteflag,'N') = 'N')
    group by inv_year,inv_month,ws_invoiceheader.invoice_nature,ws_invoiceheader.service_center,inv_id,ws_invoiceheader.location_id union
  --------------------------------------------------------------------------------------------------
  select distinct datepart(year,ws_invoiceheader.invoicedate) as inv_year,
    datepart(month,ws_invoiceheader.invoicedate) as inv_month,
    (case ws_invoiceheader.invoice_nature when 'R' then
      sum(isnull(ws_invoiceheader.consumable*curr.rate,0))*-1
    else
      sum(isnull(ws_invoiceheader.consumable*curr.rate,0))
    end) as consumable,
    6 as inv_type,
    ws_invoicetype.InvoiceTypeID as inv_id,
    ws_invoiceheader.service_center,
    ws_invoiceheader.location_id
    from DBA.ws_invoiceheader,DBA.ws_invoicetype,ledger.cur as curr
    where(curr.curr_id = isnull(ws_invoiceheader.currency_id,DBA.f_get_about('LocalCurrency'))) and(curr.company_code = DBA.f_get_about('gl_company_code'))
    and(ws_invoiceheader.invoicetype = ws_invoicetype.invoicetypeid)
    and(ws_invoiceheader.service_center = ws_invoicetype.service_center)
    and(ws_invoiceheader.status <> 'P')
    and(isnull(ws_invoiceheader.deleteflag,'N') = 'N')
    group by inv_year,inv_month,ws_invoiceheader.invoice_nature,ws_invoiceheader.service_center,inv_id,ws_invoiceheader.location_id
