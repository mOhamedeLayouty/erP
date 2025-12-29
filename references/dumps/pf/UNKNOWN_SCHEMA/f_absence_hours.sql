-- PF: UNKNOWN_SCHEMA.f_absence_hours
-- proc_id: 368
-- generated_at: 2025-12-29T13:53:28.798Z

create function dba.f_absence_hours( in an_type integer,in empcode char(30),in ad_date date ) 
returns decimal
begin
  declare l_hours decimal;
  declare l_start decimal;
  declare l_end decimal;
  declare l_num decimal;
  if an_type = 1 or an_type = 2 then //HR Existed
    select count(distinct hr.emp_days_off.p_serial) into l_hours from hr.emp_days_off where(hr.emp_days_off.emp_code = empcode) and(hr.emp_days_off.from_date <= ad_date) and(hr.emp_days_off.to_date >= ad_date) and(hr.emp_days_off.p_type = an_type)
  end if;
  if an_type = 17 then //Absence Without Permission
    select Count(distinct employee_time_sheet.employee_code)
      into l_hours from employee_time_sheet
      where(employee_time_sheet.working_date = ad_date)
      and(employee_time_sheet.employee_code = empcode)
      and(employee_time_sheet.absence_reason = 'W17')
  end if;
  if an_type = 21 then // Insted Of a Vacation Day
    select Count(distinct employee_time_sheet.employee_code)
      into l_hours from employee_time_sheet
      where(employee_time_sheet.working_date = ad_date)
      and(employee_time_sheet.employee_code = empcode)
      and(employee_time_sheet.absence_reason = 'W21')
  end if;
  if an_type = 18 then
    select Count(distinct employee_time_sheet.employee_code)
      into l_hours from employee_time_sheet
      where(employee_time_sheet.working_date = ad_date)
      and(employee_time_sheet.employee_code = empcode)
      and(employee_time_sheet.absence_reason = 'W18')
  end if;
  if an_type = 25 then
    select Count(distinct employee_time_sheet.employee_code)
      into l_hours from employee_time_sheet
      where(employee_time_sheet.working_date = ad_date)
      and(employee_time_sheet.employee_code = empcode)
      and(employee_time_sheet.absence_reason = 'W25')
  end if;
  if an_type = 27 then
    select Count(distinct employee_time_sheet.employee_code)
      into l_hours from employee_time_sheet
      where(employee_time_sheet.working_date = ad_date)
      and(employee_time_sheet.employee_code = empcode)
      and(employee_time_sheet.absence_reason = 'W27')
  end if;
  --  select my_val into l_start from about where code = 'job_start';
  --  select my_val into l_end from about where code = 'job_end';
  --  if l_start > 0 and l_end > 0 then
  --    set l_num=l_end-l_start
  -- end if;
  --  if l_num > 0 then
  --    set l_hours=l_hours*8.5 --l_num
  --  else
  set l_hours = l_hours*8.5;
  --  end if;
  return(l_hours)
end
