-- PF: UNKNOWN_SCHEMA.f_get_emp_time
-- proc_id: 409
-- generated_at: 2025-12-29T13:53:28.810Z

create function HR.f_get_emp_time( in as_empcode varchar(30),in ad_date date,in req_type varchar(10) )  /* [IN] parameter_name parameter_type [DEFAULT default_value], ... */
returns time
deterministic
--Ver 2.0 sub from late if there are permission(P,M) for employee
--Ver 3.0 add flexible time ,split Mission and Permissin as MS ,PR
--Ver 3.1 handling more mission/PR in same day
--Ver 3.2 Working Time & negative end handling if there are Mission
--Ver 3.3 add condition if Working Time & Case Of 1/2 1/4 day  < 0 
--Ver 3.4 add condition if Working Time & Case Of 1/2 1/4 day negative_end_of_day < 0
--Ver 3.5 add condition attended_from,attended_to equal permission_from,permission_to
--ver 3.6 add confirm approve mission and permission  a
--ver 3.7 add business_trip to WT ( not in weekend)
--ver 3.8 modify attended_from,attended_to (in case isnull(attended_from),isnull(attended_to))
--ver 3.9 add ramadan_flexible_minutes 
--ver 4.0 add day_start_std , day_end_std
--Ver 4.1 change empcode parameter name to as_empcode
--Ver 4.3 add and calculate shift 2
--Ver 4 edit calculate EarlyOut if there is 1/4 or 1/2 off_day.4 
--Ver 4.5 error in business trip calc
--Ver 4.6 handling permission error (double value)
begin
  declare return_val time;
  declare day_start time;
  declare day_end time;
  declare day_start_std time;
  declare day_end_std time;
  declare attended_from time;
  declare attended_to time;
  declare permission_from time;
  declare permission_to time;
  declare permission_type varchar(10);
  declare overtime_morning integer;
  declare overtime_end_of_day integer;
  declare negative_morning integer;
  declare negative_end_of_day integer;
  declare exclude_day_n varchar(30);
  declare temp_val varchar(255);
  declare hours_val integer;
  declare minutes_val integer;
  declare tmp integer;
  declare tmp_trip integer;
  declare weekDayOf integer;
  declare holidayDayOf integer;
  declare h varchar(2);
  declare m varchar(2);
  declare ldc_num decimal(3,2);
  declare ls_VacLessType varchar(2);
  declare half_day time;
  declare quarter_day time;
  declare sub_day time;
  declare minutes_var integer;
  declare minutes_tmp integer;
  declare exitwithoutperm integer;
  declare NotAssiginedCard integer;
  declare allow_minuts integer;
  declare @flexible_minutes integer;
  declare ramadan_flexible_minutes integer;
  declare ramadan_start_date date;
  declare ramadan_end_date date;
  declare ramadan_start_time time;
  declare ramadan_end_time time;
  declare ret_emp_sex varchar(1);
  declare allow_flexible_time varchar(1);
  declare start_permission time;
  declare end_permission time;
  declare return_val2 time;
  declare day_start2 time;
  declare day_end2 time;
  declare day_start_std2 time;
  declare day_end_std2 time;
  declare attended_from2 time;
  declare attended_to2 time;
  declare permission_from2 time;
  declare permission_to2 time;
  declare permission_type2 varchar(10);
  declare overtime_morning2 integer;
  declare overtime_end_of_day2 integer;
  declare negative_morning2 integer;
  declare negative_end_of_day2 integer;
  declare exclude_day_n2 varchar(30);
  declare temp_val2 varchar(255);
  declare hours_val2 integer;
  declare minutes_val2 integer;
  declare tmp2 integer;
  declare tmp_trip2 integer;
  declare weekDayOf2 integer;
  declare holidayDayOf2 integer;
  declare h2 varchar(2);
  declare m2 varchar(2);
  declare ldc_num2 decimal(3,2);
  declare ls_VacLessType2 varchar(2);
  declare half_day2 time;
  declare quarter_day2 time;
  declare sub_day2 time;
  declare minutes_var2 integer;
  declare minutes_tmp2 integer;
  declare exitwithoutperm2 integer;
  declare NotAssiginedCard2 integer;
  declare allow_minuts2 integer;
  declare @flexible_minutes2 integer;
  declare ramadan_flexible_minutes2 integer;
  declare ramadan_start_date2 date;
  declare ramadan_end_date2 date;
  declare ramadan_start_time2 time;
  declare ramadan_end_time2 time;
  declare ret_emp_sex2 varchar(1);
  declare allow_flexible_time2 varchar(1);
  declare start_permission2 time;
  declare end_permission2 time;
  //
  set overtime_morning = 0;
  set overtime_end_of_day = 0;
  set negative_morning = 0;
  set negative_end_of_day = 0;
  set tmp = 0;
  set tmp_trip = 0;
  set weekDayOf = 0;
  //
  //
  set overtime_morning2 = 0;
  set overtime_end_of_day2 = 0;
  set negative_morning2 = 0;
  set negative_end_of_day2 = 0;
  set tmp2 = 0;
  set tmp_trip2 = 0;
  set weekDayOf2 = 0;
  //
  select attendance.att_from,attendance.att_to into attended_from,attended_to
    from attendance where attendance.emp_code = as_empcode and attendance.att_date = ad_date and attendance.attended = 1;
  select count() into tmp_trip from business_trip where business_trip.emp_code = as_empcode
    and ad_date between business_trip.from_date and business_trip.to_date
    and business_trip.delete_flag = 'N' and business_trip.approved = 1
    and not DOW(ad_date) = any(select day_off from weekly_daysoff);
  select isnull(dbs_s_employe.emp_sex,'M') into ret_emp_sex from dbs_s_employe where dbs_s_employe.emp_code = as_empcode;
  //----------------- 
  if attended_from is null then
    select hr_permissions.from_time
      into attended_from from HR.hr_permissions where hr_permissions.emp_code = as_empcode and hr_permissions.permission_date = ad_date and request_status = 'A' and record_type in( 'M' ) 
  end if;
  if attended_to is null then
    select hr_permissions.to_time
      into attended_to from HR.hr_permissions where hr_permissions.emp_code = as_empcode and hr_permissions.permission_date = ad_date and request_status = 'A' and record_type in( 'M' ) 
  end if;
  //---------------------------------------------------------------------------------------------------------------------    
  select 1 into weekDayOf from weekly_daysoff where day_off = DOW(ad_date);
  select 1 into holidayDayOf from holidays,holidays_dates where holidays.holiday_code = holidays_dates.holiday_description
    and holidays_dates.holiday_year = year(ad_date) and holidays_dates.holiday_date = ad_date;
  //Shift from
  select from_time,flexible_minutes into day_start,@flexible_minutes from hr_shifts,hr_emp_shift where hr_emp_shift.shift_id = hr_shifts.shift_id and hr_emp_shift.emp_code = as_empcode;
  if day_start is null then
    select convert(time,my_val) into day_start from about where code = 'job_start'
  end if;
  //Shift To  
  select to_time into day_end from hr_shifts,hr_emp_shift where hr_emp_shift.shift_id = hr_shifts.shift_id and hr_emp_shift.emp_code = as_empcode;
  if day_end is null then
    select convert(time,my_val) into day_end from about where code = 'job_end'
  end if;
  //----Ramadan Data-------------------------------------------------------------------------------------
  select convert(date,my_val) into ramadan_start_date from dba.about where code = 'hr_ramadan_start_date';
  select convert(date,my_val) into ramadan_end_date from dba.about where code = 'hr_ramadan_end_date';
  select convert(integer,my_val) into ramadan_flexible_minutes from dba.about where code = 'hr_ramadan_flexible_minutes';
  if ret_emp_sex = 'M' then
    select convert(time,my_val) into ramadan_start_time from dba.about where code = 'hr_ramadan_start_time_mens';
    select convert(time,my_val) into ramadan_end_time from dba.about where code = 'hr_ramadan_end_time_mens'
  else
    select convert(time,my_val) into ramadan_start_time from dba.about where code = 'hr_ramadan_start_time_womens';
    select convert(time,my_val) into ramadan_end_time from dba.about where code = 'hr_ramadan_end_time_womens'
  end if;
  ---------------------------------------------------------------------------------------------------------
  if ad_date between ramadan_start_date and ramadan_end_date then
    set day_start = ramadan_start_time;
    set day_end = ramadan_end_time;
    set @flexible_minutes = ramadan_flexible_minutes
  end if;
  ---------------------------------------------
  set day_start_std = day_start;
  set day_end_std = day_end;
  //allowing time in morninig & Flexible Time---------------------------------------------------
  select convert(integer,isnull(my_val,'0')) into allow_minuts from dba.about where code = 'hr_start_calc_late_after';
  if allow_minuts > 0 then
    set day_start = cast(dateadd(minute,allow_minuts,day_start) as time)
  end if;
  select isnull(my_val,'N') into allow_flexible_time from dba.about where code = 'hr_allow_flexible_time';
  if allow_flexible_time = 'Y' and @flexible_minutes > 0 then
    set minutes_tmp = isnull(DATEDIFF(minute,day_start,attended_from),0);
    if minutes_tmp > @flexible_minutes then
      set day_end = cast(dateadd(minute,@flexible_minutes,day_end) as time)
    else
      set day_end = cast(dateadd(minute,minutes_tmp,day_end) as time)
    end if;
    set day_start = cast(dateadd(minute,@flexible_minutes,day_start) as time)
  end if;
  //special day with start and end time--------------------------------------------------------------------
  select my_val into exclude_day_n from about where code = 'exclude_day_n';
  if exclude_day_n is not null then
    if convert(integer,exclude_day_n) = DOW(ad_date) then
      select my_val into temp_val from about where code = 'exclude_job_s';
      if temp_val is not null then
        set day_start = convert(time,temp_val)
      end if;
      select my_val into temp_val from about where code = 'exclude_job_e';
      if temp_val is not null then
        set day_end = convert(time,temp_val)
      end if end if end if;
  //Over Time-------------------------------------------------------------------------------------------------------------
  select top 1 hr_permissions.from_time,hr_permissions.to_time into start_permission,end_permission from hr_permissions where emp_code = as_empcode and permission_date = ad_date and record_type in( 'M' ) and request_status = 'A';
  if attended_from < day_start then
    set overtime_morning = DATEDIFF(minute,attended_from,day_start)
  end if;
  if attended_to > day_end then
    if end_permission > attended_to then
      set overtime_end_of_day = DATEDIFF(minute,day_end,attended_to)+DATEDIFF(minute,start_permission,end_permission)
    else
      set overtime_end_of_day = DATEDIFF(minute,day_end,attended_to)
    end if end if;
  //Negative Time------------------------------------------------------------------------------------------------------------
  select top 1 from_time,to_time into permission_from,permission_to from hr_permissions where emp_code = as_empcode and permission_date = ad_date and record_type in( 'P','M' ) and request_status = 'A' order by from_time asc;
  if attended_from > day_start then
    set negative_morning = DATEDIFF(minute,day_start,attended_from)
  end if;
  if permission_from <= day_start then
    set negative_morning = negative_morning-DATEDIFF(minute,permission_from,permission_to);
    if negative_morning < 0 then
      set day_end = cast(dateadd(minute,negative_morning,day_end) as time);
      set negative_morning = 0
    end if end if;
  if attended_to < day_end then
    set negative_end_of_day = DATEDIFF(minute,attended_to,day_end)
  end if;
  if permission_to >= day_end then
    set negative_end_of_day = negative_end_of_day-DATEDIFF(minute,permission_from,permission_to);
    if negative_end_of_day < 0 then
      set negative_end_of_day = 0
    end if end if;
  //------------------------------------------------------------------------------------------------------------------------
  if req_type = 'NAC' then
    if(attended_from is null or attended_to is null) then
      set NotAssiginedCard = 1
    else
      set NotAssiginedCard = 0
    end if;
    set tmp = NotAssiginedCard
  end if;
  if req_type = 'EWP' then
    if datediff(minute,attended_to,day_end) > 0 and(attended_to is not null and day_end is not null) then
      set exitwithoutperm = datediff(minute,attended_to,day_end);
      --set exitwithoutperm = datediff(minute , permission_to , day_end ) ;
      if permission_from = day_start then
        set exitwithoutperm = exitwithoutperm-DATEDIFF(minute,permission_from,permission_to)
      elseif permission_to = day_end then
        set exitwithoutperm = exitwithoutperm-DATEDIFF(minute,permission_from,permission_to)
      elseif((permission_from <> day_start) or(permission_to <> day_end)) then
        set exitwithoutperm = exitwithoutperm-DATEDIFF(minute,permission_from,permission_to);
        set exitwithoutperm = exitwithoutperm-case when DATEDIFF(minute,day_start,attended_from) > 0 then DATEDIFF(minute,day_start,attended_from) else 0 end
      end if
    else set exitwithoutperm = 0
    end if;
    set tmp = abs(exitwithoutperm)
  end if;
  //----------------------------------------------------------------------------------------------------------------------
  --Case Of 1/2 1/4 day
  if attended_from > day_start or attended_to < day_end then
    select top 1 num_days,less_than_day_type into ldc_num,ls_VacLessType from emp_days_off where emp_code = as_empcode and from_date = ad_date and approved = 1 and delete_flag = 'N';
    if ldc_num < 1 then
      select my_val into half_day from DBA.about where DBA.about.code = 'half_day_hr';
      select my_val into quarter_day from DBA.about where DBA.about.code = 'quarter_day_hr';
      if ldc_num = .25 then
        select cast(quarter_day as time)
          into sub_day end if;
      if ldc_num = .5 then
        select cast(half_day as time)
          into sub_day end if;
      set minutes_var = (hour(sub_day)*60)+minute(sub_day);
      if ls_VacLessType = 'AM' then
        if DATEDIFF(minute,day_start,attended_from) > minutes_var then
          set negative_morning = DATEDIFF(minute,day_start,attended_from)-minutes_var
        end if;
        if DATEDIFF(minute,day_start,attended_from) < minutes_var then
          set negative_morning = 0;
          set overtime_morning = minutes_var-DATEDIFF(minute,day_start,attended_from)
        end if end if;
      if ls_VacLessType = 'PM' then
        if DATEDIFF(minute,attended_to,day_end) <= minutes_var then
          set negative_end_of_day = DATEDIFF(minute,attended_to,day_end)-minutes_var
        end if;
        if negative_end_of_day < 0 then
          set negative_end_of_day = 0
        end if;
        if DATEDIFF(minute,attended_to,day_end) > minutes_var then
          set negative_end_of_day = DATEDIFF(minute,attended_to,day_end)-minutes_var;
          set overtime_end_of_day = minutes_var-DATEDIFF(minute,attended_to,day_end)
        end if;
        if overtime_end_of_day < 0 then
          set overtime_end_of_day = 0
        end if end if end if end if;
  //-----------------------------------------------------------------------------------------------------------------------
  //Over Time
  if req_type = 'O' then
    set tmp = overtime_end_of_day+overtime_morning-(negative_end_of_day+negative_morning);
    if tmp < 0 then
      set tmp = tmp*-1
    end if end if;
  //Negative Time
  if req_type = 'N' then
    set tmp = negative_end_of_day+negative_morning-(overtime_end_of_day+overtime_morning);
    if tmp < 0 then
      set tmp = 0
    end if end if;
  //Positive Time
  if req_type = 'P' and permission_from is not null then
    set tmp = DATEDIFF(minute,permission_from,permission_to)
  end if;
  //Mission 
  if req_type = 'MS' then
    select Sum(DATEDIFF(minute,from_time,to_time)) into tmp from hr_permissions where emp_code = as_empcode and permission_date = ad_date and record_type in( 'M' ) and request_status = 'A'
  end if;
  //Permission
  if req_type = 'PR' then
    select Sum(DATEDIFF(minute,from_time,to_time)) into tmp from hr_permissions where emp_code = as_empcode and permission_date = ad_date and record_type in( 'P' ) and request_status = 'A'
  end if;
  //Mission&Permission 
  if req_type = 'MP' then
    select Sum(DATEDIFF(minute,from_time,to_time)) into tmp from hr_permissions where emp_code = as_empcode and permission_date = ad_date and record_type in( 'M','P' ) and request_status = 'A'
  end if;
  //Day Work Standard Hours
  if req_type = 'STD' then
    // set tmp = DATEDIFF(minute,day_start,day_end);
    set tmp = DATEDIFF(minute,day_start_std,day_end_std);
    if weekDayOf > 0 then
      set tmp = 0
    end if;
    if holidayDayOf > 0 then
      set tmp = 0
    end if end if;
  //Late In
  if req_type = 'LI' then
    set tmp = negative_morning
  end if;
  //Early Out
  if req_type = 'EO' then
    set tmp = negative_end_of_day
  end if;
  // Working Time
  if req_type = 'WT' then
    if(end_permission <= attended_from) or(end_permission > attended_to) then
      set tmp = DATEDIFF(minute,start_permission,end_permission)+DATEDIFF(minute,attended_from,attended_to)
    else set tmp = DATEDIFF(minute,attended_from,attended_to)
    end if;
    if tmp is null then
      set tmp = 0
    end if;
    if tmp_trip = 1 then
      set tmp = tmp+DATEDIFF(minute,day_start,day_end)
    end if end if;
  if tmp < 0 then
    set tmp = 0
  end if;
  //Over Time End Of Day
  if req_type = 'OverEnd' then
    set tmp = overtime_end_of_day
  end if;
  set hours_val = tmp/60;
  set minutes_val = Mod(tmp,60);
  select convert(varchar(2),hours_val) into h;
  select convert(varchar(2),minutes_val) into m;
  if h is null then
    set h = 0
  end if;
  if m is null then
    set m = 0
  end if;
  select cast(h+':'+m as time) into return_val;
  //2
  //
  select attendance.shift2_att_from,attendance.shift2_att_to into attended_from2,attended_to2
    from attendance where attendance.emp_code = as_empcode and attendance.att_date = ad_date and attendance.shift2_attended = 1;
  select isnull(dbs_s_employe.emp_sex,'M') into ret_emp_sex2 from dbs_s_employe where dbs_s_employe.emp_code = as_empcode;
  //---------------------------------------------------------------------------------------------------------------------    
  select 1 into weekDayOf2 from weekly_daysoff where day_off = DOW(ad_date);
  select 1 into holidayDayOf2 from holidays,holidays_dates where holidays.holiday_code = holidays_dates.holiday_description
    and holidays_dates.holiday_year = year(ad_date) and holidays_dates.holiday_date = ad_date;
  //Shift from
  select from_time2,flexible_minutes into day_start2,@flexible_minutes2 from hr_shifts,hr_emp_shift where hr_emp_shift.shift_id = hr_shifts.shift_id and hr_emp_shift.emp_code = as_empcode;
  if day_start2 is null then
    select convert(time,my_val) into day_start2 from about where code = 'job_start'
  end if;
  //Shift To  
  select to_time2 into day_end2 from hr_shifts,hr_emp_shift where hr_emp_shift.shift_id = hr_shifts.shift_id and hr_emp_shift.emp_code = as_empcode;
  if day_end2 is null then
    select convert(time,my_val) into day_end2 from about where code = 'job_end'
  end if;
  //----Ramadan Data-------------------------------------------------------------------------------------
  select convert(date,my_val) into ramadan_start_date2 from dba.about where code = 'hr_ramadan_start_date';
  select convert(date,my_val) into ramadan_end_date2 from dba.about where code = 'hr_ramadan_end_date';
  select convert(integer,my_val) into ramadan_flexible_minutes2 from dba.about where code = 'hr_ramadan_flexible_minutes';
  if ret_emp_sex2 = 'M' then
    select convert(time,my_val) into ramadan_start_time2 from dba.about where code = 'hr_ramadan_start_time_mens';
    select convert(time,my_val) into ramadan_end_time2 from dba.about where code = 'hr_ramadan_end_time_mens'
  else
    select convert(time,my_val) into ramadan_start_time2 from dba.about where code = 'hr_ramadan_start_time_womens';
    select convert(time,my_val) into ramadan_end_time2 from dba.about where code = 'hr_ramadan_end_time_womens'
  end if;
  ---------------------------------------------------------------------------------------------------------
  if ad_date between ramadan_start_date2 and ramadan_end_date2 then
    set day_start2 = ramadan_start_time;
    set day_end2 = ramadan_end_time;
    set @flexible_minutes2 = ramadan_flexible_minutes2
  end if;
  ---------------------------------------------
  set day_start_std2 = day_start2;
  set day_end_std2 = day_end2;
  //allowing time in morninig & Flexible Time---------------------------------------------------
  select convert(integer,isnull(my_val,'0')) into allow_minuts2 from dba.about where code = 'hr_start_calc_late_after';
  if allow_minuts2 > 0 then
    set day_start2 = cast(dateadd(minute,allow_minuts2,day_start2) as time)
  end if;
  select isnull(my_val,'N') into allow_flexible_time2 from dba.about where code = 'hr_allow_flexible_time';
  if allow_flexible_time2 = 'Y' and @flexible_minutes2 > 0 then
    set minutes_tmp2 = isnull(DATEDIFF(minute,day_start2,attended_from2),0);
    if minutes_tmp2 > @flexible_minutes2 then
      set day_end2 = cast(dateadd(minute,@flexible_minutes2,day_end2) as time)
    else
      set day_end2 = cast(dateadd(minute,minutes_tmp2,day_end2) as time)
    end if;
    set day_start2 = cast(dateadd(minute,@flexible_minutes2,day_start2) as time)
  end if;
  //special day with start and end time--------------------------------------------------------------------
  select my_val into exclude_day_n2 from about where code = 'exclude_day_n';
  if exclude_day_n2 is not null then
    if convert(integer,exclude_day_n2) = DOW(ad_date) then
      select my_val into temp_val2 from about where code = 'exclude_job_s';
      if temp_val2 is not null then
        set day_start2 = convert(time,temp_val2)
      /*select my_val into temp_val from about where code = 'exclude_job_e';
if temp_val is not null then
set day_end = convert(time,temp_val)
end if*/
      end if end if end if;
  //------------------------------------------------------------------------------------------------------------------------
  if req_type = 'NAC' then
    if(attended_from2 is null or attended_to2 is null) then
      set NotAssiginedCard2 = 1
    else
      set NotAssiginedCard2 = 0
    end if;
    set tmp2 = NotAssiginedCard2
  end if;
  if req_type = 'EWP' then
    if datediff(minute,attended_to2,day_end2) > 0 and(attended_to2 is not null and day_end2 is not null) then
      set exitwithoutperm2 = datediff(minute,attended_to2,day_end2);
      --set exitwithoutperm = datediff(minute , permission_to , day_end ) ;
      if permission_from2 = day_start2 then
        set exitwithoutperm2 = exitwithoutperm2-DATEDIFF(minute,permission_from2,permission_to2)
      elseif permission_to2 = day_end2 then
        set exitwithoutperm2 = exitwithoutperm2-DATEDIFF(minute,permission_from2,permission_to2)
      elseif((permission_from2 <> day_start2) or(permission_to2 <> day_end2)) then
        set exitwithoutperm2 = exitwithoutperm2-DATEDIFF(minute,permission_from2,permission_to2);
        set exitwithoutperm2 = exitwithoutperm2-case when DATEDIFF(minute,day_start2,attended_from2) > 0 then DATEDIFF(minute,day_start2,attended_from2) else 0 end
      end if
    else set exitwithoutperm2 = 0
    end if;
    set tmp2 = abs(exitwithoutperm2)
  end if;
  //----------------------------------------------------------------------------------------------------------------------
  --Case Of 1/2 1/4 day
  if attended_from2 > day_start2 or attended_to2 < day_end2 then
    select top 1 num_days,less_than_day_type into ldc_num2,ls_VacLessType2 from emp_days_off where emp_code = as_empcode and from_date = ad_date and approved = 1 and delete_flag = 'N';
    if ldc_num2 < 1 then
      select my_val into half_day2 from DBA.about where DBA.about.code = 'half_day_hr';
      select my_val into quarter_day2 from DBA.about where DBA.about.code = 'quarter_day_hr';
      if ldc_num2 = .25 then
        select cast(quarter_day2 as time)
          into sub_day2 end if;
      if ldc_num2 = .5 then
        select cast(half_day2 as time)
          into sub_day2 end if;
      set minutes_var2 = (hour(sub_day2)*60)+minute(sub_day2);
      if ls_VacLessType2 = 'AM' then
        if DATEDIFF(minute,day_start2,attended_from2) > minutes_var2 then
          set negative_morning2 = DATEDIFF(minute,day_start2,attended_from2)-minutes_var2
        end if;
        if DATEDIFF(minute,day_start2,attended_from2) < minutes_var2 then
          set negative_morning2 = 0;
          set overtime_morning2 = minutes_var2-DATEDIFF(minute,day_start2,attended_from2)
        end if end if;
      if ls_VacLessType2 = 'PM' then
        if DATEDIFF(minute,attended_to2,day_end2) < minutes_var2 then
          set negative_end_of_day2 = DATEDIFF(minute,attended_to2,day_end2)-minutes_var2
        end if;
        if negative_end_of_day2 < 0 then
          set negative_end_of_day2 = 0
        end if;
        if DATEDIFF(minute,attended_to2,day_end2) > minutes_var2 then
          set negative_end_of_day2 = DATEDIFF(minute,attended_to2,day_end2)-minutes_var2;
          set overtime_end_of_day2 = minutes_var2-DATEDIFF(minute,attended_to2,day_end2)
        end if;
        if overtime_end_of_day2 < 0 then
          set overtime_end_of_day2 = 0
        end if end if end if end if;
  //-----------------------------------------------------------------------------------------------------------------------
  //Over Time
  if req_type = 'O' then
    set tmp2 = overtime_end_of_day2+overtime_morning2-(negative_end_of_day2+negative_morning2);
    if tmp2 < 0 then
      set tmp2 = tmp2*-1
    end if end if;
  //Negative Time
  if req_type = 'N' then
    set tmp2 = negative_end_of_day2+negative_morning2-(overtime_end_of_day2+overtime_morning2);
    if tmp2 < 0 then
      set tmp2 = 0
    end if end if;
  //Day Work Standard Hours
  if req_type = 'STD' then
    // set tmp = DATEDIFF(minute,day_start,day_end);
    set tmp2 = DATEDIFF(minute,day_start_std2,day_end_std2);
    if weekDayOf2 > 0 then
      set tmp2 = 0
    end if;
    if holidayDayOf2 > 0 then
      set tmp2 = 0
    end if end if;
  //Late In
  if req_type = 'LI' then
    set tmp2 = negative_morning2
  end if;
  //Early Out
  if req_type = 'EO' then
    set tmp2 = negative_end_of_day2
  end if;
  //Over Time End Of Day
  if req_type = 'OverEnd' then
    set tmp2 = overtime_end_of_day2
  end if;
  set hours_val2 = (tmp+tmp2)/60;
  set minutes_val2 = Mod(tmp+tmp2,60);
  select convert(varchar(2),hours_val2) into h2;
  select convert(varchar(2),minutes_val2) into m2;
  if h2 is null then
    set h2 = 0
  end if;
  if m2 is null then
    set m2 = 0
  end if;
  select cast(h2+':'+m2 as time) into return_val2;
  return return_val2
end
