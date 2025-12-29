-- PF: UNKNOWN_SCHEMA.hr_emp_day_status
-- proc_id: 408
-- generated_at: 2025-12-29T13:53:28.809Z

create function HR.hr_emp_day_status( in @as_emp_code varchar(30),
  in @ad_date_from date,in @ad_date_to date,in @lang integer default 2 ) 
returns varchar(50)
deterministic
//V1.1 Return after each status
//V1.2 Vactions and Trip must approved
//V1.3 get holday name 
//V1.4 add collective vacation
//V1.5 add confirm approve mission and permission and collective vacation and add permission
//V1.6 add status arabic and add  (quar. or half) vacation
//V1.7 modify business trip not in weekend
//V1.8 add Mission && Permission
//V1.9 replace present to check it before holidays
//V2.0 add status when adding a weekend holiday from shift exception screen (is_weekend flag)(priority)
begin
  declare @day_Status varchar(50);
  declare @num_day varchar(50);
  declare @day_type varchar(50);
  declare @ll_shift integer;
  //Mission && Permission
  if(select count() from hr_permissions where hr_permissions.emp_code = @as_emp_code and request_status = 'A'
      and hr_permissions.permission_date = @ad_date_from and hr_permissions.record_type in( 'M','P' ) ) >= 2 then
    set @day_Status = 'Mission + Permission';
    if @lang = 1 then
      set @day_Status = 'Mission + Permission'
    else
      set @day_Status = '��� + �������'
    end if;
    return @day_Status
  end if;
  //Mission
  if(select count(1) from hr_permissions where hr_permissions.emp_code = @as_emp_code and request_status = 'A'
      and hr_permissions.permission_date = @ad_date_from and hr_permissions.record_type = 'M') >= 1 then
    set @day_Status = 'Mission';
    if @lang = 1 then
      set @day_Status = 'Mission'
    else
      set @day_Status = '�������'
    end if;
    return @day_Status
  end if;
  //Permission
  if(select count(1) from hr_permissions where hr_permissions.emp_code = @as_emp_code and request_status = 'A'
      and hr_permissions.permission_date = @ad_date_from and hr_permissions.record_type = 'P') >= 1 then
    set @day_Status = 'Permission';
    if @lang = 1 then
      set @day_Status = 'Permission'
    else
      set @day_Status = '���'
    end if;
    return @day_Status
  end if;
  //Trip
  if(select count(1) from business_trip where business_trip.emp_code = @as_emp_code
      and(@ad_date_from between business_trip.from_date and business_trip.to_date)
      and business_trip.delete_flag <> 'Y' and business_trip.approved = '1'
      and not DOW(@ad_date_from) = any(select day_off from weekly_daysoff)) >= 1 then
    set @day_Status = 'Trip';
    if @lang = 1 then
      set @day_Status = 'Trip'
    else
      set @day_Status = '���� ���'
    end if;
    return @day_Status
  end if;
  //Training
  if(select count(1) from training_detail,training_header
      where(training_detail.training_header = training_header.training_header)
      and(training_detail.emp_code = @as_emp_code)
      and(@ad_date_from between training_header.start_date and training_detail.end_date)) >= 1 then
    set @day_Status = 'Training';
    if @lang = 1 then
      set @day_Status = 'Training'
    else
      set @day_Status = '�����'
    end if;
    return @day_Status
  end if;
  // Present
  if(select count(1) from attendance where attendance.attended = 1 and attendance.emp_code = @as_emp_code
      and attendance.att_date = @ad_date_from) >= 1 then
    set @day_Status = 'Present';
    if @lang = 1 then
      set @day_Status = 'Present'
    else
      set @day_Status = '����'
    end if;
    return @day_Status
  end if;
  //Weekly holiday
  select shift_id into @ll_shift from HR.hr_emp_shift where emp_code = @as_emp_code;
  if(select count(1) from daysoff where daysoff.emp_code = @as_emp_code) > 0 then
    if(select count(1) from daysoff where daysoff.emp_code = @as_emp_code and day_off = DOW(@ad_date_from)) >= 1 then
      set @day_Status = 'Weeklyholiday';
      if @lang = 1 then
        set @day_Status = 'Weeklyholiday'
      else
        set @day_Status = '����� �������'
      end if;
      return @day_Status
    //shift exception holiday
    end if
  elseif(select count(1) from shift_exception where((shift_exception.day_id = DOW(@ad_date_from)) or(shift_exception.day_id = DOW(@ad_date_to))) and shift_exception.shift_id = @ll_shift and shift_exception.is_weekend = 1) > 0 then
    set @day_Status = 'Weeklyholiday';
    if @lang = 1 then
      set @day_Status = 'Weeklyholiday'
    else
      set @day_Status = '����� �������'
    end if;
    return @day_Status
  else
    if(select count(1) from weekly_daysoff where day_off = DOW(@ad_date_from)) >= 1 and(select count(1) from shift_exception where shift_exception.shift_id = @ll_shift and shift_exception.is_weekend = 1) <= 0 then
      set @day_Status = 'Weeklyholiday';
      if @lang = 1 then
        set @day_Status = 'Weeklyholiday'
      else
        set @day_Status = '����� �������'
      end if;
      return @day_Status
    end if end if;
  //holiday
  if(select count(1) from holidays_dates where holidays_dates.holiday_date = @ad_date_from) > 0 then
    if @lang = 1 then
      set @day_Status = (select top 1 holiday_desc from holidays,holidays_dates
          where holidays_dates.holiday_description = holidays.holiday_code
          and holiday_date = @ad_date_from)
    else
      set @day_Status = (select top 1 holiday_desc_a from holidays,holidays_dates
          where holidays_dates.holiday_description = holidays.holiday_code
          and holiday_date = @ad_date_from)
    end if;
    return @day_Status
  end if;
  //vacation 
  if(select count(1) from emp_days_off where emp_days_off.emp_code = @as_emp_code
      and(@ad_date_from between emp_days_off.from_date and emp_days_off.to_date)
      and emp_days_off.delete_flag <> 'Y' and emp_days_off.approved = '1') >= 1 then
    set @day_type = (select top 1 emp_days_off.p_type from emp_days_off where emp_days_off.emp_code = @as_emp_code
        and(@ad_date_from between emp_days_off.from_date and emp_days_off.to_date)
        and emp_days_off.delete_flag <> 'Y' and emp_days_off.approved = '1');
    set @num_day = (select top 1 emp_days_off.num_days from emp_days_off where emp_days_off.emp_code = @as_emp_code
        and(@ad_date_from between emp_days_off.from_date and emp_days_off.to_date)
        and emp_days_off.delete_flag <> 'Y' and emp_days_off.approved = '1');
    if @num_day = .25 then
      if @lang = 1 then
        set @day_Status = ' quar. '
      else
        set @day_Status = ' ��� '
      end if
    elseif @num_day = .5 then
      if @lang = 1 then
        set @day_Status = ' half '
      else
        set @day_Status = ' ��� '
      end if end if;
    if @lang = 1 then
      set @day_Status = @day_Status+(select description from hr.Emp_vacations where line_no = @day_type)
    else
      set @day_Status = @day_Status+(select description_a from hr.Emp_vacations where line_no = @day_type)
    end if;
    return @day_Status
  end if;
  //collective_vacation
  if(select count(1) from emp_collective_vacation
      where(@ad_date_from between emp_collective_vacation.from_date and emp_collective_vacation.to_date)
      and emp_collective_vacation.delete_flag = 'N' and emp_collective_vacation.approved = 1) >= 1 then
    set @day_Status = 'Collective Vacation';
    if @lang = 1 then
      set @day_Status = 'Collective Vacation'
    else
      set @day_Status = '����� ������'
    end if;
    return @day_Status
  end if;
  //
  if @day_Status is null then
    set @day_Status = 'Absence';
    if @lang = 1 then
      set @day_Status = 'Absence'
    else
      set @day_Status = '����'
    end if;
    return @day_Status
  end if
end
