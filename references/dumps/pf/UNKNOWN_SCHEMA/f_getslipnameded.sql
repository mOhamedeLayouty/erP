-- PF: UNKNOWN_SCHEMA.f_getslipnameded
-- proc_id: 377
-- generated_at: 2025-12-29T13:53:28.801Z

create function DBA.f_getslipnameded( in line integer )  /* [IN] parameter_name parameter_type [DEFAULT default_value], ... */
returns varchar(60)
begin
  declare slip_name varchar(60);
  select deduction_natural.description
    into slip_name from hr.deduction_natural
    where line_no = line;
  return slip_name
end
