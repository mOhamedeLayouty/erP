-- PF: UNKNOWN_SCHEMA.sa_event_schedules
-- proc_id: 184
-- generated_at: 2025-12-29T13:53:28.745Z

create procedure dbo.sa_event_schedules( in evt_id integer ) 
result( sched_name varchar(128),sched_def long varchar ) dynamic result sets 1
begin
  declare day_list char(256);
  declare time_range char(256);
  declare frequency char(256);
  declare starting char(50);
  declare sep char(1);
  declare bittest unsigned integer;
  declare daynum integer;
  declare local temporary table event_sched_results(
    sched_name varchar(128) null,
    sched_def long varchar null,
    ) in SYSTEM not transactional;
  for scheds as sched_cursor dynamic scroll cursor for
    select sched_name as sname,
      start_time,
      stop_time,
      start_date,
      days_of_week,
      days_of_month,
      interval_units,
      interval_amt
      from SYS.SYSSCHEDULE
      where event_id = evt_id for read only
  do
    if stop_time is null then
      set time_range = 'START TIME '''
         || dateformat(start_time,'hh:nn:ss') || ''' '
    else
      set time_range = 'BETWEEN '''
         || dateformat(start_time,'hh:nn:ss') || ''' AND '''
         || dateformat(stop_time,'hh:nn:ss') || ''' '
    end if;
    if interval_amt is null then
      set frequency = ''
    else
      set frequency = 'EVERY ' || interval_amt || ' '
         || case interval_units
        when 'HH' then 'HOURS '
        when 'NN' then 'MINUTES '
        when 'SS' then 'SECONDS ' end
    end if;
    if days_of_week <> 0 then
      select 'ON (' || list('''' || weekdays || '''') || ') '
        into day_list
        from(select 'Sunday' where(days_of_week&1) <> 0 union all
          select 'Monday' where(days_of_week&2) <> 0 union all
          select 'Tuesday' where(days_of_week&4) <> 0 union all
          select 'Wednesday' where(days_of_week&8) <> 0 union all
          select 'Thursday' where(days_of_week&16) <> 0 union all
          select 'Friday' where(days_of_week&32) <> 0 union all
          select 'Saturday' where(days_of_week&64) <> 0) as t( weekdays ) 
    elseif days_of_month <> 0 then
      set day_list = '';
      set sep = '';
      if days_of_month > 2147483647 then
        set day_list = '0';
        set sep = ','
      end if;
      set bittest = 1;
      set daynum = 1;
      lp: loop
        if(days_of_month&bittest) <> 0 then
          set day_list = day_list || sep || daynum;
          set sep = ','
        end if;
        set daynum = daynum+1;
        if daynum > 31 then leave lp end if;
        set bittest = bittest*2
      end loop lp;
      set day_list = 'ON (' || day_list || ') '
    else
      set day_list = ''
    end if;
    if start_date is null then
      set starting = ''
    else
      set starting = 'START DATE '''
         || dateformat(start_date,'yyyy/mm/dd') || ''' '
    end if;
    insert into event_sched_results values( sname,
      time_range || frequency || day_list || starting ) 
  end for;
  select sched_name,sched_def from event_sched_results
end
