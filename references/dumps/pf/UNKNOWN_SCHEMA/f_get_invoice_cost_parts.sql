-- PF: UNKNOWN_SCHEMA.f_get_invoice_cost_parts
-- proc_id: 453
-- generated_at: 2025-12-29T13:53:28.823Z

create function ////////////////////////////////////////
DBA.f_get_invoice_cost_parts( 
  in as_InvoiceID varchar(50),
  in an_InvoiceType integer,
  in an_center integer,
  in an_location integer ) 
returns numeric(20,7)
--Ver 1.0 get parts cost only (copy from f_get_invoice_cost )
begin
  declare as_invoice_nature varchar(20);
  declare as_joborder_id varchar(20);
  declare an_debit_header integer;
  declare an_credit_header integer;
  declare an_debit numeric(20,7);
  declare an_return numeric(20,7);
  declare an_cost numeric(20,7);
  select invoice_nature,joborder_id,debit_header,credit_header
    into as_invoice_nature,as_joborder_id,an_debit_header,an_credit_header
    from ws_invoiceheader
    where invoiceid = as_InvoiceID
    and invoicetype = an_InvoiceType
    and service_center = an_center
    and location_id = an_location;
  if as_invoice_nature = 'R' and(as_joborder_id is null or as_joborder_id = '') then
    select Sum(sc_ret_detail.cost_price*sc_ret_detail.qty)
      into an_cost from sc_ret_detail
        left outer join sc_item
        on sc_ret_detail.item_id = sc_item.item_id
        and sc_ret_detail.service_center = sc_item.service_center
        ,sc_ret_header
      where sc_ret_detail.credit_header = sc_ret_header.credit_header
      and sc_ret_detail.service_center = sc_ret_header.service_center
      and sc_ret_detail.location_id = sc_ret_header.location_id
      and sc_ret_detail.credit_header = an_credit_header
      and sc_ret_header.service_center = an_center
      and sc_ret_detail.location_id = an_location
      and sc_item.ItemType = 'S'
  else
    if as_joborder_id is null or as_joborder_id = '' then
      select sum(sc_debit_detail.item_cost*sc_debit_detail.qty)
        into an_debit from sc_debit_detail
          left outer join sc_item
          on sc_debit_detail.item_id = sc_item.item_id
          and sc_debit_detail.service_center = sc_item.service_center
          ,sc_debit_header
        where sc_debit_detail.debit_header = sc_debit_header.debit_header
        and sc_debit_detail.service_center = sc_debit_header.service_center
        and sc_debit_detail.location_id = sc_debit_header.location_id
        and sc_debit_detail.invoicetype = an_InvoiceType
        and sc_debit_header.debit_header = an_debit_header
        and sc_debit_header.service_center = an_center
        and sc_debit_header.location_id = an_location
        and sc_item.ItemType = 'S'
    else
      select distinct Sum(InvoiceDetail.qty
        *(select top 1 sc_debit_detail.item_cost
          from sc_debit_header,sc_debit_detail
          where sc_debit_detail.service_center = sc_debit_header.service_center
          and sc_debit_detail.location_id = sc_debit_header.location_id
          and sc_debit_detail.debit_header = sc_debit_header.debit_header
          and sc_debit_header.service_center = an_center
          and sc_debit_header.location_id = an_location
          and sc_debit_header.joborderid = as_joborder_id
          and sc_debit_detail.service_center = InvoiceDetail.service_center
          and sc_debit_detail.location_id = InvoiceDetail.location_id
          and sc_debit_detail.item_id = InvoiceDetail.ItemID
          and(sc_debit_detail.debit_header = InvoiceDetail.debit_header or InvoiceDetail.debit_header is null)
          and sc_debit_detail.status = 2))
        into an_debit from ws_invoicedetail as InvoiceDetail
        where InvoiceDetail.invoiceid = as_InvoiceID
        and InvoiceDetail.invoicetype = an_InvoiceType
        and InvoiceDetail.flag = 'I'
        and InvoiceDetail.service_center = an_center
        and InvoiceDetail.location_id = an_location
        and InvoiceDetail.ItemType = 'S'
    end if;
    set an_cost = isnull(an_debit,0)-isnull(an_return,0)
  end if;
  return an_cost
end
