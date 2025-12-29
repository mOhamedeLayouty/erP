-- PF: UNKNOWN_SCHEMA.f_days_month
-- proc_id: 392
-- generated_at: 2025-12-29T13:53:28.805Z

create function DBA.f_days_month( in an_year integer,in an_month integer ) 
returns integer
deterministic
begin
  declare n_days integer;
  /* Type the function statements here */
  if an_month = 1 or an_month = 3 or an_month = 5 or an_month = 7 or an_month = 8 or an_month = 10 or an_month = 12 then
    set n_days = 31
  elseif an_month = 4 or an_month = 6 or an_month = 9 or an_month = 11 then
    set n_days = 30
  elseif an_month = 2 then
    select REMAINDER(an_year,4) into n_days;
    if n_days = 0 then
      set n_days = 29
    else
      set n_days = 28
    end if end if;
  return n_days
end
