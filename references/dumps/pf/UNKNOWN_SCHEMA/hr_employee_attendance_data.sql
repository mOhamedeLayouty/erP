-- PF: UNKNOWN_SCHEMA.hr_employee_attendance_data
-- proc_id: 441
-- generated_at: 2025-12-29T13:53:28.819Z

create procedure /*****************************************/
hr.hr_employee_attendance_data( @as_emp_code varchar(30),@ad_date_from date,@ad_date_to date ) 
begin
  create table #temp_result(
    emp_code varchar(30) null,
    data_date date null,
    att_date date null,
    att_attended integer null,
    att_from time null,
    att_to time null,
    shift_from_time time null,
    shift_to_time time null,
    in_the_same_day char(1) null,
    rest_days char(1) null,
    permissions_from_time time null,
    permissions_to_time time null,
    vacation_type integer null,
    busi_trip char(1) null,
    );
  while @ad_date_from <= @ad_date_to loop
    insert into #temp_result values
      ( @as_emp_code,@ad_date_from,null,null,null,null,null,null,null,null,null,null,null,null ) ;
    update #temp_result set att_date = attendance.att_date,att_attended = attendance.attended,
      att_from = attendance.att_from,att_to = attendance.att_to from attendance
      where attendance.att_date = @ad_date_from and attendance.emp_code = @as_emp_code
      and #temp_result.data_date = @ad_date_from;
    update #temp_result set shift_from_time = hr_shifts.from_time,shift_to_time = hr_shifts.to_time,
      in_the_same_day = hr_shifts.in_the_same_day from hr_emp_shift,hr_shifts
      where hr_emp_shift.emp_code = @as_emp_code and hr_shifts.shift_id = hr_emp_shift.shift_id
      and #temp_result.data_date = @ad_date_from;
    if(select count(1) from daysoff where daysoff.emp_code = @as_emp_code) > 0 then
      if(select count(1) from daysoff where daysoff.emp_code = @as_emp_code and day_off = DOW(@ad_date_from)) >= 1 then
        update #temp_result set rest_days = 'Y' where #temp_result.data_date = @ad_date_from
      else
        update #temp_result set rest_days = 'N' where #temp_result.data_date = @ad_date_from
      end if
    else if(select count(1) from weekly_daysoff where day_off = DOW(@ad_date_from)) >= 1 then
        update #temp_result set rest_days = 'Y' where #temp_result.data_date = @ad_date_from
      else
        update #temp_result set rest_days = 'N' where #temp_result.data_date = @ad_date_from
      end if end if;
    update #temp_result set permissions_from_time = hr_permissions.from_time,permissions_to_time = hr_permissions.to_time from
      hr_permissions where hr_permissions.emp_code = @as_emp_code and hr_permissions.permission_date = @ad_date_from
      and #temp_result.data_date = @ad_date_from and hr_permissions.record_type = 'P';
    update #temp_result set vacation_type = emp_days_off.p_type from emp_days_off where emp_days_off.emp_code = @as_emp_code
      and(@ad_date_from between emp_days_off.from_date and emp_days_off.to_date)
      and emp_days_off.delete_flag <> 'Y' and #temp_result.data_date = @ad_date_from;
    if(select count(1) from business_trip where business_trip.emp_code = @as_emp_code
        and(@ad_date_from between business_trip.from_date and business_trip.to_date) and business_trip.delete_flag <> 'Y') >= 1 then
      update #temp_result set busi_trip = 'Y' where #temp_result.data_date = @ad_date_from
    else
      update #temp_result set busi_trip = 'N' where #temp_result.data_date = @ad_date_from
    end if;
    set @ad_date_from = dateadd(day,1,@ad_date_from)
  end loop;
  select * from #temp_result;
  drop table #temp_result
end --------------------------------
/*****************************************/
