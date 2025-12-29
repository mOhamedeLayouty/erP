-- PF: UNKNOWN_SCHEMA.f_get_car_aging
-- proc_id: 393
-- generated_at: 2025-12-29T13:53:28.805Z

create function DBA.f_get_car_aging( in @cust_code varchar(20),in @fdate date,in @tdate date,in @indate date ) 
returns numeric(12,3)
--error handling
--V1.4 read direct from invoice instead  
begin
  declare ret_amount numeric(12,3);
  declare ret_amount2 numeric(12,3);
  select Sum((select isnull(car_invoice_detail.price,0)
      +isnull(car_invoice_detail.accessories,0)
      +isnull(car_invoice_detail.plateregister_value,0)
      +isnull(car_invoice_detail.insurance_value,0)
      +isnull(car_invoice_detail.servicepackage_value,0)
      +isnull(car_invoice_detail.special_request_value,0)
      +isnull(car_invoice_detail.roadassistance_value,0)
      +isnull(car_invoice_header.sales_taxt,0)
      -isnull(get_getpaidamount(car_invoice_detail.vehicle_id,car_invoice_detail.chassi_no,car_invoice_detail.brand,'1900-01-01',@indate),0)))
    into ret_amount from car_invoice_header,car_invoice_detail
    where(car_invoice_detail.invoice_id = car_invoice_header.invoice_id)
    and(car_invoice_detail.log_store = car_invoice_header.log_store)
    and(car_invoice_detail.brand = car_invoice_header.brand)
    and(car_invoice_header.invoice_type = 2 and car_invoice_detail.return_created <> 'Y')
    and(car_invoice_header.main_customer_id = @cust_code) and(car_invoice_header.invoice_nature <> 'R')
    and(car_invoice_header.invoice_date >= @fdate)
    and(car_invoice_header.invoice_date < @tdate);
  select sum(isnull((select distinct Sum(doc_tot) from car_doc_son_rec
      where hld_code = car_invoice_header.main_customer_id and invoiceno = car_invoice_header.invoiceno and doc_date <= @indate
      and car_doc_son_rec.doc_detail_type = 3 and doc_type in( 'DS' ) and brand = car_invoice_header.brand),0)
    -isnull((select distinct Sum(doc_tot) from car_doc_son_rec
      where hld_code = car_invoice_header.main_customer_id and invoiceno = car_invoice_header.invoiceno and doc_date <= @indate
      and car_doc_son_rec.doc_detail_type = 3 and doc_type in( 'CS' ) and brand = car_invoice_header.brand),0))
    into ret_amount2 from car_invoice_header
    where(car_invoice_header.invoice_type = 2)
    and(car_invoice_header.main_customer_id = @cust_code) and(car_invoice_header.invoice_nature <> 'R')
    and(car_invoice_header.invoice_date >= @fdate)
    and(car_invoice_header.invoice_date < @tdate);
  return isnull(ret_amount,0)+isnull(ret_amount2,0)
end
