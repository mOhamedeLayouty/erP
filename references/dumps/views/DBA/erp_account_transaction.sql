-- VIEW: DBA.erp_account_transaction
-- generated_at: 2025-12-29T14:36:30.535Z
-- object_id: 36058
-- table_id: 1484
-- source_via: SYS.SYSVIEW(view_object_id=object_id)

create view DBA.erp_account_transaction as
  select convert(date,ws_invoiceheader.invoicedate) as rec_date,
    isnull(ws_invoiceheader.invoiceno,ws_invoiceheader.InvoiceID) as rec_no,
    (case when ws_invoiceheader.invoiceno is null and ws_InvoiceHeader.invoiceable = 'N' then 'VOC' else 'INV' end) as rec_type,
    (select ws_InvoiceType.category from DBA.ws_InvoiceType where ws_InvoiceType.InvoiceTypeID = ws_invoiceheader.InvoiceType and ws_InvoiceType.service_center = ws_invoiceheader.service_center) as inv_cat,
    (ws_invoiceheader.itemprice+ws_invoiceheader.laborprice+ws_invoiceheader.OilPrice+ws_invoiceheader.consumable+ws_invoiceheader.OutServicePrice)
    -(ws_invoiceheader.dicount_amount+ws_invoiceheader.LaborDiscount_amount+ws_invoiceheader.OilDiscount_amount)+(case ws_InvoiceHeader.non_taxable when 'Y' then 0 else((((ws_invoiceheader.itemprice-ws_InvoiceHeader.dicount_amount)*ws_invoiceheader.stax_value)/100)+(((ws_invoiceheader.laborprice-ws_InvoiceHeader.LaborDiscount_amount)*ws_invoiceheader.stax_value)/100)+ws_invoiceheader.oilprice_tax+(((ws_invoiceheader.outserviceprice)*ws_invoiceheader.stax_value)/100)+(DBA.ws_InvoiceHeader.consumable*DBA.ws_InvoiceHeader.stax_value)/100) end)-(case ws_InvoiceHeader.salestax when 'N' then 0 else((ws_InvoiceHeader.laborprice-((ws_invoiceheader.labordiscount*ws_invoiceheader.laborprice)/100))*DBA.ws_InvoiceHeader.lbr_ptax_percent)/100 end)-(case ws_InvoiceHeader.salestax when 'N' then 0 else((ws_InvoiceHeader.itemprice-((ws_invoiceheader.itemdiscount*(ws_invoiceheader.itemprice-ws_invoiceheader.total_nondisc))/100))*DBA.ws_InvoiceHeader.sp_ptax_percent)/100 end)-(case ws_InvoiceHeader.salestax when 'N' then 0 else((ws_InvoiceHeader.oilprice-ws_invoiceheader.oildiscount_amount)*DBA.ws_InvoiceHeader.sp_ptax_percent)/100 end)-(case ws_InvoiceHeader.salestax when 'N' then 0 else((DBA.ws_InvoiceHeader.consumable)*DBA.ws_InvoiceHeader.lbr_ptax_percent)/100 end)-(case ws_InvoiceHeader.salestax when 'N' then 0 else((DBA.ws_InvoiceHeader.outserviceprice)*DBA.ws_InvoiceHeader.lbr_ptax_percent)/100 end) as amount,
    ws_invoiceheader.customerid as cust_code,
    customer.customer_name_a as cust_name,
    customer.customer_name_e as cust_name_e,
    ws_invoiceheader.joborder_id as job_id,
    ws_reception.starttime as job_date,
    ws_reception.jo_id as job_request,
    ws_invoiceheader.debit_header as debite_id,
    sc_debit_header.debit_date as debite_date,
    ws_invoiceheader.service_center as service_center,
    ws_invoiceheader.location_id as location_id,
    'Cash Invoice/������ ����' as pay_type,
    '' as notes
    from DBA.ws_invoiceheader left outer join DBA.ws_reception on ws_invoiceheader.joborder_id = ws_reception.receptionid
      and ws_invoiceheader.service_center = ws_reception.service_center and ws_invoiceheader.location_id = ws_reception.location_id
      left outer join DBA.sc_debit_header on ws_invoiceheader.debit_header = sc_debit_header.debit_header
      and ws_invoiceheader.service_center = sc_debit_header.service_center and ws_invoiceheader.location_id = sc_debit_header.location_id
      left outer join DBA.ws_receipt on(ws_invoiceheader.InvoiceID = ws_receipt.InvoiceID) and(ws_invoiceheader.service_center = ws_receipt.service_center)
      and(ws_invoiceheader.location_id = ws_receipt.location_id) and(ws_invoiceheader.InvoiceType = ws_receipt.InvoiceType)
      and(ws_receipt.Delete_Flag <> 'Y')
      ,DBA.customer
    where(ws_invoiceheader.chargable = 'Y')
    and(ws_invoiceheader.customerid = customer.customer_id)
    and(ws_invoiceheader.invoice_nature <> 'R')
    and(ws_invoiceheader.status <> 'P')
    and(ws_invoiceheader.DeleteFlag <> 'Y') union
  select convert(date,ws_invoiceheader.invoicedate) as rec_date,
    ws_invoiceheader.invoiceno as rec_no,
    'RIN' as rec_type,
    ws_InvoiceType.category as inv_cat,
    (ws_invoiceheader.itemprice+ws_invoiceheader.laborprice+ws_invoiceheader.OilPrice+ws_invoiceheader.consumable+ws_invoiceheader.OutServicePrice)
    -(ws_invoiceheader.dicount_amount+ws_invoiceheader.LaborDiscount_amount+ws_invoiceheader.OilDiscount_amount)+(case ws_InvoiceHeader.non_taxable when 'Y' then 0 else((((ws_invoiceheader.itemprice-ws_InvoiceHeader.dicount_amount)*ws_invoiceheader.stax_value)/100)+(((ws_invoiceheader.laborprice-ws_InvoiceHeader.LaborDiscount_amount)*ws_invoiceheader.stax_value)/100)+ws_invoiceheader.oilprice_tax+(((ws_invoiceheader.outserviceprice)*ws_invoiceheader.stax_value)/100)+ws_invoiceheader.consumable_tax) end)-(case ws_InvoiceHeader.salestax when 'N' then 0 else((ws_InvoiceHeader.laborprice-((ws_invoiceheader.labordiscount*ws_invoiceheader.laborprice)/100))*DBA.ws_InvoiceHeader.lbr_ptax_percent)/100 end)-(case ws_InvoiceHeader.salestax when 'N' then 0 else((ws_InvoiceHeader.itemprice-((ws_invoiceheader.itemdiscount*(ws_invoiceheader.itemprice-ws_invoiceheader.total_nondisc))/100))*DBA.ws_InvoiceHeader.sp_ptax_percent)/100 end)-(case ws_InvoiceHeader.salestax when 'N' then 0 else((ws_InvoiceHeader.oilprice-ws_invoiceheader.oildiscount_amount)*DBA.ws_InvoiceHeader.sp_ptax_percent)/100 end)-(case ws_InvoiceHeader.salestax when 'N' then 0 else((DBA.ws_InvoiceHeader.consumable)*DBA.ws_InvoiceHeader.lbr_ptax_percent)/100 end)-(case ws_InvoiceHeader.salestax when 'N' then 0 else((DBA.ws_InvoiceHeader.outserviceprice)*DBA.ws_InvoiceHeader.lbr_ptax_percent)/100 end) as amount,
    ws_invoiceheader.customerid as cust_code,
    customer.customer_name_a as cust_name,
    customer.customer_name_e as cust_name_e,
    ws_invoiceheader.joborder_id as job_id,
    ws_reception.starttime as job_date,
    ws_reception.jo_id as job_request,
    ws_invoiceheader.debit_header as debite_id,
    (select sc_debit_header.debit_date from DBA.sc_debit_header,DBA.sc_ret_header
      where(sc_debit_header.debit_header = sc_ret_header.debit_header)
      and(sc_debit_header.service_center = sc_ret_header.service_center)
      and(sc_debit_header.location_id = sc_ret_header.debit_location)
      and(sc_ret_header.credit_header = ws_invoiceheader.credit_header)
      and(sc_ret_header.service_center = ws_invoiceheader.service_center)
      and(sc_ret_header.location_id = ws_invoiceheader.location_id)) as debite_date,
    ws_invoiceheader.service_center as service_center,
    ws_invoiceheader.location_id as location_id,
    'Returned Invoice/������������' as pay_type,
    '' as notes
    from DBA.ws_invoiceheader left outer join DBA.ws_reception on ws_invoiceheader.joborder_id = ws_reception.receptionid
      and ws_invoiceheader.service_center = ws_reception.service_center and ws_invoiceheader.location_id = ws_reception.location_id
      ,DBA.customer,DBA.ws_InvoiceType
    where(ws_invoiceheader.customerid = customer.customer_id)
    and(ws_invoiceheader.invoice_nature = 'R')
    and(ws_invoiceheader.DeleteFlag <> 'Y')
    and(ws_invoiceheader.status <> 'P')
    and ws_InvoiceHeader.service_center = ws_InvoiceType.service_center
    and ws_InvoiceHeader.InvoiceType = ws_InvoiceType.InvoiceTypeID union
  select convert(date,ws_receiptdetail.paymentdate) as rec_date,
    ws_receiptdetail.receiptno as rec_no,
    'REC' as rec_type,
    (select ws_InvoiceType.category from DBA.ws_InvoiceType where ws_InvoiceType.InvoiceTypeID = ws_receipt.InvoiceType and ws_InvoiceType.service_center = ws_receipt.service_center) as inv_cat,
    ws_receiptdetail.paymentamount as amount,
    ws_receipt.custid as cust_code,
    customer.customer_name_a as cust_name,
    customer.customer_name_e as cust_name_e,
    ws_reception.receptionid as job_id,
    ws_reception.starttime as job_date,
    ws_reception.jo_id as job_request,
    sc_debit_header.debit_header as debite_id,
    sc_debit_header.debit_date as debite_date,
    ws_invoiceheader.service_center as service_center,
    ws_invoiceheader.location_id as location_id,
    (case ws_receiptdetail.paymenttype when 'C' then 'Check/��� :'+ws_receiptdetail.checkno
    when 'V' then 'Visa/���� :'+ws_receiptdetail.CardNumber
    when 'M' then 'MasterCard/����� ���� :'+ws_receiptdetail.CardNumber
    when 'A' then 'AmericanCard/������� ���� :'+ws_receiptdetail.CardNumber
    when 'O' then 'Cash/����'
    else ws_receiptdetail.paymenttype
    end) as pay_type,
    '' as notes
    from DBA.ws_invoiceheader left outer join DBA.ws_reception on ws_invoiceheader.joborder_id = ws_reception.receptionid
      and ws_invoiceheader.service_center = ws_reception.service_center and ws_invoiceheader.location_id = ws_reception.location_id
      left outer join DBA.sc_debit_header on ws_invoiceheader.debit_header = sc_debit_header.debit_header
      and ws_invoiceheader.service_center = sc_debit_header.service_center and ws_invoiceheader.location_id = sc_debit_header.location_id
      ,DBA.customer
      ,DBA.ws_receipt
      ,DBA.ws_receiptdetail
    where(ws_receipt.receipt_id = ws_receiptdetail.receipt_id)
    and(ws_receipt.service_center = ws_receiptdetail.service_center)
    and(ws_receipt.location_id = ws_receiptdetail.main_location_id)
    and(ws_invoiceheader.service_center = ws_receipt.service_center)
    and(ws_invoiceheader.location_id = ws_receipt.location_id)
    and(ws_invoiceheader.InvoiceID = ws_receipt.InvoiceID)
    and(ws_invoiceheader.InvoiceType = ws_receipt.InvoiceType) and(ws_invoiceheader.chargable = 'Y')
    and(ws_receipt.custid = customer.customer_id)
    and(ws_invoiceheader.invoice_nature <> 'R') union
  select convert(date,ws_receiptdetail.paymentdate) as rec_date,
    ws_receiptdetail.receiptno as rec_no,
    'AP' as rec_type,
    (select ws_InvoiceType.category from DBA.ws_InvoiceType where ws_InvoiceType.InvoiceTypeID = ws_receipt.InvoiceType and ws_InvoiceType.service_center = ws_receipt.service_center) as inv_cat,
    ws_receiptdetail.paymentamount as amount,
    ws_receipt.custid as cust_code,
    customer.customer_name_a as cust_name,
    customer.customer_name_e as cust_name_e,
    ws_receipt.joborder_id as job_id,
    null as job_date,
    null as job_request,
    null as debite_id,
    null as debite_date,
    ws_receipt.service_center as service_center,
    ws_receipt.location_id as location_id,
    (case ws_receiptdetail.paymenttype when 'C' then 'Check/��� :'+ws_receiptdetail.checkno
    when 'V' then 'Visa/���� :'+ws_receiptdetail.CardNumber
    when 'M' then 'MasterCard/����� ���� :'+ws_receiptdetail.CardNumber
    when 'A' then 'AmericanCard/������� ���� :'+ws_receiptdetail.CardNumber
    when 'O' then 'Cash/����'
    else ws_receiptdetail.paymenttype
    end) as pay_type,
    '' as notes
    from DBA.ws_receipt
      ,DBA.ws_receiptdetail
      ,DBA.customer
    where(ws_receiptdetail.receipt_id = ws_receipt.receipt_id)
    and(ws_receiptdetail.service_center = ws_receipt.service_center)
    and(ws_receipt.location_id = ws_receiptdetail.main_location_id)
    and(ws_receipt.custid = customer.customer_id)
    and(ws_receipt.invoiceno is null and ws_receipt.InvoiceID is null) union
  select convert(date,doc_son_rec.doc_date) as rec_date,
    doc_son_rec.doc_t_num as rec_no,
    'AD' as rec_type,
    (select ws_InvoiceType.category from DBA.ws_InvoiceType where ws_InvoiceType.InvoiceTypeID = ws_invoiceheader.InvoiceType and ws_InvoiceType.service_center = ws_invoiceheader.service_center) as inv_cat,
    doc_son_rec.doc_tot as amount,
    ws_invoiceheader.customerid as cust_code,
    customer.customer_name_a as cust_name,
    customer.customer_name_e as cust_name_e,
    ws_invoiceheader.joborder_id as job_id,
    ws_reception.starttime as job_date,
    ws_reception.jo_id as job_request,
    ws_invoiceheader.debit_header as debite_id,
    sc_debit_header.debit_date as debite_date,
    ws_invoiceheader.service_center as service_center,
    ws_invoiceheader.location_id as location_id,
    (case doc_son_rec.customer_flag when 'C' then 'Check/��� :'+doc_son_rec.chqu_name
    when 'V' then 'Visa/���� :'
    when 'M' then 'MasterCard/����� ���� :'
    when 'A' then 'AmericanCard/������� ���� :'
    when 'O' then 'Cash/����'
    when 'S' then 'Settlement/�����'
    else doc_son_rec.customer_flag
    end) as pay_type,
    doc_son_rec.doc_rem as notes
    from DBA.ws_invoiceheader left outer join DBA.ws_reception on ws_invoiceheader.joborder_id = ws_reception.receptionid
      and ws_invoiceheader.service_center = ws_reception.service_center and ws_invoiceheader.location_id = ws_reception.location_id
      left outer join DBA.sc_debit_header on ws_invoiceheader.debit_header = sc_debit_header.debit_header
      and ws_invoiceheader.service_center = sc_debit_header.service_center and ws_invoiceheader.location_id = sc_debit_header.location_id
      ,DBA.doc_son_rec
      ,DBA.customer
    where(ws_invoiceheader.InvoiceID = doc_son_rec.InvoiceID)
    and(ws_invoiceheader.service_center = doc_son_rec.service_center)
    and(ws_invoiceheader.location_id = doc_son_rec.main_location_id)
    and(ws_invoiceheader.InvoiceType = doc_son_rec.InvoiceType) and(ws_invoiceheader.chargable = 'Y')
    and(ws_invoiceheader.customerid = customer.customer_id)
    and(doc_son_rec.doc_type = 2) and(doc_son_rec.doc_detail_type = 2)
    and(ws_invoiceheader.invoice_nature = isnull(doc_son_rec.invoice_nature,'O')) union
  select convert(date,doc_son_rec.doc_date) as rec_date,
    doc_son_rec.doc_t_num as rec_no,
    'AW' as rec_type,
    (select ws_InvoiceType.category from DBA.ws_InvoiceType where ws_InvoiceType.InvoiceTypeID = ws_invoiceheader.InvoiceType and ws_InvoiceType.service_center = ws_invoiceheader.service_center) as inv_cat,
    doc_son_rec.doc_tot as amount,
    ws_invoiceheader.customerid as cust_code,
    customer.customer_name_a as cust_name,
    customer.customer_name_e as cust_name_e,
    ws_invoiceheader.joborder_id as job_id,
    ws_reception.starttime as job_date,
    ws_reception.jo_id as job_request,
    ws_invoiceheader.debit_header as debite_id,
    sc_debit_header.debit_date as debite_date,
    ws_invoiceheader.service_center as service_center,
    ws_invoiceheader.location_id as location_id,
    (case doc_son_rec.customer_flag when 'C' then 'Check/��� :'+doc_son_rec.chqu_name
    when 'V' then 'Visa/���� :'
    when 'M' then 'MasterCard/����� ���� :'
    when 'A' then 'AmericanCard/������� ���� :'
    when 'O' then 'Cash/����'
    when 'S' then 'Settlement/�����'
    else doc_son_rec.customer_flag
    end) as pay_type,
    doc_son_rec.doc_rem as notes
    from DBA.ws_invoiceheader left outer join DBA.ws_reception on ws_invoiceheader.joborder_id = ws_reception.receptionid
      and ws_invoiceheader.service_center = ws_reception.service_center and ws_invoiceheader.location_id = ws_reception.location_id
      left outer join DBA.sc_debit_header on ws_invoiceheader.debit_header = sc_debit_header.debit_header
      and ws_invoiceheader.service_center = sc_debit_header.service_center and ws_invoiceheader.location_id = sc_debit_header.location_id
      ,DBA.doc_son_rec
      ,DBA.customer
    where(ws_invoiceheader.InvoiceID = doc_son_rec.InvoiceID)
    and(ws_invoiceheader.service_center = doc_son_rec.service_center)
    and(ws_invoiceheader.location_id = doc_son_rec.main_location_id)
    and(ws_invoiceheader.InvoiceType = doc_son_rec.InvoiceType) and(ws_invoiceheader.chargable = 'Y')
    and(ws_invoiceheader.customerid = customer.customer_id)
    and(doc_son_rec.doc_type = 1) and(doc_son_rec.doc_detail_type = 2) and isnull(doc_son_rec.dp_type,'I') = 'I'
    and(ws_invoiceheader.invoice_nature = isnull(doc_son_rec.invoice_nature,'O')) union
  select convert(date,doc_son_rec.doc_date) as rec_date,
    doc_son_rec.doc_t_num as rec_no,
    'OB' as rec_type,
    1 as inv_cat,
    doc_son_rec.doc_tot as amount,
    doc_son_rec.customer_id as cust_code,
    customer.customer_name_a as cust_name,
    customer.customer_name_e as cust_name_e,
    null as job_id,
    null as job_date,
    null as job_request,
    null as debite_id,
    null as debite_date,
    doc_son_rec.service_center as service_center,
    doc_son_rec.location_id as location_id,
    (case doc_son_rec.customer_flag when 'C' then 'Check/��� :'+doc_son_rec.chqu_name
    when 'V' then 'Visa/���� :'
    when 'M' then 'MasterCard/����� ���� :'
    when 'A' then 'AmericanCard/������� ���� :'
    when 'O' then 'Cash/����'
    when 'S' then 'Settlement/�����'
    else doc_son_rec.customer_flag
    end) as pay_type,
    doc_son_rec.doc_rem as notes
    from DBA.doc_son_rec
      ,DBA.customer
    where(doc_son_rec.customer_id = customer.customer_id)
    and(doc_son_rec.doc_detail_type = 5) union
  select convert(date,doc_son_rec.doc_date) as rec_date,
    doc_son_rec.doc_t_num as rec_no,
    (case doc_son_rec.doc_type when 1 then 'AW' else(case doc_son_rec.dp_type when 'P' then 'AP' else 'mAD' end) end) as rec_type,
    1 as inv_cat,
    doc_son_rec.doc_tot as amount,
    doc_son_rec.customer_id as cust_code,
    customer.customer_name_a as cust_name,
    customer.customer_name_e as cust_name_e,
    null as job_id,
    null as job_date,
    null as job_request,
    null as debite_id,
    null as debite_date,
    doc_son_rec.service_center as service_center,
    doc_son_rec.location_id as location_id,
    (case doc_son_rec.customer_flag when 'C' then 'Check/��� :'+doc_son_rec.chqu_name
    when 'V' then 'Visa/���� :'
    when 'M' then 'MasterCard/����� ���� :'
    when 'A' then 'AmericanCard/������� ���� :'
    when 'O' then 'Cash/����'
    when 'S' then 'Settlement/�����'
    else doc_son_rec.customer_flag
    end) as pay_type,
    doc_son_rec.doc_rem as notes
    from DBA.doc_son_rec
      ,DBA.customer
    where(doc_son_rec.customer_id = customer.customer_id)
    and(doc_son_rec.doc_detail_type = 2) and(doc_son_rec.doc_type = 2)
    and(doc_son_rec.invoiceno is null or doc_son_rec.invoiceno = 0) union
  select convert(date,doc_son_rec.doc_date) as rec_date,
    doc_son_rec.doc_t_num as rec_no,
    'WP' as rec_type,
    (select ws_InvoiceType.category from DBA.ws_InvoiceType where ws_InvoiceType.InvoiceTypeID = ws_receipt.InvoiceType and ws_InvoiceType.service_center = ws_receipt.service_center) as inv_cat,
    doc_son_rec.doc_tot as amount,
    doc_son_rec.customer_id as cust_code,
    customer.customer_name_a as cust_name,
    customer.customer_name_e as cust_name_e,
    ws_receipt.joborder_id as job_id,
    null as job_date,
    null as job_request,
    null as debite_id,
    null as debite_date,
    doc_son_rec.service_center as service_center,
    doc_son_rec.main_location_id as location_id,
    (case doc_son_rec.customer_flag when 'C' then 'Check/��� :'+doc_son_rec.chqu_name
    when 'V' then 'Visa/���� :'
    when 'M' then 'MasterCard/����� ���� :'
    when 'A' then 'AmericanCard/������� ���� :'
    when 'O' then 'Cash/����'
    when 'S' then 'Settlement/�����'
    else doc_son_rec.customer_flag
    end) as pay_type,
    doc_son_rec.doc_rem as notes
    from DBA.ws_Receipt
      ,DBA.doc_son_rec
      ,DBA.customer
    where(doc_son_rec.customer_id = customer.customer_id)
    and(doc_son_rec.doc_detail_type = 2) and(doc_son_rec.doc_type = 1)
    and(ws_receipt.service_center = doc_son_rec.service_center)
    and(ws_receipt.location_id = doc_son_rec.main_location_id)
    and(ws_receipt.custid = doc_son_rec.customer_id)
    and doc_son_rec.invoiceno = ws_receipt.joborder_id and isnull(doc_son_rec.dp_type,'I') <> 'I' union
  select convert(date,doc_son_rec.doc_date) as rec_date,
    doc_son_rec.doc_t_num as rec_no,
    (case doc_son_rec.doc_type when 2 then 'AW' else(case doc_son_rec.dp_type when 'P' then 'XP' else 'mAD' end) end) as rec_type,
    1 as inv_cat,
    doc_son_rec.doc_tot as amount,
    doc_son_rec.customer_id as cust_code,
    customer.customer_name_a as cust_name,
    customer.customer_name_e as cust_name_e,
    null as job_id,
    null as job_date,
    null as job_request,
    null as debite_id,
    null as debite_date,
    doc_son_rec.service_center as service_center,
    doc_son_rec.location_id as location_id,
    (case doc_son_rec.customer_flag when 'C' then 'Check/��� :'+doc_son_rec.chqu_name
    when 'V' then 'Visa/���� :'
    when 'M' then 'MasterCard/����� ���� :'
    when 'A' then 'AmericanCard/������� ���� :'
    when 'O' then 'Cash/����'
    when 'S' then 'Settlement/�����'
    else doc_son_rec.customer_flag
    end) as pay_type,
    doc_son_rec.doc_rem as notes
    from DBA.doc_son_rec
      ,DBA.customer
    where(doc_son_rec.customer_id = customer.customer_id)
    and(doc_son_rec.doc_detail_type = 2) and(doc_son_rec.doc_type = 1)
    and doc_son_rec.customer_flag <> 'P' and(doc_son_rec.invoiceno is null or doc_son_rec.invoiceno = 0)
    and(doc_son_rec.dp_type <> 'I')
    and(doc_son_rec.dp_type = 'p') union
  select convert(date,doc_son_rec.doc_date) as rec_date,
    doc_son_rec.doc_t_num as rec_no,
    'cc' as rec_type,
    (select ws_InvoiceType.category from DBA.ws_InvoiceType where ws_InvoiceType.InvoiceTypeID = ws_receipt.InvoiceType and ws_InvoiceType.service_center = ws_receipt.service_center) as inv_cat,
    doc_son_rec.doc_tot as amount,
    doc_son_rec.customer_id as cust_code,
    customer.customer_name_a as cust_name,
    customer.customer_name_e as cust_name_e,
    ws_receipt.joborder_id as job_id,
    null as job_date,
    null as job_request,
    null as debite_id,
    null as debite_date,
    doc_son_rec.service_center as service_center,
    doc_son_rec.main_location_id as location_id,
    (case doc_son_rec.customer_flag when 'C' then 'Check/��� :'+doc_son_rec.chqu_name
    when 'V' then 'Visa/���� :'
    when 'M' then 'MasterCard/����� ���� :'
    when 'A' then 'AmericanCard/������� ���� :'
    when 'O' then 'Cash/����'
    when 'S' then 'Settlement/�����'
    else doc_son_rec.customer_flag
    end) as pay_type,
    doc_son_rec.doc_rem as notes
    from DBA.ws_Receipt
      ,DBA.doc_son_rec
      ,DBA.customer
    where(doc_son_rec.customer_id = customer.customer_id)
    and(doc_son_rec.doc_detail_type = 2) and(doc_son_rec.doc_type = 2)
    and(ws_receipt.service_center = doc_son_rec.service_center)
    and(ws_receipt.location_id = doc_son_rec.main_location_id)
    and(ws_receipt.custid = doc_son_rec.customer_id)
    and doc_son_rec.invoiceno = ws_receipt.joborder_id and isnull(doc_son_rec.dp_type,'I') <> 'I'
