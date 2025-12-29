-- PF: UNKNOWN_SCHEMA.f_replace_string
-- proc_id: 406
-- generated_at: 2025-12-29T13:53:28.809Z

create function ledger.f_replace_string( in ls_string varchar(5000),in s_old_value varchar(10),in s_new_value varchar(10) ) 
returns varchar(5000)
begin
  declare ll_pos integer;
  declare ls_string_return varchar(5000);
  -------------------------------------------------------------
  set ll_pos = locate(ls_string,s_old_value);
  set ls_string_return = replace(ls_string,s_old_value,s_new_value);
  ------------------------------------------------------------------------
  return ls_string_return
end
