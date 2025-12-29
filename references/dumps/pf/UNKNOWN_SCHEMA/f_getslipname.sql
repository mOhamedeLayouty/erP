-- PF: UNKNOWN_SCHEMA.f_getslipname
-- proc_id: 378
-- generated_at: 2025-12-29T13:53:28.801Z

create function DBA.f_getslipname( in line integer ) 
returns varchar(100)
//V1.1 description_a
begin
  declare slip_name varchar(60);
  select description_a
    into slip_name from hr.Income_natural
    where line_no = line;
  return slip_name
end
