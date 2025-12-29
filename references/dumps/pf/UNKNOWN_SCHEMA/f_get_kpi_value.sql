-- PF: UNKNOWN_SCHEMA.f_get_kpi_value
-- proc_id: 398
-- generated_at: 2025-12-29T13:53:28.807Z

create function DBA.f_get_kpi_value( in ar_kpi_code char(20),in ar_year integer,in ar_month integer,in ar_center integer,in ar_location integer ) 
returns integer
begin
  declare ret_value integer;
  /* -----------------WS KPIs--------------------------------------------------------------------------*/
  /*---------------------------------------------------------------------------------------------------*/
  /*1-WS No or Reservation-----------------------------------------------------------------------------*/
  if ar_kpi_code = 'ws_reservation' then
    select count(reservationid) into ret_value from ws_reservation
      where(isnull(ws_reservation.delete_flag,'N') = 'N')
      and(service_center = ar_center and location_id = ar_location)
      and(year(reserve_date) = ar_year and month(reserve_date) = ar_month)
  /*2-WS No of Reception Order------------------------------------------------------------------------------*/
  elseif ar_kpi_code = 'ws_ro' then
    select count(receptionid) into ret_value from ws_Reception
      where(isnull(ws_reception.deleteflag,'N') = 'N')
      and(service_center = ar_center and location_id = ar_location)
      and(year(starttime) = ar_year and month(starttime) = ar_month)
  /*3-WS No of Job Order------------------------------------------------------------------------------------*/
  elseif ar_kpi_code = 'ws_jo' then
    select count(voucherid) into ret_value from ws_JobOrder
      where(isnull(ws_JobOrder.deleteflag,'N') = 'N')
      and(service_center = ar_center and location_id = ar_location)
      and(year(jobdate) = ar_year and month(jobdate) = ar_month)
  /*4-WS CAR IN----------------------------------------------------------------------------------------------*/
  elseif ar_kpi_code = 'ws_car_in' then
    select isnull(count(distinct ws_reception.EqptID),0)
      into ret_value from ws_reception
      where(isnull(ws_reception.deleteflag,'N') = 'N')
      and(ws_reception.service_center = ar_center and ws_reception.location_id = ar_location)
      and(year(ws_reception.starttime) = ar_year and month(ws_reception.starttime) = ar_month)
  /*5-WS CAR OUT----------------------------------------------------------------------------------------------*/
  elseif ar_kpi_code = 'ws_car_out' then
    select isnull(count(distinct ws_joborder.EqptID),0) into ret_value from ws_joborder
      where(isnull(ws_JobOrder.deleteflag,'N') = 'N')
      and(ws_joborder.service_center = ar_center and ws_joborder.location_id = ar_location)
      and(year(ws_joborder.out_date) = ar_year and month(ws_joborder.out_date) = ar_month)
  /*6-WS No of new Car----------------------------------------------------------------------------------------------*/
  elseif ar_kpi_code = 'ws_car_new' then
    select isnull(count(receptionid),0) into ret_value from ws_Reception
      where(isnull(ws_reception.deleteflag,'N') = 'N')
      and(service_center = ar_center and location_id = ar_location)
      and(year(starttime) = ar_year and month(starttime) = ar_month)
      and not ws_Reception.EqptID
       = any(select reception.EqptID from ws_Reception as reception
        where convert(date,reception.starttime) < YMD(ar_year,ar_month,1))
  /*7-WS CAR Returned----------------------------------------------------------------------------------------------*/
  elseif ar_kpi_code = 'ws_car_return' then
    select count(receptionid) into ret_value from ws_Reception
      where(isnull(ws_reception.deleteflag,'N') = 'N')
      and(ws_reception.ref_recptionid is not null and ws_reception.ref_recptionid <> '')
      and(service_center = ar_center and location_id = ar_location)
      and(year(starttime) = ar_year and month(starttime) = ar_month)
  /*8-WS CAR in WS----------------------------------------------------------------------------------------------*/
  elseif ar_kpi_code = 'ws_car_in_ws' then
    select count(voucherid) into ret_value from ws_JobOrder
      where(isnull(ws_JobOrder.deleteflag,'N') = 'N')
      and(ws_joborder.orderstatus <> 'C' or(ws_joborder.orderstatus = 'C' and ws_joborder.out_date is null))
      and(ws_joborder.service_center = ar_center and ws_joborder.location_id = ar_location)
  /*9-WS Technicians----------------------------------------------------------------------------------------*/
  elseif ar_kpi_code = 'ws_technician' then
    select Count(distinct employee_time_sheet.employee_code) into ret_value from hr.dbs_s_employe,employee_time_sheet
      where(employee_time_sheet.employee_code = hr.dbs_s_employe.emp_code)
      and(employee_time_sheet.service_center = hr.dbs_s_employe.service_center)
      and(employee_time_sheet.location_id = hr.dbs_s_employe.location_id)
      and(hr.dbs_s_employe.out_time_analysis = 0 or hr.dbs_s_employe.out_time_analysis is null)
      and(hr.dbs_s_employe.emp_end_hir_date is null or hr.dbs_s_employe.emp_end_hir_date = '1900-01-01')
      and(employee_time_sheet.service_center = ar_center and employee_time_sheet.location_id = ar_location)
      and(year(employee_time_sheet.working_date) = ar_year and month(employee_time_sheet.working_date) = ar_month)
  /*10-WS Attendence_Hours----------------------------------------------------------------------------------------*/
  elseif ar_kpi_code = 'ws_attendence_hours' then
    select
      SUM(
      isnull(
      (case when(isnull(datediff(minute,employee_time_sheet.from_1,employee_time_sheet.to_1),0,datediff(minute,employee_time_sheet.from_1,employee_time_sheet.to_1))
      +isnull(datediff(minute,employee_time_sheet.from_2,employee_time_sheet.to_2),0,datediff(minute,employee_time_sheet.from_2,employee_time_sheet.to_2))
      +isnull(datediff(minute,employee_time_sheet.from_3,employee_time_sheet.to_3),0,datediff(minute,employee_time_sheet.from_3,employee_time_sheet.to_3))
      +isnull(datediff(minute,employee_time_sheet.from_4,employee_time_sheet.to_4),0,datediff(minute,employee_time_sheet.from_4,employee_time_sheet.to_4))
      +isnull(datediff(minute,employee_time_sheet.from_5,employee_time_sheet.to_5),0,datediff(minute,employee_time_sheet.from_5,employee_time_sheet.to_5))
      +isnull(datediff(minute,employee_time_sheet.from_6,employee_time_sheet.to_6),0,datediff(minute,employee_time_sheet.from_6,employee_time_sheet.to_6)))
       > 0 then
        (isnull(datediff(minute,employee_time_sheet.from_1,employee_time_sheet.to_1),0,datediff(minute,employee_time_sheet.from_1,employee_time_sheet.to_1))
        +isnull(datediff(minute,employee_time_sheet.from_2,employee_time_sheet.to_2),0,datediff(minute,employee_time_sheet.from_2,employee_time_sheet.to_2))
        +isnull(datediff(minute,employee_time_sheet.from_3,employee_time_sheet.to_3),0,datediff(minute,employee_time_sheet.from_3,employee_time_sheet.to_3))
        +isnull(datediff(minute,employee_time_sheet.from_4,employee_time_sheet.to_4),0,datediff(minute,employee_time_sheet.from_4,employee_time_sheet.to_4))
        +isnull(datediff(minute,employee_time_sheet.from_5,employee_time_sheet.to_5),0,datediff(minute,employee_time_sheet.from_5,employee_time_sheet.to_5))
        +isnull(datediff(minute,employee_time_sheet.from_6,employee_time_sheet.to_6),0,datediff(minute,employee_time_sheet.from_6,employee_time_sheet.to_6)))
      else(8*60*0)
      end),0))/60 into ret_value from hr.dbs_s_employe,employee_time_sheet
      where(employee_time_sheet.employee_code = hr.dbs_s_employe.emp_code)
      and(employee_time_sheet.service_center = hr.dbs_s_employe.service_center)
      and(employee_time_sheet.location_id = hr.dbs_s_employe.location_id)
      and(hr.dbs_s_employe.out_time_analysis = 0 or hr.dbs_s_employe.out_time_analysis is null)
      and(hr.dbs_s_employe.emp_end_hir_date is null or hr.dbs_s_employe.emp_end_hir_date = '1900-01-01')
      and(employee_time_sheet.service_center = ar_center and employee_time_sheet.location_id = ar_location)
      and(year(employee_time_sheet.working_date) = ar_year and month(employee_time_sheet.working_date) = ar_month)
  /*11-WS Diverted_Hours----------------------------------------------------------------------------------------*/
  elseif ar_kpi_code = 'ws_diverted_hours' then
    select SUM(isnull((select sum(isnull(employee_off_times.time_calc,0))
        from employee_off_times
        where employee_time_sheet.employee_code = employee_off_times.emp_code
        and employee_time_sheet.working_date = employee_off_times.work_date
        and employee_time_sheet.service_center = employee_off_times.service_center
        and employee_time_sheet.location_id = employee_off_times.location_id and employee_off_times.case_reason = 'W10'),0))
      +SUM(isnull((select sum(isnull(ws_joborderemployee.timecalc,0)) from ws_joborderemployee where employee_time_sheet.working_date = ws_joborderemployee.workdate and employee_time_sheet.employee_code = ws_joborderemployee.employee_id and employee_time_sheet.service_center = ws_joborderemployee.service_center and employee_time_sheet.location_id = ws_joborderemployee.location_id and ws_joborderemployee.reason_id = 3),0))
      +SUM(isnull((select sum(isnull(ws_joborderemployee.timecalc,0)) from ws_joborderemployee where employee_time_sheet.working_date = ws_joborderemployee.workdate and employee_time_sheet.employee_code = ws_joborderemployee.employee_id and employee_time_sheet.service_center = ws_joborderemployee.service_center and employee_time_sheet.location_id = ws_joborderemployee.location_id and ws_joborderemployee.reason_id = 2),0))
      +SUM(isnull((select sum(isnull(employee_off_times.time_calc,0)) from employee_off_times where employee_time_sheet.employee_code = employee_off_times.emp_code and employee_time_sheet.working_date = employee_off_times.work_date and employee_time_sheet.service_center = employee_off_times.service_center and employee_time_sheet.location_id = employee_off_times.location_id and employee_off_times.case_reason = 'W13'),0))
      +SUM(isnull((select sum(isnull(employee_off_times.time_calc,0)) from employee_off_times where employee_time_sheet.employee_code = employee_off_times.emp_code and employee_time_sheet.working_date = employee_off_times.work_date and employee_time_sheet.service_center = employee_off_times.service_center and employee_time_sheet.location_id = employee_off_times.location_id and employee_off_times.case_reason = 'W15'),0))
      +SUM(isnull((select sum(isnull(employee_off_times.time_calc,0)) from employee_off_times where employee_time_sheet.employee_code = employee_off_times.emp_code and employee_time_sheet.working_date = employee_off_times.work_date and employee_time_sheet.service_center = employee_off_times.service_center and employee_time_sheet.location_id = employee_off_times.location_id and employee_off_times.case_reason = 'W20'),0))
      +SUM(isnull((select sum(isnull(employee_off_times.time_calc,0)) from employee_off_times where employee_time_sheet.employee_code = employee_off_times.emp_code and employee_time_sheet.working_date = employee_off_times.work_date and employee_time_sheet.service_center = employee_off_times.service_center and employee_time_sheet.location_id = employee_off_times.location_id and employee_off_times.case_reason = 'W26'),0))
      // +SUM(isnull(f_absence_hours(17,hr.dbs_s_employe.emp_code,employee_time_sheet.working_date),0)) 
      //+SUM(isnull(f_absence_hours(18,hr.dbs_s_employe.emp_code,employee_time_sheet.working_date),0))   
      // +SUM(isnull(f_absence_hours(21,hr.dbs_s_employe.emp_code,employee_time_sheet.working_date),0)) 
      // +SUM(isnull(f_absence_hours(25,hr.dbs_s_employe.emp_code,employee_time_sheet.working_date),0))  
      into ret_value from hr.dbs_s_employe,employee_time_sheet
      where(employee_time_sheet.employee_code = hr.dbs_s_employe.emp_code)
      and(employee_time_sheet.service_center = hr.dbs_s_employe.service_center)
      and(employee_time_sheet.location_id = hr.dbs_s_employe.location_id)
      and(hr.dbs_s_employe.out_time_analysis = 0 or hr.dbs_s_employe.out_time_analysis is null)
      and(hr.dbs_s_employe.emp_end_hir_date is null or hr.dbs_s_employe.emp_end_hir_date = '1900-01-01')
      and(employee_time_sheet.service_center = ar_center and employee_time_sheet.location_id = ar_location)
      and(year(employee_time_sheet.working_date) = ar_year and month(employee_time_sheet.working_date) = ar_month)
  /*12-WS Training_Hours----------------------------------------------------------------------------------------*/
  elseif ar_kpi_code = 'ws_training_hours' then
    select SUM(isnull((select sum(isnull(employee_off_times.time_calc,0)) from employee_off_times where employee_time_sheet.employee_code = employee_off_times.emp_code and employee_time_sheet.working_date = employee_off_times.work_date and employee_time_sheet.service_center = employee_off_times.service_center and employee_time_sheet.location_id = employee_off_times.location_id and employee_off_times.case_reason = 'W20'),0))
      +SUM(isnull((select sum(isnull(employee_off_times.time_calc,0)) from employee_off_times where employee_time_sheet.employee_code = employee_off_times.emp_code and employee_time_sheet.working_date = employee_off_times.work_date and employee_time_sheet.service_center = employee_off_times.service_center and employee_time_sheet.location_id = employee_off_times.location_id and employee_off_times.case_reason = 'W26'),0))
      into ret_value from hr.dbs_s_employe,employee_time_sheet
      where(employee_time_sheet.employee_code = hr.dbs_s_employe.emp_code)
      and(employee_time_sheet.service_center = hr.dbs_s_employe.service_center)
      and(employee_time_sheet.location_id = hr.dbs_s_employe.location_id)
      and(hr.dbs_s_employe.out_time_analysis = 0 or hr.dbs_s_employe.out_time_analysis is null)
      and(hr.dbs_s_employe.emp_end_hir_date is null or hr.dbs_s_employe.emp_end_hir_date = '1900-01-01')
      and(employee_time_sheet.service_center = ar_center and employee_time_sheet.location_id = ar_location)
      and(year(employee_time_sheet.working_date) = ar_year and month(employee_time_sheet.working_date) = ar_month)
  /*13-WS Camback_hours----------------------------------------------------------------------------------------*/
  elseif ar_kpi_code = 'ws_camback_hours' then
    select SUM(isnull((select sum(isnull(employee_off_times.time_calc,0)) from employee_off_times where employee_time_sheet.employee_code = employee_off_times.emp_code and employee_time_sheet.working_date = employee_off_times.work_date and employee_time_sheet.service_center = employee_off_times.service_center and employee_time_sheet.location_id = employee_off_times.location_id and employee_off_times.case_reason = 'W13'),0))
      into ret_value from hr.dbs_s_employe,employee_time_sheet
      where(employee_time_sheet.employee_code = hr.dbs_s_employe.emp_code)
      and(employee_time_sheet.service_center = hr.dbs_s_employe.service_center)
      and(employee_time_sheet.location_id = hr.dbs_s_employe.location_id)
      and(hr.dbs_s_employe.out_time_analysis = 0 or hr.dbs_s_employe.out_time_analysis is null)
      and(hr.dbs_s_employe.emp_end_hir_date is null or hr.dbs_s_employe.emp_end_hir_date = '1900-01-01')
      and(employee_time_sheet.service_center = ar_center and employee_time_sheet.location_id = ar_location)
      and(year(employee_time_sheet.working_date) = ar_year and month(employee_time_sheet.working_date) = ar_month)
  /*14-WS Clocked_Hours----------------------------------------------------------------------------------------*/
  elseif ar_kpi_code = 'ws_clocked_hours' then
    select SUM(isnull(((select sum(isnull(ws_joborderemployee.timecalc,0)) from ws_joborderemployee,ws_joborderdetail where employee_time_sheet.working_date = ws_joborderemployee.workdate and employee_time_sheet.employee_code = ws_joborderemployee.employee_id and employee_time_sheet.service_center = ws_joborderemployee.service_center and employee_time_sheet.location_id = ws_joborderemployee.location_id and ws_joborderemployee.joborderid = ws_joborderdetail.joborderid and ws_joborderemployee.service_center = ws_joborderdetail.service_center and ws_joborderemployee.location_id = ws_joborderdetail.location_id and ws_joborderemployee.serviceid = ws_joborderdetail.serviceid)),0))
      into ret_value from hr.dbs_s_employe,employee_time_sheet
      where(employee_time_sheet.employee_code = hr.dbs_s_employe.emp_code)
      and(employee_time_sheet.service_center = hr.dbs_s_employe.service_center)
      and(employee_time_sheet.location_id = hr.dbs_s_employe.location_id)
      and(hr.dbs_s_employe.out_time_analysis = 0 or hr.dbs_s_employe.out_time_analysis is null)
      and(hr.dbs_s_employe.emp_end_hir_date is null or hr.dbs_s_employe.emp_end_hir_date = '1900-01-01')
      and(employee_time_sheet.service_center = ar_center and employee_time_sheet.location_id = ar_location)
      and(year(employee_time_sheet.working_date) = ar_year and month(employee_time_sheet.working_date) = ar_month)
  /*15-WS Sold_Hours----------------------------------------------------------------------------------------*/
  elseif ar_kpi_code = 'ws_sold_hours' then
    select Sum((select sum(isnull(isnull(ws_joborderdetail.flatetime,0)*(isnull(ws_joborderemployee.emppercent,0)/100),0))*1 from ws_joborderemployee,ws_joborderdetail
        where(hr.dbs_s_employe.emp_code = ws_joborderemployee.employee_id) and(hr.dbs_s_employe.service_center = ws_joborderemployee.service_center)
        and(hr.dbs_s_employe.location_id = ws_joborderemployee.location_id) and(ws_joborderemployee.workdate = employee_time_sheet.working_date)
        and(ws_joborderemployee.service_center = employee_time_sheet.service_center) and(ws_joborderemployee.location_id = employee_time_sheet.location_id)
        and(ws_joborderdetail.joborderid = ws_joborderemployee.joborderid) and(ws_joborderdetail.service_center = ws_joborderemployee.service_center)
        and(ws_joborderdetail.location_id = ws_joborderemployee.location_id) and(ws_joborderdetail.serviceid = ws_joborderemployee.serviceid)))
      into ret_value from hr.dbs_s_employe,employee_time_sheet
      where(employee_time_sheet.employee_code = hr.dbs_s_employe.emp_code)
      and(employee_time_sheet.service_center = hr.dbs_s_employe.service_center)
      and(employee_time_sheet.location_id = hr.dbs_s_employe.location_id)
      and(hr.dbs_s_employe.out_time_analysis = 0 or hr.dbs_s_employe.out_time_analysis is null)
      and(hr.dbs_s_employe.emp_end_hir_date is null or hr.dbs_s_employe.emp_end_hir_date = '1900-01-01')
      and(employee_time_sheet.service_center = ar_center and employee_time_sheet.location_id = ar_location)
      and(year(employee_time_sheet.working_date) = ar_year and month(employee_time_sheet.working_date) = ar_month)
  /*16-WS Available_Hours-----------------------------------------------------------------------------------------*/
  elseif ar_kpi_code = 'ws_available_hours' then //= ws_attendence_hours - ws_diverted_hours
    select f_get_kpi_value('ws_attendence_hours',ar_year,ar_month,ar_center,ar_location)
      -f_get_kpi_value('ws_diverted_hours',ar_year,ar_month,ar_center,ar_location)
      /*Select Sum((case ar_month when 1 then m1 when 2 then m2 when 3 then m3 when 4 then m4 when 5 then m5 when 6 then m6
when 7 then m7 when 8 then m8 when 9 then m9 when 10 then m10 when 11 then m11 when 12 then m12 end)) into ret_value
From kpi_monthly_h where kpi_code='ws_attendence_hours' and year=ar_year and service_center=ar_center and location_id=ar_location*/
      /*17-WS Efficiency-----------------------------------------------------------------------------------------------*/
      //=(sold_hours/(case clocked_hours when 0 then 1 else clocked_hours end))*100 
      into ret_value
  elseif ar_kpi_code = 'ws_efficiency' then
    select(f_get_kpi_value('ws_sold_hours',ar_year,ar_month,ar_center,ar_location)
      /(case f_get_kpi_value('ws_clocked_hours',ar_year,ar_month,ar_center,ar_location) when 0 then 1
      else f_get_kpi_value('ws_clocked_hours',ar_year,ar_month,ar_center,ar_location)
      end))*100
      /*18-WS Utilization--------------------------------------------------------------------------------------------*/
      //=(clocked_hours/(case Available_Hours when 0 then 1 else Available_Hours end))*100
      into ret_value
  elseif ar_kpi_code = 'ws_utilization' then
    select(f_get_kpi_value('ws_clocked_hours',ar_year,ar_month,ar_center,ar_location)
      /(case f_get_kpi_value('ws_available_hours',ar_year,ar_month,ar_center,ar_location) when 0 then 1
      else f_get_kpi_value('ws_available_hours',ar_year,ar_month,ar_center,ar_location)
      end))*100
      /*19-WS Productivity---------------------------------------------------------------------------------------------*/
      //=(sold_hours/(case Available_Hours when 0 then 1 else Available_Hours end))*100
      into ret_value
  elseif ar_kpi_code = 'ws_productivity' then
    select(f_get_kpi_value('ws_sold_hours',ar_year,ar_month,ar_center,ar_location)
      /(case f_get_kpi_value('ws_available_hours',ar_year,ar_month,ar_center,ar_location) when 0 then 1
      else f_get_kpi_value('ws_available_hours',ar_year,ar_month,ar_center,ar_location)
      end))*100
      /*20-WS Labor Customer----------------------------------------------------------------------------------------*/
      into ret_value
  elseif ar_kpi_code = 'ws_labor_customer' then
    select Sum((case invoice_nature when 'R' then(ws_invoiceheader.laborprice-LaborDiscount_amount)*-1
      else ws_invoiceheader.laborprice-LaborDiscount_amount
      end)) into ret_value from ws_invoiceheader,ws_invoicetype
      where(ws_invoiceheader.invoicetype = ws_invoicetype.invoicetypeid)
      and(ws_invoiceheader.service_center = ws_invoicetype.service_center)
      and(ws_invoicetype.category not in( 3,5 ) and ws_invoicetype.chargable = 'Y')
      and(ws_invoiceheader.service_center = ar_center and ws_invoiceheader.location_id = ar_location)
      and(year(ws_invoiceheader.InvoiceDate) = ar_year and month(ws_invoiceheader.InvoiceDate) = ar_month)
  /*21-WS Labor Warranty----------------------------------------------------------------------------------------*/
  elseif ar_kpi_code = 'ws_labor_warranty' then
    select Sum((case invoice_nature when 'R' then(ws_invoiceheader.laborprice-LaborDiscount_amount)*-1
      else ws_invoiceheader.laborprice-LaborDiscount_amount
      end)) into ret_value from ws_invoiceheader,ws_invoicetype
      where(ws_invoiceheader.invoicetype = ws_invoicetype.invoicetypeid)
      and(ws_invoiceheader.service_center = ws_invoicetype.service_center)
      and(ws_invoicetype.category = 5)
      and(ws_invoiceheader.service_center = ar_center and ws_invoiceheader.location_id = ar_location)
      and(year(ws_invoiceheader.InvoiceDate) = ar_year and month(ws_invoiceheader.InvoiceDate) = ar_month)
  /*22-WS Labor P.D.I----------------------------------------------------------------------------------------*/
  elseif ar_kpi_code = 'ws_labor_pdi' then
    select Sum((case invoice_nature when 'R' then(ws_invoiceheader.laborprice-LaborDiscount_amount)*-1
      else ws_invoiceheader.laborprice-LaborDiscount_amount
      end)) into ret_value from ws_invoiceheader,ws_invoicetype
      where(ws_invoiceheader.invoicetype = ws_invoicetype.invoicetypeid)
      and(ws_invoiceheader.service_center = ws_invoicetype.service_center)
      and(ws_invoicetype.category = 3)
      and(ws_invoiceheader.service_center = ar_center and ws_invoiceheader.location_id = ar_location)
      and(year(ws_invoiceheader.InvoiceDate) = ar_year and month(ws_invoiceheader.InvoiceDate) = ar_month)
  /*23-WS Labor Internal----------------------------------------------------------------------------------------*/
  elseif ar_kpi_code = 'ws_labor_internal' then
    select Sum((case invoice_nature when 'R' then(ws_invoiceheader.laborprice-LaborDiscount_amount)*-1
      else ws_invoiceheader.laborprice-LaborDiscount_amount
      end)) into ret_value from ws_invoiceheader,ws_invoicetype
      where(ws_invoiceheader.invoicetype = ws_invoicetype.invoicetypeid)
      and(ws_invoiceheader.service_center = ws_invoicetype.service_center)
      and(ws_invoicetype.category not in( 3,5 ) and ws_invoicetype.chargable = 'N')
      and(ws_invoiceheader.service_center = ar_center and ws_invoiceheader.location_id = ar_location)
      and(year(ws_invoiceheader.InvoiceDate) = ar_year and month(ws_invoiceheader.InvoiceDate) = ar_month)
  /*-----------------------------STOCK-------------------------------------------------------------------------*/
  /*----------------------------------------------------------------------------------------------------------*/
  /*24-Items WS Sales---------------------------------------------------------------------------------*/
  elseif ar_kpi_code = 'sc_ws_sales' then
    select Sum((case invoice_nature when 'R' then
        (ws_invoiceheader.ItemPrice+ws_invoiceheader.OilPrice-(dicount_amount+OilDiscount_amount))*-1
      else(ws_invoiceheader.ItemPrice+ws_invoiceheader.OilPrice-(dicount_amount+OilDiscount_amount))
      end)) into ret_value from ws_invoiceheader
      where(joborder_id is not null)
      and(ws_invoiceheader.service_center = ar_center and ws_invoiceheader.location_id = ar_location)
      and(year(ws_invoiceheader.InvoiceDate) = ar_year and month(ws_invoiceheader.InvoiceDate) = ar_month)
  /*25-Items direct Sales---------------------------------------------------------------------------------*/
  elseif ar_kpi_code = 'sc_direct_sales' then
    select Sum((case invoice_nature when 'R' then
        (ws_invoiceheader.ItemPrice+ws_invoiceheader.OilPrice-(dicount_amount+OilDiscount_amount))*-1
      else(ws_invoiceheader.ItemPrice+ws_invoiceheader.OilPrice-(dicount_amount+OilDiscount_amount))
      end)) into ret_value from ws_invoiceheader
      where(joborder_id is null)
      and(ws_invoiceheader.service_center = ar_center and ws_invoiceheader.location_id = ar_location)
      and(year(ws_invoiceheader.InvoiceDate) = ar_year and month(ws_invoiceheader.InvoiceDate) = ar_month)
  /*26-Items Lost sales---------------------------------------------------------------------------------*/
  elseif ar_kpi_code = 'sc_lost_sales' then
    select sum(isnull(required,0)*isnull(price,0))
      into ret_value from sc_lost_sales
      where(sc_lost_sales.service_center = ar_center and sc_lost_sales.location_id = ar_location)
      and(year(date_required) = ar_year and month(date_required) = ar_month)
  /*27-Parts Stock Value-------------------------------------------------------------------------------------------*/
  elseif ar_kpi_code = 'sc_stock_value' then
    select sum(price*balance) into ret_value from sc_balance where service_center = ar_center and location_id = ar_location
  /*28-Active Parts Stock Value-------------------------------------------------------------------------------------------*/
  elseif ar_kpi_code = 'sc_active_stock_value' then
    select sum(price*balance) into ret_value from sc_balance
      where service_center = ar_center and location_id = ar_location
      and sc_balance.item_id = any(select sc_debit_detail.item_id from sc_debit_detail,sc_debit_header
        where(sc_debit_detail.debit_header = sc_debit_header.debit_header)
        and(sc_debit_detail.service_center = sc_debit_header.service_center)
        and(sc_debit_detail.location_id = sc_debit_header.location_id)
        and(sc_debit_header.debit_date >= dateadd(month,24,today()))
        and(sc_debit_detail.item_id = sc_balance.item_id)
        and(sc_debit_detail.service_center = sc_balance.service_center))
  /*27-Total Collection--------------------------------------------------------------------------------------*/
  elseif ar_kpi_code = 'collection' then
    select isnull((select sum(isnull(paymentAmount,0)) from ws_ReceiptDetail
        where(ws_ReceiptDetail.service_center = ar_center and ws_ReceiptDetail.main_location_id = ar_location)
        and(year(ws_ReceiptDetail.PaymentDate) = ar_year and month(ws_ReceiptDetail.PaymentDate) = ar_month)),0)
      +Isnull((select Sum(isnull(doc_tot,0)) from doc_son_rec
        where(doc_son_rec.doc_type = 2 and doc_son_rec.doc_detail_type = 2)
        and(doc_son_rec.service_center = ar_center and doc_son_rec.main_location_id = ar_location)
        and(year(doc_son_rec.doc_date) = ar_year and month(doc_son_rec.doc_date) = ar_month)),0)
      -Isnull((select Sum(isnull(doc_tot,0)) from doc_son_rec
        where(doc_son_rec.doc_type = 1 and doc_son_rec.doc_detail_type = 2)
        and(doc_son_rec.service_center = ar_center and doc_son_rec.main_location_id = ar_location)
        and(year(doc_son_rec.doc_date) = ar_year and month(doc_son_rec.doc_date) = ar_month)),0)
      into ret_value end if;
  select isnull(ret_value,0) into ret_value;
  return ret_value
end
