-- PF: UNKNOWN_SCHEMA.f_get_about
-- proc_id: 386
-- generated_at: 2025-12-29T13:53:28.803Z

create function DBA.f_get_about( in as_code varchar(50) ) 
returns varchar(50)
begin
  declare my_value varchar(50);
  select my_val
    into my_value from dba.about
    where code = as_code;
  return my_value
end
