-- PF: UNKNOWN_SCHEMA.max_attendance
-- proc_id: 395
-- generated_at: 2025-12-29T13:53:28.806Z

create function DBA.max_attendance( in my_date date,in as_employee_cod varchar(30) default '@' ) 
returns decimal
begin
  declare max_time time;
  declare max_interval decimal;
  declare interval decimal;
  select
    Max(
    isnull(datediff(minute,attn.from_1,attn.to_1),0,datediff(minute,attn.from_1,attn.to_1))
    +isnull(datediff(minute,attn.from_2,attn.to_2),0,datediff(minute,attn.from_2,attn.to_2))
    +isnull(datediff(minute,attn.from_3,attn.to_3),0,datediff(minute,attn.from_3,attn.to_3))
    +isnull(datediff(minute,attn.from_4,attn.to_4),0,datediff(minute,attn.from_4,attn.to_4))
    +isnull(datediff(minute,attn.from_5,attn.to_5),0,datediff(minute,attn.from_5,attn.to_5))
    +isnull(datediff(minute,attn.from_6,attn.to_6),0,datediff(minute,attn.from_6,attn.to_6)))
    into interval from employee_time_sheet as attn where attn.working_date = my_date
    and(attn.employee_code = as_employee_cod or as_employee_cod = '@');
  select
    datediff(
    minute,convert(DATETIME,(select my_val into end_time from about where code = 'job_start'),108),
    convert(DATETIME,(select my_val into end_time from about where code = 'job_end'),108))
    into max_interval;
  if interval > max_interval then
    set interval = max_interval
  end if;
  if interval < 0 then
    set interval = 0
  end if;
  return(interval)
end
