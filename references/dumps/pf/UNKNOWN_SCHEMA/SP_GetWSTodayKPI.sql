-- PF: UNKNOWN_SCHEMA.SP_GetWSTodayKPI
-- proc_id: 427
-- generated_at: 2025-12-29T13:53:28.815Z

create procedure DBA.SP_GetWSTodayKPI( in @center integer default 1,in @location integer default 1,in @FDate date default today(),in @TDate date default today() ) 
/* RESULT( column_name column_type, ... ) */
-- add revenue kpis
begin
  select location_id,
    location_name_e,
    location_name_a,
    //No or Reservation 
    isnull((select count(reservationid) from ws_reservation
      where(isnull(ws_reservation.delete_flag,'N') = 'N')
      and(convert(date,reserve_date) >= @FDate and convert(date,reserve_date) <= @TDate)
      and(service_center = @center or @center = 0)
      and(location_id = ws_center_location.location_id)),0) as reservation_count,
    //No of Reception Order
    isnull((select count(receptionid) from ws_Reception
      where(isnull(ws_reception.deleteflag,'N') = 'N')
      and(convert(date,starttime) >= @FDate and convert(date,starttime) <= @TDate)
      and(service_center = @center or @center = 0)
      and(location_id = ws_center_location.location_id)),0) as reception_count,
    //No of new Car
    isnull((select count(receptionid) from ws_Reception
      where(isnull(ws_reception.deleteflag,'N') = 'N')
      and(convert(date,starttime) >= @FDate and convert(date,starttime) <= @TDate)
      and(service_center = @center or @center = 0)
      and(location_id = ws_center_location.location_id)
      and not ws_Reception.EqptID
       = any(select reception.EqptID from ws_Reception as reception where convert(date,reception.starttime) < @FDate)),0) as new_car,
    //CAR IN
    isnull((select count(receptionid) from ws_Reception
      where(isnull(ws_reception.deleteflag,'N') = 'N')
      and(convert(date,starttime) >= @FDate and convert(date,starttime) <= @TDate)
      and(service_center = @center or @center = 0)
      and(location_id = ws_center_location.location_id)),0) as car_in,
    //CAR OUT  
    isnull((select isnull(count(distinct ws_joborder.joborderid),0) from ws_joborder
      where(isnull(ws_JobOrder.deleteflag,'N') = 'N')
      and(convert(date,out_date) >= @FDate and convert(date,out_date) <= @TDate)
      and(ws_joborder.service_center = @center or @center = 0)
      and(ws_joborder.location_id = ws_center_location.location_id)),0) as car_out,
    //CAR Returned
    isnull((select count(receptionid) from ws_Reception
      where(isnull(ws_reception.deleteflag,'N') = 'N')
      and(ws_reception.ref_recptionid is not null and ws_reception.ref_recptionid <> '')
      and(convert(date,starttime) >= @FDate and convert(date,starttime) <= @TDate)
      and(service_center = @center or @center = 0)
      and(location_id = ws_center_location.location_id)),0) as car_returned,
    //CAR in WS
    isnull((select count(voucherid) from ws_JobOrder
      where(isnull(ws_JobOrder.deleteflag,'N') = 'N')
      and(ws_joborder.orderstatus <> 'C'
      or(ws_joborder.orderstatus = 'C' and ws_joborder.out_date is null))
      and(ws_joborder.service_center = @center or @center = 0)
      and(ws_joborder.location_id = ws_center_location.location_id)),0) as car_inWS,
    // Technicions Available
    isnull((select Count(employee_time_sheet.employee_code)
      from employee_time_sheet
      where(employee_time_sheet.working_date >= @FDate and employee_time_sheet.working_date <= @TDate)
      and(employee_time_sheet.service_center = @center or @center = 0)
      and(employee_time_sheet.location_id = ws_center_location.location_id)),0) as technicions_available,
    //Technicions waiting
    isnull((select Count(employee_time_sheet.employee_code)
      from employee_time_sheet
      where(employee_time_sheet.working_date >= @FDate and employee_time_sheet.working_date <= @TDate)
      and(employee_time_sheet.service_center = @center or @center = 0)
      and(employee_time_sheet.location_id = ws_center_location.location_id)
      and not employee_time_sheet.employee_code
       = any(select employee_id from DBA.ws_JobOrderEmployee
        where(workdate >= @FDate and workdate <= @TDate)
        and ws_JobOrderEmployee.status = 'O'
        and(ws_JobOrderEmployee.service_center = @center or @center = 0)
        and(ws_JobOrderEmployee.location_id = ws_center_location.location_id))),0) as technicions_waiting,
    //No. Of Technicions
    isnull((select Count(distinct employee_time_sheet.employee_code)
      from hr.dbs_s_employe
        ,employee_time_sheet
      where(employee_time_sheet.employee_code = hr.dbs_s_employe.emp_code)
      and(employee_time_sheet.service_center = hr.dbs_s_employe.service_center)
      and(employee_time_sheet.location_id = hr.dbs_s_employe.location_id)
      and((employee_time_sheet.working_date >= @FDate)
      and(employee_time_sheet.working_date <= @TDate))
      and(employee_time_sheet.service_center = @center or @center = 0)
      and(employee_time_sheet.location_id = ws_center_location.location_id)
      and(hr.dbs_s_employe.out_time_analysis = 0 or hr.dbs_s_employe.out_time_analysis is null)
      and(hr.dbs_s_employe.emp_end_hir_date is null or hr.dbs_s_employe.emp_end_hir_date = '1900-01-01')),0) as No_Technicians,
    //Attendence_Hours
    isnull(
    (select
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
      end),0))/60 from hr.dbs_s_employe
        ,employee_time_sheet
      where(employee_time_sheet.employee_code = hr.dbs_s_employe.emp_code)
      and(employee_time_sheet.service_center = hr.dbs_s_employe.service_center)
      and(employee_time_sheet.location_id = hr.dbs_s_employe.location_id)
      and((employee_time_sheet.working_date >= @FDate)
      and(employee_time_sheet.working_date <= @TDate))
      and(employee_time_sheet.service_center = @center or @center = 0)
      and(employee_time_sheet.location_id = ws_center_location.location_id)
      and(hr.dbs_s_employe.out_time_analysis = 0 or hr.dbs_s_employe.out_time_analysis is null)
      and(hr.dbs_s_employe.emp_end_hir_date is null or hr.dbs_s_employe.emp_end_hir_date = '1900-01-01')),0) as Attendence_Hours,
    //Diverted_Hours
    isnull((select SUM(isnull((select sum(isnull(employee_off_times.time_calc,0)) from employee_off_times where employee_time_sheet.employee_code = employee_off_times.emp_code and employee_time_sheet.working_date = employee_off_times.work_date and employee_time_sheet.service_center = employee_off_times.service_center and employee_time_sheet.location_id = employee_off_times.location_id and employee_off_times.case_reason = 'W10'),0))
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
      from hr.dbs_s_employe
        ,employee_time_sheet
      where(employee_time_sheet.employee_code = hr.dbs_s_employe.emp_code)
      and(employee_time_sheet.service_center = hr.dbs_s_employe.service_center)
      and(employee_time_sheet.location_id = hr.dbs_s_employe.location_id)
      and((employee_time_sheet.working_date >= @FDate)
      and(employee_time_sheet.working_date <= @TDate))
      and(employee_time_sheet.service_center = @center or @center = 0)
      and(employee_time_sheet.location_id = ws_center_location.location_id)
      and(hr.dbs_s_employe.out_time_analysis = 0 or hr.dbs_s_employe.out_time_analysis is null)
      and(hr.dbs_s_employe.emp_end_hir_date is null or hr.dbs_s_employe.emp_end_hir_date = '1900-01-01')),0) as Diverted_Hours,
    //Training_Hours
    isnull((select SUM(isnull((select sum(isnull(employee_off_times.time_calc,0)) from employee_off_times where employee_time_sheet.employee_code = employee_off_times.emp_code and employee_time_sheet.working_date = employee_off_times.work_date and employee_time_sheet.service_center = employee_off_times.service_center and employee_time_sheet.location_id = employee_off_times.location_id and employee_off_times.case_reason = 'W20'),0))
      +SUM(isnull((select sum(isnull(employee_off_times.time_calc,0)) from employee_off_times where employee_time_sheet.employee_code = employee_off_times.emp_code and employee_time_sheet.working_date = employee_off_times.work_date and employee_time_sheet.service_center = employee_off_times.service_center and employee_time_sheet.location_id = employee_off_times.location_id and employee_off_times.case_reason = 'W26'),0))
      from hr.dbs_s_employe
        ,employee_time_sheet
      where(employee_time_sheet.employee_code = hr.dbs_s_employe.emp_code)
      and(employee_time_sheet.service_center = hr.dbs_s_employe.service_center)
      and(employee_time_sheet.location_id = hr.dbs_s_employe.location_id)
      and((employee_time_sheet.working_date >= @FDate)
      and(employee_time_sheet.working_date <= @TDate))
      and(employee_time_sheet.service_center = @center or @center = 0)
      and(employee_time_sheet.location_id = ws_center_location.location_id)
      and(hr.dbs_s_employe.out_time_analysis = 0 or hr.dbs_s_employe.out_time_analysis is null)
      and(hr.dbs_s_employe.emp_end_hir_date is null or hr.dbs_s_employe.emp_end_hir_date = '1900-01-01')),0) as Training_Hours,
    //Camback_hours
    isnull((select SUM(isnull((select sum(isnull(employee_off_times.time_calc,0)) from employee_off_times where employee_time_sheet.employee_code = employee_off_times.emp_code and employee_time_sheet.working_date = employee_off_times.work_date and employee_time_sheet.service_center = employee_off_times.service_center and employee_time_sheet.location_id = employee_off_times.location_id and employee_off_times.case_reason = 'W13'),0))
      from hr.dbs_s_employe
        ,employee_time_sheet
      where(employee_time_sheet.employee_code = hr.dbs_s_employe.emp_code)
      and(employee_time_sheet.service_center = hr.dbs_s_employe.service_center)
      and(employee_time_sheet.location_id = hr.dbs_s_employe.location_id)
      and((employee_time_sheet.working_date >= YMD(year(@TDate),month(@TDate),1))
      and(employee_time_sheet.working_date <= @TDate))
      and(employee_time_sheet.service_center = @center or @center = 0)
      and(employee_time_sheet.location_id = ws_center_location.location_id)
      and(hr.dbs_s_employe.out_time_analysis = 0 or hr.dbs_s_employe.out_time_analysis is null)
      and(hr.dbs_s_employe.emp_end_hir_date is null or hr.dbs_s_employe.emp_end_hir_date = '1900-01-01')),0) as Camback_Hours,
    //Clocked_Hours
    isnull((select SUM(isnull(((select sum(isnull(ws_joborderemployee.timecalc,0)) from ws_joborderemployee,ws_joborderdetail where employee_time_sheet.working_date = ws_joborderemployee.workdate and employee_time_sheet.employee_code = ws_joborderemployee.employee_id and employee_time_sheet.service_center = ws_joborderemployee.service_center and employee_time_sheet.location_id = ws_joborderemployee.location_id and ws_joborderemployee.joborderid = ws_joborderdetail.joborderid and ws_joborderemployee.service_center = ws_joborderdetail.service_center and ws_joborderemployee.location_id = ws_joborderdetail.location_id and ws_joborderemployee.serviceid = ws_joborderdetail.serviceid)),0))
      from hr.dbs_s_employe
        ,employee_time_sheet
      where(employee_time_sheet.employee_code = hr.dbs_s_employe.emp_code)
      and(employee_time_sheet.service_center = hr.dbs_s_employe.service_center)
      and(employee_time_sheet.location_id = hr.dbs_s_employe.location_id)
      and((employee_time_sheet.working_date >= @FDate)
      and(employee_time_sheet.working_date <= @TDate))
      and(employee_time_sheet.service_center = @center or @center = 0)
      and(employee_time_sheet.location_id = ws_center_location.location_id)
      and(hr.dbs_s_employe.out_time_analysis = 0 or hr.dbs_s_employe.out_time_analysis is null)
      and(hr.dbs_s_employe.emp_end_hir_date is null or hr.dbs_s_employe.emp_end_hir_date = '1900-01-01')),0) as Clocked_Hours,
    //Sold_Hours
    isnull((select Sum((select sum(isnull(isnull(ws_joborderdetail.flatetime,0)*(isnull(ws_joborderemployee.emppercent,0)/100),0))*1 from ws_joborderemployee,ws_joborderdetail
        where(hr.dbs_s_employe.emp_code = ws_joborderemployee.employee_id) and(hr.dbs_s_employe.service_center = ws_joborderemployee.service_center)
        and(hr.dbs_s_employe.location_id = ws_joborderemployee.location_id) and(ws_joborderemployee.workdate = employee_time_sheet.working_date)
        and(ws_joborderemployee.service_center = employee_time_sheet.service_center) and(ws_joborderemployee.location_id = employee_time_sheet.location_id)
        and(ws_joborderdetail.joborderid = ws_joborderemployee.joborderid) and(ws_joborderdetail.service_center = ws_joborderemployee.service_center)
        and(ws_joborderdetail.location_id = ws_joborderemployee.location_id) and(ws_joborderdetail.serviceid = ws_joborderemployee.serviceid)))
      from hr.dbs_s_employe
        ,employee_time_sheet
      where(employee_time_sheet.employee_code = hr.dbs_s_employe.emp_code)
      and(employee_time_sheet.service_center = hr.dbs_s_employe.service_center)
      and(employee_time_sheet.location_id = hr.dbs_s_employe.location_id)
      and((employee_time_sheet.working_date >= @FDate)
      and(employee_time_sheet.working_date <= @TDate))
      and(employee_time_sheet.service_center = @center or @center = 0)
      and(employee_time_sheet.location_id = ws_center_location.location_id)
      and(hr.dbs_s_employe.out_time_analysis = 0 or hr.dbs_s_employe.out_time_analysis is null)
      and(hr.dbs_s_employe.emp_end_hir_date is null or hr.dbs_s_employe.emp_end_hir_date = '1900-01-01')),0) as Sold_Hours,
    //Available_Hours
    attendence_hours-diverted_hours as Available_Hours,
    //Efficiency
    (sold_hours/(case clocked_hours when 0 then 1 else clocked_hours end))*100 as Efficiency,
    //Utilization
    (clocked_hours/(case Available_Hours when 0 then 1 else Available_Hours end))*100 as Utilization,
    //Productivity
    (sold_hours/(case Available_Hours when 0 then 1 else Available_Hours end))*100 as Productivity,
    //-----------------------Labor Revenue------------------------------------------------------------------------
    //Labor Customer
    isnull((select Sum((case invoice_nature when 'R' then(ws_invoiceheader.laborprice-LaborDiscount_amount)*-1
      else ws_invoiceheader.laborprice-LaborDiscount_amount
      end)) from ws_invoiceheader,ws_invoicetype
      where(ws_invoiceheader.invoicetype = ws_invoicetype.invoicetypeid)
      and(ws_invoiceheader.service_center = ws_invoicetype.service_center)
      and(ws_invoiceheader.InvoiceDate >= @FDate and ws_invoiceheader.InvoiceDate <= @TDate)
      and(ws_invoiceheader.service_center = @center or @center = 0)
      and(ws_invoiceheader.location_id = ws_center_location.location_id)
      and(ws_invoicetype.category not in( 3,5 ) and ws_invoicetype.chargable = 'Y')),0) as labor_customer,
    //Labor Warranty
    isnull((select Sum((case invoice_nature when 'R' then(ws_invoiceheader.laborprice-LaborDiscount_amount)*-1
      else ws_invoiceheader.laborprice-LaborDiscount_amount
      end)) from ws_invoiceheader,ws_invoicetype
      where(ws_invoiceheader.invoicetype = ws_invoicetype.invoicetypeid)
      and(ws_invoiceheader.service_center = ws_invoicetype.service_center)
      and(ws_invoiceheader.InvoiceDate >= @FDate and ws_invoiceheader.InvoiceDate <= @TDate)
      and(ws_invoiceheader.service_center = @center or @center = 0)
      and(ws_invoiceheader.location_id = ws_center_location.location_id)
      and(ws_invoicetype.category = 5)),0) as labor_Warranty,
    //Labor P.D.I
    isnull((select Sum((case invoice_nature when 'R' then(ws_invoiceheader.laborprice-LaborDiscount_amount)*-1
      else ws_invoiceheader.laborprice-LaborDiscount_amount
      end)) from ws_invoiceheader,ws_invoicetype
      where(ws_invoiceheader.invoicetype = ws_invoicetype.invoicetypeid)
      and(ws_invoiceheader.service_center = ws_invoicetype.service_center)
      and(ws_invoiceheader.InvoiceDate >= @FDate and ws_invoiceheader.InvoiceDate <= @TDate)
      and(ws_invoiceheader.service_center = @center or @center = 0)
      and(ws_invoiceheader.location_id = ws_center_location.location_id)
      and(ws_invoicetype.category = 3)),0) as labor_pdi,
    //Labor Internal
    isnull((select Sum((case invoice_nature when 'R' then(ws_invoiceheader.laborprice-LaborDiscount_amount)*-1
      else ws_invoiceheader.laborprice-LaborDiscount_amount
      end)) from ws_invoiceheader,ws_invoicetype
      where(ws_invoiceheader.invoicetype = ws_invoicetype.invoicetypeid)
      and(ws_invoiceheader.service_center = ws_invoicetype.service_center)
      and(ws_invoiceheader.InvoiceDate >= @FDate and ws_invoiceheader.InvoiceDate <= @TDate)
      and(ws_invoiceheader.service_center = @center or @center = 0)
      and(ws_invoiceheader.location_id = ws_center_location.location_id)
      and(ws_invoicetype.category not in( 3,5 ) and ws_invoicetype.chargable = 'N')),0) as labor_internal,
    0 as labor_mechanical,
    0 as labor_Electrical,
    0 as labor_Body,
    0 as labor_Paint,
    0 as labor_PM,
    0 as labor_other, /*
//Labor mechanical
isnull((select Sum(ws_invoicedetail.price) from ws_invoicedetail,ws_invoiceheader
where(ws_invoicedetail.invoiceid = ws_invoiceheader.invoiceid)
and(ws_invoicedetail.InvoiceType = ws_invoiceheader.InvoiceType)
and(ws_invoicedetail.service_center = ws_invoiceheader.service_center)
and(ws_invoicedetail.location_id = ws_invoiceheader.location_id)
and(ws_invoiceheader.InvoiceDate >= @FDate and ws_invoiceheader.InvoiceDate <= @TDate)
and(ws_invoicedetail.flag = 'O') and(ws_invoicedetail.operationtype = 'M')
and(ws_invoiceheader.service_center = @center or @center = 0)
and(ws_invoiceheader.location_id = ws_center_location.location_id)),0) as labor_mechanical,
//Labor Electrical
isnull((select Sum(ws_invoicedetail.price) from ws_invoicedetail,ws_invoiceheader
where(ws_invoicedetail.invoiceid = ws_invoiceheader.invoiceid)
and(ws_invoicedetail.InvoiceType = ws_invoiceheader.InvoiceType)
and(ws_invoicedetail.service_center = ws_invoiceheader.service_center)
and(ws_invoicedetail.location_id = ws_invoiceheader.location_id)
and(ws_invoiceheader.InvoiceDate >= @FDate and ws_invoiceheader.InvoiceDate <= @TDate)
and(ws_invoicedetail.flag = 'O') and(ws_invoicedetail.operationtype = 'E')
and(ws_invoiceheader.service_center = @center or @center = 0)
and(ws_invoiceheader.location_id = ws_center_location.location_id)),0) as labor_Electrical,
//Labor Body
isnull((select Sum(ws_invoicedetail.price) from ws_invoicedetail,ws_invoiceheader
where(ws_invoicedetail.invoiceid = ws_invoiceheader.invoiceid)
and(ws_invoicedetail.InvoiceType = ws_invoiceheader.InvoiceType)
and(ws_invoicedetail.service_center = ws_invoiceheader.service_center)
and(ws_invoicedetail.location_id = ws_invoiceheader.location_id)
and(ws_invoiceheader.InvoiceDate >= @FDate and ws_invoiceheader.InvoiceDate <= @TDate)
and(ws_invoicedetail.flag = 'O') and(ws_invoicedetail.operationtype = 'B')
and(ws_invoiceheader.service_center = @center or @center = 0)
and(ws_invoiceheader.location_id = ws_center_location.location_id)),0) as labor_Body,
//Labor Paint
isnull((select Sum(ws_invoicedetail.price) from ws_invoicedetail,ws_invoiceheader
where(ws_invoicedetail.invoiceid = ws_invoiceheader.invoiceid)
and(ws_invoicedetail.InvoiceType = ws_invoiceheader.InvoiceType)
and(ws_invoicedetail.service_center = ws_invoiceheader.service_center)
and(ws_invoicedetail.location_id = ws_invoiceheader.location_id)
and(ws_invoiceheader.InvoiceDate >= @FDate and ws_invoiceheader.InvoiceDate <= @TDate)
and(ws_invoicedetail.flag = 'O') and(ws_invoicedetail.operationtype = 'P')
and(ws_invoiceheader.service_center = @center or @center = 0)
and(ws_invoiceheader.location_id = ws_center_location.location_id)),0) as labor_Paint,
//Labor service
isnull((select Sum(ws_invoicedetail.price) from ws_invoicedetail,ws_invoiceheader
where(ws_invoicedetail.invoiceid = ws_invoiceheader.invoiceid)
and(ws_invoicedetail.InvoiceType = ws_invoiceheader.InvoiceType)
and(ws_invoicedetail.service_center = ws_invoiceheader.service_center)
and(ws_invoicedetail.location_id = ws_invoiceheader.location_id)
and(ws_invoiceheader.InvoiceDate >= @FDate and ws_invoiceheader.InvoiceDate <= @TDate)
and(ws_invoicedetail.flag = 'O') and(ws_invoicedetail.operationtype = 'S')
and(ws_invoiceheader.service_center = @center or @center = 0)
and(ws_invoiceheader.location_id = ws_center_location.location_id)),0) as labor_PM,
//Labor other
isnull((select Sum(ws_invoicedetail.price) from ws_invoicedetail,ws_invoiceheader
where(ws_invoicedetail.invoiceid = ws_invoiceheader.invoiceid)
and(ws_invoicedetail.InvoiceType = ws_invoiceheader.InvoiceType)
and(ws_invoicedetail.service_center = ws_invoiceheader.service_center)
and(ws_invoicedetail.location_id = ws_invoiceheader.location_id)
and(ws_invoiceheader.InvoiceDate >= @FDate and ws_invoiceheader.InvoiceDate <= @TDate)
and(ws_invoicedetail.flag = 'O') and(ws_invoicedetail.operationtype in( 'R','O' ) )
and(ws_invoiceheader.service_center = @center or @center = 0)
and(ws_invoiceheader.location_id = ws_center_location.location_id)),0) as labor_other,
*/
    //-----------------------Item Revenue------------------------------------------------------------------------
    //WS Items
    isnull((select Sum((case invoice_nature when 'R' then
        (ws_invoiceheader.ItemPrice+ws_invoiceheader.OilPrice-(dicount_amount+OilDiscount_amount))*-1
      else(ws_invoiceheader.ItemPrice+ws_invoiceheader.OilPrice-(dicount_amount+OilDiscount_amount))
      end)) from ws_invoiceheader
      where(joborder_id is not null)
      and(ws_invoiceheader.InvoiceDate >= @FDate and ws_invoiceheader.InvoiceDate <= @TDate)
      and(ws_invoiceheader.service_center = @center or @center = 0)
      and(ws_invoiceheader.location_id = ws_center_location.location_id)),0) as ws_parts,
    //OverCounter /direct
    isnull((select Sum((case invoice_nature when 'R' then
        (ws_invoiceheader.ItemPrice+ws_invoiceheader.OilPrice-(dicount_amount+OilDiscount_amount))*-1
      else(ws_invoiceheader.ItemPrice+ws_invoiceheader.OilPrice-(dicount_amount+OilDiscount_amount))
      end)) from ws_invoiceheader
      where(joborder_id is null)
      and(ws_invoiceheader.InvoiceDate >= @FDate and ws_invoiceheader.InvoiceDate <= @TDate)
      and(ws_invoiceheader.service_center = @center or @center = 0)
      and(ws_invoiceheader.location_id = ws_center_location.location_id)),0) as direct_parts,
    0 as item_SP,
    0 as item_oil,
    0 as item_paint,
    0 as item_tires,
    0 as item_batteries,
    0 as item_other,
    /*
//SP
isnull((select Sum(ws_invoicedetail.qty*ws_invoicedetail.price) from ws_invoicedetail,ws_invoiceheader
where(ws_invoicedetail.invoiceid = ws_invoiceheader.invoiceid)
and(ws_invoicedetail.InvoiceType = ws_invoiceheader.InvoiceType)
and(ws_invoicedetail.service_center = ws_invoiceheader.service_center)
and(ws_invoicedetail.location_id = ws_invoiceheader.location_id)
and(ws_invoiceheader.InvoiceDate >= @FDate and ws_invoiceheader.InvoiceDate <= @TDate)
and(ws_invoicedetail.flag = 'I') and(ws_invoicedetail.ItemType = 'S')
and(ws_invoiceheader.service_center = @center or @center = 0)
and(ws_invoiceheader.location_id = ws_center_location.location_id)),0) as item_SP,
//OIL
isnull((select Sum(ws_invoicedetail.qty*ws_invoicedetail.price) from ws_invoicedetail,ws_invoiceheader
where(ws_invoicedetail.invoiceid = ws_invoiceheader.invoiceid)
and(ws_invoicedetail.InvoiceType = ws_invoiceheader.InvoiceType)
and(ws_invoicedetail.service_center = ws_invoiceheader.service_center)
and(ws_invoicedetail.location_id = ws_invoiceheader.location_id)
and(ws_invoiceheader.InvoiceDate >= @FDate and ws_invoiceheader.InvoiceDate <= @TDate)
and(ws_invoicedetail.flag = 'I') and(ws_invoicedetail.ItemType = 'O')
and(ws_invoiceheader.service_center = @center or @center = 0)
and(ws_invoiceheader.location_id = ws_center_location.location_id)),0) as item_oil,
//paint
isnull((select Sum(ws_invoicedetail.qty*ws_invoicedetail.price) from ws_invoicedetail,ws_invoiceheader
where(ws_invoicedetail.invoiceid = ws_invoiceheader.invoiceid)
and(ws_invoicedetail.InvoiceType = ws_invoiceheader.InvoiceType)
and(ws_invoicedetail.service_center = ws_invoiceheader.service_center)
and(ws_invoicedetail.location_id = ws_invoiceheader.location_id)
and(ws_invoiceheader.InvoiceDate >= @FDate and ws_invoiceheader.InvoiceDate <= @TDate)
and(ws_invoicedetail.flag = 'I') and(ws_invoicedetail.ItemType = 'P')
and(ws_invoiceheader.service_center = @center or @center = 0)
and(ws_invoiceheader.location_id = ws_center_location.location_id)),0) as item_paint,
//tires
isnull((select Sum(ws_invoicedetail.qty*ws_invoicedetail.price) from ws_invoicedetail,ws_invoiceheader
where(ws_invoicedetail.invoiceid = ws_invoiceheader.invoiceid)
and(ws_invoicedetail.InvoiceType = ws_invoiceheader.InvoiceType)
and(ws_invoicedetail.service_center = ws_invoiceheader.service_center)
and(ws_invoicedetail.location_id = ws_invoiceheader.location_id)
and(ws_invoiceheader.InvoiceDate >= @FDate and ws_invoiceheader.InvoiceDate <= @TDate)
and(ws_invoicedetail.flag = 'I') and(ws_invoicedetail.ItemType = 'T')
and(ws_invoiceheader.service_center = @center or @center = 0)
and(ws_invoiceheader.location_id = ws_center_location.location_id)),0) as item_tires,
//batteries
isnull((select Sum(ws_invoicedetail.qty*ws_invoicedetail.price) from ws_invoicedetail,ws_invoiceheader
where(ws_invoicedetail.invoiceid = ws_invoiceheader.invoiceid)
and(ws_invoicedetail.InvoiceType = ws_invoiceheader.InvoiceType)
and(ws_invoicedetail.service_center = ws_invoiceheader.service_center)
and(ws_invoicedetail.location_id = ws_invoiceheader.location_id)
and(ws_invoiceheader.InvoiceDate >= @FDate and ws_invoiceheader.InvoiceDate <= @TDate)
and(ws_invoicedetail.flag = 'I') and(ws_invoicedetail.ItemType = 'Y')
and(ws_invoiceheader.service_center = @center or @center = 0)
and(ws_invoiceheader.location_id = ws_center_location.location_id)),0) as item_batteries,
//other
isnull((select Sum(ws_invoicedetail.qty*ws_invoicedetail.price) from ws_invoicedetail,ws_invoiceheader
where(ws_invoicedetail.invoiceid = ws_invoiceheader.invoiceid)
and(ws_invoicedetail.InvoiceType = ws_invoiceheader.InvoiceType)
and(ws_invoicedetail.service_center = ws_invoiceheader.service_center)
and(ws_invoicedetail.location_id = ws_invoiceheader.location_id)
and(ws_invoiceheader.InvoiceDate >= @FDate and ws_invoiceheader.InvoiceDate <= @TDate)
and(ws_invoicedetail.flag = 'I') and(ws_invoicedetail.ItemType in( 'V','A','B' ) )
and(ws_invoiceheader.service_center = @center or @center = 0)
and(ws_invoiceheader.location_id = ws_center_location.location_id)),0) as item_other,
*/
    //Collection--------------------------------------------------------------------------------------
    Isnull((select sum(isnull(paymentAmount,0)) from ws_ReceiptDetail
      where(ws_ReceiptDetail.PaymentDate >= @FDate and ws_ReceiptDetail.PaymentDate <= @TDate)
      and(ws_ReceiptDetail.service_center = @center or @center = 0)
      and(ws_ReceiptDetail.main_location_id = ws_center_location.location_id)),0)
    +Isnull((select Sum(isnull(doc_tot,0)) from doc_son_rec
      where doc_son_rec.doc_type = 2 and doc_son_rec.doc_detail_type = 2
      and(doc_son_rec.doc_date >= @FDate and doc_son_rec.doc_date <= @TDate)
      and(doc_son_rec.service_center = @center or @center = 0)
      and(doc_son_rec.main_location_id = ws_center_location.location_id)),0)
    -Isnull((select Sum(isnull(doc_tot,0)) from doc_son_rec
      where doc_son_rec.doc_type = 1 and doc_son_rec.doc_detail_type = 2
      and(doc_son_rec.doc_date >= @FDate and doc_son_rec.doc_date <= @TDate)
      and(doc_son_rec.service_center = @center or @center = 0)
      and(doc_son_rec.main_location_id = ws_center_location.location_id)),0) as Collection,
    //Stock------------------------------------------------------------------------------------------
    //Lost sales
    isnull((select sum(isnull(required,0)*isnull(price,0)) from sc_lost_sales
      where(date_required >= @FDate and date_required <= @TDate)
      and(sc_lost_sales.service_center = @center or @center = 0)
      and(sc_lost_sales.location_id = ws_center_location.location_id)),0) as Total_Lost_Sales,
    //Budget--------------------------------------------------------------------------------------------
    //days_month
    isnull((select Sum(isnull(month_duration,30))
      from DBA.ws_transactions_budget
      where(ws_transactions_budget.budget_year = YEARS(@TDate))
      and(ws_transactions_budget.budget_month = MONTH(@TDate))
      and(ws_transactions_budget.service_center = @center or @center = 0)
      and(ws_transactions_budget.location_id = @location or @location = 0)),0) as month_duration, /*/(select count() from DBA.ws_center_location as loc
where(loc.location_id = @location or @location = 0))*/
    DATEDIFF(day,YMD(year(@TDate),month(@TDate),1),@TDate)+1 as no_days,
    (case when no_days > month_duration then month_duration else no_days end) as days_month,
    //days_year
    isnull((select Sum(isnull(month_duration,30))
      from ws_transactions_budget
      where(ws_transactions_budget.budget_year = YEARS(@TDate))
      and(ws_transactions_budget.budget_month <= MONTH(@TDate))
      and(ws_transactions_budget.service_center = @center or @center = 0)
      and(ws_transactions_budget.location_id = @location or @location = 0)),0) as month_duration_year, /*/(select count() from DBA.ws_center_location as loc
where(loc.location_id = @location or @location = 0))*/
    DATEDIFF(day,YMD(year(@TDate),1,1),@TDate)+1 as no_days_year,
    (case when no_days_year > month_duration_year then month_duration_year else no_days_year end) as days_year,
    //budget_car_in
    (select Sum(isnull(ws_transactions_budget.in_cars_number,0))
      from ws_transactions_budget
      where(ws_transactions_budget.budget_year = YEARS(@TDate))
      and(ws_transactions_budget.budget_month = MONTH(@TDate))
      and(ws_transactions_budget.service_center = @center or @center = 0)
      and(ws_transactions_budget.location_id = @location or @location = 0))
    *days_month as budget_car_in,
    //budget_car_in_year
    (select Sum(isnull(ws_transactions_budget.in_cars_number,0))
      from ws_transactions_budget
      where(ws_transactions_budget.budget_year = YEARS(@TDate))
      and(ws_transactions_budget.budget_month <= MONTH(@TDate))
      and(ws_transactions_budget.service_center = @center or @center = 0)
      and(ws_transactions_budget.location_id = @location or @location = 0))
    /MONTH(@TDate)*days_year as budget_car_in_year,
    //budget_labor
    (select Sum(isnull(ws_transactions_budget.labor_sales,0)+ISNULL(ws_transactions_budget.labor_warranty,0))
      from ws_transactions_budget
      where(ws_transactions_budget.budget_year = YEARS(@TDate))
      and(ws_transactions_budget.budget_month = MONTH(@TDate))
      and(ws_transactions_budget.service_center = @center or @center = 0)
      and(ws_transactions_budget.location_id = @location or @location = 0))
    *days_month as budget_labor,
    //budget_labor_year
    (select Sum(isnull(ws_transactions_budget.labor_sales,0)+ISNULL(ws_transactions_budget.labor_warranty,0))
      from ws_transactions_budget
      where(ws_transactions_budget.budget_year = YEARS(@TDate))
      and(ws_transactions_budget.budget_month <= MONTH(@TDate))
      and(ws_transactions_budget.service_center = @center or @center = 0)
      and(ws_transactions_budget.location_id = @location or @location = 0))
    /MONTH(@TDate)*days_year as budget_labor_year,
    //budget_spareparts_WS
    (select Sum(ISNULL(ws_transactions_budget.spareparts_workshop,0)+ISNULL(ws_transactions_budget.spareparts_warranty,0))
      from ws_transactions_budget
      where(ws_transactions_budget.budget_year = YEARS(@TDate))
      and(ws_transactions_budget.budget_month = MONTH(@TDate))
      and(ws_transactions_budget.service_center = @center or @center = 0)
      and(ws_transactions_budget.location_id = @location or @location = 0))
    *days_month as budget_spareparts_WS,
    //budget_spareparts_WS_year
    (select Sum(ISNULL(ws_transactions_budget.spareparts_workshop,0)+ISNULL(ws_transactions_budget.spareparts_warranty,0))
      from ws_transactions_budget
      where(ws_transactions_budget.budget_year = YEARS(@TDate))
      and(ws_transactions_budget.budget_month <= MONTH(@TDate))
      and(ws_transactions_budget.service_center = @center or @center = 0)
      and(ws_transactions_budget.location_id = @location or @location = 0))
    /MONTH(@TDate)*days_year as budget_spareparts_WS_year,
    //budget_spareparts_direct
    (select Sum(ISNULL(ws_transactions_budget.spareparts_sales,0))
      from ws_transactions_budget
      where(ws_transactions_budget.budget_year = YEARS(@TDate))
      and(ws_transactions_budget.budget_month = MONTH(@TDate))
      and(ws_transactions_budget.service_center = @center or @center = 0)
      and(ws_transactions_budget.location_id = @location or @location = 0))
    *days_month as budget_spareparts_direct,
    //budget_spareparts_direct_year
    (select Sum(ISNULL(ws_transactions_budget.spareparts_sales,0))
      from ws_transactions_budget
      where(ws_transactions_budget.budget_year = YEARS(@TDate))
      and(ws_transactions_budget.budget_month <= MONTH(@TDate))
      and(ws_transactions_budget.service_center = @center or @center = 0)
      and(ws_transactions_budget.location_id = @location or @location = 0))
    /MONTH(@TDate)*days_year as budget_spareparts_direct_year
    from ws_center_location
    where(location_id = @location or @location = 0)
end
