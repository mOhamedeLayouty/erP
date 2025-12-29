-- VIEW: DBA.car_account_transaction
-- generated_at: 2025-12-29T14:36:30.521Z
-- object_id: 33129
-- table_id: 1478
-- source_via: SYS.SYSVIEW(view_object_id=object_id)

create view DBA.car_account_transaction( cust_code,cust_name,cust_name_e,doc_date,doc_all,doc_tot,doc_num,type,doc_rem,pay_type,brand,log_store ) as
  --V1.2 exclude sattlemnet receipt in car_receipt
  --set cash back  ,advance payment 
  --V1.3 set return cash back, advance payment
  --V1.4 ///���� ���� ������ ������  
  --V1.5 only display if doc_tot>0
  --V1.6 exclude deleted receipt and refund
  --V1.7 display performa invoice
  --V1.8 display performa invoice with delete_flag <>'y'
  --V1.9 Add insurance transaction
  --V2.0 subtract trade tax value from total price
  --V2.1 multiply in Curr Rate recorded in receipt transaction
  --V2.2 multiply in Curr Rate recorded in Refund transaction
  /*main-customer value*/
  select customer.customer_id as cust_code,
    customer.customer_name_a as cust_name,
    customer.customer_name_e as cust_name_e,
    car_invoice_header.invoice_date as doc_date,
    car_invoice_header.total_price-isnull(car_invoice_header.trade_tax_value,0) as doc_all,
    car_invoice_header.total_price-isnull(car_invoice_header.customer_value,0)-isnull(car_invoice_header.trade_tax_value,0) as doc_tot,
    isnull(car_invoice_header.invoiceno,'P'+car_invoice_header.invoice_id) as doc_num,
    'INV' as type,
    '' as doc_rem,
    'O' as pay_type,
    car_invoice_header.brand as brand,
    car_invoice_header.log_store as log_store
    from DBA.car_invoice_header
      ,DBA.customer
    where(car_invoice_header.main_customer_id = customer.customer_id)
    and car_invoice_header.invoice_nature <> 'R' and car_invoice_header.delete_flag <> 'Y' and doc_tot > 0 union
  /*INV sub-customer value*/
  select customer.customer_id as cust_code,
    customer.customer_name_a as cust_name,
    customer.customer_name_e as cust_name_e,
    car_invoice_header.invoice_date as doc_date,
    car_invoice_header.total_price as doc_all,
    car_invoice_header.customer_value as doc_tot,
    isnull(car_invoice_header.invoiceno,'P'+car_invoice_header.invoice_id) as doc_num,
    'INV' as type,
    '' as doc_rem,
    'O' as pay_type,
    car_invoice_header.brand as brand,
    car_invoice_header.log_store as log_store
    from DBA.car_invoice_header
      ,DBA.customer
    where(car_invoice_header.customer_id = customer.customer_id)
    and car_invoice_header.invoice_nature <> 'R' and car_invoice_header.delete_flag <> 'Y' and doc_tot > 0 union
  /*RINV main-customer value*/
  select customer.customer_id as cust_code,
    customer.customer_name_a as cust_name,
    customer.customer_name_e as cust_name_e,
    car_invoice_header.invoice_date as doc_date,
    car_invoice_header.total_price-isnull(car_invoice_header.trade_tax_value,0) as doc_all,
    car_invoice_header.total_price-isnull(car_invoice_header.customer_value,0)-isnull(car_invoice_header.trade_tax_value,0) as doc_tot,
    isnull(car_invoice_header.invoiceno,'P'+car_invoice_header.invoice_id) as doc_num,
    'RINV' as type,
    '' as doc_rem,
    'O' as pay_type,
    car_invoice_header.brand as brand,
    car_invoice_header.log_store as log_store
    from DBA.car_invoice_header
      ,DBA.customer
    where(car_invoice_header.main_customer_id = customer.customer_id)
    and car_invoice_header.invoice_nature = 'R' and car_invoice_header.delete_flag <> 'Y' and doc_tot > 0 union
  /*RINV sub-Customer value*/
  select customer.customer_id as cust_code,
    customer.customer_name_a as cust_name,
    customer.customer_name_e as cust_name_e,
    car_invoice_header.invoice_date as doc_date,
    car_invoice_header.total_price-isnull(car_invoice_header.trade_tax_value,0) as doc_all,
    car_invoice_header.customer_value as doc_tot,
    isnull(car_invoice_header.invoiceno,'P'+car_invoice_header.invoice_id) as doc_num,
    'RINV' as type,
    '' as doc_rem,
    'O' as pay_type,
    car_invoice_header.brand as brand,
    car_invoice_header.log_store as log_store
    from DBA.car_invoice_header
      ,DBA.customer
    where(car_invoice_header.main_customer_id = customer.customer_id)
    and car_invoice_header.invoice_nature = 'R' and car_invoice_header.delete_flag <> 'Y' and doc_tot > 0 union
  /*RC Receipt*/
  select customer.customer_id as cust_code,
    customer.customer_name_a as cust_name,
    customer.customer_name_e as cust_name_e,
    car_receipt_header.receipt_date as doc_date,
    (car_receipt_header.receipt_amount*car_receipt_header.curr_rate) as doc_all,
    (car_receipt_header.receipt_amount*car_receipt_header.curr_rate) as doc_tot,
    car_receipt_header.doc_no as doc_num,
    'RC' as type,
    car_receipt_header.notes as doc_rem,
    car_receipt_header.paymenttype as pay_type,
    car_receipt_header.brand as brand,
    car_receipt_header.log_store as log_store
    from DBA.car_receipt_header,DBA.customer
    where(car_receipt_header.customer_id = customer.customer_id)
    and(car_receipt_header.paymenttype <> 'S') and(isnull(car_receipt_header.delete_flag,'N') <> 'Y') union
  /*RF Refund*/
  select customer.customer_id as cust_code,
    customer.customer_name_a as cust_name,
    customer.customer_name_e as cust_name_e,
    car_refund_header.refund_date as doc_date,
    (car_refund_header.refund_amount*car_refund_header.curr_rate) as doc_all,
    (car_refund_header.refund_amount*car_refund_header.curr_rate) as doc_tot,
    car_refund_header.refund_id as doc_num,
    'RF' as type,
    car_refund_header.notes as doc_rem,
    car_refund_header.paymenttype as pay_type,
    car_refund_header.brand as brand,
    car_refund_header.log_store as log_store
    from DBA.car_refund_header,DBA.customer
    where(car_refund_header.customer_id = customer.customer_id)
    and(isnull(car_refund_header.delete_flag,'N') <> 'Y') union
  select customer.customer_id as cust_code,
    customer.customer_name_a as cust_name,
    customer.customer_name_e as cust_name_e,
    car_doc_son_rec.doc_date as doc_date,
    car_doc_son_rec.doc_tot as doc_all,
    car_doc_son_rec.doc_tot as doc_tot,
    car_doc_son_rec.doc_num as doc_num,
    car_doc_son_rec.doc_type as type,
    car_doc_son_rec.doc_rem as doc_rem,
    car_doc_son_rec.doc_tot_type as pay_type,
    car_doc_son_rec.brand as brand,
    car_doc_son_rec.log_store as log_store
    from DBA.car_doc_son_rec
      ,DBA.customer
    where(car_doc_son_rec.hld_code = customer.customer_id)
    and(car_doc_son_rec.doc_detail_type = 3) union
  select customer.customer_id as cust_code,
    customer.customer_name_a as cust_name,
    customer.customer_name_e as cust_name_e,
    car_invoice_header.invoice_date as doc_date,
    isnull(car_invoice_header.cashback_value,0) as doc_all,
    isnull(car_invoice_header.cashback_value,0) as doc_tot,
    isnull(car_invoice_header.invoiceno,'P'+car_invoice_header.invoice_id) as doc_num,
    'CC' as type,
    'Cash back' as doc_rem,
    'O' as pay_type,
    car_invoice_header.brand as brand,
    car_invoice_header.log_store as log_store
    from DBA.car_invoice_header
      ,DBA.customer
    where(car_invoice_header.customer_id = customer.customer_id)
    and car_invoice_header.invoice_nature <> 'R'
    and car_invoice_header.delete_flag <> 'Y'
    and isnull(car_invoice_header.cashback_value,0) > 0 union
  select customer.customer_id as cust_code,
    customer.customer_name_a as cust_name,
    customer.customer_name_e as cust_name_e,
    car_invoice_header.invoice_date as doc_date,
    isnull(car_invoice_header.advance_payment,0) as doc_all,
    isnull(car_invoice_header.advance_payment,0) as doc_tot,
    isnull(car_invoice_header.invoiceno,'P'+car_invoice_header.invoice_id) as doc_num,
    'INV' as type,
    'Advance Payment' as doc_rem,
    'O' as pay_type,
    car_invoice_header.brand as brand,
    car_invoice_header.log_store as log_store
    from DBA.car_invoice_header
      ,DBA.customer
    where(car_invoice_header.customer_id = customer.customer_id)
    and car_invoice_header.invoice_nature <> 'R'
    and car_invoice_header.delete_flag <> 'Y'
    and isnull(car_invoice_header.advance_payment,0) > 0 union
  select customer.customer_id as cust_code,
    customer.customer_name_a as cust_name,
    customer.customer_name_e as cust_name_e,
    car_invoice_header.invoice_date as doc_date,
    isnull(car_invoice_header.cashback_value,0) as doc_all,
    isnull(car_invoice_header.cashback_value,0) as doc_tot,
    isnull(car_invoice_header.invoiceno,'P'+car_invoice_header.invoice_id) as doc_num,
    'DD' as type,
    'Cash back Return ' as doc_rem,
    'O' as pay_type,
    car_invoice_header.brand as brand,
    car_invoice_header.log_store as log_store
    from DBA.car_invoice_header
      ,DBA.customer
    where(car_invoice_header.customer_id = customer.customer_id)
    and car_invoice_header.invoice_nature = 'R'
    and car_invoice_header.delete_flag <> 'Y'
    and isnull(car_invoice_header.cashback_value,0) > 0 union
  select customer.customer_id as cust_code,
    customer.customer_name_a as cust_name,
    customer.customer_name_e as cust_name_e,
    car_invoice_header.invoice_date as doc_date,
    isnull(car_invoice_header.advance_payment,0) as doc_all,
    isnull(car_invoice_header.advance_payment,0) as doc_tot,
    isnull(car_invoice_header.invoiceno,'P'+car_invoice_header.invoice_id) as doc_num,
    'RINV' as type,
    'Advance Payment Return ' as doc_rem,
    'O' as pay_type,
    car_invoice_header.brand as brand,
    car_invoice_header.log_store as log_store
    from DBA.car_invoice_header
      ,DBA.customer
    where(car_invoice_header.customer_id = customer.customer_id)
    and car_invoice_header.invoice_nature = 'R'
    and car_invoice_header.delete_flag <> 'Y'
    and isnull(car_invoice_header.advance_payment,0) > 0 union
  /*Insurance Transaction*/
  select customer.customer_id as cust_code,
    customer.customer_name_a as cust_name,
    customer.customer_name_e as cust_name_e,
    vehicle_insurance.insurance_date as doc_date,
    vehicle_insurance.cust_value as doc_all,
    vehicle_insurance.cust_value as doc_tot,
    vehicle_insurance.insurance_code as doc_num,
    'INS' as type,
    'Vehicle Insurance '+isnull(vehicle_insurance.notes,'') as doc_rem,
    'O' as pay_type,
    vehicle_insurance.brand as brand,
    vehicle_insurance.log_store as log_store
    from DBA.vehicle_insurance,DBA.customer
    where(vehicle_insurance.customer_id = customer.customer_id)
