-- PF: UNKNOWN_SCHEMA.sa_http_variable_info
-- proc_id: 217
-- generated_at: 2025-12-29T13:53:28.755Z

create procedure dbo.sa_http_variable_info( in variable_parm varchar(255) default null ) 
result( 
  Name varchar(255),
  Value long varchar ) dynamic result sets 1
begin
  declare variable_name varchar(255);
  declare variable_value long varchar;
  declare local temporary table t_http_variable_info(
    Name varchar(255) not null,
    Value long varchar not null,
    ) in SYSTEM not transactional;
  if(variable_parm is not null) then
    set variable_name = variable_parm
  else
    set variable_name = next_http_variable(null)
  end if;
  lbl:
  while variable_name is not null loop
    insert into t_http_variable_info
      select variable_name,
        http_variable(variable_name,row_num) as varval
        from dbo.RowGenerator
        where varval is not null;
    if(variable_parm is not null) then
      leave lbl
    else
      set variable_name = next_http_variable(variable_name)
    end if
  end loop lbl;
  select * from t_http_variable_info
end
