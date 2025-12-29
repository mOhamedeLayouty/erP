-- TRIGGER: DBA.tr_doc_son_paidamount
-- ON TABLE: DBA.doc_son_rec
-- generated_at: 2025-12-29T13:52:33.693Z

create trigger tr_doc_son_paidamount after insert,delete,update order 2 on
DBA.doc_son_rec
referencing old as old_rec new as new_rec
for each row
//V1.0
//V1.1 handle value if record deleted
//V1.2 sattlement or pay
//V1.3 round values
//V1.4 handling return advanced payment
//V1.5 Round
//V1.6 Link by invoiceid instead invoice No.
//V1.7 update ReceiptType in ('N','C')
//V1.8 sub downpayment if sub from sub,ignor delete receipt
//V1.9 disable update if different expense receipt
begin
  if updating then
    if old_rec.doc_tot = new_rec.doc_tot then
      return
    end if end if;
  if new_rec.dp_type = 'I' then //Invoice
    if(new_rec.InvoiceID is not null and new_rec.InvoiceID <> '') or(old_rec.InvoiceID is not null and old_rec.InvoiceID <> '') then
      update ws_receipt set ws_receipt.paidamount
         = Round(isnull((select sum(paymentAmount) from ws_ReceiptDetail
          where ws_ReceiptDetail.receipt_id = ws_Receipt.receipt_id
          and ws_ReceiptDetail.service_center = ws_Receipt.service_center
          and ws_ReceiptDetail.main_location_id = ws_Receipt.location_id),0)
        +(isnull((select Sum(doc_tot) from doc_son_rec
          where doc_son_rec.doc_type = 2
          and doc_son_rec.customer_id = ws_receipt.custid
          and doc_son_rec.service_center = ws_receipt.service_center
          and doc_son_rec.main_location_id = ws_receipt.location_id
          and doc_son_rec.InvoiceID = ws_receipt.InvoiceID
          and doc_son_rec.InvoiceType = ws_receipt.InvoiceType),0)
        -isnull((select Sum(doc_tot) from doc_son_rec
          where doc_son_rec.doc_type = 1
          and doc_son_rec.customer_id = ws_receipt.custid
          and doc_son_rec.service_center = ws_receipt.service_center
          and doc_son_rec.main_location_id = ws_receipt.location_id
          and doc_son_rec.InvoiceID = ws_receipt.InvoiceID
          and doc_son_rec.InvoiceType = ws_receipt.InvoiceType),0)
        -isnull((select Sum(doc_tot) from doc_son_rec
          where doc_son_rec.doc_type = 1
          and doc_son_rec.customer_id = ws_receipt.custid
          and doc_son_rec.service_center = ws_receipt.service_center
          and doc_son_rec.main_location_id = ws_receipt.location_id
          and doc_son_rec.dp_type = ws_receipt.dp_type
          and doc_son_rec.invoiceno = ws_receipt.joborder_id),0)
        +isnull((select sum(doc_son_rec_details.paid_amount)
          from doc_son_rec_details
          where doc_son_rec_details.doc_type = 2
          and doc_son_rec_details.customer_id = ws_receipt.custid
          and(doc_son_rec_details.service_center = ws_receipt.service_center)
          and(doc_son_rec_details.main_location_id = ws_receipt.location_id)
          and(doc_son_rec_details.InvoiceID = ws_receipt.InvoiceID)
          and(doc_son_rec_details.InvoiceType = ws_receipt.InvoiceType)),0)),2)
        where ws_receipt.service_center = new_rec.service_center
        and ws_receipt.location_id = new_rec.main_location_id
        and ws_receipt.InvoiceID = new_rec.InvoiceID
        and ws_receipt.InvoiceType = new_rec.InvoiceType
        and ws_receipt.custid = new_rec.customer_id
        and isnull(ws_receipt.delete_flag,'N') <> 'Y'
        and Round(isnull((select sum(paymentAmount) from ws_ReceiptDetail
          where ws_ReceiptDetail.receipt_id = ws_Receipt.receipt_id
          and ws_ReceiptDetail.service_center = ws_Receipt.service_center
          and ws_ReceiptDetail.main_location_id = ws_Receipt.location_id),0)
        +(isnull((select Sum(doc_tot) from doc_son_rec
          where doc_son_rec.doc_type = 2
          and doc_son_rec.customer_id = ws_receipt.custid
          and doc_son_rec.service_center = ws_receipt.service_center
          and doc_son_rec.main_location_id = ws_receipt.location_id
          and doc_son_rec.InvoiceID = ws_receipt.InvoiceID
          and doc_son_rec.InvoiceType = ws_receipt.InvoiceType),0)
        -isnull((select Sum(doc_tot) from doc_son_rec
          where doc_son_rec.doc_type = 1
          and doc_son_rec.customer_id = ws_receipt.custid
          and doc_son_rec.service_center = ws_receipt.service_center
          and doc_son_rec.main_location_id = ws_receipt.location_id
          and doc_son_rec.InvoiceID = ws_receipt.InvoiceID
          and doc_son_rec.InvoiceType = ws_receipt.InvoiceType),0)
        -isnull((select Sum(doc_tot) from doc_son_rec
          where doc_son_rec.doc_type = 1
          and doc_son_rec.customer_id = ws_receipt.custid
          and doc_son_rec.service_center = ws_receipt.service_center
          and doc_son_rec.main_location_id = ws_receipt.location_id
          and doc_son_rec.dp_type = ws_receipt.dp_type
          and doc_son_rec.invoiceno = ws_receipt.joborder_id),0)
        +isnull((select sum(doc_son_rec_details.paid_amount)
          from doc_son_rec_details
          where doc_son_rec_details.doc_type = 2
          and doc_son_rec_details.customer_id = ws_receipt.custid
          and(doc_son_rec_details.service_center = ws_receipt.service_center)
          and(doc_son_rec_details.main_location_id = ws_receipt.location_id)
          and(doc_son_rec_details.InvoiceID = ws_receipt.InvoiceID)
          and(doc_son_rec_details.InvoiceType = ws_receipt.InvoiceType)),0)),2)
         >= 0;
      //
      update ws_receipt set ws_receipt.ReceiptType = 'N'
        where ws_receipt.service_center = new_rec.service_center
        and ws_receipt.location_id = new_rec.main_location_id
        and ws_receipt.InvoiceID = new_rec.InvoiceID
        and ws_receipt.InvoiceType = new_rec.InvoiceType
        and ws_receipt.custid = new_rec.customer_id
        and isnull(ws_receipt.delete_flag,'N') <> 'Y'
        and ws_receipt.ReceiptType = 'Y' and round(ws_receipt.paidamount,2) >= round(ws_receipt.receipt_amount,2);
      //
      update ws_receipt set ws_receipt.ReceiptType = 'Y'
        where ws_receipt.service_center = new_rec.service_center
        and ws_receipt.location_id = new_rec.main_location_id
        and ws_receipt.InvoiceID = new_rec.InvoiceID
        and ws_receipt.InvoiceType = new_rec.InvoiceType
        and ws_receipt.custid = new_rec.customer_id
        and isnull(ws_receipt.delete_flag,'N') <> 'Y'
        and ws_receipt.ReceiptType in( 'C','N' ) and round(ws_receipt.paidamount,2) < round(ws_receipt.receipt_amount,2)
    end if end if; //dp_type
  //Return DownPayment------------------------------------------------------------------------------------------------------
  if new_rec.dp_type <> 'I' then
    if(new_rec.invoiceno is not null and new_rec.invoiceno <> '') or(old_rec.invoiceno is not null and old_rec.invoiceno <> '') then
      update ws_receipt set ws_receipt.paidamount
         = Round(isnull((select sum(paymentAmount) from ws_ReceiptDetail
          where ws_ReceiptDetail.receipt_id = ws_Receipt.receipt_id
          and ws_ReceiptDetail.service_center = ws_Receipt.service_center
          and ws_ReceiptDetail.main_location_id = ws_Receipt.location_id),0)
        -isnull((select Sum(doc_tot) from doc_son_rec
          where doc_son_rec.doc_type = 1
          and doc_son_rec.customer_id = ws_receipt.custid
          and doc_son_rec.service_center = ws_receipt.service_center
          and doc_son_rec.main_location_id = ws_receipt.location_id
          and doc_son_rec.dp_type = ws_receipt.dp_type
          and doc_son_rec.invoiceno = ws_receipt.joborder_id),0),2)
        where ws_receipt.service_center = new_rec.service_center
        and ws_receipt.location_id = new_rec.main_location_id
        and ws_receipt.joborder_id = new_rec.invoiceno
        and ws_receipt.custid = new_rec.customer_id
        and isnull(ws_receipt.delete_flag,'N') <> 'Y'
        and round(isnull((select sum(paymentAmount) from ws_ReceiptDetail
          where ws_ReceiptDetail.receipt_id = ws_Receipt.receipt_id
          and ws_ReceiptDetail.service_center = ws_Receipt.service_center
          and ws_ReceiptDetail.main_location_id = ws_Receipt.location_id),0)
        -isnull((select Sum(doc_tot) from doc_son_rec
          where doc_son_rec.doc_type = 1
          and doc_son_rec.customer_id = ws_receipt.custid
          and doc_son_rec.service_center = ws_receipt.service_center
          and doc_son_rec.main_location_id = ws_receipt.location_id
          and doc_son_rec.dp_type = ws_receipt.dp_type
          and doc_son_rec.invoiceno = ws_receipt.joborder_id),0),2)
         >= 0
    //dp_type
    end if
  end if
end
