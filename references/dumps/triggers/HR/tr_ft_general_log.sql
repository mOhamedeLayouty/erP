-- TRIGGER: HR.tr_ft_general_log
-- ON TABLE: HR.ft_general_log
-- generated_at: 2025-12-29T13:52:33.696Z

create trigger tr_ft_general_log after insert order 1 on
hr.ft_general_log
referencing old as Old_row new as New_row
for each row
//V1.0 Created
//V1.1 handling end time
//V1.2 fixing
begin
  declare @emp_code varchar(50);
  declare @shift_id integer;
  declare @shift_id2 integer;
  declare @shift_id3 integer;
  declare @log_datetime datetime;
  declare @att_from time;
  declare @att_to time;
  declare @att_from2 time;
  declare @att_to2 time;
  declare @att_from3 time;
  declare @att_to3 time;
  declare @sh_from_time time;
  declare @sh_from_time2 time;
  declare @sh_from_time3 time;
  declare @sh_to_time time;
  declare @sh_to_time2 time;
  declare @sh_to_time3 time;
  declare @diff integer;
  //
  set @emp_code = New_row.enrollNo;
  set @log_datetime = DateTime(string(New_row.yr)+'-'+String(New_row.mth)+'-'+String(New_row.day_Renamed)+' '+string(New_row.hr)+':'+string(New_row.min)+':'+string(New_row.sec)+'.000');
  select shift_id,shift_id2,shift_id3 into @shift_id,@shift_id2,@shift_id3 from HR.hr_emp_shift where emp_code = @emp_code;
  //
  if not exists(select 1 from hr.attendance
      where hr.attendance.emp_code = @emp_code
      and hr.attendance.att_date = "date"(@log_datetime)) then
    insert into hr.attendance( att_date,
      emp_code,
      attended,
      att_from,
      shift_id ) values
      ( "date"(@log_datetime),
      @emp_code,
      1,
      convert(time,@log_datetime),
      @shift_id ) 
  else
    select from_time,from_time2,from_time3,to_time,to_time2,to_time3
      into @sh_from_time,@sh_from_time2,@sh_from_time3,@sh_to_time,@sh_to_time2,@sh_to_time3
      from HR.hr_shifts where shift_id = @shift_id;
    //
    select att_from,att_to,shift2_att_from,shift2_att_to,shift3_att_from,shift3_att_to
      into @att_from,@att_to,@att_from2,@att_to2,@att_from3,@att_to3
      from hr.attendance
      where hr.attendance.emp_code = @emp_code
      and hr.attendance.att_date = "date"(@log_datetime);
    //	
    if(@att_from is null or convert(time,@log_datetime) <= convert(time,@att_from)) then
      update hr.attendance set att_from = convert(time,@log_datetime),attended = 1
        where hr.attendance.emp_code = @emp_code
        and hr.attendance.att_date = "date"(@log_datetime);
      set @att_from = convert(time,@log_datetime)
    end if;
    if((@att_to is null and convert(time,@log_datetime) > convert(time,@att_from))
      or(convert(time,@log_datetime) > @att_to and isnull(@sh_from_time2,'00:00') = convert(time,'00:00')
      and isnull(@sh_from_time3,'00:00') = convert(time,'00:00'))) then
      update hr.attendance set att_to = convert(time,@log_datetime),attended = 1
        where hr.attendance.emp_code = @emp_code
        and hr.attendance.att_date = "date"(@log_datetime);
      set @att_to = convert(time,@log_datetime)
    end if;
    ----------------------------------------Shifts---------------------------------------------
    //shift1
    if(isnull(@sh_from_time,'00:00') > convert(time,'00:00')) then
      select abs(DATEDIFF(minute,@sh_from_time,convert(time,@log_datetime))) into @diff;
      if(@att_from is null and(@diff >= 0 and @diff <= 90)) then
        update hr.attendance set att_from = convert(time,@log_datetime),attended = 1
          where hr.attendance.emp_code = @emp_code
          and hr.attendance.att_date = "date"(@log_datetime)
      end if end if;
    if(isnull(@sh_to_time,'00:00') > convert(time,'00:00')) then
      select abs(DATEDIFF(minute,@sh_to_time,convert(time,@log_datetime))) into @diff;
      if(@att_to is null and(@diff >= 0 and @diff <= 90)) then
        update hr.attendance set att_to = convert(time,@log_datetime),attended = 1
          where hr.attendance.emp_code = @emp_code
          and hr.attendance.att_date = "date"(@log_datetime)
      end if end if;
    //shift2
    if(isnull(@sh_from_time2,'00:00') > convert(time,'00:00')) then
      select abs(DATEDIFF(minute,@sh_from_time2,convert(time,@log_datetime))) into @diff;
      if(@att_from2 is null or(@diff >= 0 and @diff <= 90)) then
        update hr.attendance set shift2_att_from = convert(time,@log_datetime),shift2_attended = 1
          where hr.attendance.emp_code = @emp_code
          and hr.attendance.att_date = "date"(@log_datetime)
      end if end if;
    if(isnull(@sh_to_time2,'00:00') > convert(time,'00:00')) then
      select abs(DATEDIFF(minute,@sh_to_time2,convert(time,@log_datetime))) into @diff;
      if(@att_to2 is null or(@diff >= 0 and @diff <= 90)) then
        update hr.attendance set shift2_att_to = convert(time,@log_datetime),shift2_attended = 1
          where hr.attendance.emp_code = @emp_code
          and hr.attendance.att_date = "date"(@log_datetime)
      end if end if;
    //shift3
    if(isnull(@sh_from_time3,'00:00') > convert(time,'00:00')) then
      select abs(DATEDIFF(minute,@sh_from_time3,convert(time,@log_datetime))) into @diff;
      if(@att_from3 is null or(@diff >= 0 and @diff <= 90)) then
        update hr.attendance set shift3_att_from = convert(time,@log_datetime),shift3_attended = 1
          where hr.attendance.emp_code = @emp_code
          and hr.attendance.att_date = "date"(@log_datetime)
      end if end if;
    if(isnull(@sh_to_time3,'00:00') > convert(time,'00:00')) then
      select abs(DATEDIFF(minute,@sh_to_time3,convert(time,@log_datetime))) into @diff;
      if(@att_to3 is null or(@diff >= 0 and @diff <= 90)) then
        update hr.attendance set shift3_att_to = convert(time,@log_datetime),shift3_attended = 1
          where hr.attendance.emp_code = @emp_code
          and hr.attendance.att_date = "date"(@log_datetime)
      end if
    end if
  end if
end
