-- PF: UNKNOWN_SCHEMA.get_kpi_value
-- proc_id: 388
-- generated_at: 2025-12-29T13:53:28.804Z

create function DBA.get_kpi_value( in ar_kpi_code char(20),in ar_year integer,in ar_month integer,in ar_center integer,in ar_location integer ) 
returns integer
begin
  declare ret_value integer;
  //No or Reservation 
  if ar_kpi_code = 'ws_no_reservation' then
    select count(reservationid)
      into ret_value from ws_reservation
      where(isnull(ws_reservation.delete_flag,'N') = 'N')
      and year(reserve_date) = ar_year
      and month(reserve_date) = ar_month
      and service_center = ar_center
      and location_id = ar_location
  //No of Reception Order
  elseif ar_kpi_code = 'ws_no_ro' then
    select count(receptionid)
      into ret_value from ws_Reception
      where(isnull(ws_reception.deleteflag,'N') = 'N')
      and year(starttime) = ar_year
      and month(starttime) = ar_month
      and service_center = ar_center
      and location_id = ar_location
  //No of Job Order
  elseif ar_kpi_code = 'ws_no_jo' then
    select count(voucherid)
      into ret_value from ws_JobOrder
      where(isnull(ws_JobOrder.deleteflag,'N') = 'N')
      and year(jobdate) = ar_year
      and month(jobdate) = ar_month
      and service_center = ar_center
      and location_id = ar_location
  //-----------------------------------------------------------------------------
  //-----------------------------------------------------------------------------
  //Sold all FRU
  elseif ar_kpi_code = 'sold_all_fru' then
    select sum(isnull(ws_catalogdetail.flatrate
      *(ws_joborderemployee.emppercent/100),0))*1
      into ret_value from ws_joborderemployee
        ,ws_operation
        ,ws_joborderdetail
        ,ws_catalogdetail
        ,ws_eqpt_category
        ,ws_eqpt
        ,ws_joborder,hr.dbs_s_employe
      where(hr.dbs_s_employe.emp_code = ws_joborderemployee.employee_id)
      and(hr.dbs_s_employe.service_center = ws_joborderemployee.service_center)
      and(hr.dbs_s_employe.location_id = ws_joborderemployee.location_id)
      and(ws_joborderemployee.serviceid = ws_operation.opertationid)
      and(ws_joborderemployee.service_center = ws_operation.service_center)
      and(ws_joborderdetail.joborderid = ws_joborderemployee.joborderid)
      and(ws_joborderdetail.service_center = ws_joborderemployee.service_center)
      and(ws_joborderdetail.location_id = ws_joborderemployee.location_id)
      and(ws_joborderdetail.serviceid = ws_joborderemployee.serviceid)
      and(ws_catalogdetail.operationid = ws_operation.opertationid)
      and(ws_catalogdetail.service_center = ws_operation.service_center)
      and(ws_catalogdetail.catalogid = ws_eqpt_category.catalogid)
      and(ws_catalogdetail.service_center = ws_eqpt_category.service_center)
      and(ws_eqpt_category.category_id = ws_eqpt.category_id)
      and(ws_eqpt_category.service_center = ws_eqpt.service_center)
      and(ws_joborder.eqptid = ws_eqpt.eqpt_id)
      and(ws_joborder.service_center = ws_eqpt.service_center)
      and(ws_joborder.joborderid = ws_joborderdetail.joborderid)
      and(ws_joborder.service_center = ws_joborderdetail.service_center)
      and(ws_joborder.location_id = ws_joborderdetail.location_id)
      and(ws_operation.service_center = ws_joborderemployee.service_center)
      and(ws_catalogdetail.service_center = ws_operation.service_center)
      and(ws_catalogdetail.service_center = ws_eqpt_category.service_center)
      and(year(ws_joborderemployee.workdate) = ar_year)
      and(month(ws_joborderemployee.workdate) = ar_month)
      and(ws_joborderemployee.service_center = ar_center)
      and(ws_joborderemployee.location_id = ar_location)
      and(hr.dbs_s_employe.out_time_analysis = 0 or hr.dbs_s_employe.out_time_analysis is null)
      and(hr.dbs_s_employe.emp_end_hir_date is null or hr.dbs_s_employe.emp_end_hir_date = '1900-01-01')
  // (Sold  FRU's Customer-C)
  elseif ar_kpi_code = 'sold_c_fru' then
    select sum(isnull(ws_catalogdetail.flatrate
      *(ws_joborderemployee.emppercent/100),0))*1
      into ret_value from ws_joborderemployee
        ,ws_operation
        ,ws_joborderdetail
        ,ws_catalogdetail
        ,ws_eqpt_category
        ,ws_eqpt
        ,ws_joborder
        ,ws_invoicetype
        ,hr.dbs_s_employe
      where(hr.dbs_s_employe.emp_code = ws_joborderemployee.employee_id)
      and(hr.dbs_s_employe.service_center = ws_joborderemployee.service_center)
      and(hr.dbs_s_employe.location_id = ws_joborderemployee.location_id)
      and(ws_joborderemployee.serviceid = ws_operation.opertationid)
      and(ws_joborderdetail.joborderid = ws_joborderemployee.joborderid)
      and(ws_joborderdetail.service_center = ws_joborderemployee.service_center)
      and(ws_joborderdetail.location_id = ws_joborderemployee.location_id)
      and(ws_joborderdetail.serviceid = ws_joborderemployee.serviceid)
      and(ws_catalogdetail.operationid = ws_operation.opertationid)
      and(ws_catalogdetail.catalogid = ws_eqpt_category.catalogid)
      and(ws_eqpt_category.category_id = ws_eqpt.category_id)
      and(ws_joborder.eqptid = ws_eqpt.eqpt_id)
      and(ws_joborder.joborderid = ws_joborderdetail.joborderid)
      and(ws_joborder.service_center = ws_joborderdetail.service_center)
      and(ws_joborder.location_id = ws_joborderdetail.location_id)
      and(ws_invoicetype.invoicetypeid = ws_joborderdetail.invoicetypeid)
      and(ws_invoicetype.chargable = 'Y')
      and(ws_joborderdetail.invoicetypeid <> 5)
      and(ws_operation.service_center = ws_joborderemployee.service_center)
      and(ws_catalogdetail.service_center = ws_operation.service_center)
      and(ws_catalogdetail.service_center = ws_eqpt_category.service_center)
      and(ws_invoicetype.service_center = ws_joborderdetail.service_center)
      and(year(ws_joborderemployee.workdate) = ar_year)
      and(month(ws_joborderemployee.workdate) = ar_month)
      and(ws_joborderemployee.service_center = ar_center)
      and(ws_joborderemployee.location_id = ar_location)
      and(hr.dbs_s_employe.out_time_analysis = 0 or hr.dbs_s_employe.out_time_analysis is null)
      and(hr.dbs_s_employe.emp_end_hir_date is null or hr.dbs_s_employe.emp_end_hir_date = '1900-01-01')
  //Sold FRU's Warranty-WTY
  elseif ar_kpi_code = 'sold_g_fru' then
    select sum(isnull(ws_catalogdetail.flatrate
      *(ws_joborderemployee.emppercent/100),0))*1
      into ret_value from ws_joborderemployee
        ,ws_operation
        ,ws_joborderdetail
        ,ws_catalogdetail
        ,ws_eqpt_category
        ,ws_eqpt
        ,ws_joborder
        ,hr.dbs_s_employe
      where(hr.dbs_s_employe.emp_code = ws_joborderemployee.employee_id)
      and(hr.dbs_s_employe.service_center = ws_joborderemployee.service_center)
      and(hr.dbs_s_employe.location_id = ws_joborderemployee.location_id)
      and(ws_joborderemployee.serviceid = ws_operation.opertationid)
      and(ws_joborderdetail.joborderid = ws_joborderemployee.joborderid)
      and(ws_joborderdetail.service_center = ws_joborderemployee.service_center)
      and(ws_joborderdetail.location_id = ws_joborderemployee.location_id)
      and(ws_joborderdetail.serviceid = ws_joborderemployee.serviceid)
      and(ws_catalogdetail.operationid = ws_operation.opertationid)
      and(ws_catalogdetail.catalogid = ws_eqpt_category.catalogid)
      and(ws_eqpt_category.category_id = ws_eqpt.category_id)
      and(ws_joborder.eqptid = ws_eqpt.eqpt_id)
      and(ws_joborder.joborderid = ws_joborderdetail.joborderid)
      and(ws_joborder.service_center = ws_joborderdetail.service_center)
      and(ws_joborder.location_id = ws_joborderdetail.location_id)
      and(ws_joborderdetail.invoicetypeid = 5)
      and(ws_operation.service_center = ws_joborderemployee.service_center)
      and(ws_catalogdetail.service_center = ws_operation.service_center)
      and(ws_catalogdetail.service_center = ws_eqpt_category.service_center)
      and(ws_operation.service_center = ws_joborderemployee.service_center)
      and(ws_catalogdetail.service_center = ws_operation.service_center)
      and(ws_catalogdetail.service_center = ws_eqpt_category.service_center)
      and(year(ws_joborderemployee.workdate) = ar_year)
      and(month(ws_joborderemployee.workdate) = ar_month)
      and(ws_joborderemployee.service_center = ar_center)
      and(ws_joborderemployee.location_id = ar_location)
      and(hr.dbs_s_employe.out_time_analysis = 0 or hr.dbs_s_employe.out_time_analysis is null)
      and(hr.dbs_s_employe.emp_end_hir_date is null or hr.dbs_s_employe.emp_end_hir_date = '1900-01-01')
  //---------------------------------------------------------------------------------
  //---------------------------------------------------------------------------------
  //all Working hrs 
  elseif ar_kpi_code = 'w_all_hrs' then
    select sum(isnull(ws_joborderemployee.timecalc,0))
      into ret_value from ws_joborderemployee,hr.dbs_s_employe
        ,ws_joborderdetail,employee_time_sheet
      where employee_time_sheet.working_date = ws_joborderemployee.workdate
      and employee_time_sheet.employee_code = ws_joborderemployee.employee_id
      and employee_time_sheet.service_center = ws_joborderemployee.service_center
      and employee_time_sheet.location_id = ws_joborderemployee.location_id
      and ws_joborderemployee.joborderid = ws_joborderdetail.joborderid
      and ws_joborderemployee.service_center = ws_joborderdetail.service_center
      and ws_joborderemployee.location_id = ws_joborderdetail.location_id
      and ws_joborderemployee.serviceid = ws_joborderdetail.serviceid
      and year(employee_time_sheet.working_date) = ar_year
      and Month(employee_time_sheet.working_date) = ar_month
      and employee_time_sheet.service_center = ar_center
      and employee_time_sheet.location_id = ar_location
      and(employee_time_sheet.employee_code = hr.dbs_s_employe.emp_code)
      and(employee_time_sheet.service_center = hr.dbs_s_employe.service_center)
      and(employee_time_sheet.location_id = hr.dbs_s_employe.location_id)
      and(hr.dbs_s_employe.out_time_analysis = 0 or hr.dbs_s_employe.out_time_analysis is null)
      and(hr.dbs_s_employe.emp_end_hir_date is null or hr.dbs_s_employe.emp_end_hir_date = '1900-01-01')
  //Working hrs Customer-C
  elseif ar_kpi_code = 'w_c_hrs' then
    select sum(isnull(ws_joborderemployee.timecalc,0))
      into ret_value from ws_joborderemployee
        ,ws_joborderdetail,hr.dbs_s_employe
        ,ws_invoicetype,employee_time_sheet
      where employee_time_sheet.working_date = ws_joborderemployee.workdate
      and employee_time_sheet.employee_code = ws_joborderemployee.employee_id
      and employee_time_sheet.service_center = ws_joborderemployee.service_center
      and employee_time_sheet.location_id = ws_joborderemployee.location_id
      and ws_joborderemployee.joborderid = ws_joborderdetail.joborderid
      and ws_joborderemployee.serviceid = ws_joborderdetail.serviceid
      and ws_joborderemployee.service_center = ws_joborderdetail.service_center
      and ws_joborderemployee.location_id = ws_joborderdetail.location_id
      and ws_invoicetype.invoicetypeid = ws_joborderdetail.invoicetypeid
      and ws_invoicetype.service_center = ws_joborderdetail.service_center
      and ws_invoicetype.chargable = 'Y'
      and ws_joborderdetail.invoicetypeid <> 5
      and year(employee_time_sheet.working_date) = ar_year
      and Month(employee_time_sheet.working_date) = ar_month
      and employee_time_sheet.service_center = ar_center
      and employee_time_sheet.location_id = ar_location
      and(employee_time_sheet.employee_code = hr.dbs_s_employe.emp_code)
      and(employee_time_sheet.service_center = hr.dbs_s_employe.service_center)
      and(employee_time_sheet.location_id = hr.dbs_s_employe.location_id)
      and(hr.dbs_s_employe.out_time_analysis = 0 or hr.dbs_s_employe.out_time_analysis is null)
      and(hr.dbs_s_employe.emp_end_hir_date is null or hr.dbs_s_employe.emp_end_hir_date = '1900-01-01')
  //Working hrs Warranty-WTY
  elseif ar_kpi_code = 'w_g_hrs' then
    select sum(isnull(ws_joborderemployee.timecalc,0))
      into ret_value from ws_joborderemployee,hr.dbs_s_employe
        ,ws_joborderdetail,employee_time_sheet
      where employee_time_sheet.working_date = ws_joborderemployee.workdate
      and employee_time_sheet.employee_code = ws_joborderemployee.employee_id
      and employee_time_sheet.service_center = ws_joborderemployee.service_center
      and employee_time_sheet.location_id = ws_joborderemployee.location_id
      and ws_joborderemployee.joborderid = ws_joborderdetail.joborderid
      and ws_joborderemployee.service_center = ws_joborderdetail.service_center
      and ws_joborderemployee.location_id = ws_joborderdetail.location_id
      and ws_joborderemployee.serviceid = ws_joborderdetail.serviceid
      and ws_joborderemployee.service_center = ws_joborderdetail.service_center
      and ws_joborderemployee.location_id = ws_joborderdetail.location_id
      and ws_joborderdetail.invoicetypeid = 5
      and year(employee_time_sheet.working_date) = ar_year
      and Month(employee_time_sheet.working_date) = ar_month
      and employee_time_sheet.service_center = ar_center
      and employee_time_sheet.location_id = ar_location
      and(employee_time_sheet.employee_code = hr.dbs_s_employe.emp_code)
      and(employee_time_sheet.service_center = hr.dbs_s_employe.service_center)
      and(employee_time_sheet.location_id = hr.dbs_s_employe.location_id)
      and(hr.dbs_s_employe.out_time_analysis = 0 or hr.dbs_s_employe.out_time_analysis is null)
      and(hr.dbs_s_employe.emp_end_hir_date is null or hr.dbs_s_employe.emp_end_hir_date = '1900-01-01')
  //----------------------------------------------------------------------------------------------------    
  //Total PaidHrs
  elseif ar_kpi_code = 'paid_hrs' then
    select
      (SUM(
      isnull(
      (case when(isnull(datediff(minute,employee_time_sheet.from_1,employee_time_sheet.to_1),
      0,datediff(minute,employee_time_sheet.from_1,employee_time_sheet.to_1))
      +isnull(datediff(minute,employee_time_sheet.from_2,employee_time_sheet.to_2),
      0,datediff(minute,employee_time_sheet.from_2,employee_time_sheet.to_2))
      +isnull(datediff(minute,employee_time_sheet.from_3,employee_time_sheet.to_3),
      0,datediff(minute,employee_time_sheet.from_3,employee_time_sheet.to_3))
      +isnull(datediff(minute,employee_time_sheet.from_4,employee_time_sheet.to_4),
      0,datediff(minute,employee_time_sheet.from_4,employee_time_sheet.to_4))
      +isnull(datediff(minute,employee_time_sheet.from_5,employee_time_sheet.to_5),
      0,datediff(minute,employee_time_sheet.from_5,employee_time_sheet.to_5))
      +isnull(datediff(minute,employee_time_sheet.from_6,employee_time_sheet.to_6),
      0,datediff(minute,employee_time_sheet.from_6,employee_time_sheet.to_6)))
       > 0 then
        (isnull(datediff(minute,employee_time_sheet.from_1,employee_time_sheet.to_1),
        0,datediff(minute,employee_time_sheet.from_1,employee_time_sheet.to_1))
        +isnull(datediff(minute,employee_time_sheet.from_2,employee_time_sheet.to_2),
        0,datediff(minute,employee_time_sheet.from_2,employee_time_sheet.to_2))
        +isnull(datediff(minute,employee_time_sheet.from_3,employee_time_sheet.to_3),
        0,datediff(minute,employee_time_sheet.from_3,employee_time_sheet.to_3))
        +isnull(datediff(minute,employee_time_sheet.from_4,employee_time_sheet.to_4),
        0,datediff(minute,employee_time_sheet.from_4,employee_time_sheet.to_4))
        +isnull(datediff(minute,employee_time_sheet.from_5,employee_time_sheet.to_5),
        0,datediff(minute,employee_time_sheet.from_5,employee_time_sheet.to_5))
        +isnull(datediff(minute,employee_time_sheet.from_6,employee_time_sheet.to_6),
        0,datediff(minute,employee_time_sheet.from_6,employee_time_sheet.to_6)))
      else(8*60)
      end),0)))/60
      into ret_value from employee_time_sheet,hr.dbs_s_employe
      where year(employee_time_sheet.working_date) = ar_year
      and Month(employee_time_sheet.working_date) = ar_month
      and employee_time_sheet.service_center = ar_center
      and employee_time_sheet.location_id = ar_location
      and(employee_time_sheet.employee_code = hr.dbs_s_employe.emp_code)
      and(employee_time_sheet.service_center = hr.dbs_s_employe.service_center)
      and(employee_time_sheet.location_id = hr.dbs_s_employe.location_id)
      and(hr.dbs_s_employe.out_time_analysis = 0 or hr.dbs_s_employe.out_time_analysis is null)
      and(hr.dbs_s_employe.emp_end_hir_date is null or hr.dbs_s_employe.emp_end_hir_date = '1900-01-01')
  //Total Overtime
  elseif ar_kpi_code = 'overtime_hrs' then
    select
      (SUM(
      isnull(
      max_departure(employee_time_sheet.employee_code,employee_time_sheet.working_date),
      0)))/60
      into ret_value from employee_time_sheet,hr.dbs_s_employe
      where(employee_time_sheet.employee_code = hr.dbs_s_employe.emp_code)
      and(employee_time_sheet.service_center = hr.dbs_s_employe.service_center)
      and(employee_time_sheet.location_id = hr.dbs_s_employe.location_id)
      and year(employee_time_sheet.working_date) = ar_year
      and Month(employee_time_sheet.working_date) = ar_month
      and employee_time_sheet.service_center = ar_center
      and employee_time_sheet.location_id = ar_location
      and(hr.dbs_s_employe.out_time_analysis = 0 or hr.dbs_s_employe.out_time_analysis is null)
      and(hr.dbs_s_employe.emp_end_hir_date is null or hr.dbs_s_employe.emp_end_hir_date = '1900-01-01')
  //----------------------------------------------------------------------------------
  //------------------------------------------------------------------------------------
  //CAR IN
  elseif ar_kpi_code = 'car_in_no' then
    select isnull(count(distinct ws_reception.EqptID),0)
      into ret_value from ws_reception
      where(isnull(ws_reception.deleteflag,'N') = 'N')
      and year(ws_reception.starttime) = ar_year
      and month(ws_reception.starttime) = ar_month
      and(ws_reception.service_center = ar_center)
      and(ws_reception.location_id = ar_location)
  //CAR OUT  
  elseif ar_kpi_code = 'car_out_no' then
    select isnull(count(distinct ws_joborder.EqptID),0)
      into ret_value from ws_joborder
      where(isnull(ws_JobOrder.deleteflag,'N') = 'N')
      and year(ws_joborder.out_date) = ar_year
      and month(ws_joborder.out_date) = ar_month
      and(ws_joborder.service_center = ar_center)
      and(ws_joborder.location_id = ar_location)
  //spareparts Cash sales
  elseif ar_kpi_code = 'parts_cust_sales' then
    select isnull(sum((isnull(ws_invoiceheader.itemprice,0))
      +isnull(ws_invoiceheader.oilprice,0)),0)
      into ret_value from ws_invoiceheader,ws_invoicetype
      where(ws_invoicetype.invoicetypeid = ws_invoiceheader.invoicetype)
      and(ws_invoicetype.service_center = ws_invoiceheader.service_center)
      and(ws_invoiceheader.joborder_id is null)
      and(ws_invoiceheader.invoice_nature <> 'R')
      and(ws_invoiceheader.status <> 'P')
      and(ws_invoicetype.chargable = 'Y')
      and(ws_invoicetype.category <> 5)
      and(isnull(ws_invoiceheader.deleteflag,'N') = 'N')
      and year(ws_invoiceheader.invoicedate) = ar_year
      and month(ws_invoiceheader.invoicedate) = ar_month
      and(ws_invoiceheader.service_center = ar_center)
      and(ws_invoiceheader.location_id = ar_location)
  //spareparts Workshop sales
  elseif ar_kpi_code = 'parts_WS_sales' then
    select isnull(sum((isnull(ws_invoiceheader.itemprice,0))
      +isnull(ws_invoiceheader.oilprice,0)+0),0)
      into ret_value from ws_invoiceheader,ws_invoicetype
      where(ws_invoiceheader.invoicetype = ws_invoicetype.invoicetypeid)
      and(ws_invoicetype.service_center = ws_invoiceheader.service_center)
      and(ws_invoiceheader.joborder_id is not null)
      and(ws_invoiceheader.status <> 'P')
      and(ws_invoicetype.chargable = 'Y')
      and(ws_invoicetype.category <> 5)
      and(isnull(ws_invoiceheader.deleteflag,'N') = 'N')
      and year(ws_invoiceheader.invoicedate) = ar_year
      and month(ws_invoiceheader.invoicedate) = ar_month
      and(ws_invoiceheader.service_center = ar_center)
      and(ws_invoiceheader.location_id = ar_location)
  //spareparts Warranty sales
  elseif ar_kpi_code = 'parts_wrty_sales' then
    select isnull(sum((isnull(ws_invoiceheader.itemprice,0))
      +isnull(ws_invoiceheader.oilprice,0)+0),0)
      into ret_value from ws_invoiceheader,ws_invoicetype
      where(ws_invoiceheader.invoicetype = ws_invoicetype.invoicetypeid)
      and(ws_invoicetype.service_center = ws_invoiceheader.service_center)
      and(ws_invoiceheader.status <> 'P')
      and(ws_invoicetype.category = 5)
      and(isnull(ws_invoiceheader.deleteflag,'N') = 'N')
      and year(ws_invoiceheader.invoicedate) = ar_year
      and month(ws_invoiceheader.invoicedate) = ar_month
      and(ws_invoiceheader.service_center = ar_center)
      and(ws_invoiceheader.location_id = ar_location)
  //out service Warranty sales
  elseif ar_kpi_code = 'outservice_wrty_sales' then
    select isnull(sum((isnull(ws_invoicedetail.price,0))),0)
      into ret_value from ws_invoiceheader,ws_invoicedetail,ws_invoicetype
      where(ws_invoiceheader.invoicetype = ws_invoicetype.invoicetypeid)
      and(ws_invoicetype.service_center = ws_invoiceheader.service_center)
      and(ws_invoicedetail.invoicetype = ws_invoiceheader.invoicetype)
      and(ws_invoicedetail.service_center = ws_invoiceheader.service_center)
      and(ws_invoicedetail.location_id = ws_invoiceheader.location_id)
      and(ws_invoicedetail.invoiceid = ws_invoiceheader.invoiceid)
      and(ws_invoiceheader.status <> 'P')
      and(ws_invoicetype.category = 5)
      and(ws_invoicedetail.flag = 'S')
      and(isnull(ws_invoiceheader.deleteflag,'N') = 'N')
      and year(ws_invoiceheader.invoicedate) = ar_year
      and month(ws_invoiceheader.invoicedate) = ar_month
      and(ws_invoiceheader.service_center = ar_center)
      and(ws_invoiceheader.location_id = ar_location)
  //out service Workshop sales
  elseif ar_kpi_code = 'outservice_WS_sales' then
    select isnull(sum(isnull(ws_invoicedetail.price,0)),0)
      into ret_value from ws_invoiceheader,ws_invoicetype,ws_invoicedetail
      where(ws_invoiceheader.invoicetype = ws_invoicetype.invoicetypeid)
      and(ws_invoicetype.service_center = ws_invoiceheader.service_center)
      and(ws_invoicedetail.invoicetype = ws_invoiceheader.invoicetype)
      and(ws_invoicedetail.invoiceid = ws_invoiceheader.invoiceid)
      and(ws_invoicedetail.service_center = ws_invoiceheader.service_center)
      and(ws_invoicedetail.location_id = ws_invoiceheader.location_id)
      and(ws_invoiceheader.joborder_id is not null)
      and(ws_invoiceheader.status <> 'P')
      and(ws_invoicetype.chargable = 'Y')
      and(ws_invoicetype.category <> 5)
      and(ws_invoicedetail.flag = 'S')
      and(isnull(ws_invoiceheader.deleteflag,'N') = 'N')
      and year(ws_invoiceheader.invoicedate) = ar_year
      and month(ws_invoiceheader.invoicedate) = ar_month
      and(ws_invoiceheader.service_center = ar_center)
      and(ws_invoiceheader.location_id = ar_location)
  //Labor Customer sales
  elseif ar_kpi_code = 'labor_cust_sales' then
    select isnull(sum(isnull(ws_invoiceheader.laborprice,0)),0)
      into ret_value from ws_invoiceheader,ws_invoicetype
      where(ws_invoiceheader.invoicetype = ws_invoicetype.invoicetypeid)
      and(ws_invoiceheader.service_center = ws_invoicetype.service_center)
      and(ws_invoiceheader.status <> 'P')
      and(ws_invoicetype.chargable = 'Y')
      and(ws_invoicetype.category <> 5)
      and(isnull(ws_invoiceheader.deleteflag,'N') = 'N')
      and year(ws_invoiceheader.invoicedate) = ar_year
      and month(ws_invoiceheader.invoicedate) = ar_month
      and(ws_invoiceheader.service_center = ar_center)
      and(ws_invoiceheader.location_id = ar_location)
  //Labor Customer sales   
  elseif ar_kpi_code = 'labor_wrty_sales' then
    select isnull(sum(isnull(ws_invoiceheader.laborprice,0)),0)
      into ret_value from ws_invoiceheader,ws_invoicetype
      where(ws_invoiceheader.invoicetype = ws_invoicetype.invoicetypeid)
      and(ws_invoiceheader.service_center = ws_invoicetype.service_center)
      and(ws_invoiceheader.status <> 'P')
      and(ws_invoicetype.category = 5)
      and(isnull(ws_invoiceheader.deleteflag,'N') = 'N')
      and year(ws_invoiceheader.invoicedate) = ar_year
      and month(ws_invoiceheader.invoicedate) = ar_month
      and(ws_invoiceheader.service_center = ar_center)
      and(ws_invoiceheader.location_id = ar_location)
  //
  elseif ar_kpi_code = 'DicountLabor' then
    select distinct sum((isnull(ws_invoiceheader.labordiscount,0)
      *isnull(ws_invoiceheader.laborprice,0))/100)
      into ret_value from ws_invoiceheader,ws_invoicetype
      where(ws_invoiceheader.joborder_id is not null)
      and(ws_invoiceheader.invoicetype = ws_invoicetype.invoicetypeid)
      and(ws_invoiceheader.service_center = ws_invoicetype.service_center)
      and(ws_invoiceheader.status <> 'P')
      and(ws_invoicetype.chargable = 'Y')
      and(ws_invoicetype.category <> 5)
      and(isnull(ws_invoiceheader.deleteflag,'N') = 'N')
      and year(ws_invoiceheader.invoicedate) = ar_year
      and month(ws_invoiceheader.invoicedate) = ar_month
      and(ws_invoiceheader.service_center = ar_center)
      and(ws_invoiceheader.location_id = ar_location)
  //
  elseif ar_kpi_code = 'DicountItem' then
    select distinct sum((isnull(ws_invoiceheader.itemdiscount,0)
      *isnull(ws_invoiceheader.itemprice,0))/100)
      into ret_value from ws_invoiceheader,ws_invoicetype
      where(ws_invoiceheader.invoicetype = ws_invoicetype.invoicetypeid)
      and(ws_invoiceheader.service_center = ws_invoicetype.service_center)
      and(ws_invoiceheader.status <> 'P')
      and(ws_invoicetype.chargable = 'Y')
      and(ws_invoicetype.category <> 5)
      and(isnull(ws_invoiceheader.deleteflag,'N') = 'N')
      and year(ws_invoiceheader.invoicedate) = ar_year
      and month(ws_invoiceheader.invoicedate) = ar_month
      and(ws_invoiceheader.service_center = ar_center)
      and(ws_invoiceheader.location_id = ar_location)
  //Collection
  elseif ar_kpi_code = 'collection' then
    select isnull(sum(isnull(ws_receipt.paidamount,0)),0)
      into ret_value from ws_receipt,ws_invoiceheader
      where ws_invoiceheader.service_center = ws_receipt.service_center
      and ws_invoiceheader.location_id = ws_receipt.location_id
      and ws_invoiceheader.invoiceno = ws_receipt.invoiceno
      and year(ws_invoiceheader.invoicedate) = ar_year
      and month(ws_invoiceheader.invoicedate) = ar_month
      and(ws_invoiceheader.service_center = ar_center)
      and(ws_invoiceheader.location_id = ar_location)
  end if;
  select isnull(ret_value,0) into ret_value;
  return ret_value
end
