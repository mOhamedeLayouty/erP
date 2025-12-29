-- PF: UNKNOWN_SCHEMA.SP_CarSalesSummaryReport
-- proc_id: 434
-- generated_at: 2025-12-29T13:53:28.817Z

create procedure DBA.SP_CarSalesSummaryReport( in @brand integer default 1 ) 
begin
  select vechile_model.model_description_e,
    isnull((select count(car_invoice_detail.chassi_no)
      from car_invoice_detail
        ,car_invoice_header
      where(car_invoice_detail.invoice_id = car_invoice_header.invoice_id)
      and(car_invoice_header.brand = car_invoice_detail.brand)
      and(car_invoice_detail.log_store = car_invoice_header.log_store)
      and(car_invoice_header.invoice_nature <> 'R')
      and(car_invoice_header.vehicle_model = model_code)
      and(year(car_invoice_header.invoice_date) = year(today()))
      and(month(car_invoice_header.invoice_date) = 1)
      and(car_invoice_header.brand = @brand)
      and(car_invoice_header.invoice_type = 2 and car_invoice_header.approved = 'Y')),
    0) as sales_1,
    isnull((select count(car_invoice_detail.chassi_no)
      from car_invoice_detail
        ,car_invoice_header
      where(car_invoice_detail.invoice_id = car_invoice_header.invoice_id)
      and(car_invoice_header.brand = car_invoice_detail.brand)
      and(car_invoice_detail.log_store = car_invoice_header.log_store)
      and(car_invoice_header.invoice_nature <> 'R')
      and(car_invoice_header.vehicle_model = model_code)
      and(year(car_invoice_header.invoice_date) = year(today()))
      and(month(car_invoice_header.invoice_date) = 2)
      and(car_invoice_header.brand = @brand)
      and(car_invoice_header.invoice_type = 2 and car_invoice_header.approved = 'Y')),
    0) as sales_2,
    isnull((select count(car_invoice_detail.chassi_no)
      from car_invoice_detail
        ,car_invoice_header
      where(car_invoice_detail.invoice_id = car_invoice_header.invoice_id)
      and(car_invoice_header.brand = car_invoice_detail.brand)
      and(car_invoice_detail.log_store = car_invoice_header.log_store)
      and(car_invoice_header.invoice_nature <> 'R')
      and(car_invoice_header.vehicle_model = model_code)
      and(year(car_invoice_header.invoice_date) = year(today()))
      and(month(car_invoice_header.invoice_date) = 3)
      and(car_invoice_header.brand = @brand)
      and(car_invoice_header.invoice_type = 2 and car_invoice_header.approved = 'Y')),
    0) as sales_3,
    isnull((select count(car_invoice_detail.chassi_no)
      from car_invoice_detail
        ,car_invoice_header
      where(car_invoice_detail.invoice_id = car_invoice_header.invoice_id)
      and(car_invoice_header.brand = car_invoice_detail.brand)
      and(car_invoice_detail.log_store = car_invoice_header.log_store)
      and(car_invoice_header.invoice_nature <> 'R')
      and(car_invoice_header.vehicle_model = model_code)
      and(year(car_invoice_header.invoice_date) = year(today()))
      and(month(car_invoice_header.invoice_date) = 4)
      and(car_invoice_header.brand = @brand)
      and(car_invoice_header.invoice_type = 2 and car_invoice_header.approved = 'Y')),
    0) as sales_4,
    isnull((select count(car_invoice_detail.chassi_no)
      from car_invoice_detail
        ,car_invoice_header
      where(car_invoice_detail.invoice_id = car_invoice_header.invoice_id)
      and(car_invoice_header.brand = car_invoice_detail.brand)
      and(car_invoice_detail.log_store = car_invoice_header.log_store)
      and(car_invoice_header.invoice_nature <> 'R')
      and(car_invoice_header.vehicle_model = model_code)
      and(year(car_invoice_header.invoice_date) = year(today()))
      and(month(car_invoice_header.invoice_date) = 5)
      and(car_invoice_header.brand = @brand)
      and(car_invoice_header.invoice_type = 2 and car_invoice_header.approved = 'Y')),
    0) as sales_5,
    isnull((select count(car_invoice_detail.chassi_no)
      from car_invoice_detail
        ,car_invoice_header
      where(car_invoice_detail.invoice_id = car_invoice_header.invoice_id)
      and(car_invoice_header.brand = car_invoice_detail.brand)
      and(car_invoice_detail.log_store = car_invoice_header.log_store)
      and(car_invoice_header.invoice_nature <> 'R')
      and(car_invoice_header.vehicle_model = model_code)
      and(year(car_invoice_header.invoice_date) = year(today()))
      and(month(car_invoice_header.invoice_date) = 6)
      and(car_invoice_header.brand = @brand)
      and(car_invoice_header.invoice_type = 2 and car_invoice_header.approved = 'Y')),
    0) as sales_6,
    isnull((select count(car_invoice_detail.chassi_no)
      from car_invoice_detail
        ,car_invoice_header
      where(car_invoice_detail.invoice_id = car_invoice_header.invoice_id)
      and(car_invoice_header.brand = car_invoice_detail.brand)
      and(car_invoice_detail.log_store = car_invoice_header.log_store)
      and(car_invoice_header.invoice_nature <> 'R')
      and(car_invoice_header.vehicle_model = model_code)
      and(year(car_invoice_header.invoice_date) = year(today()))
      and(month(car_invoice_header.invoice_date) = 7)
      and(car_invoice_header.brand = @brand)
      and(car_invoice_header.invoice_type = 2 and car_invoice_header.approved = 'Y')),
    0) as sales_7,
    isnull((select count(car_invoice_detail.chassi_no)
      from car_invoice_detail
        ,car_invoice_header
      where(car_invoice_detail.invoice_id = car_invoice_header.invoice_id)
      and(car_invoice_header.brand = car_invoice_detail.brand)
      and(car_invoice_detail.log_store = car_invoice_header.log_store)
      and(car_invoice_header.invoice_nature <> 'R')
      and(car_invoice_header.vehicle_model = model_code)
      and(year(car_invoice_header.invoice_date) = year(today()))
      and(month(car_invoice_header.invoice_date) = 8)
      and(car_invoice_header.brand = @brand)
      and(car_invoice_header.invoice_type = 2 and car_invoice_header.approved = 'Y')),
    0) as sales_8,
    isnull((select count(car_invoice_detail.chassi_no)
      from car_invoice_detail
        ,car_invoice_header
      where(car_invoice_detail.invoice_id = car_invoice_header.invoice_id)
      and(car_invoice_header.brand = car_invoice_detail.brand)
      and(car_invoice_detail.log_store = car_invoice_header.log_store)
      and(car_invoice_header.invoice_nature <> 'R')
      and(car_invoice_header.vehicle_model = model_code)
      and(year(car_invoice_header.invoice_date) = year(today()))
      and(month(car_invoice_header.invoice_date) = 9)
      and(car_invoice_header.brand = @brand)
      and(car_invoice_header.invoice_type = 2 and car_invoice_header.approved = 'Y')),
    0) as sales_9,
    isnull((select count(car_invoice_detail.chassi_no)
      from car_invoice_detail
        ,car_invoice_header
      where(car_invoice_detail.invoice_id = car_invoice_header.invoice_id)
      and(car_invoice_header.brand = car_invoice_detail.brand)
      and(car_invoice_detail.log_store = car_invoice_header.log_store)
      and(car_invoice_header.invoice_nature <> 'R')
      and(car_invoice_header.vehicle_model = model_code)
      and(year(car_invoice_header.invoice_date) = year(today()))
      and(month(car_invoice_header.invoice_date) = 10)
      and(car_invoice_header.brand = @brand)
      and(car_invoice_header.invoice_type = 2 and car_invoice_header.approved = 'Y')),
    0) as sales_10,
    isnull((select count(car_invoice_detail.chassi_no)
      from car_invoice_detail
        ,car_invoice_header
      where(car_invoice_detail.invoice_id = car_invoice_header.invoice_id)
      and(car_invoice_header.brand = car_invoice_detail.brand)
      and(car_invoice_detail.log_store = car_invoice_header.log_store)
      and(car_invoice_header.invoice_nature <> 'R')
      and(car_invoice_header.vehicle_model = model_code)
      and(year(car_invoice_header.invoice_date) = year(today()))
      and(month(car_invoice_header.invoice_date) = 11)
      and(car_invoice_header.brand = @brand)
      and(car_invoice_header.invoice_type = 2 and car_invoice_header.approved = 'Y')),
    0) as sales_11,
    isnull((select count(car_invoice_detail.chassi_no)
      from car_invoice_detail
        ,car_invoice_header
      where(car_invoice_detail.invoice_id = car_invoice_header.invoice_id)
      and(car_invoice_header.brand = car_invoice_detail.brand)
      and(car_invoice_detail.log_store = car_invoice_header.log_store)
      and(car_invoice_header.invoice_nature <> 'R')
      and(car_invoice_header.vehicle_model = model_code)
      and(year(car_invoice_header.invoice_date) = year(today()))
      and(month(car_invoice_header.invoice_date) = 12)
      and(car_invoice_header.brand = @brand)
      and(car_invoice_header.invoice_type = 2 and car_invoice_header.approved = 'Y')),
    0) as sales_12
    from vechile_model
end
