-- PF: UNKNOWN_SCHEMA.F_Get_PaidOnWSInvoice
-- proc_id: 390
-- generated_at: 2025-12-29T13:53:28.804Z

create function DBA.F_Get_PaidOnWSInvoice( in @invoiceno integer,in @invoicetype integer,in @invoice_nature varchar(1) default 'O',in @service_center integer,in @location_id integer,in @CustomerID varchar(50) ) 
returns decimal
---ver 1.2
---ver 1.3 get paid value from receipt only
begin
  declare @sattl_paid decimal(12,2);
  declare @doc_paid decimal(12,2);
  declare @receipt_paid decimal(12,2);
  declare @inv_paid decimal(12,2);
  if @invoiceno = null or @invoiceno = 0 then
    return 0
  end if;
  //
  if @invoice_nature = 'R' then
    select Sum(doc_tot) into @sattl_paid from doc_son_rec
      where doc_son_rec.service_center = @service_center
      and doc_son_rec.main_location_id = @location_id
      and doc_son_rec.invoiceno = @invoiceno
      and doc_son_rec.doc_type = '2' and doc_son_rec.doc_detail_type = 2 and isnull(doc_son_rec.invoice_nature,'O') = @invoice_nature;
    select sum(doc_son_rec_details.paid_amount)
      into @doc_paid from doc_son_rec
        ,doc_son_rec_details
      where(doc_son_rec.doc_t_num = doc_son_rec_details.doc_t_num)
      and(doc_son_rec.doc_type = doc_son_rec_details.doc_type)
      and(doc_son_rec.service_center = doc_son_rec_details.service_center)
      and(doc_son_rec.location_id = doc_son_rec_details.location_id)
      and(doc_son_rec_details.service_center = @service_center)
      and(doc_son_rec_details.main_location_id = @location_id)
      and(doc_son_rec_details.invoiceno = @invoiceno)
      and(doc_son_rec_details.customer_id = @CustomerID)
      and(doc_son_rec.doc_type = '2') and(doc_son_rec.doc_detail_type = 2) and isnull(doc_son_rec.invoice_nature,'O') = @invoice_nature
  end if;
  select sum(paidamount) into @receipt_paid from ws_Receipt
    where ws_Receipt.service_center = @service_center
    and ws_Receipt.location_id = @location_id
    and ws_Receipt.invoiceno = @invoiceno
    and ws_Receipt.custid = @CustomerID
    and ws_Receipt.invoicetype = @invoicetype
    and Isnull(ws_Receipt.delete_flag,'N') <> 'Y';
  set @inv_paid = isnull(@receipt_paid,0)+isnull(@sattl_paid,0)+isnull(@doc_paid,0);
  return @inv_paid
end
