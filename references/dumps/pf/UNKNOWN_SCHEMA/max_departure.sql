-- PF: UNKNOWN_SCHEMA.max_departure
-- proc_id: 369
-- generated_at: 2025-12-29T13:53:28.799Z

create function DBA.max_departure( in emp_code char(30),in my_date date ) 
returns decimal
begin
  declare max_time time;
  declare time_1 time;
  declare time_2 time;
  declare time_3 time;
  declare time_4 time;
  declare interval decimal;
  declare end_time char(20);
  select max(to_1) into time_1 from employee_time_sheet where employee_code = emp_code and working_date = my_date;
  select max(to_2) into time_2 from employee_time_sheet where employee_code = emp_code and working_date = my_date;
  select max(to_3) into time_3 from employee_time_sheet where employee_code = emp_code and working_date = my_date;
  select max(to_4) into time_4 from employee_time_sheet where employee_code = emp_code and working_date = my_date;
  if time_1 > time_2 then
    set max_time = time_1
  else
    set max_time = time_2
  end if;
  if max_time < time_3 then
    set max_time = time_3
  end if;
  if max_time < time_4 then
    set max_time = time_4
  end if;
  select my_val into end_time from about where code = 'job_end';
  set interval = datediff(minute,convert(DATETIME,end_time,108),max_time);
  if interval < 0 then
    set interval = 0
  end if;
  return(interval)
end
